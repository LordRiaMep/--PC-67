package model;

public class UpgradeOption {
    private int id;
    private int productId;
    private String groupName;
    private String name;
    private double priceDelta;
    private boolean defaultOption;

    public UpgradeOption() {}

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

    // JSP EL: ${opt.defaultOption}
    public boolean isDefaultOption() { return defaultOption; }
    public void setDefaultOption(boolean defaultOption) { this.defaultOption = defaultOption; }
}
