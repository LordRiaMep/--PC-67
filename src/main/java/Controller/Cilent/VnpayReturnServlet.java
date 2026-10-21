package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Xử lý kết quả trả về từ VNPay (Return URL), kiểm tra checksum và cập nhật PAID.
 * ============================================================================
 */

import dao.OrderDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Order;
import util.VnpayUtil;

import java.io.IOException;

/**
 * VNPay chuyển người dùng về đây sau khi chuyển khoản (vnp_ReturnUrl).
 * Khi chữ ký hợp lệ + mã kết quả 00: CHỈ ghi nhận khách đã chuyển (số tiền, mã giao dịch).
 * Đơn vẫn UNPAID cho tới khi admin xác nhận đã nhận đủ tiền.
 */
@WebServlet("/vnpay-return")
public class VnpayReturnServlet extends HttpServlet {

    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String ctx = request.getContextPath();

        // 1. Chữ ký sai -> dữ liệu bị sửa/giả mạo
        if (!VnpayUtil.verifyReturn(request)) {
            response.sendRedirect(ctx + "/Home");
            return;
        }

        // 2. Lấy mã đơn từ vnp_TxnRef ("<orderId>x<giây>")
        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("vnp_TxnRef").split("x")[0]);
        } catch (Exception e) {
            response.sendRedirect(ctx + "/Home");
            return;
        }

        Order order = orderDao.getOrderById(orderId);
        if (order == null) {
            response.sendRedirect(ctx + "/Home");
            return;
        }

        // 3. Chuyển khoản thành công (số tiền bao nhiêu cũng được, admin sẽ đối chiếu sau)
        boolean success = "00".equals(request.getParameter("vnp_ResponseCode"))
                && "00".equals(request.getParameter("vnp_TransactionStatus"));

        if (success) {
            long paidAmount = 0;
            try {
                paidAmount = Long.parseLong(request.getParameter("vnp_Amount")) / 100;
            } catch (Exception ignored) {
            }
            String txnNo = request.getParameter("vnp_TransactionNo");
            orderDao.markTransferred(orderId, paidAmount, txnNo);
            util.realtime.RealtimeHub.broadcastPaymentTransferred(orderId, paidAmount, txnNo);
            response.sendRedirect(ctx + "/order-detail?id=" + orderId + "&pay=success");
        } else {
            response.sendRedirect(ctx + "/order-detail?id=" + orderId + "&pay=failed");
        }
    }
}
