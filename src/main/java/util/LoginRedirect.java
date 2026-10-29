package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class LoginRedirect {

    private static final String KEY = "REDIRECT_AFTER_LOGIN";

    public static void redirectToLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String target = null;
        if ("GET".equalsIgnoreCase(req.getMethod())) {
            String path = req.getRequestURI().substring(req.getContextPath().length());
            String qs = req.getQueryString();
            target = (qs == null) ? path : path + "?" + qs;
        } else {
            target = fromReferer(req);
        }
        save(req, target);
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    public static void redirectToLoginBack(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String target = fromReferer(req);
        if (target == null && "GET".equalsIgnoreCase(req.getMethod())) {
            String path = req.getRequestURI().substring(req.getContextPath().length());
            String qs = req.getQueryString();
            target = (qs == null) ? path : path + "?" + qs;
        }
        save(req, target);
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    public static void redirectToLoginFromCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String target = fromReferer(req);
        if (target == null || target.startsWith("/cart") || target.startsWith("/login") || target.startsWith("/register")) {
            target = "/Home";
        }
        save(req, target);
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    public static String popTarget(HttpSession session) {
        if (session == null) return null;
        Object o = session.getAttribute(KEY);
        session.removeAttribute(KEY);
        if (o == null) return null;
        String t = o.toString();

        if (!t.startsWith("/") || t.startsWith("//") || t.contains("://") || t.contains("\\")) return null;

        if (t.startsWith("/login") || t.startsWith("/register") || t.startsWith("/logout")) return null;
        return t;
    }

    private static void save(HttpServletRequest req, String target) {
        if (target != null) {
            req.getSession().setAttribute(KEY, target);
        }
    }

    private static String fromReferer(HttpServletRequest req) {
        String ref = req.getHeader("Referer");
        if (ref == null) return null;
        int port = req.getServerPort();
        boolean defaultPort = ("http".equals(req.getScheme()) && port == 80)
                || ("https".equals(req.getScheme()) && port == 443);
        String base = req.getScheme() + "://" + req.getServerName()
                + (defaultPort ? "" : ":" + port) + req.getContextPath();
        if (!ref.startsWith(base)) return null;
        String path = ref.substring(base.length());
        return path.isEmpty() ? "/" : path;
    }
}
