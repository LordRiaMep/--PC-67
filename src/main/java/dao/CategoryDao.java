package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Category;

public class CategoryDao {

    public List<Category> findAll() {
        List<Category> categories = new ArrayList<>();

        String sql = "SELECT * FROM danh_muc WHERE status = 'ACTIVE' ORDER BY id ASC";

        try (Connection c = ConnectDB.getConnect();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(map(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return categories;
    }

    public Category findById(int id) {
        String sql = "SELECT * FROM danh_muc WHERE id = ?";

        try (Connection c = ConnectDB.getConnect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void insert(Category category) {
        String sql = "INSERT INTO danh_muc (name, description, status) VALUES (?, ?, 'ACTIVE')";

        try (Connection c = ConnectDB.getConnect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void update(Category category) {
        String sql = "UPDATE danh_muc SET name = ?, description = ? WHERE id = ?";

        try (Connection c = ConnectDB.getConnect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription());
            ps.setInt(3, category.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public boolean delete(int id) {

        String checkSql = "SELECT COUNT(*) FROM san_pham WHERE category_id = ?";

        try (Connection c = ConnectDB.getConnect();
             PreparedStatement psCheck = c.prepareStatement(checkSql)) {

            psCheck.setInt(1, id);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {

                    return false;
                }
            }

            String deleteSql = "DELETE FROM danh_muc WHERE id = ?";
            try (PreparedStatement psDelete = c.prepareStatement(deleteSql)) {
                psDelete.setInt(1, id);
                int rowsAffected = psDelete.executeUpdate();
                return rowsAffected > 0;
            }

        } catch (SQLException e) {
            throw new RuntimeException("Lỗi khi xóa danh mục", e);
        }
    }

    public List<Category> getAllCategories() {
        return findAll();
    }

    private Category map(ResultSet rs) throws SQLException {
        return new Category(
                rs.getInt("id"),
                rs.getString("name"),
                rs.getString("description"),
                rs.getString("status"),
                rs.getTimestamp("created_at")
        );
    }
}
