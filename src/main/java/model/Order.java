package model;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Model biểu diễn thực thể Đơn hàng trong cơ sở dữ liệu.
 * ============================================================================
 */

import java.sql.Timestamp;

public class Order {
    private int id;
    private int userId;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private String note;
    private double totalMoney;
    private String status;
    private Timestamp createdAt;
    private String email;
    private String paymentMethod;
    private String paymentStatus;   // UNPAID / PAID (chỉ admin mới chuyển sang PAID)

    // Phí vận chuyển (GHN)
    private double shippingFee;

    // Thông tin khách đã chuyển khoản qua VNPay (admin dùng để đối chiếu)
    private double transferAmount;      // tổng số tiền khách đã chuyển qua VNPay (0 = chưa chuyển)
    private String vnpayTxnNo;          // mã giao dịch VNPay gần nhất
    private Timestamp transferredAt;    // thời điểm chuyển khoản gần nhất

    // Thông tin Voucher giảm giá
    private String voucherCode;
    private double discountAmount;

    public Order() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }

    public String getReceiverPhone() { return receiverPhone; }
    public void setReceiverPhone(String receiverPhone) { this.receiverPhone = receiverPhone; }

    public String getReceiverAddress() { return receiverAddress; }
    public void setReceiverAddress(String receiverAddress) { this.receiverAddress = receiverAddress; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public double getTotalMoney() { return totalMoney; }
    public void setTotalMoney(double totalMoney) { this.totalMoney = totalMoney; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public double getShippingFee() { return shippingFee; }
    public void setShippingFee(double shippingFee) { this.shippingFee = shippingFee; }

    public double getTransferAmount() { return transferAmount; }
    public void setTransferAmount(double transferAmount) { this.transferAmount = transferAmount; }

    public String getVnpayTxnNo() { return vnpayTxnNo; }
    public void setVnpayTxnNo(String vnpayTxnNo) { this.vnpayTxnNo = vnpayTxnNo; }

    public Timestamp getTransferredAt() { return transferredAt; }
    public void setTransferredAt(Timestamp transferredAt) { this.transferredAt = transferredAt; }

    public String getVoucherCode() { return voucherCode; }
    public void setVoucherCode(String voucherCode) { this.voucherCode = voucherCode; }

    public double getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(double discountAmount) { this.discountAmount = discountAmount; }

    private boolean stockRestored;
    public boolean isStockRestored() { return stockRestored; }
    public void setStockRestored(boolean stockRestored) { this.stockRestored = stockRestored; }

    public String getStatusDisplayName() {
        if (status == null) return "Chờ xử lý";
        switch (status) {
            case "PENDING": return "Chờ xử lý";
            case "CONFIRMED": return "Đã xác nhận";
            case "PREPARING": return "Đang chuẩn bị hàng";
            case "READY_TO_PICK": return "Chờ lấy hàng";
            case "SHIPPING": return "Đang giao hàng";
            case "FINISH":
            case "COMPLETED": return "Hoàn thành";
            case "CANCELLED": return "Hủy đơn hàng (Hoàn kho)";
            case "CLIENT_CANCELLED": return "Khách hủy đơn";
            case "DELIVERY_FAILED": return "Giao hàng thất bại";
            case "RETURNING": return "Đang hoàn hàng";
            case "RETURNED": return "Đã hoàn hàng (Nhập kho)";
            case "RETURN_REQUESTED": return "Yêu cầu đổi trả";
            case "RETURN_PROCESSING": return "Đang xử lý đổi trả";
            case "EXCHANGED": return "Đã đổi hàng";
            case "REFUNDED": return "Đã hoàn tiền";
            default: return status;
        }
    }

    public String getStatusDescription() {
        if (status == null) return "Đơn hàng đang chờ nhân viên xác nhận.";
        switch (status) {
            case "PENDING": return "Đơn hàng đang chờ shop xác nhận.";
            case "CONFIRMED": return "Shop đã xác nhận đơn và chuyển cho kho.";
            case "PREPARING": return "Kho đang đóng gói, soạn hàng.";
            case "READY_TO_PICK": return "Đã đóng gói xong, chờ đơn vị vận chuyển đến lấy.";
            case "SHIPPING": return "Đơn vị vận chuyển đang giao hàng đến bạn.";
            case "FINISH":
            case "COMPLETED": return "Đơn hàng đã được giao thành công.";
            case "CANCELLED": return "Đơn hàng đã hủy trước khi giao (sản phẩm đã hoàn kho).";
            case "CLIENT_CANCELLED": return "Khách hàng đã hủy đơn (sản phẩm đã hoàn kho).";
            case "DELIVERY_FAILED": return "Giao hàng không thành công (không liên lạc được / từ chối nhận).";
            case "RETURNING": return "Hàng đang trên đường chuyển hoàn về shop.";
            case "RETURNED": return "Shop đã nhận lại hàng và nhập lại tồn kho.";
            case "RETURN_REQUESTED": return "Khách hàng đã gửi yêu cầu đổi trả / hoàn tiền.";
            case "RETURN_PROCESSING": return "Shop đang kiểm tra sản phẩm và xử lý khiếu nại.";
            case "EXCHANGED": return "Shop đã gửi sản phẩm mới cho khách hàng thành công.";
            case "REFUNDED": return "Shop đã hoàn tiền cho khách và nhập lại kho hàng.";
            default: return "";
        }
    }

    public String getStatusBadgeClass() {
        if (status == null) return "bg-warning text-dark";
        switch (status) {
            case "PENDING": return "bg-warning text-dark";
            case "CONFIRMED": return "bg-primary";
            case "PREPARING": return "bg-indigo text-white";
            case "READY_TO_PICK": return "bg-info text-dark";
            case "SHIPPING": return "bg-primary bg-opacity-75 text-white";
            case "FINISH":
            case "COMPLETED": return "bg-success";
            case "CANCELLED": return "bg-danger";
            case "CLIENT_CANCELLED": return "bg-danger text-white";
            case "DELIVERY_FAILED": return "bg-danger bg-opacity-75 text-white";
            case "RETURNING": return "bg-warning text-dark";
            case "RETURNED": return "bg-secondary";
            case "RETURN_REQUESTED": return "bg-dark";
            case "RETURN_PROCESSING": return "bg-dark";
            case "EXCHANGED": return "bg-teal text-white";
            case "REFUNDED": return "bg-secondary";
            default: return "bg-secondary";
        }
    }

    public boolean isTerminal() {
        return "CANCELLED".equals(status) 
            || "CLIENT_CANCELLED".equals(status) 
            || "RETURNED".equals(status) 
            || "EXCHANGED".equals(status) 
            || "REFUNDED".equals(status);
    }
}
