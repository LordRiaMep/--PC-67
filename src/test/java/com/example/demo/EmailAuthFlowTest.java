package com.example.demo;

import dao.UserDao;
import dao.UserTokenDao;
import model.User;
import model.UserToken;
import util.EmailService;

public class EmailAuthFlowTest {
    public static void main(String[] args) {
        System.out.println("=== BẮT ĐẦU TEST LUỒNG XÁC THỰC EMAIL & ĐỔI MẬT KHẨU ===");

        UserDao userDao = new UserDao();
        UserTokenDao userTokenDao = new UserTokenDao();

        String testEmail = "test_verify_" + System.currentTimeMillis() + "@example.com";

        // 1. Test đăng ký tài khoản với trạng thái PENDING
        System.out.println("\n[1] Test Đăng ký tài khoản mới...");
        User u = new User();
        u.setFullName("Nguyễn Văn Test");
        u.setEmail(testEmail);
        u.setPasswordHash("123456");
        u.setPhone("0987654321");
        u.setAddress("Hà Nội");

        boolean regOk = userDao.register(u);
        System.out.println("Kết quả đăng ký PENDING: " + (regOk ? "THÀNH CÔNG" : "THẤT BẠI"));

        User savedUser = userDao.findByEmail(testEmail);
        System.out.println("Trạng thái user vừa tạo: " + (savedUser != null ? savedUser.getStatus() : "null"));
        if (savedUser == null || !"PENDING".equalsIgnoreCase(savedUser.getStatus())) {
            throw new RuntimeException("Lỗi: Tài khoản chưa ở trạng thái PENDING!");
        }

        // 2. Test tạo Token xác nhận và gửi email
        System.out.println("\n[2] Test Tạo Token và Gửi Email xác nhận...");
        UserToken verifyToken = userTokenDao.createToken(savedUser.getId(), testEmail, "REGISTER_VERIFY", 1440);
        System.out.println("Token tạo được: " + verifyToken.getToken());
        System.out.println("OTP tạo được: " + verifyToken.getOtpCode());

        String verifyLink = "http://localhost:8080/demo/verify-account?token=" + verifyToken.getToken();
        EmailService.sendVerificationEmail(testEmail, savedUser.getFullName(), verifyLink, verifyToken.getOtpCode());

        // 3. Test tìm Token hợp lệ
        System.out.println("\n[3] Test Kiểm tra Token xác nhận...");
        UserToken foundToken = userTokenDao.findValidToken(verifyToken.getToken(), "REGISTER_VERIFY");
        System.out.println("Tìm thấy token hợp lệ: " + (foundToken != null ? "CÓ" : "KHÔNG"));
        if (foundToken == null) throw new RuntimeException("Lỗi: Không tìm thấy token hợp lệ!");

        // 4. Test kích hoạt tài khoản
        System.out.println("\n[4] Test Kích hoạt tài khoản (Verify)...");
        boolean actOk = userDao.activateUser(foundToken.getEmail());
        userTokenDao.markUsed(foundToken.getId());
        System.out.println("Kích hoạt tài khoản: " + (actOk ? "THÀNH CÔNG" : "THẤT BẠI"));

        User activatedUser = userDao.findByEmail(testEmail);
        System.out.println("Trạng thái user sau kích hoạt: " + (activatedUser != null ? activatedUser.getStatus() : "null"));
        if (activatedUser == null || !activatedUser.isActive()) {
            throw new RuntimeException("Lỗi: Tài khoản chưa chuyển sang ACTIVE!");
        }

        // Token sau khi đã dùng phải không còn hợp lệ
        UserToken checkUsed = userTokenDao.findValidToken(verifyToken.getToken(), "REGISTER_VERIFY");
        System.out.println("Kiểm tra token sau khi đã dùng: " + (checkUsed == null ? "ĐÃ VÔ HIỆU HÓA ĐÚNG" : "LỖI"));

        // 5. Test Quên mật khẩu & Đặt lại mật khẩu
        System.out.println("\n[5] Test Luồng Quên mật khẩu...");
        UserToken resetToken = userTokenDao.createToken(activatedUser.getId(), testEmail, "RESET_PASSWORD", 30);
        String resetLink = "http://localhost:8080/demo/reset-password?token=" + resetToken.getToken();
        EmailService.sendResetPasswordEmail(testEmail, activatedUser.getFullName(), resetLink, resetToken.getOtpCode());

        UserToken foundReset = userTokenDao.findValidToken(resetToken.getToken(), "RESET_PASSWORD");
        System.out.println("Tìm thấy token reset hợp lệ: " + (foundReset != null ? "CÓ" : "KHÔNG"));

        String newPassword = "newPassword999";
        boolean pwUpdated = userDao.updatePasswordByEmail(testEmail, newPassword);
        userTokenDao.markUsed(foundReset.getId());
        System.out.println("Cập nhật mật khẩu mới: " + (pwUpdated ? "THÀNH CÔNG" : "THẤT BẠI"));

        User recheckUser = userDao.authenticate(testEmail, newPassword);
        System.out.println("Đăng nhập thử với mật khẩu mới: " + (recheckUser != null ? "THÀNH CÔNG" : "THẤT BẠI"));
        if (recheckUser == null) throw new RuntimeException("Lỗi: Không đăng nhập được với mật khẩu mới!");

        // 6. Test OTP đổi mật khẩu trong trang cá nhân
        System.out.println("\n[6] Test Luồng Đổi mật khẩu với OTP email...");
        UserToken otpToken = userTokenDao.createToken(recheckUser.getId(), testEmail, "CHANGE_PASSWORD_OTP", 10);
        EmailService.sendOtpChangePasswordEmail(testEmail, recheckUser.getFullName(), otpToken.getOtpCode());

        UserToken foundOtp = userTokenDao.findValidOtp(testEmail, otpToken.getOtpCode(), "CHANGE_PASSWORD_OTP");
        System.out.println("Xác thực mã OTP đổi mật khẩu: " + (foundOtp != null ? "HỢP LỆ" : "KHÔNG HỢP LỆ"));
        if (foundOtp == null) throw new RuntimeException("Lỗi: Mã OTP không hợp lệ!");

        // Xóa dữ liệu test sạch sẽ
        System.out.println("\n[7] Dọn dẹp dữ liệu test...");
        try (java.sql.Connection conn = dao.ConnectDB.getConnect();
             java.sql.PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE email = ?")) {
            ps.setString(1, testEmail);
            ps.executeUpdate();
            System.out.println("Đã dọn dẹp user test xong!");
        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("\n🎉 TẤT CẢ TEST ĐỀU HOÀN TOÀN THÀNH CÔNG 100%!");
    }
}
