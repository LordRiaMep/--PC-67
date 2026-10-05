package dao;

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
    // PHẦN CHUẨN BỊ SẴN CHO ADMIN (sau này chỉ cần làm Servlet + JSP)
    // =====================================================

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

    public void insert(News n) {
        String sql = "INSERT INTO tin_tuc (title, summary, content, image, author, is_featured, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getSummary());
            ps.setString(3, n.getContent());
            ps.setString(4, n.getImage());
            ps.setString(5, n.getAuthor());
            ps.setBoolean(6, n.isFeatured());
            ps.setString(7, n.getStatus() == null ? "ACTIVE" : n.getStatus());
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Lỗi insert news: " + e.getMessage());
        }
    }

    public void update(News n) {
        String sql = "UPDATE tin_tuc SET title = ?, summary = ?, content = ?, image = ?, " +
                "author = ?, is_featured = ?, status = ? WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getSummary());
            ps.setString(3, n.getContent());
            ps.setString(4, n.getImage());
            ps.setString(5, n.getAuthor());
            ps.setBoolean(6, n.isFeatured());
            ps.setString(7, n.getStatus());
            ps.setInt(8, n.getId());
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Lỗi update news: " + e.getMessage());
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM tin_tuc WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Lỗi delete news: " + e.getMessage());
        }
    }
}