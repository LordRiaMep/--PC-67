package Controller.Admin;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Quản trị danh sách đơn hàng Admin, chuyển trạng thái và hoàn kho khi hủy đơn.
 * ============================================================================
 */

import dao.OrderDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int pageSize = 5;
        int page = 1;

        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }

        int totalOrders = orderDao.getTotalOrdersCount();
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }

        int offset = Math.max(0, (page - 1) * pageSize);

        req.setAttribute("orders", orderDao.getOrdersByPage(offset, pageSize));
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);

        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                int orderId = Integer.parseInt(idParam);
                req.setAttribute("selectedOrder", orderDao.getOrderById(orderId));
                req.setAttribute("orderDetails", orderDao.getOrderDetails(orderId));
            } catch (Exception ignored) {}
        }

        jakarta.servlet.http.HttpSession session = req.getSession();
        String sessSuccess = (String) session.getAttribute("adminOrderSuccess");
        String sessError = (String) session.getAttribute("adminOrderError");
        if (sessSuccess != null) {
            req.setAttribute("successMessage", sessSuccess);
            session.removeAttribute("adminOrderSuccess");
        }
        if (sessError != null) {
            req.setAttribute("errorMessage", sessError);
            session.removeAttribute("adminOrderError");
        }

        String msg = req.getParameter("msg");
        if ("pay_confirmed".equals(msg)) req.setAttribute("successMessage", "Đã xác nhận thanh toán chuyển khoản cho đơn hàng!");

        req.getRequestDispatcher("/view/admin_orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            String newStatus = req.getParameter("status");
            String pageParam = req.getParameter("page");

            OrderDao.StatusUpdateResult result = orderDao.updateStatusWithDetail(id, newStatus);

            jakarta.servlet.http.HttpSession session = req.getSession();
            if (result.isSuccess()) {
                session.setAttribute("adminOrderSuccess", "Cập nhật tiến trình đơn hàng #" + id + " thành công!");
                model.Order updatedOrder = orderDao.getOrderById(id);
                int orderUserId = (updatedOrder != null) ? updatedOrder.getUserId() : 0;
                String receiver = (updatedOrder != null) ? updatedOrder.getReceiverName() : "";
                util.realtime.RealtimeHub.broadcastOrderStatusChanged(id, orderUserId, "", newStatus, receiver);
            } else {
                session.setAttribute("adminOrderError", result.getMessage());
            }

            String redirectUrl = req.getContextPath() + "/admin/orders?id=" + id;
            if (pageParam != null && !pageParam.isEmpty()) {
                redirectUrl += "&page=" + pageParam;
            }

            resp.sendRedirect(redirectUrl);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
        }
    }
}