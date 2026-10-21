package dao;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Thao tác CSDL: Đọc và cập nhật cấu hình kho xuất hàng GHN.
 * ============================================================================
 */

import model.WarehouseConfig;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class WarehouseDao {

    public WarehouseConfig getWarehouseConfig() {
        String sql = "SELECT TOP 1 * FROM cau_hinh_kho WHERE id = 1";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                WarehouseConfig cfg = new WarehouseConfig();
                cfg.setId(rs.getInt("id"));
                cfg.setProvinceId(rs.getInt("province_id"));
                cfg.setProvinceName(rs.getString("province_name"));
                cfg.setDistrictId(rs.getInt("district_id"));
                cfg.setDistrictName(rs.getString("district_name"));
                cfg.setWardCode(rs.getString("ward_code"));
                cfg.setWardName(rs.getString("ward_name"));
                cfg.setDetailAddress(rs.getString("detail_address"));
                cfg.setUpdatedAt(rs.getTimestamp("updated_at"));
                return cfg;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Mặc định dự phòng nếu chưa có trong DB
        WarehouseConfig defaultCfg = new WarehouseConfig();
        defaultCfg.setId(1);
        defaultCfg.setProvinceId(224);
        defaultCfg.setProvinceName("Hải Phòng");
        defaultCfg.setDistrictId(1591);
        defaultCfg.setDistrictName("Quận Hải An");
        defaultCfg.setWardCode("30504");
        defaultCfg.setWardName("Phường Đông Hải 1");
        defaultCfg.setDetailAddress("Số 15/2/437 Đà Nẵng");
        return defaultCfg;
    }

    public boolean updateWarehouseConfig(WarehouseConfig config) {
        String sql = "UPDATE cau_hinh_kho SET "
                + "province_id = ?, province_name = ?, "
                + "district_id = ?, district_name = ?, "
                + "ward_code = ?, ward_name = ?, "
                + "detail_address = ?, updated_at = GETDATE() "
                + "WHERE id = 1";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, config.getProvinceId());
            ps.setString(2, config.getProvinceName());
            ps.setInt(3, config.getDistrictId());
            ps.setString(4, config.getDistrictName());
            ps.setString(5, config.getWardCode());
            ps.setString(6, config.getWardName());
            ps.setString(7, config.getDetailAddress());
            int affected = ps.executeUpdate();
            return affected > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
