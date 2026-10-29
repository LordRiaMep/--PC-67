package Controller.Admin;

import dao.NewsDao;
import model.News;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/admin/news")
public class AdminNewsServlet extends HttpServlet {
    private final NewsDao newsDao = new NewsDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String pageParam = req.getParameter("page");
        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        String featured = req.getParameter("featured");
        String homeFilter = req.getParameter("homeFilter");
        String sort = req.getParameter("sort");

        int page = 1;
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        StringBuilder queryKeep = new StringBuilder();
        if (page > 1) queryKeep.append("&page=").append(page);
        if (keyword != null && !keyword.trim().isEmpty()) {
            queryKeep.append("&keyword=").append(urlEncode(keyword.trim()));
        }
        if (status != null && !status.trim().isEmpty()) {
            queryKeep.append("&status=").append(urlEncode(status.trim()));
        }
        if (featured != null && !featured.trim().isEmpty()) {
            queryKeep.append("&featured=").append(urlEncode(featured.trim()));
        }
        if (homeFilter != null && !homeFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(homeFilter)) {
            queryKeep.append("&homeFilter=").append(urlEncode(homeFilter.trim()));
        }
        if (sort != null && !sort.trim().isEmpty() && !"DEFAULT".equalsIgnoreCase(sort)) {
            queryKeep.append("&sort=").append(urlEncode(sort.trim()));
        }
        String keepParams = queryKeep.toString();

