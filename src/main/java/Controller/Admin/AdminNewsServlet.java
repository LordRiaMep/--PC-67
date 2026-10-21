package Controller.Admin;

/**
 * ============================================================================
 * [PHÂN HỆ 2: REALTIME WEBSOCKET HUB, DASHBOARD DOANH THU & CSKH]
 * Phụ trách: Quang
 * Chức năng: Controller quản trị bài viết công nghệ, duyệt bài, ghim tin tức trang chủ.
 * ============================================================================
 */

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

        int page = 1;
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        // Tạo chuỗi query giữ nguyên bộ lọc khi chuyển trang hoặc thao tác
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
        String keepParams = queryKeep.toString();

        // 1. Thao tác xóa bài viết
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

        // 2. Thao tác đổi nhanh trạng thái ACTIVE <-> HIDDEN
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

        // 3. Thao tác đổi nhanh trạng thái Nổi bật (Featured 1 <-> 0)
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

        // 4. Chế độ sửa bài viết (load dữ liệu vào form)
        if ("edit".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                News n = newsDao.getNewsById(id);
                if (n != null) {
                    req.setAttribute("news", n);
                }
            } catch (Exception ignored) {}
        }

        // Phân trang & lọc dữ liệu
        int pageSize = 8;
        int totalNews = newsDao.countAdminNews(keyword, status, featured);
        int totalPages = (int) Math.ceil((double) totalNews / pageSize);
        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }
        if (page < 1) page = 1;

        List<News> listNews = newsDao.getAdminNewsByPage(page, pageSize, keyword, status, featured);
        List<Integer> top5HomeIds = newsDao.getTop5HomeNewsIds();

        // Gửi dữ liệu sang JSP
        req.setAttribute("listNews", listNews);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalNews", totalNews);
        req.setAttribute("top5HomeIds", top5HomeIds);

        // Giữ lại giá trị bộ lọc
        req.setAttribute("keyword", keyword);
        req.setAttribute("status", (status != null && !status.isEmpty()) ? status : "ALL");
        req.setAttribute("featured", (featured != null && !featured.isEmpty()) ? featured : "ALL");

        // Số liệu thống kê tổng thể
        req.setAttribute("statTotal", newsDao.getStatTotalCount());
        req.setAttribute("statActive", newsDao.getStatActiveCount());
        req.setAttribute("statHidden", newsDao.getStatHiddenCount());
        req.setAttribute("statFeatured", newsDao.getStatFeaturedCount());

        // Xử lý thông báo phản hồi
        String msg = req.getParameter("msg");
        String err = req.getParameter("error");
        if ("insert_success".equals(msg)) req.setAttribute("successMessage", "Thêm bài viết mới thành công!");
        else if ("update_success".equals(msg)) req.setAttribute("successMessage", "Cập nhật bài viết thành công!");
        else if ("delete_success".equals(msg)) req.setAttribute("successMessage", "Xóa bài viết thành công!");
        else if ("status_success".equals(msg)) req.setAttribute("successMessage", "Đổi trạng thái hiển thị bài viết thành công!");
        else if ("featured_success".equals(msg)) req.setAttribute("successMessage", "Cập nhật trạng thái nổi bật thành công!");

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
        String keepParams = queryKeep.toString();

        try {
            String action = req.getParameter("action");
            int id = 0;
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                id = Integer.parseInt(idStr.trim());
            }

            String title = req.getParameter("title");
            String summary = req.getParameter("summary");
            String content = req.getParameter("content");
            String image = req.getParameter("image");
            String author = req.getParameter("author");
            String status = req.getParameter("status");
            boolean isFeatured = "on".equalsIgnoreCase(req.getParameter("isFeatured"))
                    || "true".equalsIgnoreCase(req.getParameter("isFeatured"))
                    || "1".equals(req.getParameter("isFeatured"));

            if (title == null || title.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/news?error=invalid_title" + keepParams);
                return;
            }
            if (title.trim().length() > 255) {
                resp.sendRedirect(req.getContextPath() + "/admin/news?error=title_too_long" + keepParams);
                return;
            }

            // Nếu không nhập tác giả, lấy tên Admin đăng nhập hiện tại
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

    private String urlEncode(String value) {
        if (value == null) return "";
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return value;
        }
    }
}
