package Controller.Cilent;

import dao.CategoryDao;
import dao.ProductDao;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.Category;
import model.Product;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/Home"})
public class Servlet extends HttpServlet {
    private ProductDao productDao = new ProductDao();
    private CategoryDao categoryDao = new CategoryDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Category> listCategories = categoryDao.getAllCategories();
        request.setAttribute("listCategories", listCategories);
        String cidRaw = request.getParameter("cid");
        List<Product> allProducts;
        String categoryTitle = "Tất cả sản phẩm";

        if (cidRaw != null && !cidRaw.isEmpty()) {
            try {
                int cid = Integer.parseInt(cidRaw);
                allProducts = productDao.getProductsByCategoryId(cid);
                request.setAttribute("cid", cid);
                if (listCategories != null) {
                    for (Category c : listCategories) {
                        if (c.getId() == cid) {
                            categoryTitle = c.getName();
                            break;
                        }
                    }
                }
            } catch (NumberFormatException e) {
                allProducts = productDao.getAllProducts();
            }
        } else {
            allProducts = productDao.getAllProducts();
        }

        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null && !pageRaw.isEmpty()) {
            try {
                page = Integer.parseInt(pageRaw);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 8;
        int totalProducts = allProducts.size();
        int endPage = (int) Math.ceil((double) totalProducts / pageSize);

        if (page < 1) {
            page = 1;
        }
        if (page > endPage && endPage > 0) {
            page = endPage;
        }

        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, totalProducts);

        List<Product> listProducts = (start < totalProducts && start >= 0)
                ? allProducts.subList(start, end)
                : new ArrayList<>();
        request.setAttribute("categoryTitle", categoryTitle);
        request.setAttribute("listProducts", listProducts);
        request.setAttribute("endPage", endPage);
        request.setAttribute("tag", page);

        request.getRequestDispatcher("/view/home.jsp").forward(request, response);
    }
}
