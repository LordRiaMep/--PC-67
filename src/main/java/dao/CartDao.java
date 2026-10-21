package dao;

/**
 * ============================================================================
 * [PHÂN HỆ 4: GIỎ HÀNG, ĐỘNG CƠ VOUCHER & VẬN CHUYỂN GHN]
 * Phụ trách: Bảo
 * Chức năng: Thao tác CSDL: Quản lý giỏ hàng lưu trữ của người dùng.
 * ============================================================================
 */

import model.Cart;
import model.CartItem;
import model.Product;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Quản lý giỏ hàng lưu trữ bền vững (Persistent Cart) trong Database.
 * Đảm bảo khi khách hàng đăng xuất và đăng nhập lại, giỏ hàng vẫn còn nguyên vẹn.
 */
public class CartDao {

    /**
     * Đồng bộ lưu trữ toàn bộ giỏ hàng của user vào Database
     */
    public void saveCart(int userId, Cart cart) {
        if (userId <= 0) return;

        String deleteSql = "DELETE FROM gio_hang WHERE user_id = ?";
        String insertSql = "INSERT INTO gio_hang (user_id, product_id, quantity, upgrade_key, upgrade_info, display_name, unit_price, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        try (Connection conn = ConnectDB.getConnect()) {
            if (conn == null) return;
            conn.setAutoCommit(false);

            try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                psDel.setInt(1, userId);
                psDel.executeUpdate();
            }

            if (cart != null && !cart.getItems().isEmpty()) {
                try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                    for (CartItem item : cart.getItems()) {
                        if (item.getProduct() == null) continue;
                        psIns.setInt(1, userId);
                        psIns.setInt(2, item.getProduct().getId());
                        psIns.setInt(3, item.getQuantity());
                        psIns.setString(4, item.getUpgradeKey() != null ? item.getUpgradeKey() : "");
                        psIns.setString(5, item.getUpgradeInfo() != null ? item.getUpgradeInfo() : "");
                        psIns.setString(6, item.getDisplayName() != null ? item.getDisplayName() : item.getProduct().getName());
                        psIns.setDouble(7, item.getUnitPrice());
                        psIns.addBatch();
                    }
                    psIns.executeBatch();
                }
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Tải giỏ hàng từ Database của user lên
     */
    public Cart loadCart(int userId) {
        Cart cart = new Cart();
        if (userId <= 0) return cart;

        String sql = "SELECT g.*, p.name AS p_name, p.price AS p_price, p.image AS p_image, p.quantity AS p_stock, p.category_id "
                + "FROM gio_hang g "
                + "JOIN san_pham p ON g.product_id = p.id "
                + "WHERE g.user_id = ? "
                + "ORDER BY g.id ASC";

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("product_id"));
                    p.setName(rs.getString("p_name"));
                    p.setPrice(rs.getDouble("p_price"));
                    p.setImage(rs.getString("p_image"));
                    p.setQuantity(rs.getInt("p_stock"));
                    p.setCategoryId(rs.getInt("category_id"));

                    int quantity = rs.getInt("quantity");
                    String upgradeKey = rs.getString("upgrade_key");
                    String upgradeInfo = rs.getString("upgrade_info");
                    String displayName = rs.getString("display_name");
                    double unitPrice = rs.getDouble("unit_price");

                    if (displayName == null || displayName.isEmpty()) {
                        displayName = p.getName();
                    }
                    if (unitPrice <= 0) {
                        unitPrice = p.getPrice();
                    }

                    CartItem item = new CartItem(p, quantity, upgradeKey, upgradeInfo, displayName, unitPrice);
                    cart.addItem(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return cart;
    }

    /**
     * Xóa sạch giỏ hàng khi người dùng đã đặt hàng thành công
     */
    public void clearCart(int userId) {
        if (userId <= 0) return;
        String sql = "DELETE FROM gio_hang WHERE user_id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
