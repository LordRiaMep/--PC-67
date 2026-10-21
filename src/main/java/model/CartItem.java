package model;

/**
 * ============================================================================
 * [PHÂN HỆ 4: GIỎ HÀNG, ĐỘNG CƠ VOUCHER & VẬN CHUYỂN GHN]
 * Phụ trách: Bảo
 * Chức năng: Model một dòng sản phẩm trong giỏ kèm các tùy chọn nâng cấp.
 * ============================================================================
 */

public class CartItem {
    private Product product;
    private int quantity;

    // --- Thông tin nâng cấp ---
    private String upgradeKey = "";     // vd "12,40" (id linh kiện đã sắp xếp), "" = cấu hình gốc
    private String upgradeInfo = "";    // vd "CPU: Core i5-13400F (+1.500.000 đ)|RAM: ..." (ngăn cách bằng |)
    private String displayName;         // tên đã gắn linh kiện nâng cấp
    private double unitPrice;           // đơn giá = giá gốc + tiền nâng cấp

    public CartItem() {
    }

    public CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
        this.displayName = product.getName();
        this.unitPrice = product.getPrice();
    }

    public CartItem(Product product, int quantity, String upgradeKey, String upgradeInfo,
                    String displayName, double unitPrice) {
        this.product = product;
        this.quantity = quantity;
        this.upgradeKey = upgradeKey == null ? "" : upgradeKey;
        this.upgradeInfo = upgradeInfo == null ? "" : upgradeInfo;
        this.displayName = displayName;
        this.unitPrice = unitPrice;
    }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getUpgradeKey() { return upgradeKey; }
    public void setUpgradeKey(String upgradeKey) { this.upgradeKey = upgradeKey; }

    public String getUpgradeInfo() { return upgradeInfo; }
    public void setUpgradeInfo(String upgradeInfo) { this.upgradeInfo = upgradeInfo; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }

    public double getLineTotal() { return unitPrice * quantity; }
}
