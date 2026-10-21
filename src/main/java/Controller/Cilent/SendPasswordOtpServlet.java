package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Gửi OTP bảo mật khi đổi mật khẩu.
 * ============================================================================
 */

import dao.UserTokenDao;
import model.User;
import model.UserToken;
import util.EmailConfig;
import util.EmailService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/send-password-otp")
public class SendPasswordOtpServlet extends HttpServlet {
    private final UserTokenDao userTokenDao = new UserTokenDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        User loginUser = (session != null) ? (User) session.getAttribute("USER_LOGIN") : null;

        if (loginUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để thực hiện!\"}");
            return;
        }

        try {
            // Tạo mã OTP có hạn 10 phút
            UserToken token = userTokenDao.createToken(loginUser.getId(), loginUser.getEmail(), "CHANGE_PASSWORD_OTP", 10);
            if (token != null) {
                EmailService.sendOtpChangePasswordEmail(loginUser.getEmail(), loginUser.getFullName(), token.getOtpCode());

                StringBuilder json = new StringBuilder();
                json.append("{\"success\":true,\"message\":\"Mã xác thực OTP đã được gửi đến email: ")
                    .append(loginUser.getEmail())
                    .append("\"");
                if (EmailConfig.DEV_MODE) {
                    json.append(",\"devOtp\":\"").append(token.getOtpCode()).append("\"");
                }
                json.append("}");
                response.getWriter().write(json.toString());
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Không thể tạo mã OTP, vui lòng thử lại!\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Đã xảy ra lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }
}
