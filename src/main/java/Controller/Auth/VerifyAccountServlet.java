package Controller.Auth;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Xác nhận mã OTP/Token kích hoạt tài khoản từ PENDING sang ACTIVE.
 * ============================================================================
 */

import dao.UserDao;
import dao.UserTokenDao;
import model.UserToken;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/verify-account")
public class VerifyAccountServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final UserTokenDao userTokenDao = new UserTokenDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        String email = request.getParameter("email");
        String otp = request.getParameter("otp");

        UserToken validToken = null;

        if (token != null && !token.trim().isEmpty()) {
            validToken = userTokenDao.findValidToken(token.trim(), "REGISTER_VERIFY");
        } else if (email != null && otp != null && !email.trim().isEmpty() && !otp.trim().isEmpty()) {
            validToken = userTokenDao.findValidOtp(email.trim(), otp.trim(), "REGISTER_VERIFY");
        }

        if (validToken != null) {
            // Kích hoạt tài khoản thành ACTIVE
            boolean activated = userDao.activateUser(validToken.getEmail());
            // Đánh dấu token đã được sử dụng
            userTokenDao.markUsed(validToken.getId());

            if (activated) {
                // Chuyển người dùng về lại trang bán hàng để đăng nhập và thông báo tạo tài khoản thành công
                response.sendRedirect(request.getContextPath() + "/login?verified=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/login?verified=true");
            }
        } else {
            // Liên kết không hợp lệ hoặc đã hết hạn
            response.sendRedirect(request.getContextPath() + "/login?error=invalid_token");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
