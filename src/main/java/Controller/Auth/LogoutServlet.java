package Controller.Auth;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Xử lý đăng xuất và hủy phiên làm việc.
 * ============================================================================
 */

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            model.User loginUser = (model.User) session.getAttribute("USER_LOGIN");
            model.Cart cart = (model.Cart) session.getAttribute("cart");
            if (loginUser != null && cart != null) {
                new dao.CartDao().saveCart(loginUser.getId(), cart);
            }
            session.removeAttribute("USER_LOGIN");
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/Home");
    }
}