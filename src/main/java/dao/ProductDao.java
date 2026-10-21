package dao;

/**
 * ============================================================================
 * [PHÂN HỆ 3: SẢN PHẨM, NÂNG CẤP PC & GEMINI AI CHATBOT]
 * Phụ trách: Nhân Hiếu
 * Chức năng: Thao tác CSDL: Quản lý sản phẩm máy tính PC Gaming, spec kỹ thuật và tồn kho.
 * ============================================================================
 */

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Product;

public class ProductDao {

    // Đọc 1 dòng ResultSet thành Product (dùng chung, đã gồm spec_detail)
    private Product mapRow(ResultSet rs) throws SQLException {
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
        p.setSpecDetail(rs.getString("spec_detail"));
        return p;
    }

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
                    list.add(mapRow(rs));
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
                "ORDER BY p.id DESC";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
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
                "ORDER BY p.id DESC";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql)) {

            st.setInt(1, categoryId);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
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
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi getProductById: " + e.getMessage());
        }
        return null;
    }

    // ==========================================
    // SẢN PHẨM TƯƠNG TỰ: cùng danh mục, giá gần nhất, loại trừ chính nó
    // ==========================================
    public List<Product> getRelatedProducts(int productId, int categoryId, double price, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "LEFT JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.status = 'ACTIVE' AND p.category_id = ? AND p.id <> ? " +
                "ORDER BY ABS(p.price - ?) ASC " +
                "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql)) {

            st.setInt(1, categoryId);
            st.setInt(2, productId);
            st.setDouble(3, price);
            st.setInt(4, limit);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi getRelatedProducts: " + e.getMessage());
        }
        return list;
    }

    public int insert(Product p) {
        String sql = "INSERT INTO san_pham (category_id, name, description, price, image, quantity, status, spec_detail) VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE', ?)";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setDouble(4, p.getPrice());
            ps.setString(5, p.getImage());
            ps.setInt(6, p.getQuantity());
            ps.setString(7, p.getSpecDetail());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    p.setId(id);
                    return id;
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi insert: " + e.getMessage());
        }
        return -1;
    }

    public void update(Product p) {
        String sql = "UPDATE san_pham SET category_id = ?, name = ?, description = ?, price = ?, image = ?, quantity = ?, spec_detail = ? WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setDouble(4, p.getPrice());
            ps.setString(5, p.getImage());
            ps.setInt(6, p.getQuantity());
            ps.setString(7, p.getSpecDetail());
            ps.setInt(8, p.getId());

            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Lỗi update: " + e.getMessage());
        }
    }

    public boolean delete(int id) {
        String checkOrderSql = "SELECT COUNT(*) FROM hoa_don_chi_tiet WHERE product_id = ?";
        try (Connection con = ConnectDB.getConnect()) {
            if (con == null) return false;

            try (PreparedStatement psCheck = con.prepareStatement(checkOrderSql)) {
                psCheck.setInt(1, id);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        // Đã có đơn hàng chứa sản phẩm này -> Chuyển sang INACTIVE để bảo toàn lịch sử hóa đơn
                        String sqlInactive = "UPDATE san_pham SET status = 'INACTIVE' WHERE id = ?";
                        try (PreparedStatement psIn = con.prepareStatement(sqlInactive)) {
                            psIn.setInt(1, id);
                            return psIn.executeUpdate() > 0;
                        }
                    }
                }
            }

            // Chưa có trong đơn hàng nào -> Xóa vĩnh viễn an toàn
            // Xóa liên kết trong nang_cap và gio_hang trước
            try (PreparedStatement psNangCap = con.prepareStatement("DELETE FROM nang_cap WHERE product_id = ?")) {
                psNangCap.setInt(1, id);
                psNangCap.executeUpdate();
            } catch (Exception ignored) {}
            try (PreparedStatement psGioHang = con.prepareStatement("DELETE FROM gio_hang WHERE product_id = ?")) {
                psGioHang.setInt(1, id);
                psGioHang.executeUpdate();
            } catch (Exception ignored) {}

            String sql = "DELETE FROM san_pham WHERE id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, id);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            System.out.println("Lỗi delete sản phẩm: " + e.getMessage());
            return false;
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

    // Chỉ lấy tên các danh mục PC nguyên bộ cho Slider trang chủ (loại trừ Linh kiện)
    public List<String> getPCCategoryNames() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT name FROM danh_muc WHERE id != 5 AND name NOT LIKE N'%Linh kiện%' AND (name LIKE '%PC%' OR name LIKE N'%Máy tính%')";
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
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi getTop8ProductsByCategoryName: " + e.getMessage());
        }
        return list;
    }

    // ==========================================
    // TÌM KIẾM SẢN PHẨM
    // COLLATE Vietnamese_CI_AI: không phân biệt hoa/thường và dấu
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
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi searchProducts: " + e.getMessage());
        }
        return list;
    }

    // ==========================================
    // GỢI Ý TÌM KIẾM - lấy tối đa "limit" sản phẩm theo tên
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
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi searchSuggestions: " + e.getMessage());
        }
        return list;
    }

    // ==========================================
    // CHATBOT: Tìm kiếm sản phẩm thông minh theo tokens từ khóa, khoảng giá và PC nguyên bộ
    // ==========================================
    public List<Product> searchForChatbot(String keyword, Double minPrice, Double maxPrice, int limit) {
        return searchForChatbot(keyword, minPrice, maxPrice, false, limit);
    }

    public List<Product> searchForChatbot(String keyword, Double minPrice, Double maxPrice, boolean pcOnly, int limit) {
        List<String> tokens = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            String clean = keyword.toLowerCase()
                    .replaceAll("[,.?!;:]", " ")
                    .replaceAll("\\s+", " ")
                    .trim();
            for (String w : clean.split(" ")) {
                w = w.trim();
                if (!w.isEmpty() && !w.equals("pc") && !w.equals("máy") && !w.equals("tính") && w.length() > 1) {
                    tokens.add(w);
                }
            }
        }
        return searchSmartForChatbot(tokens, null, minPrice, maxPrice, pcOnly, limit);
    }

    public List<Product> searchSmartForChatbot(List<String> tokens, Double targetPrice, Double minPrice, Double maxPrice, boolean pcOnly, int limit) {
        return searchAdvancedForChatbot(null, null, tokens, targetPrice, minPrice, maxPrice, pcOnly, limit);
    }

    public List<Product> searchAdvancedForChatbot(String brand, String gpu, List<String> tokens, Double targetPrice, Double minPrice, Double maxPrice, boolean pcOnly, int limit) {
        return searchAdvancedForChatbot(brand, gpu, tokens, targetPrice, minPrice, maxPrice, pcOnly, false, false, limit);
    }

    public List<Product> searchAdvancedForChatbot(String brand, String gpu, List<String> tokens, Double targetPrice, Double minPrice, Double maxPrice, boolean pcOnly, boolean isGaming, boolean excludeOffice, int limit) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, c.name AS category_name " +
                "FROM san_pham p " +
                "LEFT JOIN danh_muc c ON p.category_id = c.id " +
                "WHERE p.status = 'ACTIVE' AND p.quantity > 0"
        );
        List<Object> params = new ArrayList<>();

        if (pcOnly) {
            // Chỉ lấy các bộ máy PC hoàn chỉnh thuộc 4 danh mục PC (c.id != 5), loại bỏ danh mục Linh kiện
            sql.append(" AND c.id != 5 AND c.name NOT LIKE N'%Linh kiện%'");
        }

        // Loại trừ PC văn phòng nếu khách hàng yêu cầu gaming hoặc từ chối văn phòng
        if (isGaming || excludeOffice) {
            sql.append(" AND c.id != 4 AND c.name NOT LIKE N'%Văn phòng%' AND p.name NOT LIKE N'%Văn phòng%'");
        }

        // 1. Lọc theo thương hiệu CPU / Nền tảng (AMD hoặc INTEL)
        if (brand != null && !brand.trim().isEmpty()) {
            String b = brand.trim().toUpperCase();
            if ("AMD".equals(b)) {
                if (isGaming) {
                    sql.append(" AND (c.id = 3 OR (c.id != 4 AND (p.name LIKE '%AMD%' OR p.name LIKE '%Ryzen%')))");
                } else {
                    sql.append(" AND (c.id = 3 OR c.name LIKE '%AMD%' OR p.name LIKE '%AMD%' OR p.name LIKE '%Ryzen%')");
                }
            } else if ("INTEL".equals(b)) {
                if (isGaming) {
                    sql.append(" AND (c.id = 1 OR (c.id != 4 AND (p.name LIKE '%Intel%' OR p.name LIKE '%Core%' OR p.name LIKE '%Ultra%' OR p.name LIKE '%Xeon%')))")
                       .append(" AND (p.name NOT LIKE '%AMD%' AND p.name NOT LIKE '%Ryzen%')");
                } else {
                    sql.append(" AND (c.name LIKE '%Intel%' OR p.name LIKE '%Intel%' OR p.name LIKE '%Core%' OR p.name LIKE '%Ultra%' OR p.name LIKE '%Xeon%')")
                       .append(" AND (p.name NOT LIKE '%AMD%' AND p.name NOT LIKE '%Ryzen%')");
                }
            }
        }

        // 2. Lọc theo GPU / Card màn hình (5060, 4060, 4070...)
        if (gpu != null && !gpu.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.description LIKE ?)");
            String gLike = "%" + gpu.trim() + "%";
            params.add(gLike);
            params.add(gLike);
        }

        // 3. Lọc theo các từ khóa phụ nếu có
        if (tokens != null && !tokens.isEmpty()) {
            for (String token : tokens) {
                if (token != null && !token.trim().isEmpty()) {
                    sql.append(" AND (p.name COLLATE Vietnamese_CI_AI LIKE ? OR p.description COLLATE Vietnamese_CI_AI LIKE ? OR c.name COLLATE Vietnamese_CI_AI LIKE ?)");
                    String like = "%" + token.trim() + "%";
                    params.add(like);
                    params.add(like);
                    params.add(like);
                }
            }
        }

        // 4. Khoảng giá
        if (minPrice != null && minPrice > 0) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }

        if (maxPrice != null && maxPrice > 0) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }

        // 5. Sắp xếp: Gần giá mục tiêu nhất nếu có, nếu không thì theo giá tăng dần
        if (targetPrice != null && targetPrice > 0) {
            sql.append(" ORDER BY ABS(p.price - ?) ASC");
            params.add(targetPrice);
        } else {
            sql.append(" ORDER BY p.price ASC");
        }

        sql.append(" OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY");
        params.add(limit <= 0 ? 5 : limit);

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object val = params.get(i);
                if (val instanceof String) {
                    st.setString(i + 1, (String) val);
                } else if (val instanceof Double) {
                    st.setDouble(i + 1, (Double) val);
                } else if (val instanceof Integer) {
                    st.setInt(i + 1, (Integer) val);
                }
            }

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi searchAdvancedForChatbot: " + e.getMessage());
        }
        return list;
    }

    public Product getCheapestPC() {
        String sql = "SELECT TOP 1 p.*, c.name AS category_name FROM san_pham p JOIN danh_muc c ON p.category_id = c.id WHERE c.id != 5 AND p.status = 'ACTIVE' ORDER BY p.price ASC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            System.out.println("Lỗi getCheapestPC: " + e.getMessage());
        }
        return null;
    }

    public Product getMostExpensivePC() {
        String sql = "SELECT TOP 1 p.*, c.name AS category_name FROM san_pham p JOIN danh_muc c ON p.category_id = c.id WHERE c.id != 5 AND p.status = 'ACTIVE' ORDER BY p.price DESC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement st = con.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) {
            System.out.println("Lỗi getMostExpensivePC: " + e.getMessage());
        }
        return null;
    }
}
