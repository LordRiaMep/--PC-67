package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Đổi mật khẩu người dùng đang đăng nhập.
 * ============================================================================
 */

import dao.UserDao;
import dao.UserTokenDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.UserToken;

import java.io.IOException;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();
    private final UserTokenDao userTokenDao = new UserTokenDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loginUser = getLoginUser(request);
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User profile = userDao.getById(loginUser.getId());
        request.setAttribute("profile", profile != null ? profile : loginUser);
        request.getRequestDispatcher("/view/change_password.jsp").forward(request, response);
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
        String oldPw = request.getParameter("oldPassword");
        String newPw = request.getParameter("newPassword");
        String confirmPw = request.getParameter("confirmPassword");
        String otpCode = request.getParameter("otpCode");

        if (oldPw == null || newPw == null || confirmPw == null || oldPw.isEmpty() || newPw.isEmpty()) {
            session.setAttribute("pwError", "Vui lòng nhập đầy đủ các trường mật khẩu.");
        } else if (newPw.length() < 6) {
            session.setAttribute("pwError", "Mật khẩu mới phải có ít nhất 6 ký tự.");
        } else if (!newPw.equals(confirmPw)) {
            session.setAttribute("pwError", "Mật khẩu xác nhận không khớp.");
        } else if (newPw.equals(oldPw)) {
            session.setAttribute("pwError", "Mật khẩu mới phải khác mật khẩu hiện tại.");
        } else if (!userDao.checkPassword(loginUser.getId(), oldPw)) {
            session.setAttribute("pwError", "Mật khẩu hiện tại không đúng.");
        } else if (otpCode == null || otpCode.trim().isEmpty()) {
            session.setAttribute("pwError", "Vui lòng nhập mã OTP xác thực đã được gửi về email của bạn.");
        } else {
            // Kiểm tra mã OTP qua email
            UserToken validToken = userTokenDao.findValidOtp(loginUser.getEmail(), otpCode.trim(), "CHANGE_PASSWORD_OTP");
            if (validToken == null) {
                session.setAttribute("pwError", "Mã xác thực OTP qua email không chính xác hoặc đã hết hạn! Vui lòng nhấn 'Nhận mã OTP' để nhận mã mới.");
            } else if (userDao.updatePassword(loginUser.getId(), newPw)) {
                userTokenDao.markUsed(validToken.getId());
                loginUser.setPasswordHash(newPw);
                session.setAttribute("USER_LOGIN", loginUser);
                session.setAttribute("pwSuccess", "Đổi mật khẩu thành công!");
            } else {
                session.setAttribute("pwError", "Không thể đổi mật khẩu, vui lòng thử lại sau.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/change-password");
    }

    private User getLoginUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("USER_LOGIN");
    }
}
