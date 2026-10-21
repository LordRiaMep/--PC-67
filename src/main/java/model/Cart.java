package model;

/**
 * ============================================================================
 * [PHÂN HỆ 4: GIỎ HÀNG, ĐỘNG CƠ VOUCHER & VẬN CHUYỂN GHN]
 * Phụ trách: Bảo
 * Chức năng: Model giỏ hàng chứa danh sách các mặt hàng.
 * ============================================================================
 */

import java.util.ArrayList;
import java.util.List;

public class Cart {
    private List<CartItem> items = new ArrayList<>();

    public List<CartItem> getItems() {
        return items;
    }

    private boolean same(CartItem item, int productId, String key) {
        return item.getProduct().getId() == productId
                && item.getUpgradeKey().equals(key == null ? "" : key);
    }

    /** Cùng sản phẩm + cùng bộ nâng cấp thì cộng dồn số lượng, khác nâng cấp thì thành dòng riêng. */
    public void addItem(CartItem newItem) {
        for (CartItem item : items) {
            if (same(item, newItem.getProduct().getId(), newItem.getUpgradeKey())) {
                item.setQuantity(item.getQuantity() + newItem.getQuantity());
                return;
            }
        }
        items.add(newItem);
    }

    public double getTotalMoney() {
        double total = 0;
        for (CartItem item : items) {
            total += item.getUnitPrice() * item.getQuantity();
        }
        return total;
    }

    public void updateQuantity(int id, String key, int quantity) {
        for (CartItem item : items) {
            if (same(item, id, key)) {
                item.setQuantity(quantity);
                return;
            }
        }
    }

    public void removeItem(int id, String key) {
        items.removeIf(item -> same(item, id, key));
    }

    /** Tổng số lượng của 1 sản phẩm trong giỏ (mọi bản nâng cấp) - dùng kiểm tra tồn kho. */
    public int getTotalQuantityOfProduct(int productId) {
        int sum = 0;
        for (CartItem item : items) {
            if (item.getProduct().getId() == productId) sum += item.getQuantity();
        }
        return sum;
    }
}
