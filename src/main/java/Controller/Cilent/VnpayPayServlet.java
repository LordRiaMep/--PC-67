package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Tạo URL thanh toán trực tuyến qua cổng VNPay với chữ ký bảo mật SHA512.
 * ============================================================================
 */

import dao.OrderDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Order;
import model.User;
import util.VnpayConfig;
import util.VnpayUtil;

import java.io.IOException;

/**
 * Tạo link thanh toán VNPay cho 1 đơn QR chưa được admin xác nhận rồi chuyển hướng sang VNPay.
 * Dùng cho cả lần chuyển khoản đầu (sau khi đặt hàng) lẫn "Thanh toán lại".
 * URL: /vnpay-pay?id=<orderId>
 */
@WebServlet("/vnpay-pay")
public class VnpayPayServlet extends HttpServlet {

    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String ctx = request.getContextPath();
        User user = (User) request.getSession().getAttribute("USER_LOGIN");
        if (user == null) {
            response.sendRedirect(ctx + "/cart");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("id"));
        } catch (Exception e) {
            response.sendRedirect(ctx + "/Home");
            return;
        }

        Order order = orderDao.getOrderById(orderId);
        if (order == null || order.getUserId() != user.getId()) {
            response.sendRedirect(ctx + "/Home");
            return;
        }

        // Chỉ chuyển khoản được với đơn QR chưa được admin xác nhận đã nhận tiền
        if (!"QR".equals(order.getPaymentMethod()) || "PAID".equals(order.getPaymentStatus())) {
            response.sendRedirect(ctx + "/order-detail?id=" + orderId);
            return;
        }

        // Mỗi lần thanh toán dùng 1 mã giao dịch riêng (VNPay không cho trùng) -> "<orderId>x<giây>"
        String txnRef = orderId + "x" + (System.currentTimeMillis() / 1000);

        // Số tiền khách chuyển: cố định theo cấu hình, hoặc đúng tổng đơn nếu PAY_AMOUNT = 0
        long amount = VnpayConfig.PAY_AMOUNT > 0
                ? VnpayConfig.PAY_AMOUNT
                : Math.round(order.getTotalMoney());

        String returnUrl = VnpayUtil.baseUrl(request) + "/vnpay-return";

        String payUrl = VnpayUtil.buildPaymentUrl(
                txnRef,
                amount,
                "Thanh toan don hang " + orderId,     // VNPay yêu cầu không dấu
                VnpayUtil.getClientIp(request),
                returnUrl);

        response.sendRedirect(payUrl);
    }
}
