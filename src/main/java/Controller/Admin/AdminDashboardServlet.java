package Controller.Admin;

/**
 * ============================================================================
 * [PHÂN HỆ 2: REALTIME WEBSOCKET HUB, DASHBOARD DOANH THU & CSKH]
 * Phụ trách: Quang
 * Chức năng: Controller tổng hợp số liệu doanh thu, thống kê kinh doanh hiển thị Dashboard.
 * ============================================================================
 */

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// Dòng này rất quan trọng để Java biết DashboardDAO nằm ở thư mục dao
import dao.DashboardDAO;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        try {
            // Khởi tạo đối tượng DAO
            DashboardDAO dao = new DashboardDAO();

            // Lấy dữ liệu từ SQL và gán vào request
            request.setAttribute("totalRevenue", dao.getTotalRevenue());
            request.setAttribute("totalOrders", dao.getTotalOrders());
            request.setAttribute("totalProducts", dao.getTotalProducts());
            request.setAttribute("totalUsers", dao.getTotalUsers());
            request.setAttribute("recentOrders", dao.getRecentOrders());
            request.setAttribute("profitStats", dao.getProfitStats());

        } catch (Exception e) {
            System.out.println("Lỗi khi lấy dữ liệu Dashboard: " + e.getMessage());
            e.printStackTrace();
        }

        // Forward về file dashboard.jsp
        request.getRequestDispatcher("/view/dashboard.jsp").forward(request, response);
    }
}
