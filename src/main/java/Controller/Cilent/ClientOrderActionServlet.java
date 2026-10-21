package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Xử lý thao tác hủy đơn và yêu cầu đổi trả hàng từ phía khách hàng.
 * ============================================================================
 */

import dao.OrderDao;
import model.Order;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/client/order-action")
public class ClientOrderActionServlet extends HttpServlet {
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("USER_LOGIN");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(idParam);
            boolean success = false;
            String message = "";

            if ("cancel".equals(action)) {
                // Khách chủ động hủy đơn (chỉ khi đơn đang PENDING)
                success = orderDao.clientCancelOrder(orderId, user.getId());
                if (success) {
                    message = "Đã hủy đơn hàng thành công! Sản phẩm đã được hoàn lại kho.";
                    util.realtime.RealtimeHub.broadcastOrderCancelled(orderId, user.getId(), user.getFullName());
                } else {
                    message = "Không thể hủy đơn hàng do đơn đã được shop tiếp nhận xử lý hoặc không hợp lệ.";
                }
            } else if ("return_request".equals(action)) {
                // Khách gửi yêu cầu đổi trả (chỉ khi đơn đã hoàn thành)
                success = orderDao.clientRequestReturn(orderId, user.getId());
                if (success) {
                    message = "Đã gửi yêu cầu đổi trả thành công! Shop sẽ liên hệ và xử lý sớm nhất.";
                    util.realtime.RealtimeHub.broadcastOrderReturnRequested(orderId, user.getId(), user.getFullName());
                } else {
                    message = "Không thể gửi yêu cầu đổi trả cho đơn hàng này.";
                }
            }

            session.setAttribute("orderActionMsg", message);
            session.setAttribute("orderActionSuccess", success);
            resp.sendRedirect(req.getContextPath() + "/order-detail?id=" + orderId);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/orders");
        }
    }
}