        if ("delete".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean ok = newsDao.delete(id);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?msg=delete_success" + keepParams);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?error=delete_fail" + keepParams);
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/news?error=invalid_id" + keepParams);
            }
            return;
        }

        if ("toggle_status".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                newsDao.toggleStatus(id);
                resp.sendRedirect(req.getContextPath() + "/admin/news?msg=status_success" + keepParams);
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/news?error=invalid_id" + keepParams);
            }
            return;
        }

        if ("toggle_featured".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                newsDao.toggleFeatured(id);
                resp.sendRedirect(req.getContextPath() + "/admin/news?msg=featured_success" + keepParams);
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/news?error=invalid_id" + keepParams);
            }
            return;
        }

        if ("set_home_role".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                String role = req.getParameter("role");
                boolean ok = newsDao.setHomeRole(id, role);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?msg=home_role_success" + keepParams);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?error=system_error" + keepParams);
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/news?error=invalid_id" + keepParams);
            }
            return;
        }

        if ("edit".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                News n = newsDao.getNewsById(id);
                if (n != null) {
                    req.setAttribute("news", n);
                }
            } catch (Exception ignored) {}
        }

        int pageSize = 8;
        int totalNews = newsDao.countAdminNews(keyword, status, featured, homeFilter);
        int totalPages = (int) Math.ceil((double) totalNews / pageSize);
        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }
        if (page < 1) page = 1;

        List<News> listNews = newsDao.getAdminNewsByPage(page, pageSize, keyword, status, featured, homeFilter, sort);
        List<Integer> top5HomeIds = newsDao.getTop5HomeNewsIds();
        List<News> currentHomeNews = newsDao.getLatestNews(5);
        List<News> allActiveNews = newsDao.getAllActiveNews();

        req.setAttribute("listNews", listNews);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalNews", totalNews);
        req.setAttribute("top5HomeIds", top5HomeIds);
        req.setAttribute("currentHomeNews", currentHomeNews);
        req.setAttribute("allActiveNews", allActiveNews);

        req.setAttribute("keyword", keyword);
        req.setAttribute("status", (status != null && !status.isEmpty()) ? status : "ALL");
        req.setAttribute("featured", (featured != null && !featured.isEmpty()) ? featured : "ALL");
        req.setAttribute("homeFilter", (homeFilter != null && !homeFilter.isEmpty()) ? homeFilter : "ALL");
        req.setAttribute("sort", (sort != null && !sort.isEmpty()) ? sort : "DEFAULT");

        req.setAttribute("statTotal", newsDao.getStatTotalCount());
        req.setAttribute("statActive", newsDao.getStatActiveCount());
        req.setAttribute("statHidden", newsDao.getStatHiddenCount());
        req.setAttribute("statFeatured", newsDao.getStatFeaturedCount());

        String msg = req.getParameter("msg");
        String err = req.getParameter("error");
        if ("insert_success".equals(msg)) req.setAttribute("successMessage", "Thêm bài viết mới thành công!");
        else if ("update_success".equals(msg)) req.setAttribute("successMessage", "Cập nhật bài viết thành công!");
        else if ("delete_success".equals(msg)) req.setAttribute("successMessage", "Xóa bài viết thành công!");
        else if ("status_success".equals(msg)) req.setAttribute("successMessage", "Đổi trạng thái hiển thị bài viết thành công!");
        else if ("featured_success".equals(msg)) req.setAttribute("successMessage", "Cập nhật trạng thái nổi bật thành công!");
        else if ("home_role_success".equals(msg)) req.setAttribute("successMessage", "Cập nhật vị trí hiển thị trên Trang chủ thành công!");
        else if ("home_layout_success".equals(msg)) req.setAttribute("successMessage", "Đã lưu bố cục bài chính và bài phụ trên Trang chủ thành công!");

        if ("invalid_title".equals(err)) req.setAttribute("errorMessage", "Tiêu đề bài viết không được để trống!");
        else if ("title_too_long".equals(err)) req.setAttribute("errorMessage", "Tiêu đề bài viết quá dài (tối đa 255 ký tự)!");
        else if ("delete_fail".equals(err)) req.setAttribute("errorMessage", "Không thể xóa bài viết. Vui lòng thử lại!");
        else if ("invalid_id".equals(err)) req.setAttribute("errorMessage", "Mã bài viết không hợp lệ!");
        else if ("system_error".equals(err)) req.setAttribute("errorMessage", "Có lỗi xảy ra trong quá trình xử lý.");

        req.getRequestDispatcher("/view/admin_news.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String pageParam = req.getParameter("page");
        String keyword = req.getParameter("keyword");
        String statusFilter = req.getParameter("statusFilter");
        String featuredFilter = req.getParameter("featuredFilter");
        String homeFilter = req.getParameter("homeFilter");
        String sort = req.getParameter("sort");

        StringBuilder queryKeep = new StringBuilder();
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            queryKeep.append("&page=").append(pageParam.trim());
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            queryKeep.append("&keyword=").append(urlEncode(keyword.trim()));
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            queryKeep.append("&status=").append(urlEncode(statusFilter.trim()));
        }
        if (featuredFilter != null && !featuredFilter.trim().isEmpty()) {
            queryKeep.append("&featured=").append(urlEncode(featuredFilter.trim()));
        }
        if (homeFilter != null && !homeFilter.trim().isEmpty()) {
            queryKeep.append("&homeFilter=").append(urlEncode(homeFilter.trim()));
        }
        if (sort != null && !sort.trim().isEmpty()) {
            queryKeep.append("&sort=").append(urlEncode(sort.trim()));
        }
        String keepParams = queryKeep.toString();

        try {
            String action = req.getParameter("action");

            if ("save_home_layout".equalsIgnoreCase(action)) {
                int mainId = parseIntSafe(req.getParameter("mainId"));
                int subId1 = parseIntSafe(req.getParameter("subId1"));
                int subId2 = parseIntSafe(req.getParameter("subId2"));
                int subId3 = parseIntSafe(req.getParameter("subId3"));
                int subId4 = parseIntSafe(req.getParameter("subId4"));

                boolean ok = newsDao.setHomeLayout(mainId, subId1, subId2, subId3, subId4);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?msg=home_layout_success" + keepParams);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?error=system_error" + keepParams);
                }
                return;
            }

            int id = parseIntSafe(req.getParameter("id"));
            String title = req.getParameter("title");
            String summary = req.getParameter("summary");
            String content = req.getParameter("content");
            String image = req.getParameter("image");
            String author = req.getParameter("author");
            String status = req.getParameter("status");
            boolean isFeatured = "on".equalsIgnoreCase(req.getParameter("isFeatured"))
                    || "true".equalsIgnoreCase(req.getParameter("isFeatured"))
                    || "1".equals(req.getParameter("isFeatured"));

            String homeRole = req.getParameter("homeRole");
            if (homeRole == null || homeRole.trim().isEmpty()) {
                homeRole = "NONE";
            }

            if (title == null || title.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/news?error=invalid_title" + keepParams);
                return;
            }
            if (title.trim().length() > 255) {
                resp.sendRedirect(req.getContextPath() + "/admin/news?error=title_too_long" + keepParams);
                return;
            }

            if (author == null || author.trim().isEmpty()) {
                HttpSession session = req.getSession(false);
                if (session != null && session.getAttribute("USER_LOGIN") instanceof User) {
                    author = ((User) session.getAttribute("USER_LOGIN")).getFullName();
                }
                if (author == null || author.trim().isEmpty()) {
                    author = "Độ PC 67";
                }
            }

            if (status == null || (!"ACTIVE".equalsIgnoreCase(status) && !"HIDDEN".equalsIgnoreCase(status))) {
                status = "ACTIVE";
            }

            if (image == null || image.trim().isEmpty()) {
                image = "/assets/images/banner.png";
            }

            News n = new News();
            n.setId(id);
            n.setTitle(title.trim());
            n.setSummary(summary != null ? summary.trim() : "");
            n.setContent(content != null ? content.trim() : "");
            n.setImage(image.trim());
            n.setAuthor(author.trim());
            n.setFeatured(isFeatured);
            n.setStatus(status.toUpperCase());
            n.setHomeRole(homeRole.toUpperCase());

            if ("update".equalsIgnoreCase(action) && id > 0) {
                boolean ok = newsDao.update(n);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?msg=update_success" + keepParams);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?error=system_error" + keepParams);
                }
            } else {
                boolean ok = newsDao.insert(n);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?msg=insert_success&page=1");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/news?error=system_error" + keepParams);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/news?error=system_error" + keepParams);
        }
    }

    private int parseIntSafe(String val) {
        if (val == null || val.trim().isEmpty()) return 0;
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String urlEncode(String value) {
        if (value == null) return "";
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return value;
        }
    }
}
