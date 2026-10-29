package Controller.Cilent;

import model.OrderDetail;
import model.Order;
import model.User;
import dao.OrderDao;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/order-detail")
public class OrderDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("USER_LOGIN");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");

        try {
            int orderId = Integer.parseInt(idParam);
            OrderDao dao = new OrderDao();

            Order order = dao.getOrderById(orderId);

            if (order == null || (order.getUserId() != user.getId() && !user.isAdmin())) {
                response.sendRedirect(request.getContextPath() + "/orders");
                return;
            }

            List<OrderDetail> details = dao.getOrderDetails(orderId);

            request.setAttribute("order", order);
            request.setAttribute("details", details);

            request.getRequestDispatcher("/view/order_detail.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/orders");
        }
    }
}
