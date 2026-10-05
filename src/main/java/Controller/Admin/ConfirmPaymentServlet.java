package Controller.Admin;

import dao.OrderDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/confirm-payment")
public class ConfirmPaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String page = request.getParameter("page");
        if (page == null || page.isEmpty()) page = "1";

        try {
            int orderId = Integer.parseInt(idParam);
            new OrderDao().markPaid(orderId);
            response.sendRedirect(request.getContextPath() + "/admin/orders?id=" + orderId + "&page=" + page);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }
}
