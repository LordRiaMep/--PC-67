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

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-circle-check fs-5 me-2"></i>
            <div>${successMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-triangle-exclamation fs-5 me-2"></i>
            <div>${errorMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row g-4">

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
                            <tr id="order-row-${o.id}" data-order-id="${o.id}" class="${selectedOrder != null && selectedOrder.id == o.id ? 'row-edit' : ''}">
                                <td class="fw-bold">#${o.id}</td>
                                <td>
                                    <div class="prod-name">${o.receiverName}</div>
                                    <div class="muted" style="font-size: 13px;">${o.email}</div>
                                </td>
                                <td class="price">
                                    <div><fmt:formatNumber value="${o.totalMoney}" pattern="#,##0"/> đ</div>
                                    <c:if test="${o.discountAmount > 0}">
                                        <div class="small text-success fw-normal" style="font-size: 11px;">
                                            <i class="fa-solid fa-ticket me-1"></i>-<fmt:formatNumber value="${o.discountAmount}" pattern="#,##0"/> đ
                                        </div>
                                    </c:if>
                                </td>
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
                                        <c:when test="${o.status == 'PREPARING'}"><span class="badge text-white" style="background-color: #6366f1;">Chuẩn bị hàng</span></c:when>
                                        <c:when test="${o.status == 'READY_TO_PICK'}"><span class="badge text-white" style="background-color: #0284c7;">Chờ lấy hàng</span></c:when>
                                        <c:when test="${o.status == 'SHIPPING'}"><span class="badge bg-info text-dark">Đang giao</span></c:when>
                                        <c:when test="${o.status == 'FINISH' || o.status == 'COMPLETED'}"><span class="badge bg-success">Hoàn thành</span></c:when>
                                        <c:when test="${o.status == 'CANCELLED'}"><span class="badge bg-danger">Hủy (Hoàn kho)</span></c:when>
                                        <c:when test="${o.status == 'CLIENT_CANCELLED'}"><span class="badge bg-danger">Khách hủy đơn</span></c:when>
                                        <c:when test="${o.status == 'DELIVERY_FAILED'}"><span class="badge text-white" style="background-color: #b91c1c;">Giao thất bại</span></c:when>
                                        <c:when test="${o.status == 'RETURNING'}"><span class="badge text-dark" style="background-color: #f59e0b;">Đang hoàn hàng</span></c:when>
                                        <c:when test="${o.status == 'RETURNED'}"><span class="badge text-white" style="background-color: #64748b;">Đã hoàn hàng</span></c:when>
                                        <c:when test="${o.status == 'RETURN_REQUESTED'}"><span class="badge text-white" style="background-color: #7c3aed;">Yêu cầu đổi trả</span></c:when>
                                        <c:when test="${o.status == 'RETURN_PROCESSING'}"><span class="badge text-white" style="background-color: #9333ea;">Đang xử lý đổi</span></c:when>
                                        <c:when test="${o.status == 'EXCHANGED'}"><span class="badge text-white" style="background-color: #0d9488;">Đã đổi hàng</span></c:when>
                                        <c:when test="${o.status == 'REFUNDED'}"><span class="badge text-white" style="background-color: #475569;">Đã hoàn tiền</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary">${o.status}</span></c:otherwise>
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

                            <c:choose>
                                <c:when test="${selectedOrder.status == 'CANCELLED' || selectedOrder.status == 'CLIENT_CANCELLED'}">
                                    <div class="mt-3 p-3 item-box bg-danger bg-opacity-10 border-danger d-flex align-items-center gap-2">
                                        <i class="fa-solid ${selectedOrder.status == 'CLIENT_CANCELLED' ? 'fa-user-xmark' : 'fa-ban'} fs-5 text-danger"></i>
                                        <div>
                                            <strong class="text-danger d-block">${selectedOrder.statusDisplayName}</strong>
                                            <span class="small text-secondary">${selectedOrder.status == 'CLIENT_CANCELLED' ? 'Khách hàng đã chủ động hủy đơn.' : 'Shop đã hủy đơn trước khi giao.'} Toàn bộ sản phẩm đã được hoàn lại kho.</span>
                                        </div>
                                    </div>

                                    <c:if test="${selectedOrder.paymentMethod == 'QR' && (selectedOrder.paymentStatus == 'PAID' || selectedOrder.transferAmount > 0)}">
                                        <div class="mt-3 p-3 item-box" style="background: #fffbeb; border: 2px solid #f59e0b !important; border-radius: 8px;">
                                            <div class="d-flex align-items-start gap-2 mb-2">
                                                <i class="fa-solid fa-triangle-exclamation fs-4 text-warning"></i>
                                                <div>
                                                    <strong class="text-danger d-block fs-6"><i class="fa-solid fa-hand-holding-dollar me-1"></i>QUY TRÌNH HOÀN TIỀN: ĐƠN QR ĐÃ THANH TOÁN</strong>
                                                    <div class="small text-dark mt-1">
                                                        Đơn hàng này đã bị hủy nhưng khách hàng <strong>ĐÃ THANH TOÁN</strong> số tiền:
                                                        <strong class="text-danger fs-6"><fmt:formatNumber value="${selectedOrder.totalMoney}" pattern="#,##0"/> đ</strong>.
                                                        <br>
                                                        <span class="text-danger fw-semibold">Cảnh báo Admin:</span> Phải liên hệ khách hàng và thực hiện quy trình hoàn tiền, không được để thất lạc tiền của khách!
                                                    </div>
                                                </div>
                                            </div>
                                            <form action="${ctx}/admin/orders" method="post" class="mt-2 text-end"
                                                  onsubmit="return confirm('Xác nhận bạn đã chuyển khoản hoàn trả đầy đủ <fmt:formatNumber value="${selectedOrder.totalMoney}" pattern="#,##0"/> đ cho khách hàng? Trạng thái đơn sẽ được cập nhật sang [Đã hoàn tiền].');">
                                                <input type="hidden" name="id" value="${selectedOrder.id}">
                                                <input type="hidden" name="page" value="${currentPage}">
                                                <input type="hidden" name="status" value="REFUNDED">
                                                <button type="submit" class="btn btn-warning btn-sm fw-bold">
                                                    <i class="fa-solid fa-circle-check me-1"></i> Xác nhận đã hoàn tiền cho khách (Chuyển sang Đã hoàn tiền)
                                                </button>
                                            </form>
                                        </div>
                                    </c:if>
                                </c:when>

                                <c:when test="${selectedOrder.status == 'RETURNED'}">
                                    <div class="mt-3 p-3 item-box bg-secondary bg-opacity-10 border-secondary d-flex align-items-center gap-2">
                                        <i class="fa-solid fa-boxes-packing fs-5 text-secondary"></i>
                                        <div>
                                            <strong class="text-secondary d-block">Đã hoàn hàng (Nhập kho)</strong>
                                            <span class="small text-secondary">Shop đã nhận lại kiện hàng và nhập lại tồn kho thành công. Giao dịch đã kết thúc và khóa cố định.</span>
                                        </div>
                                    </div>
                                </c:when>

                                <c:when test="${selectedOrder.status == 'EXCHANGED'}">
                                    <div class="mt-3 p-3 item-box bg-info bg-opacity-10 border-info d-flex align-items-center gap-2">
                                        <i class="fa-solid fa-rotate fs-5 text-info"></i>
                                        <div>
                                            <strong class="text-info d-block">Đã đổi hàng thành công</strong>
                                            <span class="small text-secondary">Shop đã gửi sản phẩm mới thay thế cho khách hàng. Quy trình đổi trả đã hoàn tất và khóa cố định.</span>
                                        </div>
                                    </div>
                                </c:when>

                                <c:when test="${selectedOrder.status == 'REFUNDED'}">
                                    <div class="mt-3 p-3 item-box bg-dark bg-opacity-10 border-dark d-flex align-items-center gap-2">
                                        <i class="fa-solid fa-hand-holding-dollar fs-5 text-dark"></i>
                                        <div>
                                            <strong class="text-dark d-block">Đã hoàn tiền cho khách</strong>
                                            <span class="small text-secondary">Shop đã hoàn lại tiền cho khách và nhập lại hàng vào kho. Giao dịch đã hoàn tất và khóa cố định.</span>
                                        </div>
                                    </div>
                                </c:when>

                                <c:otherwise>
                                    <form action="${ctx}/admin/orders" method="post" class="mt-3 p-3 item-box"
                                          onsubmit="var sel = this.querySelector('select[name=status]'); if (sel && sel.value === 'CANCELLED' && ${selectedOrder.paymentMethod == 'QR' && (selectedOrder.paymentStatus == 'PAID' || selectedOrder.transferAmount > 0)}) { return confirm('CẢNH BÁO: Đơn hàng này khách ĐÃ THANH TOÁN QR (<fmt:formatNumber value="${selectedOrder.totalMoney}" pattern="#,##0"/> đ). Sau khi hủy, bạn phải thực hiện quy trình hoàn tiền cho khách! Bạn có chắc chắn muốn hủy đơn không?'); } return true;">
                                        <input type="hidden" name="id" value="${selectedOrder.id}">
                                        <input type="hidden" name="page" value="${currentPage}">

                                        <div class="field-label d-flex justify-content-between align-items-center mb-1">
                                            <span>Cập nhật tiến trình đơn hàng</span>
                                            <span class="badge ${selectedOrder.statusBadgeClass}">${selectedOrder.statusDisplayName}</span>
                                        </div>
                                        <div class="small text-secondary mb-2 fst-italic">${selectedOrder.statusDescription}</div>

                                        <div class="d-flex gap-2">
                                            <select name="status" class="form-select field shadow-none" required>
                                                <c:choose>
                                                    <c:when test="${selectedOrder.status == 'PENDING'}">
                                                        <option value="CONFIRMED" ${lockPay ? 'disabled' : ''}>1. Xác nhận đơn hàng</option>
                                                        <option value="CANCELLED">Hủy đơn hàng (Hoàn kho)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'CONFIRMED'}">
                                                        <option value="PREPARING" ${lockPay ? 'disabled' : ''}>2. Đang chuẩn bị hàng (Đóng gói, soạn hàng)</option>
                                                        <option value="CANCELLED">Hủy đơn hàng (Hoàn kho)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'PREPARING'}">
                                                        <option value="READY_TO_PICK" ${lockPay ? 'disabled' : ''}>3. Chờ lấy hàng (Đã đóng gói xong, chờ ĐVVC lấy)</option>
                                                        <option value="CANCELLED">Hủy đơn hàng (Hoàn kho)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'READY_TO_PICK'}">
                                                        <option value="SHIPPING" ${lockPay ? 'disabled' : ''}>4. Bắt đầu giao hàng (ĐVVC đã lấy và đang giao)</option>
                                                        <option value="CANCELLED">Hủy đơn hàng (Hoàn kho)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'SHIPPING'}">
                                                        <option value="FINISH">5. Giao thành công (Hoàn thành đơn)</option>
                                                        <option value="DELIVERY_FAILED">Giao hàng thất bại (Không liên lạc được / khách từ chối)</option>
                                                        <option value="RETURNING">Đang hoàn hàng (Hàng đang chuyển trả về shop)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'DELIVERY_FAILED'}">
                                                        <option value="SHIPPING">Giao lại (Shipper phát lại kiện hàng)</option>
                                                        <option value="RETURNING">Đang hoàn hàng (Hàng đang chuyển trả về shop)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'RETURNING'}">
                                                        <option value="RETURNED">Đã hoàn hàng - Nhập kho (Shop nhận lại hàng, cộng tồn kho)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'FINISH' || selectedOrder.status == 'COMPLETED'}">
                                                        <option value="RETURN_REQUESTED">Mở yêu cầu đổi trả (Khách khiếu nại)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'RETURN_REQUESTED'}">
                                                        <option value="RETURN_PROCESSING">Tiếp nhận &amp; Đang xử lý đổi trả (Shop đang kiểm tra)</option>
                                                        <option value="FINISH">Từ chối đổi trả (Khôi phục Hoàn thành)</option>
                                                    </c:when>
                                                    <c:when test="${selectedOrder.status == 'RETURN_PROCESSING'}">
                                                        <option value="EXCHANGED">Đã đổi hàng (Đã gửi hàng mới cho khách)</option>
                                                        <option value="REFUNDED">Đã hoàn tiền (Đã trả tiền khách &amp; nhập lại kho)</option>
                                                    </c:when>
                                                </c:choose>
                                            </select>
                                            <button type="submit" class="btn btn-neon text-nowrap px-3">Cập nhật</button>
                                        </div>
                                    </form>
                                </c:otherwise>
                            </c:choose>

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

                            <c:if test="${selectedOrder.shippingFee > 0 || selectedOrder.discountAmount > 0}">
                                <div class="d-flex justify-content-between align-items-center mt-3 pt-2">
                                    <span class="muted">Tiền hàng:</span>
                                    <span class="fw-semibold text-dark"><fmt:formatNumber value="${selectedOrder.totalMoney + selectedOrder.discountAmount - selectedOrder.shippingFee}" pattern="#,##0"/> đ</span>
                                </div>
                                <c:if test="${selectedOrder.discountAmount > 0}">
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <span class="muted"><i class="fa-solid fa-ticket text-danger me-1"></i>Voucher (${not empty selectedOrder.voucherCode ? selectedOrder.voucherCode : 'Ưu đãi'}):</span>
                                        <span class="fw-bold text-success">-<fmt:formatNumber value="${selectedOrder.discountAmount}" pattern="#,##0"/> đ</span>
                                    </div>
                                </c:if>
                                <c:if test="${selectedOrder.shippingFee > 0}">
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <span class="muted"><i class="fa-solid fa-truck-fast text-danger me-1"></i>Phí ship GHN:</span>
                                        <span class="fw-semibold text-primary"><fmt:formatNumber value="${selectedOrder.shippingFee}" pattern="#,##0"/> đ</span>
                                    </div>
                                </c:if>
                            </c:if>

                            <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top" style="border-color: var(--border-color) !important;">
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
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js">

</script>
</body>
</html>
