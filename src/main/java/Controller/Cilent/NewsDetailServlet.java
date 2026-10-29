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

@WebServlet(name = "NewsDetailServlet", urlPatterns = {"/news/detail"})
public class NewsDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/news");
            return;
        }

        NewsDao dao = new NewsDao();
        News news = dao.getNewsById(id);

        if (news == null || !"ACTIVE".equals(news.getStatus())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Bài viết không tồn tại hoặc đã bị xóa!");
            return;
        }

        dao.increaseView(id);
        news.setViewCount(news.getViewCount() + 1);

        List<News> relatedNews = dao.getRelatedNews(id, 4);

        request.setAttribute("news", news);
        request.setAttribute("relatedNews", relatedNews);
        request.getRequestDispatcher("/view/news_detail.jsp").forward(request, response);
    }
}
