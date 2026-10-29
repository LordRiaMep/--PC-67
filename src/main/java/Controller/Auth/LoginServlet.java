package Controller.Auth;

import dao.UserDao;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import util.LoginRedirect;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String verifiedParam = request.getParameter("verified");
        if ("true".equals(verifiedParam)) {
            request.setAttribute("successMessage", "🎉 Kích hoạt tài khoản thành công! Chào mừng bạn đến với Độ-PC 67. Vui lòng đăng nhập để tiếp tục mua sắm.");
        }

        String resetParam = request.getParameter("reset");
        if ("success".equals(resetParam)) {
            request.setAttribute("successMessage", "✅ Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới của bạn.");
        }

        String errorParam = request.getParameter("error");
        if ("account_locked".equals(errorParam)) {
            String reason = request.getParameter("reason");
            request.setAttribute("accountLocked", true);
            request.setAttribute("lockReason", reason != null && !reason.trim().isEmpty() ? reason : "Tài khoản của bạn đã bị khóa do vi phạm chính sách.");
            request.setAttribute("supportHotline", "090.411.2618");
            request.setAttribute("supportEmail", "cskh@dopc67.vn");
            request.setAttribute("supportZalo", "0904.112.618");
        } else if ("need_login".equals(errorParam)) {
            request.setAttribute("error", "Vui lòng đăng nhập để tiếp tục!");
        } else if ("invalid_token".equals(errorParam)) {
            request.setAttribute("error", "Liên kết xác nhận tài khoản không hợp lệ hoặc đã hết hạn. Vui lòng đăng ký lại hoặc yêu cầu gửi lại thư kích hoạt!");
        } else if ("password_changed".equals(errorParam)) {
            request.setAttribute("error", "Mật khẩu của tài khoản vừa được thay đổi từ một trình duyệt hoặc thiết bị khác. Vui lòng đăng nhập lại với mật khẩu mới!");
        }

        request.getRequestDispatcher("/view/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ email và mật khẩu.");
            request.setAttribute("enteredEmail", email);
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
            return;
        }

        String cleanEmail = email.trim().toLowerCase();

        if (service.LoginSecurityService.isLocked(cleanEmail)) {
            long remainMinutes = service.LoginSecurityService.getRemainingLockMinutes(cleanEmail);
            request.setAttribute("tempLocked", true);
            request.setAttribute("remainMinutes", remainMinutes);
            request.setAttribute("error", "Tài khoản của bạn đã bị tạm khóa do nhập sai mật khẩu quá 5 lần liên tiếp vì lý do bảo mật. Vui lòng thử lại sau " + remainMinutes + " phút nữa hoặc nhấn 'Quên mật khẩu' để khôi phục!");
            request.setAttribute("enteredEmail", email);
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
            return;
        }

        User user = userDao.authenticate(cleanEmail, password);

        if (user == null) {

            User existingUser = userDao.findByEmail(cleanEmail);
            if (existingUser != null) {

                int failedCount = service.LoginSecurityService.recordFailedAttempt(cleanEmail);
                if (failedCount >= service.LoginSecurityService.MAX_FAILED_ATTEMPTS) {
                    long remainMinutes = service.LoginSecurityService.getRemainingLockMinutes(cleanEmail);
                    request.setAttribute("tempLocked", true);
                    request.setAttribute("remainMinutes", remainMinutes);
                    request.setAttribute("error", "Cảnh báo bảo mật: Bạn đã nhập sai mật khẩu 5 lần! Tài khoản đã bị tạm thời khóa đăng nhập trong " + remainMinutes + " phút.");
                } else {
                    int remainAttempts = service.LoginSecurityService.MAX_FAILED_ATTEMPTS - failedCount;
                    request.setAttribute("error", "Email hoặc mật khẩu không chính xác! Bạn còn " + remainAttempts + " lần thử trước khi tài khoản bị tạm khóa vì lý do bảo mật.");
                }
            } else {
                request.setAttribute("error", "Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại!");
            }
            request.setAttribute("enteredEmail", email);
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
            return;
        }

        service.LoginSecurityService.resetAttempts(cleanEmail);

        if (user.isPending()) {
            request.setAttribute("accountPending", true);
            request.setAttribute("pendingEmail", user.getEmail());
            request.setAttribute("enteredEmail", email);
            request.setAttribute("error", "Tài khoản của bạn chưa được kích hoạt qua Email! Vui lòng kiểm tra hộp thư email hoặc nhấn nút bên dưới để gửi lại thư kích hoạt.");
            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
            return;
        }

        if (user.isLocked()) {
            String reason = user.getLockReason();
            if (reason == null || reason.trim().isEmpty()) {
                reason = "Tài khoản của bạn vi phạm điều khoản dịch vụ hoặc quy định cộng đồng.";
            }

            request.setAttribute("accountLocked", true);
            request.setAttribute("lockReason", reason);
            request.setAttribute("lockedAt", user.getLockedAt());
            request.setAttribute("lockedBy", user.getLockedBy());
            request.setAttribute("lockedEmail", user.getEmail());
            request.setAttribute("enteredEmail", email);
            request.setAttribute("supportHotline", "090.411.2618");
            request.setAttribute("supportEmail", "cskh@dopc67.vn");
            request.setAttribute("supportZalo", "0904.112.618");

            request.getRequestDispatcher("/view/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("USER_LOGIN", user);

        dao.CartDao cartDao = new dao.CartDao();
        model.Cart dbCart = cartDao.loadCart(user.getId());
        model.Cart sessionCart = (model.Cart) session.getAttribute("cart");

        if (sessionCart != null && !sessionCart.getItems().isEmpty()) {
            for (model.CartItem item : sessionCart.getItems()) {
                dbCart.addItem(item);
            }
            cartDao.saveCart(user.getId(), dbCart);
        }
        session.setAttribute("cart", dbCart);

        String target = LoginRedirect.popTarget(session);

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else if (target != null && !target.isEmpty()) {
            response.sendRedirect(request.getContextPath() + target);
        } else {
            response.sendRedirect(request.getContextPath() + "/Home");
        }
    }
}
