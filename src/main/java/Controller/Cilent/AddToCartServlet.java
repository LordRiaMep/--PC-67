package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 4: GIỎ HÀNG, ĐỘNG CƠ VOUCHER & VẬN CHUYỂN GHN]
 * Phụ trách: Bảo
 * Chức năng: Xử lý thêm sản phẩm kèm các tùy chọn nâng cấp linh kiện vào giỏ hàng.
 * ============================================================================
 */

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
        HttpSession session = request.getSession();
        if (session.getAttribute("USER_LOGIN") == null) {
            LoginRedirect.redirectToLoginBack(request, response);
            return;
        }
        int productId = Integer.parseInt(request.getParameter("id"));
        String qtyParam = request.getParameter("quantity");
        int quantity = (qtyParam != null && !qtyParam.isEmpty()) ? Integer.parseInt(qtyParam) : 1;
        if (quantity < 1) quantity = 1;

        ProductDao dao = new ProductDao();
        Product product = dao.getProductById(productId);

        if (product != null) {
            if (product.getQuantity() <= 0) {
                session.setAttribute("error", "Sản phẩm \"" + product.getName() + "\" hiện đã hết hàng!");
                response.sendRedirect(request.getContextPath() + "/detail?id=" + productId);
                return;
            }
            // ---- Xử lý linh kiện nâng cấp: giá và tên luôn tính lại ở server ----
            UpgradeDao upgradeDao = new UpgradeDao();
            Map<String, UpgradeOption> chosenByGroup = new LinkedHashMap<>();
            String[] upgradeIds = request.getParameterValues("upgradeId");
            if (upgradeIds != null) {
                for (String s : upgradeIds) {
                    try {
                        UpgradeOption o = upgradeDao.getByIdAndProduct(Integer.parseInt(s), productId);
                        // bỏ qua linh kiện mặc định; mỗi nhóm chỉ nhận 1 lựa chọn
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

            // kiểm tra tồn kho theo tổng số lượng của sản phẩm
            int inCart = cart.getTotalQuantityOfProduct(productId);
            if (inCart + quantity > product.getQuantity()) {
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

            // Lưu mã voucher đã chọn vào session để áp dụng khi thanh toán
            String voucherCode = request.getParameter("voucherCode");
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                session.setAttribute("APPLIED_VOUCHER", voucherCode.trim().toUpperCase());
            }
        }

        // nút ĐẶT HÀNG gửi thêm buyNow=1 -> vào thẳng trang thanh toán
        if ("1".equals(request.getParameter("buyNow"))) {
            response.sendRedirect(request.getContextPath() + "/checkout");
        } else {
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }
}
