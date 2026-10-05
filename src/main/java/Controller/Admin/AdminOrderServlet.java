package Controller.Admin;

import dao.OrderDao;
import model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int pageSize = 5;
        int page = 1;

        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }

        int offset = (page - 1) * pageSize;
        int totalOrders = orderDao.getTotalOrdersCount();
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);

        req.setAttribute("orders", orderDao.getOrdersByPage(offset, pageSize));
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);

        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                int orderId = Integer.parseInt(idParam);
                req.setAttribute("selectedOrder", orderDao.getOrderById(orderId));
                req.setAttribute("orderDetails", orderDao.getOrderDetails(orderId));
            } catch (Exception ignored) {}
        }

        req.getRequestDispatcher("/view/admin_orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            int id = Integer.parseInt(req.getParameter("id"));
            String newStatus = req.getParameter("status");
            String pageParam = req.getParameter("page");

            Order currentOrder = orderDao.getOrderById(id);

            if (currentOrder != null) {
                String currentStatus = currentOrder.getStatus();

                boolean isInvalidCancel = ("SHIPPING".equals(currentStatus) || "FINISH".equals(currentStatus) || "COMPLETED".equals(currentStatus))
                        && "CANCELLED".equals(newStatus);

                if (!isInvalidCancel) {
                    orderDao.updateStatus(id, newStatus);
                }
            }

            String redirectUrl = req.getContextPath() + "/admin/orders?id=" + id;
            if (pageParam != null && !pageParam.isEmpty()) {
                redirectUrl += "&page=" + pageParam;
            }

            resp.sendRedirect(redirectUrl);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
        }
    }
}