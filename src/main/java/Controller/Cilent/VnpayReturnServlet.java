package Controller.Cilent;

import dao.OrderDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Order;
import util.VnpayUtil;

import java.io.IOException;

@WebServlet("/vnpay-return")
public class VnpayReturnServlet extends HttpServlet {

    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String ctx = request.getContextPath();

        if (!VnpayUtil.verifyReturn(request)) {
            response.sendRedirect(ctx + "/Home");
            return;
        }

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
