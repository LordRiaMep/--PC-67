package Controller.Cilent;

import dao.NewsDao;

import model.News;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "NewsServlet", urlPatterns = {"/news"})
public class NewsServlet extends HttpServlet {

    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        NewsDao dao = new NewsDao();

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException ignored) {
        }

        int total = dao.getTotalNewestNews();
        int totalPages = (int) Math.ceil(total / (double) PAGE_SIZE);
        if (page > totalPages) page = totalPages;
        if (page < 1) page = 1;

        List<News> featuredNews = dao.getFeaturedNews(NewsDao.FEATURED_LIMIT);
        List<News> listNews = dao.getNewestNewsByPage(page, PAGE_SIZE);

        request.setAttribute("featuredNews", featuredNews);
        request.setAttribute("listNews", listNews);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/view/news.jsp").forward(request, response);
    }
}
