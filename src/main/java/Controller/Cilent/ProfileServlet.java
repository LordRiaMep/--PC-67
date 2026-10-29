package Controller.Cilent;

import dao.OrderDao;

import dao.UserDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loginUser = getLoginUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User profile = userDao.getById(loginUser.getId());
        request.setAttribute("profile", profile != null ? profile : loginUser);

        request.setAttribute("stats", orderDao.getUserOrderStats(loginUser.getId()));
        List<Order> orders = orderDao.getOrdersByUserId(loginUser.getId());
        request.setAttribute("recentOrders", orders.size() > 3 ? orders.subList(0, 3) : orders);

        request.getRequestDispatcher("/view/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        HttpSession session = request.getSession();
        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        if (fullName.isEmpty()) {
            session.setAttribute("profileError", "Họ tên không được để trống.");
        } else if (!phone.isEmpty() && !phone.matches("^(0|\\+84)[35789][0-9]{8}$")) {
            session.setAttribute("profileError", "Số điện thoại không hợp lệ. Vui lòng nhập đúng định dạng số Việt Nam (VD: 0912345678 hoặc +84912345678).");
        } else if (userDao.updateProfile(loginUser.getId(), fullName, phone, address)) {

            loginUser.setFullName(fullName);
            loginUser.setPhone(phone);
            loginUser.setAddress(address);
            session.setAttribute("USER_LOGIN", loginUser);
            session.setAttribute("profileSuccess", "Cập nhật thông tin thành công.");
        } else {
            session.setAttribute("profileError", "Không thể cập nhật, vui lòng thử lại.");
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private User getLoginUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("USER_LOGIN");
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
