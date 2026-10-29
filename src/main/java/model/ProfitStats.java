package model;

import java.io.Serializable;

public class ProfitStats implements Serializable {
    private double totalRevenue;
    private double productRevenue;
    private double serviceRevenue;
    private double totalProfit;
    private double productProfit;
    private double serviceProfit;
    private double voucherDiscount;
    private double productPercent;
    private double servicePercent;
    private double productRevPercent;
    private double serviceRevPercent;
    private int activeOrdersCount;
    private int cancelledOrdersCount;
    private double cancelledAmount;
    private double profitMargin;

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
