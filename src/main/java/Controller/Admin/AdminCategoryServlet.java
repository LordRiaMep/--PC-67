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
    private CategoryDao dao = new CategoryDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            int categoryId = Integer.parseInt(req.getParameter("id"));
            boolean isDeleted = dao.delete(categoryId);

            // Xử lý kết quả trả về từ hàm delete
            if (isDeleted) {
                // Xóa thành công
                resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=delete_success");
            } else {
                // Xóa thất bại (do vướng khóa ngoại / còn sản phẩm)
                resp.sendRedirect(req.getContextPath() + "/admin/categories?error=has_products");
            }
            return;

        } else if ("edit".equals(action)) {
            req.setAttribute("category", dao.findById(Integer.parseInt(req.getParameter("id"))));
        }

        List<Category> list = dao.findAll();
        int total = (list != null) ? list.size() : 0;
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception e) {}

        int endPage = (int) Math.ceil((double) total / 5);
        page = Math.max(1, Math.min(page, endPage > 0 ? endPage : 1));
        int start = (page - 1) * 5;

        req.setAttribute("listCategories", total > 0 ? list.subList(start, Math.min(start + 5, total)) : list);
        req.setAttribute("endPage", endPage);
        req.setAttribute("tag", page);
        req.getRequestDispatcher("/view/admin_categories.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String idParam = req.getParameter("id");
        int id = (idParam != null && !idParam.isEmpty()) ? Integer.parseInt(idParam) : 0;

        Category c = new Category(id, req.getParameter("name"), req.getParameter("description"));
        if ("update".equals(req.getParameter("action"))) {
            dao.update(c);
            resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=update_success");
        } else {
            dao.insert(c);
            resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=insert_success");
        }
    }
}