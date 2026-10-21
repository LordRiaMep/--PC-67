package Controller.Auth;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Gửi lại email xác thực cho người dùng.
 * ============================================================================
 */

import dao.UserDao;
import dao.UserTokenDao;
import model.User;
import model.UserToken;
import util.EmailService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/resend-verification")
public class ResendVerificationServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final UserTokenDao userTokenDao = new UserTokenDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String cleanEmail = email.trim().toLowerCase();
        User user = userDao.findByEmail(cleanEmail);

        if (user != null) {
            if (user.isActive()) {
                response.sendRedirect(request.getContextPath() + "/login?verified=true");
                return;
            }

            if (user.isPending()) {
                // Tạo token mới và gửi lại email
                UserToken token = userTokenDao.createToken(user.getId(), cleanEmail, "REGISTER_VERIFY", 1440);
                if (token != null) {
                    String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
                    String verifyLink = baseUrl + "/verify-account?token=" + token.getToken();
                    EmailService.sendVerificationEmail(cleanEmail, user.getFullName(), verifyLink, token.getOtpCode());
                }

                response.sendRedirect(request.getContextPath() + "/register-success?email=" + URLEncoder.encode(cleanEmail, StandardCharsets.UTF_8.name()) + "&resent=true");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/login");
    }
}
