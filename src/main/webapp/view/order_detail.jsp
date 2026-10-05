<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="header.jsp" />

<style>
    .od-wrap { max-width: 1100px; }
    .od-card { background: #fff; border: 1px solid #e9ecef; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,.05); }
    .od-title { font-size: 13px; font-weight: 700; letter-spacing: .5px; text-transform: uppercase; color: #6c757d; margin-bottom: 10px; }
    .od-info-icon { width: 38px; height: 38px; border-radius: 50%; background: #fdecee; color: #dc3545; display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }

    /* Thanh tiến trình trạng thái */
    .od-steps { display: flex; align-items: flex-start; }
    .od-step { flex: 1; text-align: center; position: relative; }
    .od-step::before { content: ''; position: absolute; top: 17px; left: -50%; width: 100%; height: 3px; background: #dee2e6; z-index: 0; }
    .od-step:first-child::before { display: none; }
    .od-step.done::before { background: #dc3545; }
    .od-dot { width: 36px; height: 36px; border-radius: 50%; background: #dee2e6; color: #fff; display: inline-flex; align-items: center; justify-content: center; position: relative; z-index: 1; font-size: 14px; }
    .od-step.done .od-dot { background: #dc3545; }
    .od-step.current .od-dot { box-shadow: 0 0 0 5px rgba(220,53,69,.2); }
    .od-step-label { font-size: 13px; margin-top: 8px; color: #6c757d; font-weight: 500; }
    .od-step.done .od-step-label { color: #212529; font-weight: 700; }

    .od-table th { background: #f8f9fa; font-size: 13px; text-transform: uppercase; letter-spacing: .3px; color: #6c757d; border-bottom: 1px solid #e9ecef; padding: 12px 16px; }
    .od-table td { padding: 16px; vertical-align: top; border-color: #f1f3f5; }
    .od-upgrade { background: #f0f7ff; border-left: 3px solid #0d6efd; border-radius: 6px; padding: 8px 12px; margin-top: 10px; font-size: 13px; }
    .od-upgrade ul { margin: 4px 0 0; padding-left: 18px; color: #495057; }
    .od-total-box { background: #f8f9fa; border-radius: 10px; padding: 16px 20px; min-width: 320px; }
</style>

<c:set var="step" value="0"/>
<c:choose>
    <c:when test="${order.status == 'PENDING'}"><c:set var="step" value="1"/></c:when>
    <c:when test="${order.status == 'CONFIRMED'}"><c:set var="step" value="2"/></c:when>
    <c:when test="${order.status == 'SHIPPING'}"><c:set var="step" value="3"/></c:when>
    <c:when test="${order.status == 'FINISH' || order.status == 'COMPLETED'}"><c:set var="step" value="4"/></c:when>
</c:choose>

<div class="container od-wrap my-5">

    <!-- Tiêu đề -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
        <div>
            <h2 class="fw-bold text-dark mb-1">Đơn hàng #${order.id}</h2>
            <div class="text-muted small">
                <i class="far fa-clock me-1"></i>Đặt lúc
                <fmt:formatDate value="${order.createdAt}" pattern="HH:mm - dd/MM/yyyy"/>
            </div>
        </div>
        <c:choose>
            <c:when test="${order.status == 'PENDING'}"><span class="badge bg-warning text-dark fs-6 px-3 py-2">Chờ xử lý</span></c:when>
            <c:when test="${order.status == 'CONFIRMED'}"><span class="badge bg-primary fs-6 px-3 py-2">Đã xác nhận</span></c:when>
            <c:when test="${order.status == 'SHIPPING'}"><span class="badge bg-info text-dark fs-6 px-3 py-2">Đang giao</span></c:when>
            <c:when test="${order.status == 'FINISH' || order.status == 'COMPLETED'}"><span class="badge bg-success fs-6 px-3 py-2">Hoàn thành</span></c:when>
            <c:when test="${order.status == 'CANCELLED'}"><span class="badge bg-danger fs-6 px-3 py-2">Đã hủy</span></c:when>
            <c:otherwise><span class="badge bg-secondary fs-6 px-3 py-2">${order.status}</span></c:otherwise>
        </c:choose>
    </div>

    <!-- Tiến trình đơn hàng -->
    <div class="od-card p-4 mb-4">
        <c:choose>
            <c:when test="${order.status == 'CANCELLED'}">
                <div class="text-danger fw-semibold text-center py-2">
                    <i class="fas fa-ban me-2"></i>Đơn hàng này đã bị hủy.
                </div>
            </c:when>
            <c:otherwise>
                <div class="od-steps">
                    <div class="od-step ${step >= 1 ? 'done' : ''} ${step == 1 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-file-lines"></i></span>
                        <div class="od-step-label">Đã đặt hàng</div>
                    </div>
                    <div class="od-step ${step >= 2 ? 'done' : ''} ${step == 2 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-check"></i></span>
                        <div class="od-step-label">Đã xác nhận</div>
                    </div>
                    <div class="od-step ${step >= 3 ? 'done' : ''} ${step == 3 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-truck-fast"></i></span>
                        <div class="od-step-label">Đang giao</div>
                    </div>
                    <div class="od-step ${step >= 4 ? 'done' : ''} ${step == 4 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-box-open"></i></span>
                        <div class="od-step-label">Hoàn thành</div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Thông tin nhận hàng: 3 ô đều nhau -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="od-card p-3 h-100 d-flex gap-3">
                <span class="od-info-icon"><i class="fas fa-user"></i></span>
                <div>
                    <div class="od-title mb-1">Người nhận</div>
                    <div class="fw-bold text-dark">${order.receiverName}</div>
                    <div class="text-secondary"><i class="fas fa-phone me-1 small"></i>${order.receiverPhone}</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="od-card p-3 h-100 d-flex gap-3">
                <span class="od-info-icon"><i class="fas fa-location-dot"></i></span>
                <div>
                    <div class="od-title mb-1">Địa chỉ nhận hàng</div>
                    <div class="text-dark">${order.receiverAddress}</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="od-card p-3 h-100 d-flex gap-3">
                <span class="od-info-icon"><i class="fas fa-wallet"></i></span>
                <div>
                    <div class="od-title mb-1">Thanh toán &amp; ghi chú</div>
                    <div class="fw-bold text-dark">
                        <c:choose>
                            <c:when test="${order.paymentMethod == 'QR'}">Thanh toán online qua QR code
                                <span class="ms-1"><c:choose><c:when test="${order.paymentStatus == 'PAID'}"><span class="badge bg-success">Đã thanh toán</span></c:when><c:otherwise><span class="badge bg-danger">Chưa thanh toán</span></c:otherwise></c:choose></span></c:when>
                            <c:otherwise>Thanh toán khi nhận hàng (COD)</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="text-secondary small">
                        <c:choose>
                            <c:when test="${not empty order.note}">${order.note}</c:when>
                            <c:otherwise>Không có ghi chú</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Đơn QR chưa thanh toán: cho khách quét lại mã -->
    <c:if test="${order.paymentMethod == 'QR' && order.paymentStatus != 'PAID' && order.status != 'CANCELLED'}">
        <div class="od-card p-4 mb-4 text-center">
            <div class="od-title">Chưa thanh toán - quét mã QR để chuyển khoản</div>
            <img src="${pageContext.request.contextPath}/assets/images/qr_payment.png" alt="QR thanh toán" style="max-width:240px; width:100%;">
            <p class="mt-2 mb-1 text-dark">Số tiền: <strong class="text-danger"><fmt:formatNumber value="${order.totalMoney}" pattern="#,##0"/> đ</strong></p>
            <p class="small text-muted mb-0">Nội dung chuyển khoản: <strong>Đơn #${order.id} - ${order.receiverPhone}</strong>. Shop sẽ xử lý đơn sau khi xác nhận đã nhận tiền.</p>
        </div>
    </c:if>

    <!-- Sản phẩm -->
    <div class="od-card overflow-hidden mb-4">
        <div class="px-4 pt-4 pb-2"><div class="od-title">Sản phẩm đã đặt</div></div>
        <div class="table-responsive">
            <table class="table od-table mb-0 align-middle">
                <thead>
                <tr>
                    <th>Sản phẩm</th>
                    <th class="text-center" style="width: 150px;">Đơn giá</th>
                    <th class="text-center" style="width: 70px;">SL</th>
                    <th class="text-end" style="width: 160px;">Thành tiền</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${details}" var="item">
                    <tr>
                        <td>
                            <div class="fw-semibold text-dark">${item.productName}</div>
                            <c:if test="${not empty item.upgradeInfo}">
                                <div class="od-upgrade">
                                    <span class="fw-semibold text-primary"><i class="fas fa-arrow-up me-1"></i>Linh kiện nâng cấp</span>
                                    <ul>
                                        <c:forEach items="${fn:split(item.upgradeInfo, '|')}" var="line">
                                            <li>${line}</li>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                        </td>
                        <td class="text-center text-dark text-nowrap"><fmt:formatNumber value="${item.price}" pattern="#,##0"/> đ</td>
                        <td class="text-center text-dark">${item.quantity}</td>
                        <td class="text-end fw-bold text-dark text-nowrap"><fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0"/> đ</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
        <div class="d-flex justify-content-end p-4 border-top">
            <div class="od-total-box">
                <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-5 fw-semibold text-dark">Tổng thanh toán</span>
                    <span class="text-danger fw-bold fs-3 ms-4 text-nowrap"><fmt:formatNumber value="${order.totalMoney}" pattern="#,##0"/> đ</span>
                </div>
            </div>
        </div>
    </div>

    <a href="${pageContext.request.contextPath}/Home" class="btn btn-outline-secondary fw-semibold">
        <i class="fas fa-arrow-left me-1"></i> Tiếp tục mua hàng
    </a>
</div>

<jsp:include page="footer.jsp" />
