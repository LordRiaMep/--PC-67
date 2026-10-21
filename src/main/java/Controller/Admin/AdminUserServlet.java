package Controller.Admin;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Admin quản lý danh sách người dùng, phân quyền và khóa/mở tài khoản.
 * ============================================================================
 */

import dao.OrderDao;
import dao.UserDao;
import model.Order;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        // 1. XEM CHI TIẾT KHÁCH HÀNG (API JSON CHO MODAL HOẶC VIEW THƯỜNG)
        if ("detail".equalsIgnoreCase(action)) {
            handleUserDetail(req, resp);
            return;
        }

        // 2. MỞ KHÓA TÀI KHOẢN (qua link GET tiện lợi)
        if ("unlock".equalsIgnoreCase(action)) {
            handleUnlock(req, resp);
            return;
        }

        // 3. TOGGLE STATUS CŨ (Tương thích ngược)
        if ("toggle-status".equalsIgnoreCase(action)) {
            handleToggleStatus(req, resp);
            return;
        }

        // 4. DANH SÁCH & BỘ LỌC TÌM KIẾM
        String keyword = req.getParameter("q");
        String status = req.getParameter("status");
        String role = req.getParameter("role");

        if (status == null || status.trim().isEmpty()) status = "ALL";
        if (role == null || role.trim().isEmpty()) role = "ALL";

        String pageParam = req.getParameter("page");
        int currentPage = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (Exception ignored) {}
        }

        List<User> filteredUsers = userDao.searchUsers(keyword, status, role);
        int totalUsers = filteredUsers.size();
        int pageSize = 10;
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);
        if (totalPages > 0 && currentPage > totalPages) {
            currentPage = totalPages;
        }

        int fromIndex = Math.max(0, (currentPage - 1) * pageSize);
        int toIndex = Math.min(fromIndex + pageSize, totalUsers);

        List<User> pageUsers = new ArrayList<>();
        if (fromIndex < totalUsers) {
            pageUsers = filteredUsers.subList(fromIndex, toIndex);
        }

        // Thống kê thẻ KPI
        Map<String, Integer> userCounts = userDao.getUserCounts();

        req.setAttribute("users", pageUsers);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalUsersCount", totalUsers);
        req.setAttribute("userCounts", userCounts);
        req.setAttribute("searchKeyword", keyword != null ? keyword : "");
        req.setAttribute("filterStatus", status);
        req.setAttribute("filterRole", role);

        // Thông báo kết quả
        String msg = req.getParameter("msg");
        String err = req.getParameter("error");
        if ("locked".equals(msg)) req.setAttribute("successMessage", "Đã khóa tài khoản khách hàng thành công!");
        else if ("unlocked".equals(msg)) req.setAttribute("successMessage", "Đã mở khóa tài khoản khách hàng thành công!");
        else if ("status_toggled".equals(msg)) req.setAttribute("successMessage", "Đã cập nhật trạng thái tài khoản!");

        if ("self_lock".equals(err)) req.setAttribute("errorMessage", "Không thể tự khóa tài khoản Admin đang đăng nhập!");
        else if ("admin_lock".equals(err)) req.setAttribute("errorMessage", "Không được phép khóa tài khoản Quản trị viên (ADMIN)!");
        else if ("action_failed".equals(err)) req.setAttribute("errorMessage", "Thao tác không thành công. Vui lòng kiểm tra lại.");

        req.getRequestDispatcher("/view/admin_users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String page = req.getParameter("page");
        String redirectSuffix = (page != null && !page.isEmpty()) ? "&page=" + page : "";

        if ("lock".equalsIgnoreCase(action)) {
            try {
                int userId = Integer.parseInt(req.getParameter("id"));
                String reason = req.getParameter("reason");
                if (reason == null || reason.trim().isEmpty()) {
                    reason = "Vi phạm quy định của hệ thống";
                }

                User currentAdmin = (User) req.getSession().getAttribute("USER_LOGIN");
                if (currentAdmin != null && currentAdmin.getId() == userId) {
                    resp.sendRedirect(req.getContextPath() + "/admin/users?error=self_lock" + redirectSuffix);
                    return;
                }

                User target = userDao.getById(userId);
                if (target == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/users?error=action_failed" + redirectSuffix);
                    return;
                }
                if (target.isAdmin()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/users?error=admin_lock" + redirectSuffix);
                    return;
                }

                String adminName = (currentAdmin != null) ? currentAdmin.getFullName() : "Admin";
                boolean ok = userDao.lockUser(userId, reason, adminName);
                if (ok) {
                    util.realtime.RealtimeHub.broadcastUserStatusChanged(userId, "LOCKED");
                    resp.sendRedirect(req.getContextPath() + "/admin/users?msg=locked" + redirectSuffix);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/users?error=action_failed" + redirectSuffix);
                }
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/admin/users?error=action_failed" + redirectSuffix);
            }
            return;
        }

        if ("unlock".equalsIgnoreCase(action)) {
            handleUnlock(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private void handleUnlock(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String page = req.getParameter("page");
        String redirectSuffix = (page != null && !page.isEmpty()) ? "&page=" + page : "";
        try {
            int userId = Integer.parseInt(req.getParameter("id"));
            boolean ok = userDao.unlockUser(userId);
            if (ok) {
                util.realtime.RealtimeHub.broadcastUserStatusChanged(userId, "ACTIVE");
                resp.sendRedirect(req.getContextPath() + "/admin/users?msg=unlocked" + redirectSuffix);
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/users?error=action_failed" + redirectSuffix);
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=action_failed" + redirectSuffix);
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String page = req.getParameter("page");
        String redirectSuffix = (page != null && !page.isEmpty()) ? "&page=" + page : "";
        try {
            int userId = Integer.parseInt(req.getParameter("id"));
            User currentAdmin = (User) req.getSession().getAttribute("USER_LOGIN");
            if (currentAdmin != null && currentAdmin.getId() == userId) {
                resp.sendRedirect(req.getContextPath() + "/admin/users?error=self_lock" + redirectSuffix);
                return;
            }

            boolean ok = userDao.toggleUserStatus(userId);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/users?msg=status_toggled" + redirectSuffix);
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/users?error=action_failed" + redirectSuffix);
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=action_failed" + redirectSuffix);
        }
    }

    /**
     * Xử lý lấy thông tin chi tiết tài khoản của khách hàng
     */
    private void handleUserDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        int userId = 0;
        try {
            userId = Integer.parseInt(idParam);
        } catch (Exception ignored) {}

        User targetUser = userDao.getById(userId);
        if (targetUser == null) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy người dùng!\"}");
            return;
        }

        Map<String, Number> orderStats = orderDao.getUserOrderStats(userId);
        List<Order> orders = orderDao.getOrdersByUserId(userId);
        List<Order> recentOrders = (orders != null && orders.size() > 5) ? orders.subList(0, 5) : orders;

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || "json".equalsIgnoreCase(req.getParameter("format"));

        if (isAjax) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"success\":true,");
            sb.append("\"user\":{");
            sb.append("\"id\":").append(targetUser.getId()).append(",");
            sb.append("\"fullName\":\"").append(escape(targetUser.getFullName())).append("\",");
            sb.append("\"email\":\"").append(escape(targetUser.getEmail())).append("\",");
            sb.append("\"phone\":\"").append(escape(targetUser.getPhone())).append("\",");
            sb.append("\"address\":\"").append(escape(targetUser.getAddress())).append("\",");
            sb.append("\"role\":\"").append(escape(targetUser.getRole())).append("\",");
            sb.append("\"status\":\"").append(escape(targetUser.getStatus())).append("\",");
            sb.append("\"createdAt\":\"").append(targetUser.getCreatedAt() != null ? sdf.format(targetUser.getCreatedAt()) : "").append("\",");
            sb.append("\"lockReason\":\"").append(escape(targetUser.getLockReason())).append("\",");
            sb.append("\"lockedAt\":\"").append(targetUser.getLockedAt() != null ? sdf.format(targetUser.getLockedAt()) : "").append("\",");
            sb.append("\"lockedBy\":\"").append(escape(targetUser.getLockedBy())).append("\"");
            sb.append("},");

            sb.append("\"stats\":{");
            sb.append("\"total\":").append(orderStats.getOrDefault("total", 0)).append(",");
            sb.append("\"pending\":").append(orderStats.getOrDefault("pending", 0)).append(",");
            sb.append("\"spent\":").append(orderStats.getOrDefault("spent", 0.0));
            sb.append("},");

            sb.append("\"orders\":[");
            if (recentOrders != null) {
                for (int i = 0; i < recentOrders.size(); i++) {
                    Order o = recentOrders.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{");
                    sb.append("\"id\":").append(o.getId()).append(",");
                    sb.append("\"total\":").append((long) o.getTotalMoney()).append(",");
                    sb.append("\"status\":\"").append(escape(o.getStatus())).append("\",");
                    sb.append("\"statusName\":\"").append(escape(o.getStatusDisplayName())).append("\",");
                    sb.append("\"paymentMethod\":\"").append(escape(o.getPaymentMethod())).append("\",");
                    sb.append("\"paymentStatus\":\"").append(escape(o.getPaymentStatus())).append("\",");
                    sb.append("\"createdAt\":\"").append(o.getCreatedAt() != null ? sdf.format(o.getCreatedAt()) : "").append("\"");
                    sb.append("}");
                }
            }
            sb.append("]");
            sb.append("}");
            out.print(sb.toString());
            return;
        }

        req.setAttribute("targetUser", targetUser);
        req.setAttribute("orderStats", orderStats);
        req.setAttribute("recentOrders", recentOrders);
        req.getRequestDispatcher("/view/admin_users.jsp").forward(req, resp);
    }

    private String escape(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }
}