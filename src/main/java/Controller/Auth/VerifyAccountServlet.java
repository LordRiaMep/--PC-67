package Controller.Auth;

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

            boolean activated = userDao.activateUser(validToken.getEmail());

            userTokenDao.markUsed(validToken.getId());

            if (activated) {

                response.sendRedirect(request.getContextPath() + "/login?verified=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/login?verified=true");
            }
        } else {

            response.sendRedirect(request.getContextPath() + "/login?error=invalid_token");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
