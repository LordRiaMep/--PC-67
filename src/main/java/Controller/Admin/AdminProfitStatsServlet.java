package Controller.Admin;

/**
 * ============================================================================
 * [PHÂN HỆ 2: REALTIME WEBSOCKET HUB, DASHBOARD DOANH THU & CSKH]
 * Phụ trách: Quang
 * Chức năng: API cung cấp số liệu cơ cấu Lãi kinh doanh (Products vs Services)
 *            phục vụ biểu đồ tròn Doughnut Realtime trên Dashboard Admin.
 * ============================================================================
 */

import com.google.gson.Gson;
import dao.DashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ProfitStats;
import util.realtime.RealtimeHub;

import java.io.IOException;

@WebServlet(name = "AdminProfitStatsServlet", urlPatterns = {"/api/admin/profit-stats"})
public class AdminProfitStatsServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private final DashboardDAO dashboardDao = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        try {
            ProfitStats stats = dashboardDao.getProfitStats();
            resp.getWriter().write(gson.toJson(stats));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String action = req.getParameter("action");
        if ("simulate_buy".equalsIgnoreCase(action)) {
            // Giả lập sự kiện khách mua để kiểm thử chuyển động biểu đồ
            int simId = 900 + (int)(Math.random() * 99);
            double simAmount = 15500000.0;
            RealtimeHub.broadcastOrderCreated(simId, 1, "Khách hàng thử nghiệm", "test@demo.vn", simAmount, "COD", 0);
            resp.getWriter().write("{\"success\":true,\"message\":\"Đã phát sự kiện Đơn hàng mới mô phỏng!\"}");
            return;
        }

        if ("simulate_cancel".equalsIgnoreCase(action)) {
            // Giả lập sự kiện hủy đơn để kiểm thử chuyển động biểu đồ
            int simId = 900 + (int)(Math.random() * 99);
            RealtimeHub.broadcastOrderCancelled(simId, 1, "Khách hàng thử nghiệm");
            resp.getWriter().write("{\"success\":true,\"message\":\"Đã phát sự kiện Hủy đơn mô phỏng!\"}");
            return;
        }

        resp.getWriter().write("{\"success\":false,\"error\":\"Unknown action\"}");
    }
}
