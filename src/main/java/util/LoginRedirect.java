package util;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Điều hướng người dùng về đúng trang trước khi đăng nhập.
 * ============================================================================
 */

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Nhớ trang khách đang xem khi bị bắt đăng nhập, để đăng nhập xong quay lại đúng trang đó.
 */
public class LoginRedirect {

    private static final String KEY = "REDIRECT_AFTER_LOGIN";

    /**
     * Dùng thay cho response.sendRedirect(".../login") ở chỗ bắt đăng nhập.
     * - Yêu cầu GET: nhớ chính địa chỉ đang mở (kể cả ?id=...).
     * - Yêu cầu POST: không mở lại được bằng GET nên nhớ trang trước đó (Referer).
     */
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

    /**
     * Giống trên nhưng luôn quay về trang trước đó (Referer).
     * Hợp cho nút "Thêm vào giỏ" / "Mua ngay" ở trang chi tiết sản phẩm:
     * đăng nhập xong khách về lại trang chi tiết thay vì trang xử lý thêm giỏ hàng.
     */
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

    /**
     * Dành riêng cho giỏ hàng: Khi khách chưa đăng nhập ấn vào giỏ hàng,
     * hệ thống chuyển sang đăng nhập, sau khi đăng nhập xong chuyển về đúng trang khách đang đứng trước đó.
     */
    public static void redirectToLoginFromCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String target = fromReferer(req);
        if (target == null || target.startsWith("/cart") || target.startsWith("/login") || target.startsWith("/register")) {
            target = "/Home";
        }
        save(req, target);
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    /**
     * Gọi trong LoginServlet sau khi đăng nhập thành công (TRƯỚC khi invalidate session nếu có).
     * Trả về đường dẫn nội bộ (bắt đầu bằng "/", không kèm context path) hoặc null nếu không có.
     */
    public static String popTarget(HttpSession session) {
        if (session == null) return null;
        Object o = session.getAttribute(KEY);
        session.removeAttribute(KEY);
        if (o == null) return null;
        String t = o.toString();

        // Chỉ cho phép đường dẫn nội bộ, chặn chuyển hướng ra trang ngoài
        if (!t.startsWith("/") || t.startsWith("//") || t.contains("://") || t.contains("\\")) return null;
        // Không quay lại các trang đăng nhập / đăng ký / đăng xuất
        if (t.startsWith("/login") || t.startsWith("/register") || t.startsWith("/logout")) return null;
        return t;
    }

    private static void save(HttpServletRequest req, String target) {
        if (target != null) {
            req.getSession().setAttribute(KEY, target);
        }
    }

    // Lấy đường dẫn nội bộ từ header Referer (chỉ nhận nếu cùng host + context path)
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
