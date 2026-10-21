package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Hiển thị lịch sử đơn hàng cá nhân của khách hàng.
 * ============================================================================
 */

import dao.OrderDao;
import model.Order;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/orders")
public class MyOrderServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("USER_LOGIN");

        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        OrderDao dao = new OrderDao();
        List<Order> orders = dao.getOrdersByUserId(user.getId());

        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/view/my_orders.jsp").forward(request, response);
    }
}