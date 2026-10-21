package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 4: GIỎ HÀNG, ĐỘNG CƠ VOUCHER & VẬN CHUYỂN GHN]
 * Phụ trách: Bảo
 * Chức năng: Hiển thị trang giỏ hàng của người dùng.
 * ============================================================================
 */

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.LoginRedirect;
import java.io.IOException;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("USER_LOGIN") == null) {
            LoginRedirect.redirectToLoginFromCart(request, response);
            return;
        }

        model.Cart cart = (model.Cart) session.getAttribute("cart");
        if (cart != null) {
            dao.ProductDao pDao = new dao.ProductDao();
            for (model.CartItem it : cart.getItems()) {
                if (it.getProduct() != null) {
                    model.Product fresh = pDao.getProductById(it.getProduct().getId());
                    if (fresh != null) {
                        it.getProduct().setQuantity(fresh.getQuantity());
                        it.getProduct().setStatus(fresh.getStatus());
                    }
                }
            }
        }

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        request.getRequestDispatcher("/view/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}