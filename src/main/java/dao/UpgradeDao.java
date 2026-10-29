package dao;

import model.UpgradeOption;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

public class UpgradeDao {

    private UpgradeOption map(ResultSet rs) throws Exception {
        UpgradeOption o = new UpgradeOption();
        o.setId(rs.getInt("id"));
        o.setProductId(rs.getInt("product_id"));
        o.setGroupName(rs.getString("group_name"));
        o.setName(rs.getString("name"));
        o.setPriceDelta(rs.getDouble("price_delta"));
        o.setDefaultOption(rs.getBoolean("is_default"));
        try {
            o.setSortOrder(rs.getInt("sort_order"));
        } catch (Exception ignored) {}
        try {
            o.setStatus(rs.getString("status"));
        } catch (Exception ignored) {}
        return o;
    }

    public Map<String, List<UpgradeOption>> getGroupsByProduct(int productId) {
        Map<String, List<UpgradeOption>> groups = new LinkedHashMap<>();
        String sql = "SELECT * FROM nang_cap WHERE product_id = ? AND status = 'ACTIVE' ORDER BY sort_order, id";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UpgradeOption o = map(rs);
                    groups.computeIfAbsent(o.getGroupName(), k -> new ArrayList<>()).add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return groups;
    }

    public List<UpgradeOption> getOptionsByProductId(int productId) {
        List<UpgradeOption> list = new ArrayList<>();
        String sql = "SELECT * FROM nang_cap WHERE product_id = ? AND status = 'ACTIVE' ORDER BY sort_order, id";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public UpgradeOption getByIdAndProduct(int upgradeId, int productId) {
        String sql = "SELECT * FROM nang_cap WHERE id = ? AND product_id = ? AND status = 'ACTIVE'";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, upgradeId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Map<Integer, Integer> getOptionCountByProductIds(List<Integer> productIds) {
        Map<Integer, Integer> counts = new HashMap<>();
        if (productIds == null || productIds.isEmpty()) return counts;

        StringBuilder sb = new StringBuilder();
        sb.append("SELECT product_id, COUNT(*) as cnt FROM nang_cap WHERE status = 'ACTIVE' AND product_id IN (");
        for (int i = 0; i < productIds.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("?");
        }
        sb.append(") GROUP BY product_id");

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sb.toString())) {
            for (int i = 0; i < productIds.size(); i++) {
                ps.setInt(i + 1, productIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getInt("product_id"), rs.getInt("cnt"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    public boolean saveProductOptions(int productId, List<UpgradeOption> options) {
        if (productId <= 0) return false;

        String deleteSql = "DELETE FROM nang_cap WHERE product_id = ?";
        String insertSql = "INSERT INTO nang_cap (product_id, group_name, name, price_delta, is_default, sort_order, status) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ConnectDB.getConnect()) {
            if (conn == null) return false;
            conn.setAutoCommit(false);
            try {

                try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                    psDel.setInt(1, productId);
                    psDel.executeUpdate();
                }

                if (options != null && !options.isEmpty()) {
                    try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                        int orderCounter = 100;
                        for (UpgradeOption opt : options) {
                            if (opt == null) continue;
                            String grp = opt.getGroupName();
                            String name = opt.getName();
                            if (grp == null || grp.trim().isEmpty() || name == null || name.trim().isEmpty()) {
                                continue;
                            }

                            psIns.setInt(1, productId);
                            psIns.setString(2, grp.trim());
                            psIns.setString(3, name.trim());
                            psIns.setDouble(4, opt.getPriceDelta());
                            psIns.setBoolean(5, opt.isDefaultOption());
                            psIns.setInt(6, opt.getSortOrder() > 0 ? opt.getSortOrder() : orderCounter++);
                            psIns.setString(7, (opt.getStatus() != null && !opt.getStatus().isEmpty()) ? opt.getStatus() : "ACTIVE");
                            psIns.addBatch();
                        }
                        psIns.executeBatch();
                    }
                }

                conn.commit();
                return true;
            } catch (Exception ex) {
                conn.rollback();
                ex.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteByProductId(int productId) {
        String sql = "DELETE FROM nang_cap WHERE product_id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
