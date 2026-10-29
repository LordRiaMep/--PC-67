package Controller.Cilent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;

import java.io.IOException;

@WebServlet("/remove-from-cart")
public class RemoveCartServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pageParam = request.getParameter("page");
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String key = request.getParameter("key");
            if (key == null) key = "";

            HttpSession session = request.getSession();
            Cart cart = (Cart) session.getAttribute("cart");

            if (cart != null) {
                cart.removeItem(id, key);
                session.setAttribute("cart", cart);

                model.User loginUser = (model.User) session.getAttribute("USER_LOGIN");
                if (loginUser != null) {
                    new dao.CartDao().saveCart(loginUser.getId(), cart);
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
