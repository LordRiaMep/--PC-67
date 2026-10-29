package dao;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.News;

public class NewsDao {

    public static final int FEATURED_LIMIT = 5;

    private static final String NEWS_ORDER_BY = " ORDER BY created_at DESC, id DESC";

    private static final String NOT_IN_FEATURED =
            "id NOT IN (SELECT TOP " + FEATURED_LIMIT + " id FROM tin_tuc " +
                    "WHERE status = 'ACTIVE' AND is_featured = 1 " + NEWS_ORDER_BY + ")";

    private static final String LIST_COLUMNS =
            "id, title, summary, image, author, view_count, is_featured, status, created_at, home_role";

    private static volatile boolean schemaChecked = false;

    public NewsDao() {
        ensureSchema();
    }

    private static synchronized void ensureSchema() {
        if (schemaChecked) return;
        try (Connection con = ConnectDB.getConnect()) {
            if (con != null) {
                DatabaseMetaData meta = con.getMetaData();
                try (ResultSet rs1 = meta.getColumns(null, null, "tin_tuc", "home_role")) {
                    if (!rs1.next()) {
                        try (Statement stmt = con.createStatement()) {
                            stmt.executeUpdate("ALTER TABLE tin_tuc ADD home_role NVARCHAR(20) DEFAULT 'NONE'");
                        }
                    }
                }
                schemaChecked = true;
            }
        } catch (Exception e) {
            System.out.println("Kiểm tra schema tin_tuc: " + e.getMessage());
        }
    }

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
        try {
            String hr = rs.getString("home_role");
            n.setHomeRole(hr != null && !hr.trim().isEmpty() ? hr.trim() : "NONE");
        } catch (Exception ignored) {
            n.setHomeRole("NONE");
        }
        if (withContent) {
            n.setContent(rs.getString("content"));
        }
        return n;
    }

    public List<News> getLatestNews(int limit) {
        List<News> result = new ArrayList<>();
        Set<Integer> addedIds = new HashSet<>();

        News mainNews = getHomeMainNews();
        if (mainNews != null) {
            result.add(mainNews);
            addedIds.add(mainNews.getId());
        }

        int subLimit = Math.max(0, limit - result.size());
        if (subLimit > 0) {
            List<News> subList = getHomeSubNews(subLimit);
            for (News sub : subList) {
                if (!addedIds.contains(sub.getId())) {
                    result.add(sub);
                    addedIds.add(sub.getId());
                }
            }
        }

        if (mainNews == null) {
            News fallbackMain = getFallbackActiveNews(addedIds);
            if (fallbackMain != null) {
                result.add(0, fallbackMain);
                addedIds.add(fallbackMain.getId());
            }
        }

        if (result.size() < limit) {
            int need = limit - result.size();
            List<News> fallbacks = getFallbackActiveNewsList(addedIds, need);
            for (News fb : fallbacks) {
                if (!addedIds.contains(fb.getId())) {
                    result.add(fb);
                    addedIds.add(fb.getId());
                }
            }
        }

        return result;
    }

    public News getHomeMainNews() {
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' AND home_role = 'MAIN' " +
                "ORDER BY created_at DESC, id DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return map(rs, false);
        } catch (Exception e) {
            System.out.println("Lỗi getHomeMainNews: " + e.getMessage());
        }
        return null;
    }

    public List<News> getHomeSubNews(int limit) {
        List<News> list = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' AND home_role = 'SUB' " +
                "ORDER BY created_at DESC, id DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, false));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getHomeSubNews: " + e.getMessage());
        }
        return list;
    }

    private News getFallbackActiveNews(Set<Integer> excludeIds) {
        List<News> list = getFallbackActiveNewsList(excludeIds, 1);
        return list.isEmpty() ? null : list.get(0);
    }

    private List<News> getFallbackActiveNewsList(Set<Integer> excludeIds, int count) {
        List<News> list = new ArrayList<>();
        if (count <= 0) return list;
        StringBuilder sql = new StringBuilder("SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' ");
        List<Integer> ids = new ArrayList<>(excludeIds);
        if (!ids.isEmpty()) {
            sql.append("AND id NOT IN (");
            for (int i = 0; i < ids.size(); i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
            }
            sql.append(") ");
        }
        sql.append("ORDER BY created_at DESC, id DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY");
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int pIndex = 1;
            for (Integer id : ids) {
                ps.setInt(pIndex++, id);
            }
            ps.setInt(pIndex, count);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, false));
            }
        } catch (Exception e) {
            System.out.println("Lỗi getFallbackActiveNewsList: " + e.getMessage());
        }
        return list;
    }

    public List<Integer> getTop5HomeNewsIds() {
        List<Integer> ids = new ArrayList<>();
        List<News> homeNews = getLatestNews(5);
        for (News n : homeNews) {
            ids.add(n.getId());
        }
        return ids;
    }

    public List<News> getFeaturedNews(int limit) {
        List<News> list = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' AND is_featured = 1 " +
                NEWS_ORDER_BY + " OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
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

    public List<News> getNewestNewsByPage(int page, int pageSize) {
        List<News> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' AND " + NOT_IN_FEATURED +
                NEWS_ORDER_BY + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
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

    public List<News> getNewsByPage(int page, int pageSize) {
        List<News> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' " +
                NEWS_ORDER_BY + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
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

    public List<News> getRelatedNews(int excludeId, int limit) {
        List<News> list = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' AND id <> ? " +
                NEWS_ORDER_BY + " OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
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

    public int countAdminNews(String keyword, String statusFilter, String featuredFilter) {
        return countAdminNews(keyword, statusFilter, featuredFilter, "ALL");
    }

    public int countAdminNews(String keyword, String statusFilter, String featuredFilter, String homeFilter) {
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

        if ("MAIN".equalsIgnoreCase(homeFilter)) {
            sql.append("AND home_role = 'MAIN' ");
        } else if ("SUB".equalsIgnoreCase(homeFilter)) {
            sql.append("AND home_role = 'SUB' ");
        } else if ("HOME_ONLY".equalsIgnoreCase(homeFilter)) {
            sql.append("AND home_role IN ('MAIN', 'SUB') ");
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

    public List<News> getAdminNewsByPage(int page, int pageSize, String keyword, String statusFilter, String featuredFilter) {
        return getAdminNewsByPage(page, pageSize, keyword, statusFilter, featuredFilter, "ALL", "DEFAULT");
    }

    public List<News> getAdminNewsByPage(int page, int pageSize, String keyword, String statusFilter,
                                         String featuredFilter, String homeFilter, String sortOption) {
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

        if ("MAIN".equalsIgnoreCase(homeFilter)) {
            sql.append("AND home_role = 'MAIN' ");
        } else if ("SUB".equalsIgnoreCase(homeFilter)) {
            sql.append("AND home_role = 'SUB' ");
        } else if ("HOME_ONLY".equalsIgnoreCase(homeFilter)) {
            sql.append("AND home_role IN ('MAIN', 'SUB') ");
        }

        if ("HOME".equalsIgnoreCase(sortOption)) {
            sql.append("ORDER BY CASE WHEN home_role = 'MAIN' THEN 0 WHEN home_role = 'SUB' THEN 1 ELSE 2 END ASC, created_at DESC, id DESC ");
        } else if ("VIEW".equalsIgnoreCase(sortOption)) {
            sql.append("ORDER BY view_count DESC, id DESC ");
        } else {

            sql.append("ORDER BY created_at DESC, id DESC ");
        }

        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
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

    public List<News> getAllActiveNews() {
        List<News> list = new ArrayList<>();
        String sql = "SELECT " + LIST_COLUMNS + " FROM tin_tuc WHERE status = 'ACTIVE' ORDER BY created_at DESC, id DESC";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs, false));
        } catch (Exception e) {
            System.out.println("Lỗi getAllActiveNews: " + e.getMessage());
        }
        return list;
    }

    public boolean setHomeRole(int id, String role) {
        return setHomeRole(id, role, 0);
    }

    public boolean setHomeRole(int id, String role, int order) {
        String cleanRole = role != null ? role.trim().toUpperCase() : "NONE";
        try (Connection con = ConnectDB.getConnect()) {
            if ("MAIN".equals(cleanRole)) {

                try (PreparedStatement ps1 = con.prepareStatement("UPDATE tin_tuc SET home_role = 'NONE' WHERE home_role = 'MAIN'");
                     PreparedStatement ps2 = con.prepareStatement("UPDATE tin_tuc SET home_role = 'MAIN' WHERE id = ? AND status = 'ACTIVE'")) {
                    ps1.executeUpdate();
                    ps2.setInt(1, id);
                    return ps2.executeUpdate() > 0;
                }
            } else if ("SUB".equals(cleanRole)) {

                try (PreparedStatement psList = con.prepareStatement("SELECT id FROM tin_tuc WHERE home_role = 'SUB' AND status = 'ACTIVE' ORDER BY created_at ASC, id ASC");
                     ResultSet rs = psList.executeQuery()) {
                    List<Integer> currentSubs = new ArrayList<>();
                    while (rs.next()) {
                        currentSubs.add(rs.getInt(1));
                    }

                    if (currentSubs.contains(id)) {
                        return true;
                    }

                    if (currentSubs.size() >= 4) {
                        int oldestSubId = currentSubs.get(0);
                        try (PreparedStatement psDemote = con.prepareStatement("UPDATE tin_tuc SET home_role = 'NONE' WHERE id = ?")) {
                            psDemote.setInt(1, oldestSubId);
                            psDemote.executeUpdate();
                        }
                    }
                }

                try (PreparedStatement ps = con.prepareStatement("UPDATE tin_tuc SET home_role = 'SUB' WHERE id = ? AND status = 'ACTIVE'")) {
                    ps.setInt(1, id);
                    return ps.executeUpdate() > 0;
                }
            } else {

                try (PreparedStatement ps = con.prepareStatement("UPDATE tin_tuc SET home_role = 'NONE' WHERE id = ?")) {
                    ps.setInt(1, id);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi setHomeRole: " + e.getMessage());
            return false;
        }
    }

    public boolean setHomeLayout(int mainId, int subId1, int subId2, int subId3, int subId4) {
        try (Connection con = ConnectDB.getConnect()) {
            con.setAutoCommit(false);
            try {

                try (Statement st = con.createStatement()) {
                    st.executeUpdate("UPDATE tin_tuc SET home_role = 'NONE' WHERE home_role IN ('MAIN', 'SUB')");
                }

                if (mainId > 0) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE tin_tuc SET home_role = 'MAIN' WHERE id = ? AND status = 'ACTIVE'")) {
                        ps.setInt(1, mainId);
                        ps.executeUpdate();
                    }
                }

                int[] rawSubs = new int[]{subId1, subId2, subId3, subId4};
                Set<Integer> assignedIds = new HashSet<>();
                if (mainId > 0) assignedIds.add(mainId);

                for (int sid : rawSubs) {
                    if (sid > 0 && !assignedIds.contains(sid)) {
                        assignedIds.add(sid);
                        try (PreparedStatement ps = con.prepareStatement(
                                "UPDATE tin_tuc SET home_role = 'SUB' WHERE id = ? AND status = 'ACTIVE'")) {
                            ps.setInt(1, sid);
                            ps.executeUpdate();
                        }
                    }
                }

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.out.println("Lỗi setHomeLayout: " + e.getMessage());
            return false;
        }
    }

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

    public boolean toggleStatus(int id) {
        String sql = "UPDATE tin_tuc SET status = CASE WHEN status = 'ACTIVE' THEN 'HIDDEN' ELSE 'ACTIVE' END, " +
                "home_role = CASE WHEN status = 'ACTIVE' THEN 'NONE' ELSE home_role END WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi toggleStatus: " + e.getMessage());
            return false;
        }
    }

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
        String homeRole = (n.getHomeRole() != null && !n.getHomeRole().trim().isEmpty()) ? n.getHomeRole().trim().toUpperCase() : "NONE";
        if ("MAIN".equals(homeRole)) {
            try (Connection con = ConnectDB.getConnect();
                 PreparedStatement psClean = con.prepareStatement("UPDATE tin_tuc SET home_role = 'NONE' WHERE home_role = 'MAIN'")) {
                psClean.executeUpdate();
            } catch (Exception ignored) {}
        }

        String sql = "INSERT INTO tin_tuc (title, summary, content, image, author, is_featured, status, home_role) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getSummary());
            ps.setString(3, n.getContent());
            ps.setString(4, n.getImage());
            ps.setString(5, (n.getAuthor() == null || n.getAuthor().trim().isEmpty()) ? "Độ PC 67" : n.getAuthor().trim());
            ps.setBoolean(6, n.isFeatured());
            ps.setString(7, n.getStatus() == null || n.getStatus().trim().isEmpty() ? "ACTIVE" : n.getStatus().trim());
            ps.setString(8, homeRole);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi insert news: " + e.getMessage());
            return false;
        }
    }

    public boolean update(News n) {
        String homeRole = (n.getHomeRole() != null && !n.getHomeRole().trim().isEmpty()) ? n.getHomeRole().trim().toUpperCase() : "NONE";
        if ("MAIN".equals(homeRole)) {
            try (Connection con = ConnectDB.getConnect();
                 PreparedStatement psClean = con.prepareStatement("UPDATE tin_tuc SET home_role = 'NONE' WHERE home_role = 'MAIN' AND id <> ?")) {
                psClean.setInt(1, n.getId());
                psClean.executeUpdate();
            } catch (Exception ignored) {}
        }

        String sql = "UPDATE tin_tuc SET title = ?, summary = ?, content = ?, image = ?, " +
                "author = ?, is_featured = ?, status = ?, home_role = ? WHERE id = ?";
        try (Connection con = ConnectDB.getConnect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getSummary());
            ps.setString(3, n.getContent());
            ps.setString(4, n.getImage());
            ps.setString(5, (n.getAuthor() == null || n.getAuthor().trim().isEmpty()) ? "Độ PC 67" : n.getAuthor().trim());
            ps.setBoolean(6, n.isFeatured());
            ps.setString(7, n.getStatus());
            ps.setString(8, homeRole);
            ps.setInt(9, n.getId());
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
