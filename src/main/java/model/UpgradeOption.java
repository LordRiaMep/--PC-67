package model;

public class UpgradeOption {
    private int id;
    private int productId;
    private String groupName;
    private String name;
    private double priceDelta;
    private boolean defaultOption;
    private int sortOrder = 0;
    private String status = "ACTIVE";

    public UpgradeOption() {}

    public UpgradeOption(int productId, String groupName, String name, double priceDelta, boolean defaultOption) {
        this.productId = productId;
        this.groupName = groupName;
        this.name = name;
        this.priceDelta = priceDelta;
        this.defaultOption = defaultOption;
        this.status = "ACTIVE";
    }

    public UpgradeOption(int id, int productId, String groupName, String name, double priceDelta, boolean defaultOption, int sortOrder, String status) {
        this.id = id;
        this.productId = productId;
        this.groupName = groupName;
        this.name = name;
        this.priceDelta = priceDelta;
        this.defaultOption = defaultOption;
        this.sortOrder = sortOrder;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getPriceDelta() { return priceDelta; }
    public void setPriceDelta(double priceDelta) { this.priceDelta = priceDelta; }

    public boolean isDefaultOption() { return defaultOption; }
    public void setDefaultOption(boolean defaultOption) { this.defaultOption = defaultOption; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
