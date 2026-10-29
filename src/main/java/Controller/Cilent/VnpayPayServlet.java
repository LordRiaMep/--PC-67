package Controller.Cilent;

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

        if (!"QR".equals(order.getPaymentMethod()) || "PAID".equals(order.getPaymentStatus())) {
            response.sendRedirect(ctx + "/order-detail?id=" + orderId);
            return;
        }

        String txnRef = orderId + "x" + (System.currentTimeMillis() / 1000);

        long amount = VnpayConfig.PAY_AMOUNT > 0
                ? VnpayConfig.PAY_AMOUNT
                : Math.round(order.getTotalMoney());

        String returnUrl = VnpayUtil.baseUrl(request) + "/vnpay-return";

        String payUrl = VnpayUtil.buildPaymentUrl(
                txnRef,
                amount,
                "Thanh toan don hang " + orderId,
                VnpayUtil.getClientIp(request),
                returnUrl);

        response.sendRedirect(payUrl);
    }
}
