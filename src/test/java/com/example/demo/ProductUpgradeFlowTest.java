package com.example.demo;

import dao.ConnectDB;
import dao.ProductDao;
import dao.UpgradeDao;
import model.Product;
import model.UpgradeOption;

import java.sql.Connection;
import java.util.*;

public class ProductUpgradeFlowTest {

    public static void main(String[] args) {
        System.out.println("================================================================");
        System.out.println("  BẮT ĐẦU TEST TOÀN TRÌNH: TÙY CHỌN NÂNG CẤP & ĐỔI MÀU SẢN PHẨM");
        System.out.println("================================================================\n");

        ProductDao productDao = new ProductDao();
        UpgradeDao upgradeDao = new UpgradeDao();

        int testProductId = -1;
        try {
            // 1. Tạo sản phẩm mới
            System.out.println("[TEST 1] Tạo sản phẩm mới trong cơ sở dữ liệu...");
            Product p = new Product(0, 1, "PC Test Nâng Cấp & Màu Sắc " + System.currentTimeMillis(),
                    "Mô tả sản phẩm test", 20000000.0, "/assets/images/logo.png", 10, "ACTIVE", "PC Gaming");
            p.setSpecDetail("CPU Core i5|RAM 16GB|SSD 512GB|VGA RTX 4060");
            testProductId = productDao.insert(p);

            if (testProductId <= 0) {
                throw new RuntimeException("LỖI: Không thể tạo sản phẩm test!");
            }
            System.out.println(" -> Đã tạo sản phẩm test ID: " + testProductId);

            // 2. Thiết lập tùy chọn Nâng cấp linh kiện & Đổi màu sắc cho sản phẩm này
            System.out.println("\n[TEST 2] Thiết lập các tùy chọn (Màu sắc & RAM) cho sản phẩm mới...");
            List<UpgradeOption> options = new ArrayList<>();
            // Nhóm 1: Màu sắc
            options.add(new UpgradeOption(testProductId, "Màu sắc", "Màu Đen (Black)", 0.0, true));
            options.add(new UpgradeOption(testProductId, "Màu sắc", "Màu Trắng (White)", 0.0, false));
            options.add(new UpgradeOption(testProductId, "Màu sắc", "Màu Hồng (Pink)", 150000.0, false));
            // Nhóm 2: RAM
            options.add(new UpgradeOption(testProductId, "RAM", "16GB DDR5 5600MHz", 0.0, true));
            options.add(new UpgradeOption(testProductId, "RAM", "32GB (2x16GB) DDR5 5600MHz", 1200000.0, false));

            boolean saveOk = upgradeDao.saveProductOptions(testProductId, options);
            if (!saveOk) {
                throw new RuntimeException("LỖI: saveProductOptions trả về false!");
            }
            System.out.println(" -> Đã lưu thành công " + options.size() + " tùy chọn cho sản phẩm ID " + testProductId);

            // 3. Kiểm tra đọc lại dữ liệu theo nhóm (getGroupsByProduct)
            System.out.println("\n[TEST 3] Kiểm tra gom nhóm (getGroupsByProduct)...");
            Map<String, List<UpgradeOption>> groups = upgradeDao.getGroupsByProduct(testProductId);
            if (groups.size() != 2) {
                throw new RuntimeException("LỖI: Mong đợi 2 nhóm (Màu sắc, RAM), nhưng nhận được " + groups.size());
            }
            if (!groups.containsKey("Màu sắc") || !groups.containsKey("RAM")) {
                throw new RuntimeException("LỖI: Thiếu nhóm Màu sắc hoặc RAM!");
            }
            System.out.println(" -> Nhóm tìm thấy: " + groups.keySet());
            for (String g : groups.keySet()) {
                System.out.println("    Nhóm [" + g + "]: " + groups.get(g).size() + " lựa chọn");
                for (UpgradeOption opt : groups.get(g)) {
                    System.out.println("       + " + opt.getName() + " (+" + opt.getPriceDelta() + " đ, Mặc định: " + opt.isDefaultOption() + ")");
                }
            }

            // 4. Kiểm tra đếm số lượng tùy chọn (getOptionCountByProductIds)
            System.out.println("\n[TEST 4] Kiểm tra đếm số lượng tùy chọn (getOptionCountByProductIds)...");
            Map<Integer, Integer> countMap = upgradeDao.getOptionCountByProductIds(Collections.singletonList(testProductId));
            int cnt = countMap.getOrDefault(testProductId, 0);
            if (cnt != 5) {
                throw new RuntimeException("LỖI: Mong đợi 5 tùy chọn, nhưng nhận được " + cnt);
            }
            System.out.println(" -> Đếm chính xác: " + cnt + " tùy chọn cho sản phẩm ID " + testProductId);

            // 5. Mô phỏng khách hàng chọn Màu Trắng (+0đ) và RAM 32GB (+1.200.000đ)
            System.out.println("\n[TEST 5] Mô phỏng logic tính tiền & hiển thị khi khách chọn Màu Trắng & RAM 32GB...");
            UpgradeOption chosenColor = null;
            UpgradeOption chosenRam = null;
            for (UpgradeOption opt : groups.get("Màu sắc")) {
                if (opt.getName().contains("Trắng")) chosenColor = opt;
            }
            for (UpgradeOption opt : groups.get("RAM")) {
                if (opt.getName().contains("32GB")) chosenRam = opt;
            }

            if (chosenColor == null || chosenRam == null) {
                throw new RuntimeException("LỖI: Không tìm thấy lựa chọn mong đợi!");
            }

            double basePrice = p.getPrice();
            double finalPrice = basePrice + chosenColor.getPriceDelta() + chosenRam.getPriceDelta();
            System.out.println(" -> Giá gốc: " + basePrice + " đ");
            System.out.println(" -> Chọn màu: " + chosenColor.getName() + " (+" + chosenColor.getPriceDelta() + " đ)");
            System.out.println(" -> Chọn RAM: " + chosenRam.getName() + " (+" + chosenRam.getPriceDelta() + " đ)");
            System.out.println(" -> Tổng tiền đơn hàng: " + finalPrice + " đ (Kỳ vọng: 21,200,000 đ)");
            if (finalPrice != 21200000.0) {
                throw new RuntimeException("LỖI: Sai lệch tiền!");
            }

            // 6. Cập nhật tùy chọn (sửa đổi hoặc thêm nhóm mới)
            System.out.println("\n[TEST 6] Cập nhật tùy chọn: Thêm nhóm 'Ổ cứng SSD'...");
            options.add(new UpgradeOption(testProductId, "Ổ cứng SSD", "SSD 1TB NVMe Gen 4", 800000.0, false));
            boolean updateOk = upgradeDao.saveProductOptions(testProductId, options);
            if (!updateOk) {
                throw new RuntimeException("LỖI: Cập nhật tùy chọn thất bại!");
            }
            List<UpgradeOption> updatedList = upgradeDao.getOptionsByProductId(testProductId);
            System.out.println(" -> Số lượng tùy chọn sau khi cập nhật: " + updatedList.size() + " (Kỳ vọng: 6)");
            if (updatedList.size() != 6) {
                throw new RuntimeException("LỖI: Số lượng tùy chọn không đúng sau cập nhật!");
            }

            // 7. Xóa sản phẩm và dọn dẹp sạch sẽ
            System.out.println("\n[TEST 7] Xóa sản phẩm và kiểm tra ràng buộc khóa ngoại...");
            boolean delOk = productDao.delete(testProductId);
            if (!delOk) {
                throw new RuntimeException("LỖI: Không thể xóa sản phẩm test (có thể do lỗi FK)!");
            }
            System.out.println(" -> Xóa sản phẩm thành công!");

            // Kiểm tra xem nang_cap đã được dọn sạch chưa
            List<UpgradeOption> remainOptions = upgradeDao.getOptionsByProductId(testProductId);
            if (!remainOptions.isEmpty()) {
                throw new RuntimeException("LỖI: Vẫn còn tùy chọn rác trong nang_cap!");
            }
            System.out.println(" -> Các tùy chọn trong nang_cap đã được xóa dọn sạch sẽ.");

            System.out.println("\n================================================================");
            System.out.println("  TẤT CẢ 7 TEST CASE ĐÃ VƯỢT QUA XUẤT SẮC - LOGIC HOÀN HẢO!");
            System.out.println("================================================================");

        } catch (Exception e) {
            System.err.println("\n>>> TEST THẤT BẠI: " + e.getMessage());
            e.printStackTrace();
            // Cố gắng dọn dẹp nếu có lỗi
            if (testProductId > 0) {
                try { productDao.delete(testProductId); } catch (Exception ignored) {}
            }
        }
    }
}
