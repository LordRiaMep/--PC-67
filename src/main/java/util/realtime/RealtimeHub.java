package util.realtime;

import jakarta.websocket.Session;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedDeque;
import java.util.logging.Level;
import java.util.logging.Logger;

public class RealtimeHub {
    private static final Logger LOGGER = Logger.getLogger(RealtimeHub.class.getName());
    private static final DecimalFormat CURRENCY_FMT = new DecimalFormat("#,##0");

    private static final Set<Session> SESSIONS = ConcurrentHashMap.newKeySet();

    private static final int MAX_HISTORY = 100;
    private static final Deque<RealtimeEvent> EVENT_HISTORY = new ConcurrentLinkedDeque<>();

    public static void registerSession(Session session, String query) {
        if (session == null) return;
        try {
            String role = "client";
            int userId = 0;
            if (query != null && !query.isEmpty()) {
                String[] params = query.split("&");
                for (String p : params) {
                    String[] kv = p.split("=");
                    if (kv.length == 2) {
                        if ("role".equalsIgnoreCase(kv[0])) {
                            role = kv[1].trim().toLowerCase();
                        } else if ("userId".equalsIgnoreCase(kv[0])) {
                            try {
                                userId = Integer.parseInt(kv[1].trim());
                            } catch (Exception ignored) {}
                        }
                    }
                }
            }
            session.getUserProperties().put("role", role);
            session.getUserProperties().put("userId", userId);
            SESSIONS.add(session);
            LOGGER.info("[RealtimeHub] Đã kết nối WebSocket: ID=" + session.getId() + " | Role=" + role + " | UserId=" + userId);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[RealtimeHub] Lỗi đăng ký session", e);
        }
    }

    public static void unregisterSession(Session session) {
        if (session != null) {
            SESSIONS.remove(session);
            LOGGER.info("[RealtimeHub] Đã ngắt kết nối WebSocket: ID=" + session.getId());
        }
    }

    public static int getActiveSessionsCount() {
        return SESSIONS.size();
    }

    public static void broadcast(RealtimeEvent event) {
        if (event == null) return;

        EVENT_HISTORY.addLast(event);
        while (EVENT_HISTORY.size() > MAX_HISTORY) {
            EVENT_HISTORY.pollFirst();
        }

        String json = event.toJson();
        LOGGER.info("[RealtimeHub] BROADCAST: " + event.getType() + " -> Target=" + event.getTarget() + " | " + event.getTitle());

        for (Session session : SESSIONS) {
            if (session == null || !session.isOpen()) {
                SESSIONS.remove(session);
                continue;
            }

            try {
                String sessionRole = (String) session.getUserProperties().getOrDefault("role", "client");
                int sessionUserId = (int) session.getUserProperties().getOrDefault("userId", 0);

                boolean canSend = true;
                if ("ADMIN".equalsIgnoreCase(event.getTarget())) {
                    if (!"admin".equalsIgnoreCase(sessionRole)) {
                        canSend = false;
                    }
                } else if ("CLIENT".equalsIgnoreCase(event.getTarget())) {

                    if (event.getTargetUserId() > 0 && !"admin".equalsIgnoreCase(sessionRole)) {
                        if (sessionUserId != event.getTargetUserId()) {
                            canSend = false;
                        }
                    }
                }

                if (canSend) {
                    session.getAsyncRemote().sendText(json);
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "[RealtimeHub] Lỗi gửi tin cho session " + session.getId(), e);
            }
        }
    }

    public static List<RealtimeEvent> getEventsSince(long sinceId, String role, int userId) {
        List<RealtimeEvent> result = new ArrayList<>();
        if (role == null) role = "client";

        for (RealtimeEvent ev : EVENT_HISTORY) {
            if (ev.getId() > sinceId) {
                boolean canAdd = true;
                if ("ADMIN".equalsIgnoreCase(ev.getTarget())) {
                    if (!"admin".equalsIgnoreCase(role)) canAdd = false;
                } else if ("CLIENT".equalsIgnoreCase(ev.getTarget())) {
                    if (ev.getTargetUserId() > 0 && !"admin".equalsIgnoreCase(role)) {
                        if (userId != ev.getTargetUserId()) canAdd = false;
                    }
                }
                if (canAdd) {
                    result.add(ev);
                }
            }
        }
        return result;
    }

