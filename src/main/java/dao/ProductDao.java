package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Product;

public class ProductDao {
    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM san_pham WHERE status = 'ACTIVE'";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            System.out.println("Lỗi getTotalProducts: " + e.getMessage());
        }
        return 0;
    }

    public List<Product> getProductsByPage(int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        String sql = "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "LEFT JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.status = 'ACTIVE' " +
                "ORDER BY p.id DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql)) {

            st.setInt(1, offset);
            st.setInt(2, pageSize);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product(
                            rs.getInt("id"),
                            rs.getInt("category_id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getDouble("price"),
                            rs.getString("image"),
                            rs.getInt("quantity"),
                            rs.getString("status"),
                            rs.getString("category_name")
                    );
                    list.add(p);
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi getProductsByPage: " + e.getMessage());
        }
        return list;
    }

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "LEFT JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.status = 'ACTIVE' " +
                "ORDER BY p.id ASC";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {

            while(rs.next()) {
                Product p = new Product(
                        rs.getInt("id"),
                        rs.getInt("category_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getDouble("price"),
                        rs.getString("image"),
                        rs.getInt("quantity"),
                        rs.getString("status"),
                        rs.getString("category_name")
                );
                list.add(p);
            }
        } catch (Exception e) {
            System.out.println("Lỗi getAllProducts: " + e.getMessage());
        }
        return list;
    }

    public List<Product> getProductsByCategoryId(int categoryId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "LEFT JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.status = 'ACTIVE' AND p.category_id = ? " +
                "ORDER BY p.id ASC";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql)) {

            st.setInt(1, categoryId);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product(
                            rs.getInt("id"),
                            rs.getInt("category_id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getDouble("price"),
                            rs.getString("image"),
                            rs.getInt("quantity"),
                            rs.getString("status"),
                            rs.getString("category_name")
                    );
                    list.add(p);
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi getProductsByCategoryId: " + e.getMessage());
        }
        return list;
    }

    public Product getProductById(int id) {
        String sql = "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "LEFT JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Product(
                            rs.getInt("id"),
                            rs.getInt("category_id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getDouble("price"),
                            rs.getString("image"),
                            rs.getInt("quantity"),
                            rs.getString("status"),
                            rs.getString("category_name")
                    );
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi getProductById: " + e.getMessage());
        }
        return null;
    }

    public void insert(Product p) {
        String sql = "INSERT INTO san_pham (category_id, name, description, price, image, quantity, status) VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE')";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setDouble(4, p.getPrice());
            ps.setString(5, p.getImage());
            ps.setInt(6, p.getQuantity());

            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Lỗi insert: " + e.getMessage());
        }
    }

    public void update(Product p) {
        String sql = "UPDATE san_pham SET category_id = ?, name = ?, description = ?, price = ?, image = ?, quantity = ? WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setDouble(4, p.getPrice());
            ps.setString(5, p.getImage());
            ps.setInt(6, p.getQuantity());
            ps.setInt(7, p.getId());

            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Lỗi update: " + e.getMessage());
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM san_pham WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Lỗi delete: " + e.getMessage());
        }
    }

    // ==========================================
    // CÁC HÀM DÙNG CHO TRANG CHỦ (HOME)
    // ==========================================

    public List<String> getAllCategoryNames() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT name FROM danh_muc";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("name"));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getAllCategoryNames: " + e.getMessage());
        }
        return list;
    }

    // Hàm mới: Chỉ lấy tên các danh mục chứa từ "PC" hoặc "Máy tính"
    public List<String> getPCCategoryNames() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT name FROM danh_muc WHERE name LIKE '%PC%' OR name LIKE N'%Máy tính%'";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("name"));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getPCCategoryNames: " + e.getMessage());
        }
        return list;
    }

    public List<Product> getTop8ProductsByCategoryName(String categoryName) {
        List<Product> list = new ArrayList<>();
        // Inner join để lấy đúng tên danh mục, giới hạn lấy 8 sản phẩm mới nhất
        String sql = "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "INNER JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.status = 'ACTIVE' AND c.name = ? " +
                "ORDER BY p.id DESC " +
                "OFFSET 0 ROWS FETCH NEXT 8 ROWS ONLY";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql)) {

            st.setString(1, categoryName);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product(
                            rs.getInt("id"),
                            rs.getInt("category_id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getDouble("price"),
                            rs.getString("image"),
                            rs.getInt("quantity"),
                            rs.getString("status"),
                            rs.getString("category_name")
                    );
                    list.add(p);
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi getTop8ProductsByCategoryName: " + e.getMessage());
        }
        return list;
    }

    // ==========================================
    // HÀM TÌM KIẾM SẢN PHẨM (MỚI)
    // Tìm theo tên sản phẩm, mô tả hoặc tên danh mục.
    // COLLATE Vietnamese_CI_AI: không phân biệt hoa/thường và dấu
    // (gõ "may tinh" vẫn ra "Máy tính").
    // ==========================================
    public List<Product> searchProducts(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "LEFT JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.status = 'ACTIVE' AND (" +
                "   p.name COLLATE Vietnamese_CI_AI LIKE ? " +
                "   OR p.description COLLATE Vietnamese_CI_AI LIKE ? " +
                "   OR c.name COLLATE Vietnamese_CI_AI LIKE ?" +
                ") " +
                "ORDER BY p.id DESC";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql)) {

            String like = "%" + keyword + "%";
            st.setString(1, like);
            st.setString(2, like);
            st.setString(3, like);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product(
                            rs.getInt("id"),
                            rs.getInt("category_id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getDouble("price"),
                            rs.getString("image"),
                            rs.getInt("quantity"),
                            rs.getString("status"),
                            rs.getString("category_name")
                    );
                    list.add(p);
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi searchProducts: " + e.getMessage());
        }
        return list;
    }

    // ==========================================
    // HÀM GỢI Ý TÌM KIẾM (MỚI) - lấy tối đa "limit" sản phẩm theo tên
    // ==========================================
    public List<Product> searchSuggestions(String keyword, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "LEFT JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.status = 'ACTIVE' " +
                "AND p.name COLLATE Vietnamese_CI_AI LIKE ? " +
                "ORDER BY p.id DESC " +
                "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql)) {

            st.setString(1, "%" + keyword + "%");
            st.setInt(2, limit);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product(
                            rs.getInt("id"),
                            rs.getInt("category_id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getDouble("price"),
                            rs.getString("image"),
                            rs.getInt("quantity"),
                            rs.getString("status"),
                            rs.getString("category_name")
                    );
                    list.add(p);
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi searchSuggestions: " + e.getMessage());
        }
        return list;
    }
}