package filter;

import dao.UserDao;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(urlPatterns = {"/*"})
public class UserStatusFilter implements Filter {

    private final UserDao userDao = new UserDao();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI().substring(req.getContextPath().length());

        if (uri.startsWith("/assets/") || uri.endsWith(".css") || uri.endsWith(".js")
                || uri.endsWith(".png") || uri.endsWith(".jpg") || uri.endsWith(".jpeg")
                || uri.endsWith(".gif") || uri.endsWith(".svg") || uri.endsWith(".ico")
                || uri.endsWith(".mp4") || uri.equals("/check-auth")
                || uri.equals("/login") || uri.equals("/logout") || uri.equals("/register")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null) {
            Object userObj = session.getAttribute("USER_LOGIN");
            if (userObj instanceof User) {
                User sessionUser = (User) userObj;
                User latestUser = userDao.getById(sessionUser.getId());

                if (latestUser == null) {
                    session.removeAttribute("USER_LOGIN");
                    session.invalidate();
                    resp.sendRedirect(req.getContextPath() + "/login?error=need_login");
                    return;
                }

                if (!sessionUser.isAdmin() && latestUser.isLocked()) {
                    session.removeAttribute("USER_LOGIN");
                    session.invalidate();

                    String reason = latestUser.getLockReason();
                    if (reason == null || reason.trim().isEmpty()) {
                        reason = "Tài khoản của bạn đã bị khóa do vi phạm chính sách của hệ thống.";
                    }
                    String encodedReason = URLEncoder.encode(reason, StandardCharsets.UTF_8.name());
                    resp.sendRedirect(req.getContextPath() + "/login?error=account_locked&reason=" + encodedReason);
                    return;
                }

                if (sessionUser.getPasswordHash() != null && latestUser.getPasswordHash() != null
                        && !sessionUser.getPasswordHash().equals(latestUser.getPasswordHash())) {
                    session.removeAttribute("USER_LOGIN");
                    session.invalidate();
                    resp.sendRedirect(req.getContextPath() + "/login?error=password_changed");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }
}
