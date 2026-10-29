package Controller.Cilent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.LoginRedirect;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

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

        int pageSize = 5;
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }

        int totalItems = (cart != null && cart.getItems() != null) ? cart.getItems().size() : 0;
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }
        if (page < 1) {
            page = 1;
        }

        List<model.CartItem> pageItems = new ArrayList<>();
        if (cart != null && totalItems > 0) {
            int fromIndex = (page - 1) * pageSize;
            int toIndex = Math.min(fromIndex + pageSize, totalItems);
            if (fromIndex < totalItems) {
                pageItems = cart.getItems().subList(fromIndex, toIndex);
            }
        }

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        request.setAttribute("cartItems", pageItems);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        request.getRequestDispatcher("/view/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
