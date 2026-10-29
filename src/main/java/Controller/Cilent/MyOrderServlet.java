package Controller.Cilent;

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
        int pageSize = 5;
        int page = 1;

        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }

        int totalOrders = dao.getTotalOrdersCountByUserId(user.getId());
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }
        if (page < 1) {
            page = 1;
        }

        int offset = Math.max(0, (page - 1) * pageSize);
        List<Order> orders = dao.getOrdersByUserIdAndPage(user.getId(), offset, pageSize);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.getRequestDispatcher("/view/my_orders.jsp").forward(request, response);
    }
}
