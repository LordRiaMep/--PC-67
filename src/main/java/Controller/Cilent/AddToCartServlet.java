package Controller.Cilent;

import dao.ProductDao;
import dao.UpgradeDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;
import model.CartItem;
import model.Product;
import model.UpgradeOption;
import util.LoginRedirect;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/add-to-cart")
public class AddToCartServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        boolean isAjax = "1".equals(request.getParameter("ajax"))
                || "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));

        HttpSession session = request.getSession();
        if (session.getAttribute("USER_LOGIN") == null) {
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"requireLogin\":true,\"loginUrl\":\""
                        + request.getContextPath() + "/login?error=need_login\"}");
                return;
            }
            LoginRedirect.redirectToLoginBack(request, response);
            return;
        }
        int productId = Integer.parseInt(request.getParameter("id"));
        String qtyParam = request.getParameter("quantity");
        int quantity = (qtyParam != null && !qtyParam.isEmpty()) ? Integer.parseInt(qtyParam) : 1;
        if (quantity < 1) quantity = 1;

        ProductDao dao = new ProductDao();
        Product product = dao.getProductById(productId);

        if (product == null) {
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy sản phẩm!\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/Home");
            return;
        }

        if (product != null) {
            if (product.getQuantity() <= 0) {
                if (isAjax) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Sản phẩm này hiện đã hết hàng!\"}");
                    return;
                }
                session.setAttribute("error", "Sản phẩm \"" + product.getName() + "\" hiện đã hết hàng!");
                response.sendRedirect(request.getContextPath() + "/detail?id=" + productId);
                return;
            }

            UpgradeDao upgradeDao = new UpgradeDao();
            Map<String, UpgradeOption> chosenByGroup = new LinkedHashMap<>();
            String[] upgradeIds = request.getParameterValues("upgradeId");
            if (upgradeIds != null) {
                for (String s : upgradeIds) {
                    try {
                        UpgradeOption o = upgradeDao.getByIdAndProduct(Integer.parseInt(s), productId);

                        if (o != null && !o.isDefaultOption()) {
                            chosenByGroup.put(o.getGroupName(), o);
                        }
                    } catch (NumberFormatException ignored) {}
                }
            }

            DecimalFormat df = new DecimalFormat("#,##0");
            double unitPrice = product.getPrice();
            List<Integer> ids = new ArrayList<>();
            List<String> infoLines = new ArrayList<>();
            List<String> shortNames = new ArrayList<>();
            for (UpgradeOption o : chosenByGroup.values()) {
                unitPrice += o.getPriceDelta();
                ids.add(o.getId());
                if (o.getPriceDelta() > 0) {
                    infoLines.add(o.getGroupName() + ": " + o.getName() + " (+" + df.format(o.getPriceDelta()) + " đ)");
                } else if (o.getPriceDelta() < 0) {
                    infoLines.add(o.getGroupName() + ": " + o.getName() + " (" + df.format(o.getPriceDelta()) + " đ)");
                } else {
                    infoLines.add(o.getGroupName() + ": " + o.getName());
                }
                shortNames.add(o.getName());
            }
            ids.sort(Integer::compare);
            String upgradeKey = ids.stream().map(String::valueOf).collect(Collectors.joining(","));
            String upgradeInfo = String.join("|", infoLines);
            String displayName = product.getName();
            if (!shortNames.isEmpty()) {
                displayName += " (" + String.join(" - ", shortNames) + ")";
            }

            Cart cart = (Cart) session.getAttribute("cart");
            if (cart == null) {
                cart = new Cart();
            }

            int inCart = cart.getTotalQuantityOfProduct(productId);
            if (inCart + quantity > product.getQuantity()) {
                if (isAjax) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Bạn đã có " + inCart + " bộ trong giỏ hàng. Kho chỉ còn " + product.getQuantity() + " bộ!\"}");
                    return;
                }
                session.setAttribute("error", "Sản phẩm \"" + product.getName() + "\" chỉ còn " + product.getQuantity() + " bộ.");
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }

            cart.addItem(new CartItem(product, quantity, upgradeKey, upgradeInfo, displayName, unitPrice));
            session.setAttribute("cart", cart);

            model.User loginUser = (model.User) session.getAttribute("USER_LOGIN");
            if (loginUser != null) {
                new dao.CartDao().saveCart(loginUser.getId(), cart);
            }

            String voucherCode = request.getParameter("voucherCode");
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                session.setAttribute("APPLIED_VOUCHER", voucherCode.trim().toUpperCase());
            }

            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                int totalCount = cart.getTotalQuantity();
                String safeName = (product.getName() == null ? "" : product.getName())
                        .replace("\\", "\\\\")
                        .replace("\"", "\\\"")
                        .replace("\r", "")
                        .replace("\n", " ");
                response.getWriter().write("{\"success\":true,\"cartCount\":" + totalCount + ",\"productName\":\"" + safeName + "\"}");
                return;
            }
        }

        if ("1".equals(request.getParameter("buyNow"))) {
            response.sendRedirect(request.getContextPath() + "/checkout");
        } else {
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
