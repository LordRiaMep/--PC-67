<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Đơn hàng - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="orders"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <h3 class="m-0 text-dark fw-bold">Quản lý Đơn hàng</h3>
        <div class="d-flex align-items-center">
            <span class="me-3">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <div class="row g-4">

        <!-- Danh sách đơn -->
        <div class="col-xl-7">
            <div class="panel overflow-hidden">
                <div class="panel-head">
                    <h5><i class="fa-solid fa-list me-2"></i>Danh sách đơn hàng</h5>
                </div>
                <div class="table-responsive">
                    <table class="table tbl align-middle">
                        <thead>
                        <tr>
                            <th>Mã</th>
                            <th>Khách hàng</th>
                            <th>Tổng tiền</th>
                            <th>Thanh toán</th>
                            <th>Trạng thái</th>
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${orders}" var="o">
                            <tr class="${selectedOrder != null && selectedOrder.id == o.id ? 'row-edit' : ''}">
                                <td class="fw-bold">#${o.id}</td>
                                <td>
                                    <div class="prod-name">${o.receiverName}</div>
                                    <div class="muted" style="font-size: 13px;">${o.email}</div>
                                </td>
                                <td class="price"><fmt:formatNumber value="${o.totalMoney}" pattern="#,##0"/> đ</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${o.paymentMethod == 'QR'}">
                                            <span class="badge bg-info text-dark">QR</span>
                                            <div class="mt-1">
                                                <c:choose>
                                                    <c:when test="${o.paymentStatus == 'PAID'}"><span class="badge bg-success">Đã thanh toán</span></c:when>
                                                    <c:otherwise><span class="badge bg-danger">Chưa thanh toán</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:when>
                                        <c:otherwise><span class="badge bg-secondary">COD</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${o.status == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ xử lý</span></c:when>
                                        <c:when test="${o.status == 'CONFIRMED'}"><span class="badge bg-primary">Đã xác nhận</span></c:when>
                                        <c:when test="${o.status == 'SHIPPING'}"><span class="badge bg-info text-dark">Đang giao</span></c:when>
                                        <c:when test="${o.status == 'FINISH' || o.status == 'COMPLETED'}"><span class="badge bg-success">Hoàn thành</span></c:when>
                                        <c:when test="${o.status == 'CANCELLED'}"><span class="badge bg-danger">Đã hủy</span></c:when>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <a href="?id=${o.id}&page=${currentPage}" class="btn btn-sm btn-ghost px-3">Xem</a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty orders}">
                            <tr><td colspan="6" class="text-center muted py-5">
                                <i class="fa-solid fa-box-open fs-1 d-block mb-2"></i>Chưa có đơn hàng nào.
                            </td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <c:if test="${totalPages > 1}">
                <nav class="mt-4">
                    <ul class="pagination justify-content-center mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}"><a class="page-link shadow-none" href="?page=${currentPage - 1}">Trước</a></li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link shadow-none" href="?page=${i}">${i}</a></li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}"><a class="page-link shadow-none" href="?page=${currentPage + 1}">Sau</a></li>
                    </ul>
                </nav>
            </c:if>
        </div>

        <!-- Chi tiết đơn -->
        <div class="col-xl-5">
            <c:choose>
                <c:when test="${not empty selectedOrder}">
                    <c:set var="lockPay" value="${selectedOrder.paymentMethod == 'QR' && selectedOrder.paymentStatus != 'PAID'}"/>
                    <div class="panel sticky-panel">
                        <div class="panel-head">
                            <h5><i class="fa-solid fa-file-invoice me-2"></i>Chi tiết đơn #${selectedOrder.id}</h5>
                        </div>
                        <div class="panel-body">
                            <div class="info-row"><span class="k">Người nhận</span><span class="text-dark">${selectedOrder.receiverName}</span></div>
                            <div class="info-row"><span class="k">SĐT</span><span class="text-dark">${selectedOrder.receiverPhone}</span></div>
                            <div class="info-row"><span class="k">Địa chỉ</span><span class="text-dark">${selectedOrder.receiverAddress}</span></div>
                            <div class="info-row">
                                <span class="k">Thanh toán</span>
                                <span>
                                    <c:choose>
                                        <c:when test="${selectedOrder.paymentMethod == 'QR'}">
                                            <span class="text-primary">QR code (chuyển khoản)</span>
                                            <c:choose>
                                                <c:when test="${selectedOrder.paymentStatus == 'PAID'}"><span class="badge bg-success ms-1">Đã thanh toán</span></c:when>
                                                <c:otherwise><span class="badge bg-danger ms-1">Chưa thanh toán</span></c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise><span class="text-dark">Khi nhận hàng (COD)</span></c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <!-- Xác nhận đã nhận tiền (đơn QR) -->
                            <c:if test="${lockPay && selectedOrder.status != 'CANCELLED'}">
                                <div class="pay-warn mt-3">
                                    <div class="warn-text small mb-2"><i class="fa-solid fa-triangle-exclamation me-1"></i>
                                        Đơn QR chưa thanh toán. Kiểm tra tiền đã về tài khoản rồi mới xác nhận. Chưa xác nhận thì không thể chuyển sang Đã xác nhận, Đang giao hoặc Hoàn thành.</div>
                                    <form action="${ctx}/admin/confirm-payment" method="post"
                                          onsubmit="return confirm('Xác nhận đã nhận đủ tiền cho đơn #${selectedOrder.id}?');">
                                        <input type="hidden" name="id" value="${selectedOrder.id}">
                                        <input type="hidden" name="page" value="${currentPage}">
                                        <button type="submit" class="btn btn-warning btn-sm fw-bold"><i class="fa-solid fa-circle-check me-1"></i> Xác nhận đã thanh toán</button>
                                    </form>
                                </div>
                            </c:if>

                            <!-- Cập nhật trạng thái -->
                            <form action="${ctx}/admin/orders" method="post" class="mt-3 p-3 item-box">
                                <input type="hidden" name="id" value="${selectedOrder.id}">
                                <input type="hidden" name="page" value="${currentPage}">
                                <div class="field-label">Cập nhật trạng thái</div>
                                <div class="d-flex gap-2">
                                    <select name="status" class="form-select field shadow-none">
                                        <option value="PENDING" ${selectedOrder.status == 'PENDING' ? 'selected' : ''}>Chờ xử lý</option>
                                        <option value="CONFIRMED" ${lockPay ? 'disabled' : ''} ${selectedOrder.status == 'CONFIRMED' ? 'selected' : ''}>Đã xác nhận</option>
                                        <option value="SHIPPING" ${lockPay ? 'disabled' : ''} ${selectedOrder.status == 'SHIPPING' ? 'selected' : ''}>Đang giao hàng</option>
                                        <option value="FINISH" ${lockPay ? 'disabled' : ''} ${selectedOrder.status == 'FINISH' || selectedOrder.status == 'COMPLETED' ? 'selected' : ''}>Hoàn thành</option>
                                        <c:if test="${selectedOrder.status != 'SHIPPING' && selectedOrder.status != 'FINISH' && selectedOrder.status != 'COMPLETED'}">
                                            <option value="CANCELLED" ${selectedOrder.status == 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
                                        </c:if>
                                    </select>
                                    <button type="submit" class="btn btn-neon text-nowrap px-3">Cập nhật</button>
                                </div>
                            </form>

                            <!-- Sản phẩm -->
                            <div class="field-label mt-4">Sản phẩm đã đặt</div>
                            <c:forEach items="${orderDetails}" var="item">
                                <div class="item-box">
                                    <div class="d-flex justify-content-between align-items-start gap-3">
                                        <span class="text-dark">${item.productName} <span class="text-danger">x${item.quantity}</span></span>
                                        <strong class="price"><fmt:formatNumber value="${item.price}" pattern="#,##0"/> đ</strong>
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty item.upgradeInfo}">
                                            <div class="upgrade-box">
                                                <div class="text-danger fw-bold mb-1"><i class="fa-solid fa-screwdriver-wrench me-1"></i>Linh kiện nâng cấp</div>
                                                <ul class="mb-0 ps-3">
                                                    <c:forEach items="${fn:split(item.upgradeInfo, '|')}" var="line">
                                                        <li>${line}</li>
                                                    </c:forEach>
                                                </ul>
                                            </div>
                                        </c:when>
                                        <c:otherwise><div class="mt-1 small muted">Cấu hình gốc, không nâng cấp</div></c:otherwise>
                                    </c:choose>
                                </div>
                            </c:forEach>

                            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top" style="border-color: var(--border-color) !important;">
                                <span class="fs-5 text-dark">Tổng cộng</span>
                                <span class="text-danger fw-bold fs-4"><fmt:formatNumber value="${selectedOrder.totalMoney}" pattern="#,##0"/> đ</span>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="panel text-center p-5 muted">
                        <i class="fa-solid fa-hand-pointer fs-1 mb-3 text-danger d-block"></i>
                        Chọn một đơn hàng bên trái để xem chi tiết.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
