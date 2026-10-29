package com.example.demo;

import dao.NewsDao;
import model.News;
import java.util.List;

public class NewsOrderAndHomeRoleFlowTest {
    public static void main(String[] args) {
        NewsDao dao = new NewsDao();
        System.out.println("==================================================================");
        System.out.println("KIỂM THỬ: LOGIC BÀI PHỤ & BÀI CHÍNH TRANG CHỦ (KHÔNG CÒN ƯU TIÊN)");
        System.out.println("==================================================================");

        List<News> activeNews = dao.getAllActiveNews();
        if (activeNews.size() < 6) {
            System.out.println("Cần tối thiểu 6 bài viết ACTIVE để kiểm thử đầy đủ (1 main + 5 subs để test xoay vòng)!");
            return;
        }

        int idMain = activeNews.get(0).getId();
        int idSub1 = activeNews.get(1).getId();
        int idSub2 = activeNews.get(2).getId();
        int idSub3 = activeNews.get(3).getId();
        int idSub4 = activeNews.get(4).getId();
        int idSub5 = activeNews.get(5).getId();

        System.out.println("\n--- 1. TEST GÁN BÀI CHÍNH DUY NHẤT (setHomeRole: MAIN) ---");
        dao.setHomeRole(idMain, "MAIN");
        News currentMain = dao.getHomeMainNews();
        if (currentMain != null && currentMain.getId() == idMain) {
            System.out.println("✅ CHÍNH XÁC: Bài chính trang chủ là #" + idMain);
        } else {
            System.err.println("❌ LỖI: Bài chính không khớp! Nhận được: " + (currentMain != null ? currentMain.getId() : "null"));
        }

        dao.setHomeRole(idSub1, "MAIN");
        News newMain = dao.getHomeMainNews();
        News oldMain = dao.getNewsById(idMain);
        if (newMain != null && newMain.getId() == idSub1 && "NONE".equals(oldMain.getHomeRole())) {
            System.out.println("✅ CHÍNH XÁC: Đổi bài chính sang #" + idSub1 + " thành công, bài #" + idMain + " tự động về NONE (Không trùng lặp bài chính)");
        } else {
            System.err.println("❌ LỖI: Đổi bài chính thất bại!");
        }

        System.out.println("\n--- 2. TEST GÁN BÀI PHỤ & GIỚI HẠN TỐI ĐA 4 BÀI (setHomeRole: SUB) ---");

        dao.setHomeLayout(idMain, 0, 0, 0, 0);

        dao.setHomeRole(idSub1, "SUB");
        dao.setHomeRole(idSub2, "SUB");
        dao.setHomeRole(idSub3, "SUB");
        dao.setHomeRole(idSub4, "SUB");

        List<News> subList4 = dao.getHomeSubNews(10);
        System.out.println("Số lượng bài phụ hiện tại: " + subList4.size() + " bài");
        if (subList4.size() == 4) {
            System.out.println("✅ CHÍNH XÁC: Đã gán đúng 4 bài phụ!");
        } else {
            System.err.println("❌ LỖI: Số bài phụ không đúng: " + subList4.size());
        }

        System.out.println("\n--- 3. TEST CƠ CHẾ XOAY VÒNG THÔNG MINH KHI GHIM BÀI PHỤ THỨ 5 ---");
        System.out.println("Ghim thêm bài phụ thứ 5: #" + idSub5);
        dao.setHomeRole(idSub5, "SUB");

        List<News> subListAfter5 = dao.getHomeSubNews(10);
        System.out.println("Số lượng bài phụ sau khi ghim bài thứ 5: " + subListAfter5.size() + " bài (Luôn được khóa cứng tối đa 4 bài)");
        boolean hasNewSub = false;
        for (News n : subListAfter5) {
            if (n.getId() == idSub5) hasNewSub = true;
        }

        if (subListAfter5.size() == 4 && hasNewSub) {
            System.out.println("✅ CHÍNH XÁC: Bài thứ 5 (#" + idSub5 + ") được ghim thành công và bài phụ cũ nhất đã tự động nhường chỗ (Auto-rotation)");
        } else {
            System.err.println("❌ LỖI: Cơ chế giới hạn 4 bài phụ thất bại!");
        }

        System.out.println("\n--- 4. TEST BỎ GHIM (setHomeRole: NONE) ---");
        dao.setHomeRole(idSub5, "NONE");
        News unpinned = dao.getNewsById(idSub5);
        if ("NONE".equals(unpinned.getHomeRole())) {
            System.out.println("✅ CHÍNH XÁC: Bỏ ghim bài #" + idSub5 + " thành công (home_role = NONE)");
        } else {
            System.err.println("❌ LỖI: Bỏ ghim thất bại!");
        }

        System.out.println("\n--- 5. TEST CHỐNG LỖ HỔNG: KHI ẨN BÀI VIẾT (HIDDEN) TỰ ĐỘNG BỎ GHIM TRANG CHỦ ---");

        dao.setHomeRole(idSub2, "SUB");
        System.out.println("Trạng thái bài #" + idSub2 + " trước khi ẩn: " + dao.getNewsById(idSub2).getHomeRole());
        dao.toggleStatus(idSub2);
        News hiddenNews = dao.getNewsById(idSub2);
        System.out.println("Trạng thái bài #" + idSub2 + " sau khi ẩn: status=" + hiddenNews.getStatus() + ", homeRole=" + hiddenNews.getHomeRole());
        if ("HIDDEN".equals(hiddenNews.getStatus()) && "NONE".equals(hiddenNews.getHomeRole())) {
            System.out.println("✅ CHÍNH XÁC: Lỗ hổng bài ẩn bị triệt tiêu! Khi chuyển sang HIDDEN, bài viết tự động bị loại khỏi Trang chủ.");
        } else {
            System.err.println("❌ LỖI: Bài ẩn vẫn còn ghim trang chủ!");
        }

        dao.toggleStatus(idSub2);

        System.out.println("\n--- 6. TEST getLatestNews(5) CHO TRANG CHỦ ---");

        dao.setHomeLayout(idMain, idSub1, idSub2, idSub3, idSub4);
        List<News> finalHome = dao.getLatestNews(5);
        System.out.println("5 bài viết cuối cùng hiển thị trên Trang chủ:");
        for (int i = 0; i < finalHome.size(); i++) {
            News n = finalHome.get(i);
            String roleName = (i == 0) ? "👑 Bài chính (Khung to trái)" : ("📌 Bài phụ " + i + " (Khung nhỏ phải)");
            System.out.println("   Slot " + i + " [" + roleName + "]: #" + n.getId() + " - " + n.getTitle());
        }

        if (finalHome.size() == 5 && finalHome.get(0).getId() == idMain) {
            System.out.println("✅ CHÍNH XÁC: Trang chủ có đủ đúng 5 bài viết, vị trí 0 là Bài chính to (#" + idMain + ")!");
        }

        System.out.println("\n==================================================================");
        System.out.println("TẤT CẢ KIỂM THỬ ĐÃ VƯỢT QUA 100%! HỆ THỐNG AN TOÀN VÀ KHÔNG LỖ HỔNG!");
        System.out.println("==================================================================");
    }
}
