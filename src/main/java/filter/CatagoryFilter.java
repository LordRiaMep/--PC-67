package filter;

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