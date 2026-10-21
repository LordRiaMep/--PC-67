package dao;

/**
 * ============================================================================
 * [PHÂN HỆ 5: QUẢN TRỊ TÀI KHOẢN, XÁC THỰC EMAIL & BẢO MẬT]
 * Phụ trách: Phong
 * Chức năng: Thao tác CSDL: Tạo token, mã OTP kích hoạt tài khoản và quên mật khẩu.
 * ============================================================================
 */

import model.UserToken;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Random;
import java.util.UUID;

public class UserTokenDao {

    private UserToken mapToken(ResultSet rs) throws Exception {
        UserToken t = new UserToken();
        t.setId(rs.getInt("id"));
        int uid = rs.getInt("user_id");
        if (!rs.wasNull()) {
            t.setUserId(uid);
        }
        t.setEmail(rs.getString("email"));
        t.setToken(rs.getString("token"));
        t.setOtpCode(rs.getString("otp_code"));
        t.setType(rs.getString("type"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        t.setExpiresAt(rs.getTimestamp("expires_at"));
        t.setUsed(rs.getBoolean("is_used"));
        return t;
    }

    /**
     * Tạo mã token mới (kèm mã OTP 6 chữ số), vô hiệu hóa các mã cũ cùng loại của email này
     */
    public UserToken createToken(Integer userId, String email, String type, int durationMinutes) {
        if (email == null || email.trim().isEmpty()) return null;
        String cleanEmail = email.trim();

        // 1. Vô hiệu hóa token cũ chưa dùng cùng loại
        invalidateExisting(cleanEmail, type);

        // 2. Tạo token ngẫu nhiên và mã OTP 6 chữ số
        String token = UUID.randomUUID().toString().replace("-", "");
        String otpCode = String.format("%06d", 100000 + new Random().nextInt(900000));

        String sql = "INSERT INTO user_tokens (user_id, email, token, otp_code, type, created_at, expires_at, is_used) "
                   + "VALUES (?, ?, ?, ?, ?, GETDATE(), DATEADD(minute, ?, GETDATE()), 0)";

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            if (userId != null && userId > 0) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setString(2, cleanEmail);
            ps.setString(3, token);
            ps.setString(4, otpCode);
            ps.setString(5, type);
            ps.setInt(6, durationMinutes > 0 ? durationMinutes : 15);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int id = rs.getInt(1);
                        return getById(id);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public UserToken getById(int id) {
        String sql = "SELECT * FROM user_tokens WHERE id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapToken(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tìm token hợp lệ (chưa dùng và chưa hết hạn)
     */
    public UserToken findValidToken(String token, String type) {
        if (token == null || token.trim().isEmpty()) return null;
        String sql = "SELECT * FROM user_tokens WHERE token = ? AND type = ? AND is_used = 0 AND expires_at > GETDATE()";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.trim());
            ps.setString(2, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapToken(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tìm mã OTP hợp lệ theo email và loại
     */
    public UserToken findValidOtp(String email, String otpCode, String type) {
        if (email == null || otpCode == null) return null;
        String sql = "SELECT * FROM user_tokens WHERE email = ? AND otp_code = ? AND type = ? AND is_used = 0 AND expires_at > GETDATE()";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            ps.setString(2, otpCode.trim());
            ps.setString(3, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapToken(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Đánh dấu token đã được sử dụng
     */
    public boolean markUsed(int id) {
        String sql = "UPDATE user_tokens SET is_used = 1 WHERE id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Đánh dấu token đã được sử dụng theo chuỗi token
     */
    public boolean markUsedByToken(String token) {
        if (token == null) return false;
        String sql = "UPDATE user_tokens SET is_used = 1 WHERE token = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Vô hiệu hóa token cũ chưa dùng
     */
    public boolean invalidateExisting(String email, String type) {
        String sql = "UPDATE user_tokens SET is_used = 1 WHERE email = ? AND type = ? AND is_used = 0";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            ps.setString(2, type);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
