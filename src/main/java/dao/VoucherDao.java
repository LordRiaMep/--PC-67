package dao;

import model.Voucher;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VoucherDao {

    private Voucher mapRow(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setId(rs.getInt("id"));
        v.setCode(rs.getString("code"));
        v.setName(rs.getString("name"));
        v.setDiscountType(rs.getString("discount_type"));
        v.setDiscountValue(rs.getDouble("discount_value"));

        double maxDisc = rs.getDouble("max_discount_amount");
        if (rs.wasNull()) {
            v.setMaxDiscountAmount(null);
        } else {
            v.setMaxDiscountAmount(maxDisc);
        }

        v.setMinOrderAmount(rs.getDouble("min_order_amount"));
        v.setUsageLimit(rs.getInt("usage_limit"));
        v.setUsedCount(rs.getInt("used_count"));
        v.setStartDate(rs.getTimestamp("start_date"));
        v.setEndDate(rs.getTimestamp("end_date"));
        v.setStatus(rs.getString("status"));
        v.setCreatedAt(rs.getTimestamp("created_at"));
        return v;
    }

    public List<Voucher> getAll() {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM voucher ORDER BY id DESC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.getAll: " + e.getMessage());
        }
        return list;
    }

    public int getTotalCount(String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM voucher WHERE 1=1");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (code LIKE ? OR name LIKE ?)");
        }
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(1, kw);
                ps.setString(2, kw);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.getTotalCount: " + e.getMessage());
        }
        return 0;
    }

    public List<Voucher> getByPage(int page, int pageSize, String keyword) {
        List<Voucher> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder("SELECT * FROM voucher WHERE 1=1");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (code LIKE ? OR name LIKE ?)");
        }
        sql.append(" ORDER BY id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.getByPage: " + e.getMessage());
        }
        return list;
    }

    public Voucher getById(int id) {
        String sql = "SELECT * FROM voucher WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.getById: " + e.getMessage());
        }
        return null;
    }

    public Voucher getByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        String sql = "SELECT * FROM voucher WHERE UPPER(code) = UPPER(?)";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.getByCode: " + e.getMessage());
        }
        return null;
    }

    public List<Voucher> getActiveVouchers() {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM voucher " +
                     "WHERE status = 'ACTIVE' " +
                     "AND start_date <= GETDATE() AND end_date >= GETDATE() " +
                     "AND (usage_limit <= 0 OR used_count < usage_limit) " +
                     "ORDER BY discount_value DESC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.getActiveVouchers: " + e.getMessage());
        }
        return list;
    }

    public List<Voucher> getAvailableVouchersForDisplay() {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM voucher " +
                     "WHERE status = 'ACTIVE' " +
                     "AND end_date >= GETDATE() " +
                     "AND (usage_limit <= 0 OR used_count < usage_limit) " +
                     "ORDER BY min_order_amount ASC, discount_value DESC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.getAvailableVouchersForDisplay: " + e.getMessage());
        }
        return list;
    }

    public boolean isCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM voucher WHERE UPPER(code) = UPPER(?) AND id <> ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.isCodeExists: " + e.getMessage());
        }
        return false;
    }

    public int insert(Voucher v) {
        String sql = "INSERT INTO voucher (code, name, discount_type, discount_value, max_discount_amount, " +
                     "min_order_amount, usage_limit, used_count, start_date, end_date, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?)";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, v.getCode().trim().toUpperCase());
            ps.setString(2, v.getName());
            ps.setString(3, v.getDiscountType());
            ps.setDouble(4, v.getDiscountValue());

            if (v.getMaxDiscountAmount() != null && v.getMaxDiscountAmount() > 0) {
                ps.setDouble(5, v.getMaxDiscountAmount());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }

            ps.setDouble(6, v.getMinOrderAmount());
            ps.setInt(7, v.getUsageLimit());
            ps.setTimestamp(8, v.getStartDate());
            ps.setTimestamp(9, v.getEndDate());
            ps.setString(10, v.getStatus() != null ? v.getStatus() : "ACTIVE");

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    v.setId(id);
                    return id;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.insert: " + e.getMessage());
        }
        return -1;
    }

    public boolean update(Voucher v) {
        String sql = "UPDATE voucher SET code = ?, name = ?, discount_type = ?, discount_value = ?, " +
                     "max_discount_amount = ?, min_order_amount = ?, usage_limit = ?, start_date = ?, " +
                     "end_date = ?, status = ? WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, v.getCode().trim().toUpperCase());
            ps.setString(2, v.getName());
            ps.setString(3, v.getDiscountType());
            ps.setDouble(4, v.getDiscountValue());

            if (v.getMaxDiscountAmount() != null && v.getMaxDiscountAmount() > 0) {
                ps.setDouble(5, v.getMaxDiscountAmount());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }

            ps.setDouble(6, v.getMinOrderAmount());
            ps.setInt(7, v.getUsageLimit());
            ps.setTimestamp(8, v.getStartDate());
            ps.setTimestamp(9, v.getEndDate());
            ps.setString(10, v.getStatus());
            ps.setInt(11, v.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.update: " + e.getMessage());
        }
        return false;
    }

    public boolean toggleStatus(int id) {
        String sql = "UPDATE voucher SET status = CASE WHEN status = 'ACTIVE' THEN 'INACTIVE' ELSE 'ACTIVE' END WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.toggleStatus: " + e.getMessage());
        }
        return false;
    }

    public boolean delete(int id) {

        String checkSql = "SELECT COUNT(*) FROM hoa_don h " +
                          "INNER JOIN voucher v ON h.voucher_code = v.code " +
                          "WHERE v.id = ?";
        try (Connection con = ConnectDB.getConnect()) {
            if (con == null) return false;

            try (PreparedStatement psCheck = con.prepareStatement(checkSql)) {
                psCheck.setInt(1, id);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {

                        String sqlInactive = "UPDATE voucher SET status = 'INACTIVE' WHERE id = ?";
                        try (PreparedStatement psIn = con.prepareStatement(sqlInactive)) {
                            psIn.setInt(1, id);
                            return psIn.executeUpdate() > 0;
                        }
                    }
                }
            }

            String deleteSql = "DELETE FROM voucher WHERE id = ?";
            try (PreparedStatement psDel = con.prepareStatement(deleteSql)) {
                psDel.setInt(1, id);
                return psDel.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi VoucherDao.delete: " + e.getMessage());
        }
        return false;
    }

    public boolean incrementUsedCount(String code, Connection con) throws SQLException {
        if (code == null || code.trim().isEmpty()) return true;
        String sql = "UPDATE voucher SET used_count = used_count + 1 WHERE UPPER(code) = UPPER(?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            return ps.executeUpdate() > 0;
        }
    }
}