    public static void broadcastOrderCreated(int orderId, int userId, String customerName, String email,
                                             double totalMoney, String paymentMethod, double discountAmount) {
        String moneyStr = CURRENCY_FMT.format(totalMoney) + " đ";
        RealtimeEvent event = new RealtimeEvent(
                "ORDER_CREATED",
                "ALL",
                "🔔 Đơn hàng mới #" + orderId + "!",
                "Khách hàng " + customerName + " vừa đặt đơn hàng trị giá " + moneyStr
        );
        event.withSound("order_new")
             .withLink("/admin/orders?id=" + orderId)
             .withTargetUserId(userId)
             .withData("orderId", orderId)
             .withData("userId", userId)
             .withData("receiverName", customerName)
             .withData("email", email != null ? email : "")
             .withData("totalMoney", totalMoney)
             .withData("totalMoneyFormatted", moneyStr)
             .withData("paymentMethod", paymentMethod)
             .withData("paymentStatus", "UNPAID")
             .withData("status", "PENDING")
             .withData("statusDisplayName", "Chờ xử lý")
             .withData("discountAmount", discountAmount);

        broadcast(event);
    }

    public static void broadcastOrderCancelled(int orderId, int userId, String customerName) {
        RealtimeEvent event = new RealtimeEvent(
                "ORDER_CANCELLED",
                "ALL",
                "⚠️ Đơn hàng #" + orderId + " đã bị hủy!",
                "Khách hàng " + (customerName != null ? customerName : "") + " đã hủy đơn hàng. Số lượng hàng đã được hoàn kho."
        );
        event.withSound("cancel")
             .withLink("/admin/orders?id=" + orderId)
             .withTargetUserId(userId)
             .withData("orderId", orderId)
             .withData("userId", userId)
             .withData("status", "CLIENT_CANCELLED")
             .withData("statusDisplayName", "Khách hủy đơn");

        broadcast(event);
    }

    public static void broadcastOrderReturnRequested(int orderId, int userId, String customerName) {
        RealtimeEvent event = new RealtimeEvent(
                "ORDER_RETURN_REQUESTED",
                "ADMIN",
                "🔄 Yêu cầu đổi trả đơn #" + orderId,
                "Khách hàng " + (customerName != null ? customerName : "") + " vừa gửi yêu cầu đổi trả đơn hàng."
        );
        event.withSound("warning")
             .withLink("/admin/orders?id=" + orderId)
             .withTargetUserId(userId)
             .withData("orderId", orderId)
             .withData("userId", userId)
             .withData("status", "RETURN_REQUESTED")
             .withData("statusDisplayName", "Yêu cầu đổi trả");

        broadcast(event);
    }

    public static void broadcastOrderStatusChanged(int orderId, int userId, String oldStatus, String newStatus, String receiverName) {
        String statusName = getStatusDisplayName(newStatus);
        RealtimeEvent event = new RealtimeEvent(
                "ORDER_STATUS_CHANGED",
                "ALL",
                "📦 Cập nhật đơn hàng #" + orderId,
                "Đơn hàng #" + orderId + " đã được chuyển sang trạng thái: " + statusName
        );
        event.withSound("order_new")
             .withLink("/order-detail?id=" + orderId)
             .withTargetUserId(userId)
             .withData("orderId", orderId)
             .withData("userId", userId)
             .withData("oldStatus", oldStatus)
             .withData("newStatus", newStatus)
             .withData("statusDisplayName", statusName)
             .withData("receiverName", receiverName);

        broadcast(event);
    }

    public static void broadcastPaymentConfirmed(int orderId) {
        RealtimeEvent event = new RealtimeEvent(
                "PAYMENT_CONFIRMED",
                "ALL",
                "💳 Xác nhận thanh toán đơn #" + orderId,
                "Quản trị viên đã xác nhận thanh toán thành công cho đơn hàng #" + orderId
        );
        event.withSound("order_new")
             .withLink("/order-detail?id=" + orderId)
             .withData("orderId", orderId)
             .withData("paymentStatus", "PAID");

        broadcast(event);
    }

    public static void broadcastPaymentTransferred(int orderId, long paidAmount, String txnNo) {
        String amountStr = CURRENCY_FMT.format(paidAmount) + " đ";
        RealtimeEvent event = new RealtimeEvent(
                "PAYMENT_TRANSFERRED",
                "ADMIN",
                "💰 Chuyển khoản VNPay đơn #" + orderId,
                "Khách hàng vừa hoàn tất chuyển khoản VNPay số tiền: " + amountStr + " (Mã GD: " + txnNo + ")"
        );
        event.withSound("order_new")
             .withLink("/admin/orders?id=" + orderId)
             .withData("orderId", orderId)
             .withData("paidAmount", paidAmount)
             .withData("txnNo", txnNo);

        broadcast(event);
    }

