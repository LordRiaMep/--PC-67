package dao;

import model.ProductImage;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProductImageDao {

    public List<String> getImagesByProductId(int productId, String mainImage) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT image_url FROM san_pham_anh WHERE product_id = ? ORDER BY sort_order ASC, id ASC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String url = rs.getString("image_url");
                    if (url != null && !url.trim().isEmpty() && !list.contains(url.trim())) {
                        list.add(url.trim());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getImagesByProductId: " + e.getMessage());
        }

        // Đảm bảo mainImage được thêm vào đầu danh sách nếu chưa có
        if (mainImage != null && !mainImage.trim().isEmpty()) {
            String trimmed = mainImage.trim();
            if (!list.contains(trimmed)) {
                list.add(0, trimmed);
            }
        }
        return list;
    }

    public List<String> getImagesByProductId(int productId) {
        return getImagesByProductId(productId, null);
    }

    public List<ProductImage> getListByProductId(int productId) {
        List<ProductImage> list = new ArrayList<>();
        String sql = "SELECT id, product_id, image_url, sort_order FROM san_pham_anh WHERE product_id = ? ORDER BY sort_order ASC, id ASC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ProductImage(
                            rs.getInt("id"),
                            rs.getInt("product_id"),
                            rs.getString("image_url"),
                            rs.getInt("sort_order")
                    ));
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getListByProductId: " + e.getMessage());
        }
        return list;
    }

    public Map<Integer, Integer> getImageCountByProductIds(List<Integer> productIds) {
        Map<Integer, Integer> map = new HashMap<>();
        if (productIds == null || productIds.isEmpty()) return map;

        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < productIds.size(); i++) {
            if (i > 0) inClause.append(",");
            inClause.append("?");
        }
        String sql = "SELECT product_id, COUNT(*) AS cnt FROM san_pham_anh WHERE product_id IN (" + inClause + ") GROUP BY product_id";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < productIds.size(); i++) {
                ps.setInt(i + 1, productIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("product_id"), rs.getInt("cnt"));
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getImageCountByProductIds: " + e.getMessage());
        }
        return map;
    }

    public boolean saveProductImages(int productId, List<String> imageUrls) {
        if (productId <= 0) return false;
        String deleteSql = "DELETE FROM san_pham_anh WHERE product_id = ?";
        String insertSql = "INSERT INTO san_pham_anh (product_id, image_url, sort_order) VALUES (?, ?, ?)";

        try (Connection con = ConnectDB.getConnect()) {
            if (con == null) return false;
            con.setAutoCommit(false);
            try {
                try (PreparedStatement psDel = con.prepareStatement(deleteSql)) {
                    psDel.setInt(1, productId);
                    psDel.executeUpdate();
                }

                if (imageUrls != null && !imageUrls.isEmpty()) {
                    try (PreparedStatement psIns = con.prepareStatement(insertSql)) {
                        int order = 1;
                        for (String url : imageUrls) {
                            if (url != null && !url.trim().isEmpty()) {
                                psIns.setInt(1, productId);
                                psIns.setString(2, url.trim());
                                psIns.setInt(3, order++);
                                psIns.addBatch();
                            }
                        }
                        psIns.executeBatch();
                    }
                }
                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                System.err.println("Lỗi lưu san_pham_anh (rollback): " + e.getMessage());
                return false;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.err.println("Lỗi saveProductImages: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteByProductId(int productId) {
        String sql = "DELETE FROM san_pham_anh WHERE product_id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) {
            System.err.println("Lỗi deleteByProductId: " + e.getMessage());
            return false;
        }
    }
}
