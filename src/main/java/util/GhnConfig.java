package util;

/**
 * ============================================================================
 * [PHÂN HỆ 4: GIỎ HÀNG, ĐỘNG CƠ VOUCHER & VẬN CHUYỂN GHN]
 * Phụ trách: Bảo
 * Chức năng: Cấu hình API Token, Shop ID kết nối Giao Hàng Nhanh.
 * ============================================================================
 */

/**
 * Cấu hình API Giao Hàng Nhanh (GHN)
 */
public class GhnConfig {
    // API Token của shop
    public static final String API_TOKEN = "8bc2f3c9-5646-43e9-8665-627aedff1253";

    // Shop ID đăng ký trên GHN
    public static final int SHOP_ID = 6715571;

    // Kho gửi hàng: Cửa hàng Độ PC 67 - Phường Đông Hải 1, Quận Hải An, TP Hải Phòng
    public static final int FROM_DISTRICT_ID = 1591;
    public static final String FROM_WARD_CODE = "30504";

    // Endpoint GHN API Production
    public static final String API_PROVINCE = "https://online-gateway.ghn.vn/shiip/public-api/master-data/province";
    public static final String API_DISTRICT = "https://online-gateway.ghn.vn/shiip/public-api/master-data/district";
    public static final String API_WARD = "https://online-gateway.ghn.vn/shiip/public-api/master-data/ward";
    public static final String API_FEE = "https://online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/fee";
}
