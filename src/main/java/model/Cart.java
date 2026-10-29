package model;

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

    public int getTotalQuantityOfProduct(int productId) {
        int sum = 0;
        for (CartItem item : items) {
            if (item.getProduct().getId() == productId) sum += item.getQuantity();
        }
        return sum;
    }

    public int getTotalQuantity() {
        int sum = 0;
        for (CartItem item : items) {
            sum += item.getQuantity();
        }
        return sum;
    }

    public int getItemCount() {
        return items.size();
    }
}
