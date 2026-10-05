package Controller.Admin;

import dao.CategoryDao;
import dao.ProductDao;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/products")
public class AdminProductServlet extends HttpServlet {
    private ProductDao productDao = new ProductDao();
    private CategoryDao categoryDao = new CategoryDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        // 1. Xóa
        if ("delete".equals(action)) {
            productDao.delete(Integer.parseInt(req.getParameter("id")));
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        else if ("edit".equals(action)) {
            req.setAttribute("product", productDao.getProductById(Integer.parseInt(req.getParameter("id"))));
        }

        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 10;
        int totalProducts = productDao.getTotalProducts();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        List<Product> listProducts = productDao.getProductsByPage(page, pageSize);

        req.setAttribute("listProducts", listProducts);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("listCategories", categoryDao.findAll());

        req.getRequestDispatcher("/view/admin_product.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        int id = req.getParameter("id") != null && !req.getParameter("id").isEmpty() ? Integer.parseInt(req.getParameter("id")) : 0;
        int categoryId = Integer.parseInt(req.getParameter("categoryId"));
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        double price = Double.parseDouble(req.getParameter("price"));
        int stock = Integer.parseInt(req.getParameter("stock"));
        String imageUrl = req.getParameter("imageUrl");

        Product p = new Product(id, categoryId, name, description, price, imageUrl, stock, "ACTIVE", null);

        if ("update".equals(action)) {
            productDao.update(p);
        } else {
            productDao.insert(p);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }
}