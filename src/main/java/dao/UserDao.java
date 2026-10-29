package dao;

import model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDao {
    private User mapUser(ResultSet rs) throws Exception {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        try { u.setPasswordHash(rs.getString("password_hash")); } catch (Exception ignored) {}
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setRole(rs.getString("role"));
        u.setStatus(rs.getString("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        try { u.setLockReason(rs.getString("lock_reason")); } catch (Exception ignored) {}
        try { u.setLockedAt(rs.getTimestamp("locked_at")); } catch (Exception ignored) {}
        try { u.setLockedBy(rs.getString("locked_by")); } catch (Exception ignored) {}
        return u;
    }

    public User authenticate(String email, String password) {
        String sql = "SELECT * FROM users WHERE email=? AND password_hash=?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email != null ? email.trim() : "");
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public User checkLogin(String email, String password) {
        return authenticate(email, password);
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email=?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email != null ? email.trim() : "");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean register(User user) {
        return registerWithStatus(user, "PENDING");
    }

    public boolean registerWithStatus(User user, String status) {
        String sql = "INSERT INTO users (full_name, email, password_hash, phone, address, status, role) VALUES (?, ?, ?, ?, ?, ?, 'CUSTOMER')";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail() != null ? user.getEmail().trim() : "");
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, status != null ? status : "PENDING");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        user.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean updatePendingUser(User user) {
        String sql = "UPDATE users SET full_name=?, password_hash=?, phone=?, address=? WHERE email=? AND status='PENDING'";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPasswordHash());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getAddress());
            ps.setString(5, user.getEmail() != null ? user.getEmail().trim() : "");
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean activateUser(String email) {
        String sql = "UPDATE users SET status='ACTIVE' WHERE email=? AND status='PENDING'";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email != null ? email.trim() : "");
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public List<User> getAllUsers() {
        return searchUsers(null, null, null);
    }

    public List<User> searchUsers(String keyword, String status, String role) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql.append("AND status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (role != null && !role.trim().isEmpty() && !"ALL".equalsIgnoreCase(role.trim())) {
            sql.append("AND role = ? ");
            params.add(role.trim().toUpperCase());
        }

        sql.append("ORDER BY id DESC");

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public java.util.Map<String, Integer> getUserCounts() {
        java.util.Map<String, Integer> counts = new java.util.HashMap<>();
        counts.put("total", 0);
        counts.put("active", 0);
        counts.put("locked", 0);
        counts.put("pending", 0);
        counts.put("admin", 0);

        String sql = "SELECT "
                + "COUNT(*) AS total, "
                + "SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active, "
                + "SUM(CASE WHEN status = 'LOCKED' THEN 1 ELSE 0 END) AS locked, "
                + "SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS pending, "
                + "SUM(CASE WHEN role = 'ADMIN' THEN 1 ELSE 0 END) AS admin "
                + "FROM users";

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                counts.put("total", rs.getInt("total"));
                counts.put("active", rs.getInt("active"));
                counts.put("locked", rs.getInt("locked"));
                counts.put("pending", rs.getInt("pending"));
                counts.put("admin", rs.getInt("admin"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return counts;
    }

    public User getById(int id) {
        String sql = "SELECT * FROM users WHERE id=?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean updateProfile(int id, String fullName, String phone, String address) {
        String sql = "UPDATE users SET full_name=?, phone=?, address=? WHERE id=?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, address);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean checkPassword(int id, String password) {
        String sql = "SELECT 1 FROM users WHERE id=? AND password_hash=?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean updatePassword(int id, String newPassword) {
        String sql = "UPDATE users SET password_hash=? WHERE id=?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean updatePasswordByEmail(String email, String newPassword) {
        String sql = "UPDATE users SET password_hash=? WHERE email=?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setString(2, email != null ? email.trim() : "");
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean lockUser(int userId, String reason, String lockedBy) {
        String sqlCheck = "SELECT role FROM users WHERE id = ?";
        String sqlUpdate = "UPDATE users SET status = 'LOCKED', lock_reason = ?, locked_at = GETDATE(), locked_by = ? WHERE id = ?";

        try (Connection conn = ConnectDB.getConnect()) {
            if (conn == null) return false;

            try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                psCheck.setInt(1, userId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        String role = rs.getString("role");
                        if ("ADMIN".equalsIgnoreCase(role)) {
                            return false;
                        }
                    } else {
                        return false;
                    }
                }
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                psUpdate.setString(1, reason != null && !reason.trim().isEmpty() ? reason.trim() : "Vi phạm quy định của hệ thống");
                psUpdate.setString(2, lockedBy != null ? lockedBy : "Admin");
                psUpdate.setInt(3, userId);
                return psUpdate.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean unlockUser(int userId) {
        String sqlUpdate = "UPDATE users SET status = 'ACTIVE', lock_reason = NULL, locked_at = NULL, locked_by = NULL WHERE id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean toggleUserStatus(int userId) {
        User u = getById(userId);
        if (u == null || u.isAdmin()) return false;
        if (u.isLocked()) {
            return unlockUser(userId);
        } else {
            return lockUser(userId, "Khóa bởi Admin", "Admin");
        }
    }
}
