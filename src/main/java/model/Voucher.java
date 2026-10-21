package model;

/**
 * ============================================================================
 * [PHÂN HỆ 4: GIỎ HÀNG, ĐỘNG CƠ VOUCHER & VẬN CHUYỂN GHN]
 * Phụ trách: Bảo
 * Chức năng: Model voucher kèm thuật toán tính giảm giá.
 * ============================================================================
 */

import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

/**
 * Model đại diện cho Voucher / Mã giảm giá
 */
public class Voucher {
    private int id;
    private String code;
    private String name;
    private String discountType; // "PERCENT" hoặc "FIXED"
    private double discountValue; // % (ví dụ 10) hoặc số tiền VNĐ (ví dụ 100000)
    private Double maxDiscountAmount; // Mức giảm tối đa (cho PERCENT), có thể null
    private double minOrderAmount; // Giá trị đơn hàng / sản phẩm tối thiểu để áp dụng
    private int usageLimit; // Số lượt dùng tối đa
    private int usedCount; // Số lượt đã dùng
    private Timestamp startDate; // Ngày bắt đầu hiệu lực
    private Timestamp endDate; // Ngày hết hạn
    private String status; // "ACTIVE" hoặc "INACTIVE"
    private Timestamp createdAt;

    public Voucher() {
        this.status = "ACTIVE";
        this.usageLimit = 100;
        this.usedCount = 0;
        this.minOrderAmount = 0.0;
        this.discountType = "PERCENT";
    }

    public Voucher(int id, String code, String name, String discountType, double discountValue,
                   Double maxDiscountAmount, double minOrderAmount, int usageLimit, int usedCount,
                   Timestamp startDate, Timestamp endDate, String status) {
        this.id = id;
        this.code = (code != null) ? code.trim().toUpperCase() : "";
        this.name = name;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.maxDiscountAmount = maxDiscountAmount;
        this.minOrderAmount = minOrderAmount;
        this.usageLimit = usageLimit;
        this.usedCount = usedCount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = (code != null) ? code.trim().toUpperCase() : ""; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public double getDiscountValue() { return discountValue; }
    public void setDiscountValue(double discountValue) { this.discountValue = discountValue; }

    public Double getMaxDiscountAmount() { return maxDiscountAmount; }
    public void setMaxDiscountAmount(Double maxDiscountAmount) { this.maxDiscountAmount = maxDiscountAmount; }

    public double getMinOrderAmount() { return minOrderAmount; }
    public void setMinOrderAmount(double minOrderAmount) { this.minOrderAmount = minOrderAmount; }

    public int getUsageLimit() { return usageLimit; }
    public void setUsageLimit(int usageLimit) { this.usageLimit = usageLimit; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }

    public Timestamp getEndDate() { return endDate; }
    public void setEndDate(Timestamp endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // ==========================================
    // LOGIC NGHIỆP VỤ (BUSINESS LOGIC)
    // ==========================================

    public boolean isPercent() {
        return "PERCENT".equalsIgnoreCase(discountType);
    }

    public boolean isFixed() {
        return "FIXED".equalsIgnoreCase(discountType);
    }

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(status);
    }

    public boolean isExpired() {
        if (endDate == null) return false;
        return System.currentTimeMillis() > endDate.getTime();
    }

    public boolean isNotStarted() {
        if (startDate == null) return false;
        return System.currentTimeMillis() < startDate.getTime();
    }

    public boolean isUsageExceeded() {
        return usageLimit > 0 && usedCount >= usageLimit;
    }

    /**
     * Voucher có đang trong trạng thái có thể sử dụng được nói chung không
     */
    public boolean isUsableNow() {
        return isActive() && !isExpired() && !isNotStarted() && !isUsageExceeded();
    }

    /**
     * Kiểm tra xem voucher có áp dụng được cho số tiền cụ thể hay không
     */
    public boolean isApplicableFor(double amount) {
        if (!isUsableNow()) return false;
        return amount >= minOrderAmount;
    }

    /**
     * Tính toán số tiền được giảm thực tế
     */
    public double calculateDiscount(double amount) {
        if (!isApplicableFor(amount) || amount <= 0) {
            return 0.0;
        }

        double discount = 0.0;
        if (isPercent()) {
            discount = amount * (discountValue / 100.0);
            if (maxDiscountAmount != null && maxDiscountAmount > 0) {
                discount = Math.min(discount, maxDiscountAmount);
            }
        } else {
            discount = discountValue;
        }

        // Không được giảm vượt quá tổng số tiền
        return Math.min(discount, amount);
    }

    public int getRemainingUsage() {
        return Math.max(0, usageLimit - usedCount);
    }

    public String getFormattedDiscount() {
        DecimalFormat df = new DecimalFormat("#,##0");
        if (isPercent()) {
            String text = "Giảm " + df.format(discountValue) + "%";
            if (maxDiscountAmount != null && maxDiscountAmount > 0) {
                text += " (Tối đa " + df.format(maxDiscountAmount) + "đ)";
            }
            return text;
        } else {
            return "Giảm " + df.format(discountValue) + " đ";
        }
    }

    public String getFormattedMinOrder() {
        if (minOrderAmount <= 0) return "Đơn bất kỳ";
        DecimalFormat df = new DecimalFormat("#,##0");
        return "Đơn từ " + df.format(minOrderAmount) + " đ";
    }

    public String getStartDateFormatted() {
        if (startDate == null) return "";
        return new SimpleDateFormat("yyyy-MM-dd").format(startDate);
    }

    public String getEndDateFormatted() {
        if (endDate == null) return "";
        return new SimpleDateFormat("yyyy-MM-dd").format(endDate);
    }

    public String getStartDateDisplay() {
        if (startDate == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy").format(startDate);
    }

    public String getEndDateDisplay() {
        if (endDate == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy").format(endDate);
    }
}
