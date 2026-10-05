package Controller.Cilent; // <-- đổi cho đúng package của bạn (giống SearchServlet)

import dao.NewsDao;
import model.News;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

// Trang chi tiết 1 bài viết: /news/detail?id=...
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

        // Không có bài hoặc bài đang bị admin ẩn -> về trang tin tức
        if (news == null || !"ACTIVE".equals(news.getStatus())) {
            response.sendRedirect(ctx + "/news");
            return;
        }

        dao.increaseView(id);
        news.setViewCount(news.getViewCount() + 1); // hiển thị luôn số mới

        List<News> relatedNews = dao.getRelatedNews(id, 4);

        request.setAttribute("news", news);
        request.setAttribute("relatedNews", relatedNews);
        request.getRequestDispatcher("/view/news_detail.jsp").forward(request, response);
    }
}