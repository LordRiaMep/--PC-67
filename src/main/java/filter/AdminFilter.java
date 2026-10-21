package filter;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Bộ lọc bảo mật: Chặn người dùng không có quyền truy cập /admin.
 * ============================================================================
 */

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Filter bảo vệ toàn bộ khu vực /admin/*
 * Chỉ cho phép người dùng có quyền ADMIN truy cập.
 */
@WebFilter(urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        Object loggedInUser = (session != null) ? session.getAttribute("USER_LOGIN") : null;

        // 1. Chưa đăng nhập -> Chuyển về trang đăng nhập
        if (loggedInUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 2. Đã đăng nhập nhưng không phải ADMIN -> Chặn quyền và đưa về trang chủ
        if (!(loggedInUser instanceof User) || !((User) loggedInUser).isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/Home");
            return;
        }

        chain.doFilter(request, response);
    }
}