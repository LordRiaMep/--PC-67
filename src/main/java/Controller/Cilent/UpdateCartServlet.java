package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 4: GIỎ HÀNG, ĐỘNG CƠ VOUCHER & VẬN CHUYỂN GHN]
 * Phụ trách: Bảo
 * Chức năng: Cập nhật số lượng sản phẩm trong giỏ hàng.
 * ============================================================================
 */

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;
import model.Product;
import dao.ProductDao;
import java.io.IOException;

@WebServlet("/update-cart")
public class UpdateCartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("productId"));
            String key = request.getParameter("upgradeKey");
            if (key == null) key = "";
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            HttpSession session = request.getSession();
            Cart cart = (Cart) session.getAttribute("cart");

            if (cart != null && quantity >= 1) {
                ProductDao dao = new ProductDao();
                Product p = dao.getProductById(id);

                // tổng SL của sản phẩm này ở các dòng KHÁC (bản nâng cấp khác) + SL mới
                int others = cart.getTotalQuantityOfProduct(id);
                for (model.CartItem it : cart.getItems()) {
                    if (it.getProduct().getId() == id && it.getUpgradeKey().equals(key)) {
                        others -= it.getQuantity();
                    }
                }

                if (others + quantity > p.getQuantity()) {
                    session.setAttribute("error", "Số sản phẩm phải nhỏ hơn hoặc bằng số sp hiện đang có");
                } else {
                    cart.updateQuantity(id, key, quantity);
                    session.setAttribute("cart", cart);
                    session.removeAttribute("error");

                    model.User loginUser = (model.User) session.getAttribute("USER_LOGIN");
                    if (loginUser != null) {
                        new dao.CartDao().saveCart(loginUser.getId(), cart);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
