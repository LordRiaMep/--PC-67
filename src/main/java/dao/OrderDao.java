package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Cart;
import model.CartItem;
import model.Order;
import model.OrderDetail;

public class OrderDao {

    public int saveOrder(int userId, String name, String phone, String address, String note, Cart cart, String paymentMethod) {
        int orderId = 0;
        String sqlOrder = "INSERT INTO hoa_don (user_id, receiver_name, receiver_phone, receiver_address, note, total_amount, payment_method, order_status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')";
        String sqlDetail = "INSERT INTO hoa_don_chi_tiet (invoice_id, product_id, product_name, product_image, price_at_purchase, quantity, line_total, upgrade_info) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlUpdateStock = "UPDATE san_pham SET quantity = quantity - ? WHERE id = ? AND quantity >= ?";

        try (Connection conn = ConnectDB.getConnect()) {
            conn.setAutoCommit(false);

            try {
                try (PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                    psOrder.setInt(1, userId);
                    psOrder.setString(2, name);
                    psOrder.setString(3, phone);
                    psOrder.setString(4, address);
                    psOrder.setString(5, note);
                    psOrder.setDouble(6, cart.getTotalMoney());
                    psOrder.setString(7, "QR".equals(paymentMethod) ? "QR" : "COD");
                    psOrder.executeUpdate();

                    try (ResultSet rs = psOrder.getGeneratedKeys()) {
                        if (rs.next()) {
                            orderId = rs.getInt(1);
                        } else {
                            throw new SQLException("Không thể tạo ID cho hóa đơn.");
                        }
                    }
                }

                if (orderId > 0) {
                    try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
                         PreparedStatement psStock = conn.prepareStatement(sqlUpdateStock)) {

                        java.util.Map<Integer, Integer> stockByProduct = new java.util.LinkedHashMap<>();

                        for (CartItem item : cart.getItems()) {
                            double price = item.getUnitPrice();   // giá đã gồm tiền nâng cấp
                            int quantity = item.getQuantity();

                            psDetail.setInt(1, orderId);
                            psDetail.setInt(2, item.getProduct().getId());
                            psDetail.setString(3, item.getDisplayName());   // tên đã gắn linh kiện nâng cấp
                            psDetail.setString(4, item.getProduct().getImage());
                            psDetail.setDouble(5, price);
                            psDetail.setInt(6, quantity);
                            psDetail.setDouble(7, price * quantity);
                            String info = item.getUpgradeInfo();
                            psDetail.setString(8, (info == null || info.isEmpty()) ? null : info);
                            psDetail.addBatch();

                            stockByProduct.merge(item.getProduct().getId(), quantity, Integer::sum);
                        }

                        for (java.util.Map.Entry<Integer, Integer> e : stockByProduct.entrySet()) {
                            psStock.setInt(1, e.getValue());
                            psStock.setInt(2, e.getKey());
                            psStock.setInt(3, e.getValue());
                            psStock.addBatch();
                        }

                        psDetail.executeBatch();
                        int[] stockUpdates = psStock.executeBatch();

                        for (int updateCount : stockUpdates) {
                            if (updateCount == 0) {
                                throw new SQLException("Sản phẩm đã hết hàng hoặc không đủ số lượng!");
                            }
                        }
                    }
                }

                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                return 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return orderId;
    }

    public List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM hoa_don WHERE user_id = ? ORDER BY id DESC";

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order order = new Order();
                order.setId(rs.getInt("id"));
                order.setReceiverName(rs.getString("receiver_name"));
                order.setTotalMoney(rs.getDouble("total_amount"));
                order.setStatus(rs.getString("order_status"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(order);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Order getOrderById(int orderId) {
        String sql = "SELECT hd.*, u.email FROM hoa_don hd LEFT JOIN users u ON hd.user_id = u.id WHERE hd.id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order order = new Order();
                order.setId(rs.getInt("id"));
                order.setReceiverName(rs.getString("receiver_name"));
                order.setReceiverPhone(rs.getString("receiver_phone"));
                order.setReceiverAddress(rs.getString("receiver_address"));
                order.setNote(rs.getString("note"));
                order.setTotalMoney(rs.getDouble("total_amount"));
                order.setStatus(rs.getString("order_status"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCreatedAt(rs.getTimestamp("created_at"));

                String realEmail = rs.getString("email");
                order.setEmail(realEmail != null ? realEmail : "Không có email");
                return order;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<OrderDetail> getOrderDetails(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM hoa_don_chi_tiet WHERE invoice_id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderDetail detail = new OrderDetail();
                detail.setProductName(rs.getString("product_name"));
                detail.setPrice(rs.getDouble("price_at_purchase"));
                detail.setQuantity(rs.getInt("quantity"));
                detail.setUpgradeInfo(rs.getString("upgrade_info"));
                list.add(detail);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT hd.*, u.email FROM hoa_don hd LEFT JOIN users u ON hd.user_id = u.id ORDER BY hd.id DESC";

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order order = new Order();
                order.setId(rs.getInt("id"));
                order.setReceiverName(rs.getString("receiver_name"));
                order.setReceiverPhone(rs.getString("receiver_phone"));
                order.setReceiverAddress(rs.getString("receiver_address"));
                order.setTotalMoney(rs.getDouble("total_amount"));
                order.setStatus(rs.getString("order_status"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCreatedAt(rs.getTimestamp("created_at"));

                String realEmail = rs.getString("email");
                order.setEmail(realEmail != null ? realEmail : "Không có email");

                list.add(order);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void updateStatus(int orderId, String status) {
        // Đơn QR chưa thanh toán thì không cho chuyển sang Đã xác nhận / Đang giao / Hoàn thành
        String sql = "UPDATE hoa_don SET order_status = ? WHERE id = ? "
                + "AND NOT (payment_method = 'QR' AND payment_status = 'UNPAID' "
                + "AND ? IN ('CONFIRMED', 'SHIPPING', 'FINISH', 'COMPLETED'))";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.setString(3, status);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Admin xác nhận đã nhận tiền chuyển khoản QR
    public void markPaid(int orderId) {
        String sql = "UPDATE hoa_don SET payment_status = 'PAID' WHERE id = ? AND payment_method = 'QR'";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int getTotalOrdersCount() {
        String sql = "SELECT COUNT(*) FROM hoa_don";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Order> getOrdersByPage(int offset, int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT hd.*, u.email FROM hoa_don hd LEFT JOIN users u ON hd.user_id = u.id ORDER BY hd.id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setId(rs.getInt("id"));
                    order.setReceiverName(rs.getString("receiver_name"));
                    order.setReceiverPhone(rs.getString("receiver_phone"));
                    order.setReceiverAddress(rs.getString("receiver_address"));
                    order.setTotalMoney(rs.getDouble("total_amount"));
                    order.setStatus(rs.getString("order_status"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    order.setCreatedAt(rs.getTimestamp("created_at"));

                    String realEmail = rs.getString("email");
                    order.setEmail(realEmail != null ? realEmail : "Không có email");

                    list.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}