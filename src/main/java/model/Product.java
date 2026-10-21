package model;

/**
 * ============================================================================
 * [PHÂN HỆ 3: SẢN PHẨM, NÂNG CẤP PC & GEMINI AI CHATBOT]
 * Phụ trách: Nhân Hiếu
 * Chức năng: Model biểu diễn sản phẩm PC Gaming.
 * ============================================================================
 */

import java.util.ArrayList;
import java.util.List;

public class Product {
    private int id;
    private int categoryId;
    private String name;
    private String description;
    private double price;
    private String image;
    private int quantity;
    private String status;
    private String categoryName;
    private String specDetail; // mô tả chi tiết, các dòng ngăn cách bằng dấu |

    public Product() {
    }

    public Product(int id, int categoryId, String name, String description, double price, String image, int quantity, String status, String categoryName) {
        this.id = id;
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
        this.price = price;
        this.image = image;
        this.quantity = quantity;
        this.status = status;
        this.categoryName = categoryName;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getSpecDetail() { return specDetail; }
    public void setSpecDetail(String specDetail) { this.specDetail = specDetail; }

    /** Danh sách từng dòng thông số, dùng cho trang chi tiết: ${product.specList} */
    public List<String> getSpecList() {
        List<String> list = new ArrayList<>();
        if (specDetail != null && !specDetail.trim().isEmpty()) {
            for (String s : specDetail.split("\\|")) {
                s = s.trim();
                if (!s.isEmpty()) list.add(s);
            }
        } else if (description != null && !description.trim().isEmpty() && description.contains("|")) {
            for (String s : description.split("\\|")) {
                s = s.trim();
                if (!s.isEmpty()) list.add(s);
            }
        }
        return list;
    }

    /** Mỗi dòng một thông số, dùng để đổ vào textarea trong trang admin: ${product.specText} */
    public String getSpecText() {
        return String.join("\n", getSpecList());
    }
}