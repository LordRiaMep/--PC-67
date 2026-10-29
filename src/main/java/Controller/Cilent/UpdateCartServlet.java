package Controller.Cilent;

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
        String pageParam = request.getParameter("page");
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

        String redirectUrl = request.getContextPath() + "/cart";
        if (pageParam != null && !pageParam.isEmpty()) {
            redirectUrl += "?page=" + pageParam;
        }
        response.sendRedirect(redirectUrl);
    }
}
