package Controller;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import util.realtime.RealtimeEvent;
import util.realtime.RealtimeHub;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "RealtimeSyncServlet", urlPatterns = {"/api/realtime-sync"})
public class RealtimeSyncServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        long sinceId = 0;
        try {
            String sinceParam = req.getParameter("sinceId");
            if (sinceParam != null && !sinceParam.isEmpty()) {
                sinceId = Long.parseLong(sinceParam);
            }
        } catch (Exception ignored) {}

        String role = req.getParameter("role");
        if (role == null || role.isEmpty()) {
            User u = (User) req.getSession().getAttribute("USER_LOGIN");
            if (u != null && u.isAdmin()) role = "admin";
            else role = "client";
        }

        int userId = 0;
        try {
            String uParam = req.getParameter("userId");
            if (uParam != null && !uParam.isEmpty()) {
                userId = Integer.parseInt(uParam);
            }
        } catch (Exception ignored) {}

        List<RealtimeEvent> events = RealtimeHub.getEventsSince(sinceId, role, userId);
        resp.getWriter().write(gson.toJson(events));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String action = req.getParameter("action");
        if ("test_broadcast".equalsIgnoreCase(action)) {
            String title = req.getParameter("title");
            String message = req.getParameter("message");
            if (title == null) title = "🔔 Thông báo thử nghiệm";
            if (message == null) message = "Đồng bộ 2 chiều đang hoạt động hoàn hảo!";
            RealtimeEvent ev = new RealtimeEvent("TEST_BROADCAST", "ALL", title, message);
            RealtimeHub.broadcast(ev);
            resp.getWriter().write("{\"success\":true,\"message\":\"Đã phát sự kiện thử nghiệm thành công!\"}");
            return;
        }

        resp.getWriter().write("{\"success\":false,\"error\":\"Unknown action\"}");
    }
}
