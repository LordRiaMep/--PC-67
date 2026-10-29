package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Cart;
import model.CartItem;
import model.Order;
import model.OrderDetail;

public class OrderDao {

    private void readTransfer(ResultSet rs, Order order) throws SQLException {
        order.setTransferAmount(rs.getDouble("transfer_amount"));
        order.setVnpayTxnNo(rs.getString("vnpay_txn_no"));
        order.setTransferredAt(rs.getTimestamp("transferred_at"));
        try {
            order.setStockRestored(rs.getBoolean("is_stock_restored"));
        } catch (SQLException ignored) {}
        try {
            order.setVoucherCode(rs.getString("voucher_code"));
            order.setDiscountAmount(rs.getDouble("discount_amount"));
        } catch (SQLException ignored) {}
    }

    public int saveOrder(int userId, String name, String phone, String address, String note, Cart cart, String paymentMethod) {
        return saveOrder(userId, name, phone, address, note, cart, paymentMethod, 0.0, null, 0.0);
    }

    public int saveOrder(int userId, String name, String phone, String address, String note, Cart cart, String paymentMethod, double shippingFee) {
        return saveOrder(userId, name, phone, address, note, cart, paymentMethod, shippingFee, null, 0.0);
    }

    public int saveOrder(int userId, String name, String phone, String address, String note, Cart cart, String paymentMethod, double shippingFee, String voucherCode, double discountAmount) {
        int orderId = 0;
        String sqlOrder = "INSERT INTO hoa_don (user_id, receiver_name, receiver_phone, receiver_address, note, total_amount, payment_method, order_status, shipping_fee, is_stock_restored, voucher_code, discount_amount) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING', ?, 0, ?, ?)";
        String sqlDetail = "INSERT INTO hoa_don_chi_tiet (invoice_id, product_id, product_name, product_image, price_at_purchase, quantity, line_total, upgrade_info) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlUpdateStock = "UPDATE san_pham SET quantity = quantity - ? WHERE id = ? AND quantity >= ?";

        try (Connection conn = ConnectDB.getConnect()) {
            conn.setAutoCommit(false);

            try {
                double finalTotal = Math.max(0, cart.getTotalMoney() - discountAmount) + shippingFee;
                try (PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                    psOrder.setInt(1, userId);
                    psOrder.setString(2, name);
                    psOrder.setString(3, phone);
                    psOrder.setString(4, address);
                    psOrder.setString(5, note);
                    psOrder.setDouble(6, finalTotal);
                    psOrder.setString(7, "QR".equals(paymentMethod) ? "QR" : "COD");
                    psOrder.setDouble(8, shippingFee);
                    if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                        psOrder.setString(9, voucherCode.trim().toUpperCase());
                    } else {
                        psOrder.setNull(9, Types.VARCHAR);
                    }
                    psOrder.setDouble(10, discountAmount);
                    psOrder.executeUpdate();

                    try (ResultSet rs = psOrder.getGeneratedKeys()) {
                        if (rs.next()) {
                            orderId = rs.getInt(1);
                        } else {
                            throw new SQLException("Không thể tạo ID cho hóa đơn.");
                        }
                    }
                }

                if (voucherCode != null && !voucherCode.trim().isEmpty() && discountAmount > 0) {
                    new VoucherDao().incrementUsedCount(voucherCode, conn);
                }

                if (orderId > 0) {
                    try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
                         PreparedStatement psStock = conn.prepareStatement(sqlUpdateStock)) {

                        java.util.Map<Integer, Integer> stockByProduct = new java.util.LinkedHashMap<>();

                        for (CartItem item : cart.getItems()) {
                            double price = item.getUnitPrice();
                            int quantity = item.getQuantity();

                            psDetail.setInt(1, orderId);
                            psDetail.setInt(2, item.getProduct().getId());
                            psDetail.setString(3, item.getDisplayName());
                            psDetail.setString(4, item.getProduct().getImage());
                            psDetail.setDouble(5, price);
                            psDetail.setInt(6, quantity);
                            psDetail.setDouble(7, price * quantity);
                            String info = item.getUpgradeInfo();
                            psDetail.setString(8, (info == null || info.isEmpty()) ? null : info);
                            psDetail.addBatch();

                            stockByProduct.merge(item.getProduct().getId(), quantity, Integer::sum);
                        }

                        String sqlSelectStock = "SELECT quantity, name FROM san_pham WITH (UPDLOCK) WHERE id = ?";
                        try (PreparedStatement psCheck = conn.prepareStatement(sqlSelectStock)) {
                            for (java.util.Map.Entry<Integer, Integer> e : stockByProduct.entrySet()) {
                                psCheck.setInt(1, e.getKey());
                                try (ResultSet rsStock = psCheck.executeQuery()) {
                                    if (rsStock.next()) {
                                        int curStock = rsStock.getInt("quantity");
                                        String pName = rsStock.getString("name");
                                        if (curStock < e.getValue() || curStock <= 0) {
                                            throw new SQLException("Sản phẩm \"" + pName + "\" đã hết hàng hoặc không đủ số lượng trong kho!");
                                        }
                                    } else {
                                        throw new SQLException("Sản phẩm không tồn tại trong hệ thống!");
                                    }
                                }
                            }
                        }

                        for (java.util.Map.Entry<Integer, Integer> e : stockByProduct.entrySet()) {
                            psStock.setInt(1, e.getValue());
                            psStock.setInt(2, e.getKey());
                            psStock.setInt(3, e.getValue());
                            int affected = psStock.executeUpdate();
                            if (affected <= 0) {
                                throw new SQLException("Sản phẩm đã hết hàng hoặc không đủ số lượng trong kho!");
                            }
                        }

                        psDetail.executeBatch();
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
                order.setShippingFee(rs.getDouble("shipping_fee"));
                order.setStatus(rs.getString("order_status"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                readTransfer(rs, order);
                list.add(order);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalOrdersCountByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM hoa_don WHERE user_id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Order> getOrdersByUserIdAndPage(int userId, int offset, int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM hoa_don WHERE user_id = ? ORDER BY id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setId(rs.getInt("id"));
                    order.setReceiverName(rs.getString("receiver_name"));
                    order.setTotalMoney(rs.getDouble("total_amount"));
                    order.setShippingFee(rs.getDouble("shipping_fee"));
                    order.setStatus(rs.getString("order_status"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    order.setCreatedAt(rs.getTimestamp("created_at"));
                    readTransfer(rs, order);
                    list.add(order);
                }
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
                order.setUserId(rs.getInt("user_id"));
                order.setReceiverName(rs.getString("receiver_name"));
                order.setReceiverPhone(rs.getString("receiver_phone"));
                order.setReceiverAddress(rs.getString("receiver_address"));
                order.setNote(rs.getString("note"));
                order.setTotalMoney(rs.getDouble("total_amount"));
                order.setShippingFee(rs.getDouble("shipping_fee"));
                order.setStatus(rs.getString("order_status"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                readTransfer(rs, order);

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
                order.setShippingFee(rs.getDouble("shipping_fee"));
                order.setStatus(rs.getString("order_status"));
                order.setPaymentMethod(rs.getString("payment_method"));
                order.setPaymentStatus(rs.getString("payment_status"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                readTransfer(rs, order);

                String realEmail = rs.getString("email");
                order.setEmail(realEmail != null ? realEmail : "Không có email");

                list.add(order);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public static class StatusUpdateResult {
        private final boolean success;
        private final String message;

        public StatusUpdateResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }

        public static StatusUpdateResult ok() { return new StatusUpdateResult(true, null); }
        public static StatusUpdateResult error(String msg) { return new StatusUpdateResult(false, msg); }
    }

    public StatusUpdateResult updateStatusWithDetail(int orderId, String newStatus) {
        if (newStatus == null) return StatusUpdateResult.error("Trạng thái mới không hợp lệ!");
        newStatus = newStatus.trim().toUpperCase();

        Order currentOrder = getOrderById(orderId);
        if (currentOrder == null) return StatusUpdateResult.error("Không tìm thấy đơn hàng #" + orderId + " trong hệ thống!");

        String currentStatus = currentOrder.getStatus();
        if (currentStatus == null) currentStatus = "PENDING";
        else currentStatus = currentStatus.trim().toUpperCase();

        if (currentStatus.equals(newStatus)) return StatusUpdateResult.ok();

        boolean isPaidCancelled = ("CANCELLED".equals(currentStatus) || "CLIENT_CANCELLED".equals(currentStatus))
                && ("PAID".equals(currentOrder.getPaymentStatus()) || currentOrder.getTransferAmount() > 0);

        if ("RETURNED".equals(currentStatus)
                || "EXCHANGED".equals(currentStatus)
                || "REFUNDED".equals(currentStatus)) {
            return StatusUpdateResult.error("Đơn hàng #" + orderId + " đang ở trạng thái kết thúc [" + currentOrder.getStatusDisplayName() + "] nên đã bị khóa cố định, không thể thay đổi!");
        }

        if (("CANCELLED".equals(currentStatus) || "CLIENT_CANCELLED".equals(currentStatus))) {
            if (isPaidCancelled && "REFUNDED".equals(newStatus)) {

            } else {
                return StatusUpdateResult.error("Đơn hàng #" + orderId + " đang ở trạng thái kết thúc [" + currentOrder.getStatusDisplayName() + "] nên đã bị khóa cố định, không thể thay đổi!");
            }
        }

        boolean isValid = false;
        String allowedTransitionsHint = "";
        if (isPaidCancelled && "REFUNDED".equals(newStatus)) {
            isValid = true;
        } else {
        switch (currentStatus) {
            case "PENDING":
                isValid = "CONFIRMED".equals(newStatus)
                       || "CANCELLED".equals(newStatus)
                       || "CLIENT_CANCELLED".equals(newStatus);
                allowedTransitionsHint = "Từ 'Chờ xử lý', chỉ có thể chuyển sang 'Xác nhận đơn' hoặc 'Hủy đơn hàng (Hoàn kho)'.";
                break;
            case "CONFIRMED":
                isValid = "PREPARING".equals(newStatus)
                       || "CANCELLED".equals(newStatus);
                allowedTransitionsHint = "Từ 'Đã xác nhận', chỉ có thể chuyển sang 'Đang chuẩn bị hàng' hoặc 'Hủy đơn hàng (Hoàn kho)'.";
                break;
            case "PREPARING":
                isValid = "READY_TO_PICK".equals(newStatus)
                       || "CANCELLED".equals(newStatus);
                allowedTransitionsHint = "Từ 'Đang chuẩn bị hàng', chỉ có thể chuyển sang 'Chờ lấy hàng' hoặc 'Hủy đơn hàng (Hoàn kho)'.";
                break;
            case "READY_TO_PICK":
                isValid = "SHIPPING".equals(newStatus)
                       || "CANCELLED".equals(newStatus);
                allowedTransitionsHint = "Từ 'Chờ lấy hàng', chỉ có thể chuyển sang 'Đang giao hàng' hoặc 'Hủy đơn hàng (Hoàn kho)'.";
                break;
            case "SHIPPING":
                isValid = "FINISH".equals(newStatus)
                       || "COMPLETED".equals(newStatus)
                       || "DELIVERY_FAILED".equals(newStatus)
                       || "RETURNING".equals(newStatus);
                allowedTransitionsHint = "Từ 'Đang giao hàng', chỉ có thể chuyển sang 'Giao thành công', 'Giao hàng thất bại', hoặc 'Đang hoàn hàng'.";
                break;
            case "DELIVERY_FAILED":
                isValid = "SHIPPING".equals(newStatus)
                       || "RETURNING".equals(newStatus);
                allowedTransitionsHint = "Khi 'Giao hàng thất bại', chỉ có thể chọn 'Giao lại' hoặc 'Đang hoàn hàng'.";
                break;
            case "RETURNING":
                isValid = "RETURNED".equals(newStatus);
                allowedTransitionsHint = "Khi 'Đang hoàn hàng', chỉ có thể chuyển sang 'Đã hoàn hàng (Nhập kho)'.";
                break;
            case "FINISH":
            case "COMPLETED":
                isValid = "RETURN_REQUESTED".equals(newStatus);
                allowedTransitionsHint = "Đơn hàng đã hoàn thành, chỉ có thể mở 'Yêu cầu đổi trả' nếu khách khiếu nại.";
                break;
            case "RETURN_REQUESTED":
                isValid = "RETURN_PROCESSING".equals(newStatus)
                       || "FINISH".equals(newStatus);
                allowedTransitionsHint = "Yêu cầu đổi trả chỉ có thể chuyển sang 'Đang xử lý đổi trả' hoặc 'Từ chối (Khôi phục Hoàn thành)'.";
                break;
            case "RETURN_PROCESSING":
                isValid = "EXCHANGED".equals(newStatus)
                       || "REFUNDED".equals(newStatus);
                allowedTransitionsHint = "Đang xử lý đổi trả chỉ có thể chuyển sang 'Đã đổi hàng' hoặc 'Đã hoàn tiền'.";
                break;
            default:
                allowedTransitionsHint = "Trạng thái hiện tại không hợp lệ.";
                break;
        }
        }

        if (!isValid) {
            return StatusUpdateResult.error("Không thể chuyển từ trạng thái [" + currentOrder.getStatusDisplayName() + "] sang trạng thái mới này! " + allowedTransitionsHint);
        }

        if ("QR".equals(currentOrder.getPaymentMethod()) && !"PAID".equals(currentOrder.getPaymentStatus())) {
            if ("CONFIRMED".equals(newStatus)
                    || "PREPARING".equals(newStatus)
                    || "READY_TO_PICK".equals(newStatus)
                    || "SHIPPING".equals(newStatus)
                    || "FINISH".equals(newStatus)
                    || "COMPLETED".equals(newStatus)) {
                return StatusUpdateResult.error("Đơn hàng #" + orderId + " thanh toán bằng mã QR nhưng CHƯA ĐƯỢC XÁC NHẬN TIỀN VỀ (Chưa thanh toán)! Vui lòng kiểm tra tài khoản và bấm nút 'Xác nhận đã thanh toán' trước khi chuyển bước.");
            }
        }

        boolean needsRestoreStock = "CANCELLED".equals(newStatus)
                || "CLIENT_CANCELLED".equals(newStatus)
                || "RETURNED".equals(newStatus)
                || "REFUNDED".equals(newStatus);

        String sqlUpdate = "UPDATE hoa_don SET order_status = ? WHERE id = ?";
        String sqlCheckRestored = "SELECT is_stock_restored FROM hoa_don WHERE id = ?";
        String sqlMarkRestored = "UPDATE hoa_don SET is_stock_restored = 1 WHERE id = ?";
        String sqlGetItems = "SELECT product_id, quantity FROM hoa_don_chi_tiet WHERE invoice_id = ?";
        String sqlRestoreStock = "UPDATE san_pham SET quantity = quantity + ? WHERE id = ?";

        try (Connection conn = ConnectDB.getConnect()) {
            if (conn == null) return StatusUpdateResult.error("Không thể kết nối đến cơ sở dữ liệu!");
            conn.setAutoCommit(false);

            try {
                try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                    psUpdate.setString(1, newStatus);
                    psUpdate.setInt(2, orderId);
                    psUpdate.executeUpdate();
                }

                if (needsRestoreStock) {
                    boolean alreadyRestored = false;
                    try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckRestored)) {
                        psCheck.setInt(1, orderId);
                        try (ResultSet rsCheck = psCheck.executeQuery()) {
                            if (rsCheck.next()) {
                                alreadyRestored = rsCheck.getBoolean("is_stock_restored");
                            }
                        }
                    }

                    if (!alreadyRestored) {
                        List<int[]> itemsToRestore = new ArrayList<>();
                        try (PreparedStatement psItems = conn.prepareStatement(sqlGetItems)) {
                            psItems.setInt(1, orderId);
                            try (ResultSet rsItems = psItems.executeQuery()) {
                                while (rsItems.next()) {
                                    itemsToRestore.add(new int[]{rsItems.getInt("product_id"), rsItems.getInt("quantity")});
                                }
                            }
                        }

                        if (!itemsToRestore.isEmpty()) {
                            try (PreparedStatement psStock = conn.prepareStatement(sqlRestoreStock)) {
                                for (int[] item : itemsToRestore) {
                                    psStock.setInt(1, item[1]);
                                    psStock.setInt(2, item[0]);
                                    psStock.addBatch();
                                }
                                psStock.executeBatch();
                            }
                        }

                        try (PreparedStatement psMark = conn.prepareStatement(sqlMarkRestored)) {
                            psMark.setInt(1, orderId);
                            psMark.executeUpdate();
                        }
                    }
                }

                conn.commit();
                return StatusUpdateResult.ok();
            } catch (Exception ex) {
                conn.rollback();
                ex.printStackTrace();
                return StatusUpdateResult.error("Lỗi cơ sở dữ liệu: " + ex.getMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
            return StatusUpdateResult.error("Lỗi hệ thống: " + e.getMessage());
        }
    }

    public boolean updateStatus(int orderId, String newStatus) {
        return updateStatusWithDetail(orderId, newStatus).isSuccess();
    }

    public boolean clientCancelOrder(int orderId, int userId) {
        Order order = getOrderById(orderId);
        if (order == null || order.getUserId() != userId) return false;
        if (!"PENDING".equals(order.getStatus())) return false;
        return updateStatus(orderId, "CLIENT_CANCELLED");
    }

    public boolean clientRequestReturn(int orderId, int userId) {
        Order order = getOrderById(orderId);
        if (order == null || order.getUserId() != userId) return false;
        if (!"FINISH".equals(order.getStatus()) && !"COMPLETED".equals(order.getStatus())) return false;
        return updateStatus(orderId, "RETURN_REQUESTED");
    }

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

    public void markTransferred(int orderId, double amount, String txnNo) {
        String sql = "UPDATE hoa_don SET transfer_amount = ISNULL(transfer_amount, 0) + ?, "
                + "vnpay_txn_no = ?, transferred_at = GETDATE() "
                + "WHERE id = ? AND payment_method = 'QR' AND ISNULL(payment_status, 'UNPAID') <> 'PAID' "
                + "AND (vnpay_txn_no IS NULL OR vnpay_txn_no <> ?)";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, amount);
            ps.setString(2, txnNo);
            ps.setInt(3, orderId);
            ps.setString(4, txnNo);
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
                    order.setShippingFee(rs.getDouble("shipping_fee"));
                    order.setStatus(rs.getString("order_status"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    order.setCreatedAt(rs.getTimestamp("created_at"));
                    readTransfer(rs, order);

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

    public java.util.Map<String, Number> getUserOrderStats(int userId) {
        java.util.Map<String, Number> stats = new java.util.LinkedHashMap<>();
        stats.put("total", 0);
        stats.put("pending", 0);
        stats.put("spent", 0.0);

        String sql = "SELECT COUNT(*) AS total, "
                + "SUM(CASE WHEN order_status = 'PENDING' THEN 1 ELSE 0 END) AS pending, "
                + "SUM(CASE WHEN order_status IN ('FINISH', 'COMPLETED') THEN total_amount ELSE 0 END) AS spent "
                + "FROM hoa_don WHERE user_id = ?";
        try (Connection conn = ConnectDB.getConnect();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("total", rs.getInt("total"));
                stats.put("pending", rs.getInt("pending"));
                stats.put("spent", rs.getDouble("spent"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }
}
