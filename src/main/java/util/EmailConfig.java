package util;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Cấu hình tài khoản gửi mail SMTP.
 * ============================================================================
 */

/**
 * Cấu hình hệ thống Email cho ứng dụng Độ-PC 67
 * Sử dụng Brevo SMTP Relay chính thức
 */
public class EmailConfig {

    // =========================================================================
    // CẤU HÌNH BREVO SMTP RELAY (ĐÃ KÍCH HOẠT CHẠY THẬT)
    // =========================================================================
    public static final String SMTP_HOST = "smtp-relay.brevo.com";
    public static final int SMTP_PORT = 465; // Cổng 465 SSL bảo mật

    // Tài khoản đăng nhập SMTP Brevo (hỗ trợ đọc từ biến môi trường hoặc key mặc định)
    public static String SMTP_USERNAME = System.getenv("SMTP_USERNAME") != null ? System.getenv("SMTP_USERNAME") : "bdbd76001@smtp-brevo.com";
    public static String SMTP_PASSWORD = System.getenv("SMTP_PASSWORD") != null ? System.getenv("SMTP_PASSWORD") : "YOUR_BREVO_SMTP_KEY";

    // Địa chỉ email và tên hiển thị người gửi
    public static String SENDER_EMAIL = "dopc6767@gmail.com";
    public static String SENDER_NAME = "Độ-PC 67 Store";

    // =========================================================================
    // CHẾ ĐỘ HOẠT ĐỘNG
    // =========================================================================
    // Tắt hoàn toàn chế độ Demo - Gửi thư THẬT 100% đến hòm thư người dùng
    public static boolean DEV_MODE = false;
}
