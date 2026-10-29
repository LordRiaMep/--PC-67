package model;

public class CartItem {
    private Product product;
    private int quantity;

    private String upgradeKey = "";
    private String upgradeInfo = "";
    private String displayName;
    private double unitPrice;

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
