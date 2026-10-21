package dao;

/**
 * ============================================================================
 * [PHÂN HỆ 2: REALTIME WEBSOCKET HUB, DASHBOARD DOANH THU & CSKH]
 * Phụ trách: Quang
 * Chức năng: Thao tác CSDL: CRUD bài viết tin tức công nghệ, phân trang, ghim trang chủ.
 * ============================================================================
 */

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.News;

public class NewsDao {

    // Số bài hiển thị ở mục "Nổi bật nhất"
    public static final int FEATURED_LIMIT = 5;

    // Điều kiện loại các bài đang nằm ở mục "Nổi bật nhất" ra khỏi mục "Tin tức mới"
    private static final String NOT_IN_FEATURED =
            "id NOT IN (SELECT TOP " + FEATURED_LIMIT + " id FROM tin_tuc " +
                    "WHERE status = 'ACTIVE' AND is_featured = 1 ORDER BY created_at DESC, id DESC)";

    // Các cột dùng cho danh sách (không lấy content cho nhẹ)
    private static final String LIST_COLUMNS =
            "id, title, summary, image, author, view_count, is_featured, status, created_at";

    // ---------- Map 1 dòng ResultSet -> News ----------
    private News map(ResultSet rs, boolean withContent) throws SQLException {
        News n = new News();
        n.setId(rs.getInt("id"));
        n.setTitle(rs.getString("title"));
        n.setSummary(rs.getString("summary"));
        n.setImage(rs.getString("image"));
        n.setAuthor(rs.getString("author"));
        n.setViewCount(rs.getInt("view_count"));
        n.setFeatured(rs.getBoolean("is_featured"));
        n.setStatus(rs.getString("status"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        if (withContent) {
            n.setContent(rs.getString("content"));
        }
        return n;
    }

    // =====================================================
    // PHẦN DÀNH CHO KHÁCH (chỉ lấy bài ACTIVE)
    // =====================================================

    // Tin mới nhất (dùng cho trang chủ)
    public List<News> getLatestNews(int limit) {
        List<News> list = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' " +
                "ORDER BY created_at DESC, id DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, false));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getLatestNews: " + e.getMessage());
        }
        return list;
    }