    public static void broadcastContactCreated(int contactId, String fullName, String phone, String email, String topic, String message) {
        RealtimeEvent event = new RealtimeEvent(
                "CONTACT_CREATED",
                "ADMIN",
                "📩 Khiếu nại / Liên hệ mới!",
                "Khách hàng " + fullName + " (" + phone + ") vừa gửi liên hệ: " + topic
        );
        event.withSound("warning")
             .withLink("/admin/contacts")
             .withData("contactId", contactId)
             .withData("fullName", fullName)
             .withData("phone", phone)
             .withData("email", email != null ? email : "")
             .withData("topic", topic)
             .withData("message", message != null ? message : "")
             .withData("status", "Chưa xử lý");

        broadcast(event);
    }

    public static void broadcastContactUpdated(int contactId, String status, String note) {
        RealtimeEvent event = new RealtimeEvent(
                "CONTACT_UPDATED",
                "ALL",
                "✅ Đã xử lý liên hệ #" + contactId,
                "Trạng thái yêu cầu liên hệ #" + contactId + " đã cập nhật: " + status
        );
        event.withData("contactId", contactId)
             .withData("status", status)
             .withData("note", note);

        broadcast(event);
    }

    public static void broadcastProductChanged(String action, int productId, String productName,
                                               double price, int stock, String imageUrl) {
        String actionText = "create".equalsIgnoreCase(action) ? "thêm mới"
                          : "delete".equalsIgnoreCase(action) ? "xóa" : "cập nhật";
        String priceStr = CURRENCY_FMT.format(price) + " đ";

        RealtimeEvent event = new RealtimeEvent(
                "PRODUCT_CHANGED",
                "CLIENT",
                "🖥️ Cập nhật sản phẩm",
                "Sản phẩm \"" + productName + "\" vừa được " + actionText + " bởi Quản trị viên."
        );
        event.withLink("/product/detail?id=" + productId)
             .withData("action", action)
             .withData("productId", productId)
             .withData("productName", productName)
             .withData("price", price)
             .withData("priceFormatted", priceStr)
             .withData("stock", stock)
             .withData("imageUrl", imageUrl);

        broadcast(event);
    }

    public static void broadcastCategoryChanged(String action, int categoryId, String categoryName) {
        RealtimeEvent event = new RealtimeEvent(
                "CATEGORY_CHANGED",
                "CLIENT",
                "📁 Danh mục sản phẩm",
                "Danh mục \"" + categoryName + "\" vừa được cập nhật."
        );
        event.withData("action", action)
             .withData("categoryId", categoryId)
             .withData("categoryName", categoryName);

        broadcast(event);
    }

    public static void broadcastVoucherChanged(String action, String voucherCode) {
        RealtimeEvent event = new RealtimeEvent(
                "VOUCHER_CHANGED",
                "CLIENT",
                "🎟️ Cập nhật mã giảm giá",
                "Mã voucher [" + voucherCode + "] vừa có thay đổi."
        );
        event.withData("action", action)
             .withData("voucherCode", voucherCode);

        broadcast(event);
    }

    public static void broadcastUserStatusChanged(int userId, String status) {
        RealtimeEvent event = new RealtimeEvent(
                "USER_STATUS_CHANGED",
                "ALL",
                "Cập nhật tài khoản",
                "Trạng thái tài khoản của bạn đã thay đổi: " + status
        );
        event.withTargetUserId(userId)
             .withData("userId", userId)
             .withData("status", status);

        broadcast(event);
    }

    private static String getStatusDisplayName(String status) {
        if (status == null) return "Chờ xử lý";
        switch (status.trim().toUpperCase()) {
            case "PENDING": return "Chờ xử lý";
            case "CONFIRMED": return "Đã xác nhận";
            case "PREPARING": return "Chuẩn bị hàng";
            case "READY_TO_PICK": return "Chờ lấy hàng";
            case "SHIPPING": return "Đang giao hàng";
            case "FINISH":
            case "COMPLETED": return "Hoàn thành";
            case "CANCELLED": return "Đã hủy (Hoàn kho)";
            case "CLIENT_CANCELLED": return "Khách hủy đơn";
            case "DELIVERY_FAILED": return "Giao thất bại";
            case "RETURNING": return "Đang hoàn hàng";
            case "RETURNED": return "Đã hoàn hàng";
            case "RETURN_REQUESTED": return "Yêu cầu đổi trả";
            case "RETURN_PROCESSING": return "Đang xử lý đổi";
            case "EXCHANGED": return "Đã đổi hàng";
            case "REFUNDED": return "Đã hoàn tiền";
            default: return status;
        }
    }
}
