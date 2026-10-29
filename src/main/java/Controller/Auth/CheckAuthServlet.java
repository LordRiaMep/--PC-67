package Controller.Auth;

import dao.UserDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

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
