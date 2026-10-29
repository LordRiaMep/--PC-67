package Controller.Cilent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;

import java.io.IOException;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        if (session.getAttribute("USER_LOGIN") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null || cart.getItems().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        dao.ProductDao productDao = new dao.ProductDao();
        java.util.Map<Integer, Integer> productQtyMap = new java.util.HashMap<>();
        for (model.CartItem item : cart.getItems()) {
            if (item.getProduct() != null) {
                int pid = item.getProduct().getId();
                productQtyMap.merge(pid, item.getQuantity(), Integer::sum);
            }
        }

        for (java.util.Map.Entry<Integer, Integer> entry : productQtyMap.entrySet()) {
            int pid = entry.getKey();
            int requestedQty = entry.getValue();
            model.Product p = productDao.getProductById(pid);

            if (p == null || p.getQuantity() <= 0) {
                String pName = (p != null) ? p.getName() : "Sản phẩm";
                session.setAttribute("error", "Sản phẩm \"" + pName + "\" hiện đã hết hàng trong kho. Vui lòng xóa khỏi giỏ để tiếp tục!");
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }

            if (requestedQty > p.getQuantity()) {
                session.setAttribute("error", "Sản phẩm \"" + p.getName() + "\" chỉ còn " + p.getQuantity() + " bộ trong kho (giỏ hàng của bạn đang có " + requestedQty + " bộ). Vui lòng cập nhật lại số lượng!");
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }
        }

        dao.VoucherDao voucherDao = new dao.VoucherDao();
        request.setAttribute("voucherList", voucherDao.getAvailableVouchersForDisplay());

        String sessionVoucherCode = (String) session.getAttribute("APPLIED_VOUCHER");
        if (sessionVoucherCode != null && !sessionVoucherCode.trim().isEmpty()) {
            model.Voucher appliedVoucher = voucherDao.getByCode(sessionVoucherCode);
            if (appliedVoucher != null && appliedVoucher.isUsableNow()) {
                request.setAttribute("appliedVoucher", appliedVoucher);
            } else {
                session.removeAttribute("APPLIED_VOUCHER");
            }
        }

        request.getRequestDispatcher("/view/checkout.jsp").forward(request, response);
    }
}
