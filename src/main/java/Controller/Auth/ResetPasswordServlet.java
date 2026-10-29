package Controller.Auth;

import dao.UserDao;
import dao.UserTokenDao;
import model.UserToken;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final UserTokenDao userTokenDao = new UserTokenDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/forgot-password?error=invalid_token");
            return;
        }

        UserToken userToken = userTokenDao.findValidToken(token.trim(), "RESET_PASSWORD");
        if (userToken == null) {
            response.sendRedirect(request.getContextPath() + "/forgot-password?error=invalid_token");
            return;
        }

        request.setAttribute("token", token.trim());
        request.setAttribute("resetEmail", userToken.getEmail());
        request.getRequestDispatcher("/view/reset_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (token == null || token.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/forgot-password?error=invalid_token");
            return;
        }

        UserToken userToken = userTokenDao.findValidToken(token.trim(), "RESET_PASSWORD");
        if (userToken == null) {
            response.sendRedirect(request.getContextPath() + "/forgot-password?error=invalid_token");
            return;
        }

        if (newPassword == null || newPassword.trim().isEmpty() || confirmPassword == null || confirmPassword.trim().isEmpty()) {
            request.setAttribute("token", token.trim());
            request.setAttribute("resetEmail", userToken.getEmail());
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin mật khẩu mới.");
            request.getRequestDispatcher("/view/reset_password.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 6) {
            request.setAttribute("token", token.trim());
            request.setAttribute("resetEmail", userToken.getEmail());
            request.setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/view/reset_password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("token", token.trim());
            request.setAttribute("resetEmail", userToken.getEmail());
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/view/reset_password.jsp").forward(request, response);
            return;
        }

        boolean updated = userDao.updatePasswordByEmail(userToken.getEmail(), newPassword);
        if (updated) {
            userTokenDao.markUsed(userToken.getId());
            response.sendRedirect(request.getContextPath() + "/login?reset=success");
        } else {
            request.setAttribute("token", token.trim());
            request.setAttribute("resetEmail", userToken.getEmail());
            request.setAttribute("error", "Không thể cập nhật mật khẩu, vui lòng thử lại sau!");
            request.getRequestDispatcher("/view/reset_password.jsp").forward(request, response);
        }
    }
}
