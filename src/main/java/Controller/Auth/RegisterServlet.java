package Controller.Auth;

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

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final UserTokenDao userTokenDao = new UserTokenDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/view/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ các trường bắt buộc (*).");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        String cleanName = fullName.trim();
        if (cleanName.length() > 25) {
            request.setAttribute("error", "Họ và tên không được vượt quá 25 ký tự.");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        if (!cleanName.matches("^[\\p{L}\\s]{1,25}$")) {
            request.setAttribute("error", "Họ và tên chỉ được chứa chữ cái và khoảng trắng, không được chứa số, icon hoặc ký tự lạ.");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có tối thiểu 6 ký tự.");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        if (!password.matches("^[\\x21-\\x7E]{6,}$")) {
            request.setAttribute("error", "Mật khẩu không được chứa khoảng trắng, icon hoặc ký tự lạ (chỉ dùng chữ cái, số và ký tự thông thường).");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        String cleanPhone = phone != null ? phone.trim() : "";
        if (!cleanPhone.isEmpty() && !cleanPhone.matches("^(0|\\+84)[35789][0-9]{8}$")) {
            request.setAttribute("error", "Số điện thoại không hợp lệ. Vui lòng nhập đúng định dạng số Việt Nam (VD: 0912345678 hoặc +84912345678).");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
            return;
        }

        String cleanEmail = email.trim().toLowerCase();
        User existingUser = userDao.findByEmail(cleanEmail);

        User userToRegister = new User();
        userToRegister.setFullName(fullName.trim());
        userToRegister.setEmail(cleanEmail);
        userToRegister.setPasswordHash(password);
        userToRegister.setPhone(phone != null ? phone.trim() : "");
        userToRegister.setAddress(address != null ? address.trim() : "");

        boolean isRegisteredOrUpdated = false;

        if (existingUser != null) {
            if (existingUser.isActive() || existingUser.isLocked()) {
                request.setAttribute("error", "Địa chỉ email này đã được sử dụng. Vui lòng đăng nhập hoặc dùng email khác.");
                request.getRequestDispatcher("/view/register.jsp").forward(request, response);
                return;
            } else if (existingUser.isPending()) {

                userToRegister.setId(existingUser.getId());
                isRegisteredOrUpdated = userDao.updatePendingUser(userToRegister);
            }
        } else {

            isRegisteredOrUpdated = userDao.register(userToRegister);
        }

        if (isRegisteredOrUpdated) {

            User savedUser = userDao.findByEmail(cleanEmail);
            Integer userId = savedUser != null ? savedUser.getId() : null;

            UserToken token = userTokenDao.createToken(userId, cleanEmail, "REGISTER_VERIFY", 1440);

            if (token != null) {

                String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
                String verifyLink = baseUrl + "/verify-account?token=" + token.getToken();

                EmailService.sendVerificationEmail(cleanEmail, userToRegister.getFullName(), verifyLink, token.getOtpCode());
            }

            response.sendRedirect(request.getContextPath() + "/register-success?email=" + URLEncoder.encode(cleanEmail, StandardCharsets.UTF_8.name()));
        } else {
            request.setAttribute("error", "Không thể tạo tài khoản. Vui lòng kiểm tra lại thông tin hoặc thử lại sau!");
            request.getRequestDispatcher("/view/register.jsp").forward(request, response);
        }
    }
}
