package Controller.Cilent; // <-- đổi cho đúng package của bạn (giống SearchServlet)

import dao.NewsDao;

/**
 * ============================================================================
 * [PHÂN HỆ 2: REALTIME WEBSOCKET HUB, DASHBOARD DOANH THU & CSKH]
 * Phụ trách: Quang
 * Chức năng: Hiển thị danh sách tin tức công nghệ cho khách hàng xem.
 * ============================================================================
 */
import model.News;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

// Trang "Tất cả tin tức": /news
@WebServlet(name = "NewsServlet", urlPatterns = {"/news"})
public class NewsServlet extends HttpServlet {

    private static final int PAGE_SIZE = 5; // 1 bài to + 4 bài nhỏ mỗi trang

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

        int total = dao.getTotalNewestNews(); // chỉ đếm các bài ở mục "Tin tức mới"
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