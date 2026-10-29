package com.example.demo;

import dao.ConnectDB;
import dao.VoucherDao;
import model.Voucher;

import java.sql.Connection;
import java.sql.Timestamp;
import java.util.List;

public class VoucherFlowTest {

    public static void main(String[] args) {
        System.out.println("=== BẮT ĐẦU TEST TOÀN DIỆN HỆ THỐNG VOUCHER ===");

        System.out.println("\n[1] Kiểm tra logic tính toán Voucher...");
        Voucher vPercent = new Voucher();
        vPercent.setCode("TEST10");
        vPercent.setName("Giảm 10%");
        vPercent.setDiscountType("PERCENT");
        vPercent.setDiscountValue(10.0);
        vPercent.setMaxDiscountAmount(null);
        vPercent.setMinOrderAmount(1000000.0);
        vPercent.setUsageLimit(50);
        vPercent.setUsedCount(0);
        vPercent.setStartDate(new Timestamp(System.currentTimeMillis() - 100000));
        vPercent.setEndDate(new Timestamp(System.currentTimeMillis() + 100000000));
        vPercent.setStatus("ACTIVE");

        assertEqual(0.0, vPercent.calculateDiscount(500000.0), "Đơn 500k chưa đạt min 1tr");

        assertEqual(200000.0, vPercent.calculateDiscount(2000000.0), "Đơn 2tr giảm 10% = 200k");

        vPercent.setMaxDiscountAmount(150000.0);
        assertEqual(150000.0, vPercent.calculateDiscount(2000000.0), "Đơn 2tr giảm 10% nhưng bị chặn tối đa 150k");

        Voucher vFixed = new Voucher();
        vFixed.setCode("TESTFIXED");
        vFixed.setName("Giảm 100k");
        vFixed.setDiscountType("FIXED");
        vFixed.setDiscountValue(100000.0);
        vFixed.setMinOrderAmount(500000.0);
        vFixed.setStartDate(new Timestamp(System.currentTimeMillis() - 100000));
        vFixed.setEndDate(new Timestamp(System.currentTimeMillis() + 100000000));
        vFixed.setStatus("ACTIVE");

        assertEqual(0.0, vFixed.calculateDiscount(300000.0), "Đơn 300k chưa đạt min 500k");
        assertEqual(100000.0, vFixed.calculateDiscount(1000000.0), "Đơn 1tr giảm cố định 100k");

        System.out.println("-> Logic tính toán giảm giá: ĐẠT!");

        System.out.println("\n[2] Kiểm tra thao tác CSDL VoucherDao (CRUD)...");
        VoucherDao dao = new VoucherDao();

        List<Voucher> activeList = dao.getActiveVouchers();
        if (activeList == null || activeList.isEmpty()) {
            throw new RuntimeException("Lỗi: Danh sách voucher hoạt động rỗng!");
        }
        System.out.println("-> Tìm thấy " + activeList.size() + " voucher đang hoạt động trong DB.");

        String testCode = "TEST" + (System.currentTimeMillis() % 10000);
        Voucher newVoucher = new Voucher();
        newVoucher.setCode(testCode);
        newVoucher.setName("Voucher kiểm thử tự động");
        newVoucher.setDiscountType("FIXED");
        newVoucher.setDiscountValue(50000);
        newVoucher.setMinOrderAmount(200000);
        newVoucher.setUsageLimit(10);
        newVoucher.setStartDate(new Timestamp(System.currentTimeMillis() - 60000));
        newVoucher.setEndDate(new Timestamp(System.currentTimeMillis() + 86400000L));
        newVoucher.setStatus("ACTIVE");

        int id = dao.insert(newVoucher);
        if (id <= 0) throw new RuntimeException("Lỗi: Không thể insert voucher mới!");
        System.out.println("-> Thêm mới voucher thành công, ID = " + id + ", Code = " + testCode);

        Voucher fetched = dao.getById(id);
        if (fetched == null || !testCode.equalsIgnoreCase(fetched.getCode())) {
            throw new RuntimeException("Lỗi: Không tìm thấy voucher vừa thêm!");
        }
        System.out.println("-> Tìm voucher theo ID thành công: " + fetched.getName());

        try (Connection conn = ConnectDB.getConnect()) {
            dao.incrementUsedCount(testCode, conn);
        } catch (Exception e) {
            throw new RuntimeException("Lỗi incrementUsedCount: " + e.getMessage());
        }

        Voucher updated = dao.getById(id);
        assertEqual(1.0, (double) updated.getUsedCount(), "Lượt dùng phải tăng lên 1");
        System.out.println("-> Tăng lượt dùng voucher thành công: " + updated.getUsedCount() + "/" + updated.getUsageLimit());

        boolean deleted = dao.delete(id);
        if (!deleted) throw new RuntimeException("Lỗi: Không thể xóa voucher test!");
        System.out.println("-> Xóa voucher kiểm thử an toàn thành công!");

        System.out.println("\n=== TẤT CẢ KIỂM THỬ VOUCHER ĐÃ VƯỢT QUA XUẤT SẮC! ===");
    }

    private static void assertEqual(double expected, double actual, String message) {
        if (Math.abs(expected - actual) > 0.001) {
            throw new AssertionError("Thất bại [" + message + "]: Kỳ vọng " + expected + " nhưng thực tế là " + actual);
        }
    }
}
