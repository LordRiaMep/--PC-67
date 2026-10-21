package model;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Model biểu diễn chi tiết từng sản phẩm trong đơn hàng.
 * ============================================================================
 */

public class OrderDetail {
    private int id;
    private int orderId;
    private int productId;
    private String productName;
    private double price;
    private int quantity;
    private String upgradeInfo;   // các dòng nâng cấp, ngăn cách bằng '|'

    public OrderDetail() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getUpgradeInfo() { return upgradeInfo; }
    public void setUpgradeInfo(String upgradeInfo) { this.upgradeInfo = upgradeInfo; }
}