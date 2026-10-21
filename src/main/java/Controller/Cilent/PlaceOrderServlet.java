package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Khởi tạo đơn hàng mới, kiểm tra tồn kho, trừ voucher và điều hướng thanh toán.
 * ============================================================================
 */

import dao.OrderDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;
import model.User;
import util.GhnService;

import java.io.IOException;

@WebServlet("/place-order")
public class PlaceOrderServlet extends HttpServlet {

    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        User user = (User) session.getAttribute("USER_LOGIN");

        if (user == null || cart == null || cart.getItems().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        try {
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            String note = request.getParameter("note");
            String paymentMethod = request.getParameter("paymentMethod");
            if (!"QR".equals(paymentMethod)) paymentMethod = "COD";   // chặn giá trị lạ

            // Đọc thông tin địa chỉ GHN
            String provinceName = request.getParameter("provinceName");
            String districtName = request.getParameter("districtName");
            String wardName = request.getParameter("wardName");
            String detailAddress = request.getParameter("detailAddress");

            int districtId = 0;
            try {
                districtId = Integer.parseInt(request.getParameter("districtId"));
            } catch (Exception ignored) {}
            String wardCode = request.getParameter("wardCode");

            // Ghép địa chỉ đầy đủ
            String fullAddress;
            if (detailAddress != null && !detailAddress.trim().isEmpty()
                    && provinceName != null && !provinceName.trim().isEmpty()) {
                fullAddress = detailAddress.trim();
                if (wardName != null && !wardName.trim().isEmpty()) fullAddress += ", " + wardName.trim();
                if (districtName != null && !districtName.trim().isEmpty()) fullAddress += ", " + districtName.trim();
                fullAddress += ", " + provinceName.trim();
            } else {
                fullAddress = request.getParameter("address");
            }

            if (fullAddress == null || fullAddress.trim().isEmpty()) {
                fullAddress = "Chưa cung cấp địa chỉ";
            }

            // Tính và kiểm tra phí vận chuyển GHN phía backend (chống sửa giá client-side)
            double shippingFee = 0.0;
            if (districtId > 0 && wardCode != null && !wardCode.trim().isEmpty()) {
                shippingFee = GhnService.calculateShippingFee(districtId, wardCode, 1000);
            } else {
                try {
                    shippingFee = Double.parseDouble(request.getParameter("shippingFee"));
                } catch (Exception ignored) {
                    shippingFee = 30000.0; // Phí dự phòng
                }
            }

            // Đọc và xác thực Voucher giảm giá chặt chẽ từ Database backend (chống sửa giá từ client)
            String voucherCode = request.getParameter("voucherCode");
            if (voucherCode == null || voucherCode.trim().isEmpty()) {
                voucherCode = (String) session.getAttribute("APPLIED_VOUCHER");
            }

            double discountAmount = 0.0;
            String validVoucherCode = null;
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                dao.VoucherDao vDao = new dao.VoucherDao();
                model.Voucher v = vDao.getByCode(voucherCode.trim());
                if (v != null && v.isApplicableFor(cart.getTotalMoney())) {
                    discountAmount = v.calculateDiscount(cart.getTotalMoney());
                    validVoucherCode = v.getCode();
                }
            }

            // Kiểm tra tồn kho thời gian thực cho từng sản phẩm trong giỏ hàng
            dao.ProductDao productDao = new dao.ProductDao();
            java.util.Map<Integer, Integer> productQtyMap = new java.util.HashMap<>();
            for (model.CartItem item : cart.getItems()) {
                if (item.getProduct() != null) {
                    productQtyMap.merge(item.getProduct().getId(), item.getQuantity(), Integer::sum);
                }
            }

            for (java.util.Map.Entry<Integer, Integer> entry : productQtyMap.entrySet()) {
                int pid = entry.getKey();
                int requestedQty = entry.getValue();
                model.Product p = productDao.getProductById(pid);

                if (p == null || p.getQuantity() <= 0) {
                    String pName = (p != null) ? p.getName() : "Sản phẩm";
                    session.setAttribute("error", "Sản phẩm \"" + pName + "\" hiện đã hết hàng trong kho! Không thể hoàn tất đơn hàng.");
                    response.sendRedirect(request.getContextPath() + "/cart");
                    return;
                }

                if (requestedQty > p.getQuantity()) {
                    session.setAttribute("error", "Sản phẩm \"" + p.getName() + "\" không đủ số lượng trong kho (chỉ còn " + p.getQuantity() + " bộ). Vui lòng cập nhật lại giỏ hàng!");
                    response.sendRedirect(request.getContextPath() + "/cart");
                    return;
                }
            }

            int orderId = orderDao.saveOrder(user.getId(), name, phone, fullAddress, note, cart, paymentMethod, shippingFee, validVoucherCode, discountAmount);
            if (orderId > 0) {
                double finalTotal = Math.max(0, cart.getTotalMoney() - discountAmount) + shippingFee;
                util.realtime.RealtimeHub.broadcastOrderCreated(orderId, user.getId(), name, user.getEmail(), finalTotal, paymentMethod, discountAmount);

                session.removeAttribute("cart");
                session.removeAttribute("APPLIED_VOUCHER");
                new dao.CartDao().clearCart(user.getId());

                if ("QR".equals(paymentMethod)) {
                    // Thanh toán online: chuyển sang VNPay (đơn đang ở trạng thái UNPAID)
                    response.sendRedirect(request.getContextPath() + "/vnpay-pay?id=" + orderId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/order-detail?id=" + orderId);
                }
            } else {
                if (session.getAttribute("error") == null) {
                    session.setAttribute("error", "Không thể hoàn tất đặt hàng vì sản phẩm đã hết hàng hoặc không đủ số lượng!");
                }
                response.sendRedirect(request.getContextPath() + "/cart");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Đã xảy ra lỗi trong quá trình xử lý đơn hàng: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }
}
