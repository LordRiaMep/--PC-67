package Controller.Auth;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: API kiểm tra trạng thái đăng nhập nhanh qua AJAX.
 * ============================================================================
 */

import dao.UserDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Endpoint kiểm tra định kỳ phiên đăng nhập của người dùng.
 * Quét kiểm tra xem tài khoản có bị đổi mật khẩu hoặc bị khóa từ trình duyệt khác không.
 */
@WebServlet("/check-auth")
public class CheckAuthServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.getWriter().write("{\"loggedIn\":false,\"reason\":\"no_session\"}");
            return;
        }

        Object userObj = session.getAttribute("USER_LOGIN");
        if (!(userObj instanceof User)) {
            response.getWriter().write("{\"loggedIn\":false,\"reason\":\"not_logged_in\"}");
            return;
        }

        User sessionUser = (User) userObj;
        User latestUser = userDao.getById(sessionUser.getId());

        if (latestUser == null) {
            session.removeAttribute("USER_LOGIN");
            session.invalidate();
            response.getWriter().write("{\"loggedIn\":false,\"reason\":\"deleted\"}");
            return;
        }

        if (!sessionUser.isAdmin() && latestUser.isLocked()) {
            session.removeAttribute("USER_LOGIN");
            session.invalidate();
            response.getWriter().write("{\"loggedIn\":false,\"reason\":\"account_locked\"}");
            return;
        }

        // Kiểm tra xem mật khẩu có bị đổi ở trình duyệt khác không
        if (sessionUser.getPasswordHash() != null && latestUser.getPasswordHash() != null
                && !sessionUser.getPasswordHash().equals(latestUser.getPasswordHash())) {
            session.removeAttribute("USER_LOGIN");
            session.invalidate();
            response.getWriter().write("{\"loggedIn\":false,\"reason\":\"password_changed\"}");
            return;
        }

        response.getWriter().write("{\"loggedIn\":true}");
    }
}
