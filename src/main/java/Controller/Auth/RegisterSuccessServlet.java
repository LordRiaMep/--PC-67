package Controller.Auth;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Hiển thị trang thông báo đăng ký thành công, chờ kích hoạt.
 * ============================================================================
 */

import util.EmailConfig;
import util.EmailService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/register-success")
public class RegisterSuccessServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String resent = request.getParameter("resent");

        if (email != null && !email.trim().isEmpty()) {
            email = email.trim();
            request.setAttribute("registeredEmail", email);
            if (EmailConfig.DEV_MODE) {
                request.setAttribute("devLink", EmailService.getLatestDevLink(email));
                request.setAttribute("devOtp", EmailService.getLatestDevOtp(email));
            }
        }

        if ("true".equals(resent)) {
            request.setAttribute("resentSuccess", true);
        }

        request.getRequestDispatcher("/view/register_success.jsp").forward(request, response);
    }
}
