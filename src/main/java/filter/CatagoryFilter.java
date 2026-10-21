package filter;

/**
 * ============================================================================
 * [PHÂN HỆ 3: SẢN PHẨM, NÂNG CẤP PC & GEMINI AI CHATBOT]
 * Phụ trách: Nhân Hiếu
 * Chức năng: Bộ lọc nạp danh mục sản phẩm tự động cho mọi trang web.
 * ============================================================================
 */

import dao.CategoryDao;
import model.Category;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.List;

@WebFilter(urlPatterns = {"/*"})
public class CatagoryFilter implements Filter {

    private CategoryDao categoryDao = new CategoryDao();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        List<Category> list = categoryDao.findAll();
        req.setAttribute("listCategories", list);
        chain.doFilter(request, response);
    }
}