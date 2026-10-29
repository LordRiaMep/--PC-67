package Controller.Admin;

import dao.CategoryDao;
import model.Category;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/categories")
public class AdminCategoryServlet extends HttpServlet {
    private final CategoryDao dao = new CategoryDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String pageParam = req.getParameter("page");
        int page = 1;
        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException ignored) {}

        if ("delete".equals(action)) {
            try {
                int categoryId = Integer.parseInt(req.getParameter("id"));
                Category oldCat = dao.findById(categoryId);
                String oldCatName = (oldCat != null) ? oldCat.getName() : "Danh mục #" + categoryId;
                boolean isDeleted = dao.delete(categoryId);
                if (isDeleted) {
                    util.realtime.RealtimeHub.broadcastCategoryChanged("delete", categoryId, oldCatName);
                    resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=delete_success&page=" + page);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/categories?error=has_products&page=" + page);
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/categories?error=invalid_id&page=" + page);
            }
            return;
        } else if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Category c = dao.findById(id);
                if (c != null) {
                    req.setAttribute("category", c);
                }
            } catch (Exception ignored) {}
        }

        List<Category> list = dao.findAll();
        int total = (list != null) ? list.size() : 0;
        int endPage = (int) Math.ceil((double) total / 5);
        if (endPage > 0 && page > endPage) {
            page = endPage;
        }
        int start = (page - 1) * 5;

        req.setAttribute("listCategories", (list != null && total > 0) ? list.subList(start, Math.min(start + 5, total)) : list);
        req.setAttribute("endPage", endPage);
        req.setAttribute("tag", page);

        String msg = req.getParameter("msg");
        String err = req.getParameter("error");
        if ("delete_success".equals(msg)) req.setAttribute("successMessage", "Xóa danh mục thành công!");
        else if ("insert_success".equals(msg)) req.setAttribute("successMessage", "Thêm danh mục mới thành công!");
        else if ("update_success".equals(msg)) req.setAttribute("successMessage", "Cập nhật danh mục thành công!");

        if ("has_products".equals(err)) req.setAttribute("errorMessage", "Không thể xóa! Danh mục này đang chứa sản phẩm. Hãy xóa hoặc chuyển danh mục các sản phẩm trước.");
        else if ("invalid_data".equals(err)) req.setAttribute("errorMessage", "Tên danh mục không được để trống!");

        req.getRequestDispatcher("/view/admin_categories.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String pageParam = req.getParameter("page");
        String redirectPage = (pageParam != null && !pageParam.isEmpty()) ? "&page=" + pageParam : "";

        try {
            String idParam = req.getParameter("id");
            int id = (idParam != null && !idParam.isEmpty()) ? Integer.parseInt(idParam) : 0;
            String name = req.getParameter("name");
            String description = req.getParameter("description");

            if (name == null || name.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/categories?error=invalid_data" + redirectPage);
                return;
            }

            Category c = new Category(id, name.trim(), description);
            if ("update".equals(req.getParameter("action")) && id > 0) {
                dao.update(c);
                util.realtime.RealtimeHub.broadcastCategoryChanged("update", id, c.getName());
                resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=update_success" + redirectPage);
            } else {
                dao.insert(c);
                util.realtime.RealtimeHub.broadcastCategoryChanged("create", id, c.getName());
                resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=insert_success" + redirectPage);
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/categories?error=invalid_data" + redirectPage);
        }
    }
}
