package Controller.Auth;

import dao.UserDao;
import dao.UserTokenDao;
import model.User;
import model.UserToken;
import util.EmailConfig;
import util.EmailService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final UserTokenDao userTokenDao = new UserTokenDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String sent = request.getParameter("sent");
        String email = request.getParameter("email");
        String errorParam = request.getParameter("error");

        if ("invalid_token".equals(errorParam)) {
            request.setAttribute("error", "Liên kết đổi mật khẩu không hợp lệ hoặc đã hết hạn (chỉ có hiệu lực trong 30 phút). Vui lòng gửi lại yêu cầu mới!");
        }

        if ("true".equals(sent) && email != null && !email.trim().isEmpty()) {
            request.setAttribute("emailSent", true);
            request.setAttribute("sentEmail", email.trim());
            if (EmailConfig.DEV_MODE) {
                request.setAttribute("devLink", EmailService.getLatestDevLink(email.trim()));
                request.setAttribute("devOtp", EmailService.getLatestDevOtp(email.trim()));
            }
        }

        request.getRequestDispatcher("/view/forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ email của bạn.");
            request.getRequestDispatcher("/view/forgot_password.jsp").forward(request, response);
            return;
        }

        String cleanEmail = email.trim().toLowerCase();
        User user = userDao.findByEmail(cleanEmail);

        if (user == null) {
            request.setAttribute("error", "Email này chưa được đăng ký trong hệ thống!");
            request.setAttribute("enteredEmail", email);
            request.getRequestDispatcher("/view/forgot_password.jsp").forward(request, response);
            return;
        }

        if (user.isLocked()) {
            request.setAttribute("error", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Hotline 0904.112.618 để được hỗ trợ!");
            request.setAttribute("enteredEmail", email);
            request.getRequestDispatcher("/view/forgot_password.jsp").forward(request, response);
            return;
        }

        if (user.isPending()) {
            request.setAttribute("error", "Tài khoản của bạn chưa được xác nhận kích hoạt qua email. Vui lòng kiểm tra email kích hoạt trước!");
            request.setAttribute("enteredEmail", email);
            request.getRequestDispatcher("/view/forgot_password.jsp").forward(request, response);
            return;
        }

        UserToken token = userTokenDao.createToken(user.getId(), cleanEmail, "RESET_PASSWORD", 30);
        if (token != null) {
            String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
            String resetLink = baseUrl + "/reset-password?token=" + token.getToken();
            EmailService.sendResetPasswordEmail(cleanEmail, user.getFullName(), resetLink, token.getOtpCode());
        }

        response.sendRedirect(request.getContextPath() + "/forgot-password?sent=true&email=" + URLEncoder.encode(cleanEmail, StandardCharsets.UTF_8.name()));
    }
}
