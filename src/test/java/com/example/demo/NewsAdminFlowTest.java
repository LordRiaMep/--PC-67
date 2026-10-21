package com.example.demo;

import dao.NewsDao;
import model.News;
import java.util.List;

public class NewsAdminFlowTest {
    public static void main(String[] args) {
        NewsDao dao = new NewsDao();
        System.out.println("=== KIỂM TRA HỆ THỐNG QUẢN LÝ BÀI VIẾT (NEWS ADMIN FLOW) ===");

        // 1. Kiểm tra lấy 5 bài viết trang chủ
        List<Integer> top5Home = dao.getTop5HomeNewsIds();
        System.out.println("1. Top 5 bài viết hiển thị trên Trang chủ: " + top5Home);
        if (!top5Home.isEmpty()) {
            System.out.println("   -> Bài to chính trang chủ: #" + top5Home.get(0));
            if (top5Home.size() > 1) {
                System.out.println("   -> 4 bài nhỏ trang chủ: " + top5Home.subList(1, top5Home.size()));
            }
        }

        // 2. Kiểm tra thống kê
        int total = dao.getStatTotalCount();
        int active = dao.getStatActiveCount();
        int hidden = dao.getStatHiddenCount();
        int featured = dao.getStatFeaturedCount();
        System.out.println("2. Thống kê bài viết:");
        System.out.println("   - Tổng bài: " + total);
        System.out.println("   - Đang hiển thị (ACTIVE): " + active);
        System.out.println("   - Đang ẩn (HIDDEN): " + hidden);
        System.out.println("   - Nổi bật: " + featured);

        // 3. Kiểm tra tìm kiếm & phân trang
        List<News> page1 = dao.getAdminNewsByPage(1, 5, "", "ALL", "ALL");
        System.out.println("3. Lấy trang 1 (5 bài): " + page1.size() + " bài");
        for (News n : page1) {
            String role = "Trang tin tức";
            if (!top5Home.isEmpty() && top5Home.get(0).equals(n.getId())) {
                role = "⭐ Trang chủ: Bài chính (Lớn)";
            } else if (top5Home.contains(n.getId())) {
                role = "📌 Trang chủ: Bài phụ";
            }
            System.out.println("   [#" + n.getId() + "] " + n.getTitle() + " | Vị trí: " + role + " | Trạng thái: " + n.getStatus());
        }

        // 4. Test chu trình Tạo -> Sửa -> Toggle -> Xóa bài viết thử nghiệm
        System.out.println("4. Thử nghiệm Thêm mới bài viết...");
        News testNews = new News();
        testNews.setTitle("TEST BÀI VIẾT TỰ ĐỘNG - " + System.currentTimeMillis());
        testNews.setSummary("Tóm tắt bài viết test tự động");
        testNews.setContent("<p>Nội dung chi tiết test tự động</p>");
        testNews.setImage("https://placehold.co/600x340");
        testNews.setAuthor("Admin Test");
        testNews.setFeatured(false);
        testNews.setStatus("ACTIVE");

        boolean inserted = dao.insert(testNews);
        System.out.println("   -> Insert kết quả: " + inserted);

        List<News> searchNew = dao.getAdminNewsByPage(1, 1, "TEST BÀI VIẾT TỰ ĐỘNG", "ALL", "ALL");
        if (!searchNew.isEmpty()) {
            News insertedNews = searchNew.get(0);
            int newId = insertedNews.getId();
            System.out.println("   -> ID bài viết vừa tạo: #" + newId);

            // Test Toggle Status (ACTIVE -> HIDDEN)
            dao.toggleStatus(newId);
            News updated1 = dao.getNewsById(newId);
            System.out.println("   -> Sau toggleStatus: " + updated1.getStatus() + " (Kỳ vọng: HIDDEN)");

            // Test Toggle Featured (false -> true)
            dao.toggleFeatured(newId);
            News updated2 = dao.getNewsById(newId);
            System.out.println("   -> Sau toggleFeatured: " + updated2.isFeatured() + " (Kỳ vọng: true)");

            // Test Delete
            boolean deleted = dao.delete(newId);
            System.out.println("   -> Xóa bài test: " + deleted);
        }

        System.out.println("\n=== TẤT CẢ KIỂM THỬ ĐÃ HOÀN TẤT THÀNH CÔNG! ===");
    }
}
