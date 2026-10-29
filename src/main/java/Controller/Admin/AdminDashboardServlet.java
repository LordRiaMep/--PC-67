package Controller.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import dao.DashboardDAO;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        try {

            DashboardDAO dao = new DashboardDAO();

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

        request.getRequestDispatcher("/view/dashboard.jsp").forward(request, response);
    }
}
