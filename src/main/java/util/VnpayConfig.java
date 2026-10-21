package util;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Cấu hình tham số kết nối cổng thanh toán VNPay (TMN Code, Hash Secret, URL).
 * ============================================================================
 */

/**
 * Cấu hình VNPay (môi trường SANDBOX).
 * Đăng ký tại https://sandbox.vnpayment.vn/devreg để nhận TMN_CODE và HASH_SECRET qua email.
 */
public class VnpayConfig {
    public static final String TMN_CODE    = "FSL2X0MA";
    public static final String HASH_SECRET = "GITGIKMIOSFPNDEDHCCCBKEMHCTCEVIS";
    public static final String PAY_URL     = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

    // "" = người dùng tự chọn phương thức trên trang VNPay (dễ test bằng thẻ NCB sandbox)
    // "VNPAYQR" = vào thẳng trang quét mã QR
    public static final String BANK_CODE   = "";

    // Số tiền khách phải chuyển qua VNPay (VNĐ).
    //   0      = chuyển đúng tổng tiền đơn hàng
    //   > 0    = chuyển số tiền cố định này cho mọi đơn (ví dụ 10000)
    // Lưu ý: VNPay yêu cầu tối thiểu 5.000đ mỗi giao dịch.
    // Dù số tiền là bao nhiêu, đơn vẫn chỉ được xử lý sau khi admin xác nhận đã nhận đủ tiền.
    public static final long PAY_AMOUNT    = 0;
}
