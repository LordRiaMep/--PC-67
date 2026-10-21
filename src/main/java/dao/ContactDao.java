package dao;

/**
 * ============================================================================
 * [PHÂN HỆ 2: REALTIME WEBSOCKET HUB, DASHBOARD DOANH THU & CSKH]
 * Phụ trách: Quang
 * Chức năng: Thao tác CSDL: Tiếp nhận liên hệ/khiếu nại khách hàng và cập nhật phản hồi.
 * ============================================================================
 */

import model.Contact;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ContactDao {

    public boolean insert(Contact c) {
        String sql = "INSERT INTO lien_he (full_name, phone, email, topic, message, status, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, c.getFullName());
            ps.setString(2, c.getPhone());
            ps.setString(3, c.getEmail());
            ps.setString(4, c.getTopic());
            ps.setString(5, c.getMessage());
            ps.setString(6, c.getStatus() != null ? c.getStatus() : "Chưa xử lý");
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        c.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Contact> getAll(String statusFilter, String keyword) {
        List<Contact> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT id, full_name, phone, email, topic, message, status, admin_note, created_at, updated_at FROM lien_he WHERE 1=1 ");

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND status = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR phone LIKE ? OR email LIKE ? OR topic LIKE ?) ");
        }

        sql.append(" ORDER BY id DESC");

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                ps.setString(paramIndex++, statusFilter.trim());
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Contact c = new Contact();
                    c.setId(rs.getInt("id"));
                    c.setFullName(rs.getString("full_name"));
                    c.setPhone(rs.getString("phone"));
                    c.setEmail(rs.getString("email"));
                    c.setTopic(rs.getString("topic"));
                    c.setMessage(rs.getString("message"));
                    c.setStatus(rs.getString("status"));
                    c.setAdminNote(rs.getString("admin_note"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    c.setUpdatedAt(rs.getTimestamp("updated_at"));
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Contact getById(int id) {
        String sql = "SELECT id, full_name, phone, email, topic, message, status, admin_note, created_at, updated_at FROM lien_he WHERE id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Contact c = new Contact();
                    c.setId(rs.getInt("id"));
                    c.setFullName(rs.getString("full_name"));
                    c.setPhone(rs.getString("phone"));
                    c.setEmail(rs.getString("email"));
                    c.setTopic(rs.getString("topic"));
                    c.setMessage(rs.getString("message"));
                    c.setStatus(rs.getString("status"));
                    c.setAdminNote(rs.getString("admin_note"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    c.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return c;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateStatusAndNote(int id, String status, String adminNote) {
        String sql = "UPDATE lien_he SET status = ?, admin_note = ?, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, adminNote);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM lien_he WHERE id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM lien_he WHERE status = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countTotal() {
        String sql = "SELECT COUNT(*) FROM lien_he";
        try (Connection conn = ConnectDB.getConnect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