    // Tin nổi bật: chỉ lấy bài đánh dấu is_featured = 1, bài mới nhất đứng trước
    public List<News> getFeaturedNews(int limit) {
        List<News> list = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' AND is_featured = 1 " +
                "ORDER BY created_at DESC, id DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, false));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getFeaturedNews: " + e.getMessage());
        }
        return list;
    }

    // Tổng số bài của mục "Tin tức mới" (đã loại các bài nổi bật)
    public int getTotalNewestNews() {
        String sql = "SELECT COUNT(*) FROM tin_tuc WHERE status = 'ACTIVE' AND " + NOT_IN_FEATURED;
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            System.out.println("Lỗi getTotalNewestNews: " + e.getMessage());
        }
        return 0;
    }

    // Mục "Tin tức mới": phân trang, KHÔNG trùng với mục "Nổi bật nhất"
    public List<News> getNewestNewsByPage(int page, int pageSize) {
        List<News> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' AND " + NOT_IN_FEATURED +
                " ORDER BY created_at DESC, id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, false));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getNewestNewsByPage: " + e.getMessage());
        }
        return list;
    }

    public int getTotalNews() {
        String sql = "SELECT COUNT(*) FROM tin_tuc WHERE status = 'ACTIVE'";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            System.out.println("Lỗi getTotalNews: " + e.getMessage());
        }
        return 0;
    }

    // Phân trang cho trang "Tất cả tin tức"
    public List<News> getNewsByPage(int page, int pageSize) {
        List<News> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' " +
                "ORDER BY created_at DESC, id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, false));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getNewsByPage: " + e.getMessage());
        }
        return list;
    }

    // Lấy 1 bài đầy đủ (có content) - dùng cho trang chi tiết và cả admin
    public News getNewsById(int id) {
        String sql = "SELECT " + LIST_COLUMNS + ", content FROM tin_tuc WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs, true);
            }
        } catch (Exception e) {
            System.out.println("Lỗi getNewsById: " + e.getMessage());
        }
        return null;
    }

    public void increaseView(int id) {
        String sql = "UPDATE tin_tuc SET view_count = view_count + 1 WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Lỗi increaseView: " + e.getMessage());
        }
    }

    // Tin liên quan (các bài mới nhất, trừ bài đang xem)
    public List<News> getRelatedNews(int excludeId, int limit) {
        List<News> list = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' AND id <> ? " +
                "ORDER BY created_at DESC, id DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, excludeId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, false));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getRelatedNews: " + e.getMessage());
        }
        return list;
    }

    // =====================================================
    // PHẦN DÀNH CHO ADMIN QUẢN LÝ BÀI VIẾT
    // =====================================================

    // Lấy ID của 5 bài viết đang hiển thị trên Trang chủ (theo thứ tự: index 0 là bài to, 1-4 là bài nhỏ)
    public List<Integer> getTop5HomeNewsIds() {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT id FROM tin_tuc WHERE status = 'ACTIVE' ORDER BY created_at DESC, id DESC OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) ids.add(rs.getInt(1));
        } catch (Exception e) {
            System.out.println("Lỗi getTop5HomeNewsIds: " + e.getMessage());
        }
        return ids;
    }

    // Đếm tổng số bài theo bộ lọc tìm kiếm
    public int countAdminNews(String keyword, String statusFilter, String featuredFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM tin_tuc WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (title LIKE ? OR summary LIKE ? OR author LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }
        if ("FEATURED".equalsIgnoreCase(featuredFilter)) {
            sql.append("AND is_featured = 1 ");
        } else if ("NOT_FEATURED".equalsIgnoreCase(featuredFilter)) {
            sql.append("AND is_featured = 0 ");
        }

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            System.out.println("Lỗi countAdminNews: " + e.getMessage());
        }
        return 0;
    }

    // Lấy danh sách bài viết phân trang theo bộ lọc tìm kiếm
    public List<News> getAdminNewsByPage(int page, int pageSize, String keyword, String statusFilter, String featuredFilter) {
        List<News> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (title LIKE ? OR summary LIKE ? OR author LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }
        if ("FEATURED".equalsIgnoreCase(featuredFilter)) {
            sql.append("AND is_featured = 1 ");
        } else if ("NOT_FEATURED".equalsIgnoreCase(featuredFilter)) {
            sql.append("AND is_featured = 0 ");
        }

        sql.append("ORDER BY created_at DESC, id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        int offset = Math.max(0, (page - 1) * pageSize);
        params.add(offset);
        params.add(pageSize);

        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, false));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getAdminNewsByPage: " + e.getMessage());
        }
        return list;
    }

    // Thống kê nhanh số lượng
    public int getStatTotalCount() {
        return getCountBySql("SELECT COUNT(*) FROM tin_tuc");
    }

    public int getStatActiveCount() {
        return getCountBySql("SELECT COUNT(*) FROM tin_tuc WHERE status = 'ACTIVE'");
    }

    public int getStatHiddenCount() {
        return getCountBySql("SELECT COUNT(*) FROM tin_tuc WHERE status = 'HIDDEN'");
    }

    public int getStatFeaturedCount() {
        return getCountBySql("SELECT COUNT(*) FROM tin_tuc WHERE is_featured = 1");
    }

    private int getCountBySql(String sql) {
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            System.out.println("Lỗi getCountBySql: " + e.getMessage());
        }
        return 0;
    }

    // Đổi trạng thái nhanh ACTIVE <-> HIDDEN
    public boolean toggleStatus(int id) {
        String sql = "UPDATE tin_tuc SET status = CASE WHEN status = 'ACTIVE' THEN 'HIDDEN' ELSE 'ACTIVE' END WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi toggleStatus: " + e.getMessage());
            return false;
        }
    }

    // Đổi trạng thái nhanh Nổi bật 1 <-> 0
    public boolean toggleFeatured(int id) {
        String sql = "UPDATE tin_tuc SET is_featured = CASE WHEN is_featured = 1 THEN 0 ELSE 1 END WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi toggleFeatured: " + e.getMessage());
            return false;
        }
    }

    // Admin xem tất cả bài (cả ACTIVE lẫn HIDDEN)
    public List<News> getAllNewsAdmin() {
        List<News> list = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc ORDER BY created_at DESC, id DESC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs, false));
        } catch (Exception e) {
            System.out.println("Lỗi getAllNewsAdmin: " + e.getMessage());
        }
        return list;
    }

    public boolean insert(News n) {
        String sql = "INSERT INTO tin_tuc (title, summary, content, image, author, is_featured, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getSummary());
            ps.setString(3, n.getContent());
            ps.setString(4, n.getImage());
            ps.setString(5, (n.getAuthor() == null || n.getAuthor().trim().isEmpty()) ? "Độ PC 67" : n.getAuthor().trim());
            ps.setBoolean(6, n.isFeatured());
            ps.setString(7, n.getStatus() == null || n.getStatus().trim().isEmpty() ? "ACTIVE" : n.getStatus().trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi insert news: " + e.getMessage());
            return false;
        }
    }

    public boolean update(News n) {
        String sql = "UPDATE tin_tuc SET title = ?, summary = ?, content = ?, image = ?, " +
                "author = ?, is_featured = ?, status = ? WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getSummary());
            ps.setString(3, n.getContent());
            ps.setString(4, n.getImage());
            ps.setString(5, (n.getAuthor() == null || n.getAuthor().trim().isEmpty()) ? "Độ PC 67" : n.getAuthor().trim());
            ps.setBoolean(6, n.isFeatured());
            ps.setString(7, n.getStatus());
            ps.setInt(8, n.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi update news: " + e.getMessage());
            return false;
        }
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM tin_tuc WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi delete news: " + e.getMessage());
            return false;
        }
    }
}