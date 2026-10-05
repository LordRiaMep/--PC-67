package Controller.Auth;

import dao.UserDao;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/view/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        User user = userDao.checkLogin(email, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("USER_LOGIN", user);

            // --- CHIA NGÃ RẼ TẠI ĐÂY ---
            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                // Đẩy vào Servlet của trang Dashboard
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                // Nếu là Khách hàng -> Đẩy về trang chủ mua sắm
                response.sendRedirect(request.getContextPath() + "/Home");
            }
        } else {
            request.setAttribute("error", "Email hoặc mật khẩu không chính xác!");
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
        }
    }
}