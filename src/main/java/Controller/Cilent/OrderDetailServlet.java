package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Xem chi tiết thông tin đơn hàng, danh sách sản phẩm và trạng thái vận chuyển.
 * ============================================================================
 */

import model.OrderDetail;
import dao.OrderDao;
import model.Order;
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
        if (session.getAttribute("USER_LOGIN") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");

        try {
            int orderId = Integer.parseInt(idParam);
            OrderDao dao = new OrderDao();

            Order order = dao.getOrderById(orderId);
            List<OrderDetail> details = dao.getOrderDetails(orderId);

            request.setAttribute("order", order);
            request.setAttribute("details", details);

            request.getRequestDispatcher("/view/order_detail.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendRedirect("my-orders");
        }
    }
}