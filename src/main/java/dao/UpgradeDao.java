package dao;

import model.UpgradeOption;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class UpgradeDao {

    private UpgradeOption map(ResultSet rs) throws Exception {
        UpgradeOption o = new UpgradeOption();
        o.setId(rs.getInt("id"));
        o.setProductId(rs.getInt("product_id"));
        o.setGroupName(rs.getString("group_name"));
        o.setName(rs.getString("name"));
        o.setPriceDelta(rs.getDouble("price_delta"));
        o.setDefaultOption(rs.getBoolean("is_default"));
        return o;
    }

    /** Tất cả linh kiện nâng cấp của 1 sản phẩm, gom theo nhóm (CPU, VGA, RAM...). */
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

    /** Lấy 1 linh kiện theo id nhưng bắt buộc thuộc đúng sản phẩm (chống sửa request). */
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
}
