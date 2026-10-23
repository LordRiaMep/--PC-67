package model;

import java.io.Serializable;

/**
 * ============================================================================
 * Model thống kê lãi kinh doanh, cơ cấu doanh thu & lợi nhuận (Products vs Services)
 * ============================================================================
 */
public class ProfitStats implements Serializable {
    private double totalRevenue;        // Tổng doanh thu đơn hợp lệ
    private double productRevenue;     // Doanh thu từ Sản phẩm phần cứng
    private double serviceRevenue;     // Doanh thu từ Dịch vụ (nâng cấp + vận chuyển)
    private double totalProfit;         // Tổng lãi kinh doanh ước tính (đã trừ Voucher theo Phương án B)
    private double productProfit;      // Lãi từ Sản phẩm (Hardware margin ~18%)
    private double serviceProfit;      // Lãi từ Dịch vụ (Upgrades & Services margin ~65%)
    private double voucherDiscount;    // Tổng tiền Voucher giảm giá đã trừ vào Tổng lãi
    private double productPercent;     // % Lãi Sản phẩm trong tổng lãi
    private double servicePercent;     // % Lãi Dịch vụ trong tổng lãi
    private double productRevPercent;  // % Doanh thu Sản phẩm trong tổng doanh thu
    private double serviceRevPercent;  // % Doanh thu Dịch vụ trong tổng doanh thu
    private int activeOrdersCount;     // Số đơn hàng hợp lệ
    private int cancelledOrdersCount;  // Số đơn đã hủy
    private double cancelledAmount;    // Tổng tiền các đơn đã hủy
    private double profitMargin;       // Tỷ suất sinh lời bình quân (%)

    public ProfitStats() {
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public double getProductRevenue() {
        return productRevenue;
    }

    public void setProductRevenue(double productRevenue) {
        this.productRevenue = productRevenue;
    }

    public double getServiceRevenue() {
        return serviceRevenue;
    }

    public void setServiceRevenue(double serviceRevenue) {
        this.serviceRevenue = serviceRevenue;
    }

    public double getTotalProfit() {
        return totalProfit;
    }

    public void setTotalProfit(double totalProfit) {
        this.totalProfit = totalProfit;
    }

    public double getProductProfit() {
        return productProfit;
    }

    public void setProductProfit(double productProfit) {
        this.productProfit = productProfit;
    }

    public double getServiceProfit() {
        return serviceProfit;
    }

    public void setServiceProfit(double serviceProfit) {
        this.serviceProfit = serviceProfit;
    }

    public double getVoucherDiscount() {
        return voucherDiscount;
    }

    public void setVoucherDiscount(double voucherDiscount) {
        this.voucherDiscount = voucherDiscount;
    }

    public double getProductPercent() {
        return productPercent;
    }

    public void setProductPercent(double productPercent) {
        this.productPercent = productPercent;
    }

    public double getServicePercent() {
        return servicePercent;
    }

    public void setServicePercent(double servicePercent) {
        this.servicePercent = servicePercent;
    }

    public double getProductRevPercent() {
        return productRevPercent;
    }

    public void setProductRevPercent(double productRevPercent) {
        this.productRevPercent = productRevPercent;
    }

    public double getServiceRevPercent() {
        return serviceRevPercent;
    }

    public void setServiceRevPercent(double serviceRevPercent) {
        this.serviceRevPercent = serviceRevPercent;
    }

    public int getActiveOrdersCount() {
        return activeOrdersCount;
    }

    public void setActiveOrdersCount(int activeOrdersCount) {
        this.activeOrdersCount = activeOrdersCount;
    }

    public int getCancelledOrdersCount() {
        return cancelledOrdersCount;
    }

    public void setCancelledOrdersCount(int cancelledOrdersCount) {
        this.cancelledOrdersCount = cancelledOrdersCount;
    }

    public double getCancelledAmount() {
        return cancelledAmount;
    }

    public void setCancelledAmount(double cancelledAmount) {
        this.cancelledAmount = cancelledAmount;
    }

    public double getProfitMargin() {
        return profitMargin;
    }

    public void setProfitMargin(double profitMargin) {
        this.profitMargin = profitMargin;
    }
}
