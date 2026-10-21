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
    .od-upgrade { background: #f0f7ff; border-left: 3px solid #0d6efd; border-radius: 6px; padding: 10px 14px; font-size: 13px; }
    .od-upgrade ul { margin: 4px 0 0; padding-left: 18px; color: #495057; }
    .od-voucher { background: #fff5f5; border-left: 3px solid #dc3545; border-radius: 6px; padding: 10px 14px; font-size: 13px; }
    .od-total-box { background: #f8f9fa; border-radius: 10px; padding: 16px 20px; min-width: 320px; }

    /* Khối chờ thanh toán QR */
    .od-pay { border: 1px solid #f5c2c7; background: #fff5f5; border-radius: 12px; }
</style>

<c:set var="step" value="0"/>
<c:choose>
    <c:when test="${order.status == 'PENDING'}"><c:set var="step" value="1"/></c:when>
    <c:when test="${order.status == 'CONFIRMED'}"><c:set var="step" value="2"/></c:when>
    <c:when test="${order.status == 'PREPARING'}"><c:set var="step" value="3"/></c:when>
    <c:when test="${order.status == 'READY_TO_PICK'}"><c:set var="step" value="4"/></c:when>
    <c:when test="${order.status == 'SHIPPING'}"><c:set var="step" value="5"/></c:when>
    <c:when test="${order.status == 'FINISH' || order.status == 'COMPLETED'}"><c:set var="step" value="6"/></c:when>
</c:choose>

<div class="container od-wrap my-5">

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${not empty sessionScope.orderActionMsg}">
        <div class="alert ${sessionScope.orderActionSuccess ? 'alert-success' : 'alert-danger'} alert-dismissible fade show mb-4" role="alert">
            <i class="fas ${sessionScope.orderActionSuccess ? 'fa-check-circle' : 'fa-exclamation-circle'} me-2"></i>${sessionScope.orderActionMsg}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="orderActionMsg" scope="session"/>
        <c:remove var="orderActionSuccess" scope="session"/>
    </c:if>

    <!-- Tiêu đề -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
        <div>
            <h2 class="fw-bold text-dark mb-1">Đơn hàng #${order.id}</h2>
            <div class="text-muted small">
                <i class="far fa-clock me-1"></i>Đặt lúc
                <fmt:formatDate value="${order.createdAt}" pattern="HH:mm - dd/MM/yyyy"/>
            </div>
        </div>
        <div id="order-detail-status-badge">
        <c:choose>
            <c:when test="${order.status == 'PENDING'}"><span class="badge bg-warning text-dark fs-6 px-3 py-2">Chờ xử lý</span></c:when>
            <c:when test="${order.status == 'CONFIRMED'}"><span class="badge bg-primary fs-6 px-3 py-2">Đã xác nhận</span></c:when>
            <c:when test="${order.status == 'PREPARING'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #6366f1;">Chuẩn bị hàng</span></c:when>
            <c:when test="${order.status == 'READY_TO_PICK'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #0284c7;">Chờ lấy hàng</span></c:when>
            <c:when test="${order.status == 'SHIPPING'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #0ea5e9;">Đang giao hàng</span></c:when>
            <c:when test="${order.status == 'FINISH' || order.status == 'COMPLETED'}"><span class="badge bg-success fs-6 px-3 py-2">Hoàn thành</span></c:when>
            <c:when test="${order.status == 'CANCELLED'}"><span class="badge bg-danger fs-6 px-3 py-2">Đã hủy</span></c:when>
            <c:when test="${order.status == 'CLIENT_CANCELLED'}"><span class="badge bg-danger fs-6 px-3 py-2">Khách hủy đơn</span></c:when>
            <c:when test="${order.status == 'DELIVERY_FAILED'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #b91c1c;">Giao thất bại</span></c:when>
            <c:when test="${order.status == 'RETURNING'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #f59e0b;">Đang hoàn hàng</span></c:when>
            <c:when test="${order.status == 'RETURNED'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #64748b;">Đã hoàn hàng</span></c:when>
            <c:when test="${order.status == 'RETURN_REQUESTED'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #7c3aed;">Yêu cầu đổi trả</span></c:when>
            <c:when test="${order.status == 'RETURN_PROCESSING'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #9333ea;">Đang xử lý đổi trả</span></c:when>
            <c:when test="${order.status == 'EXCHANGED'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #0d9488;">Đã đổi hàng</span></c:when>
            <c:when test="${order.status == 'REFUNDED'}"><span class="badge fs-6 px-3 py-2 text-white" style="background-color: #475569;">Đã hoàn tiền</span></c:when>
            <c:otherwise><span class="badge bg-secondary fs-6 px-3 py-2">${order.status}</span></c:otherwise>
        </c:choose>
        </div>
    </div>

    <!-- Tiến trình đơn hàng -->
    <div class="od-card p-4 mb-4">
        <c:choose>
            <c:when test="${order.status == 'CANCELLED' || order.status == 'CLIENT_CANCELLED'}">
                <div class="text-danger fw-semibold text-center py-2">
                    <i class="fas fa-ban me-2"></i>Đơn hàng này đã bị hủy. Toàn bộ sản phẩm đã được hoàn lại kho.
                    <c:if test="${order.paymentMethod == 'QR' && (order.paymentStatus == 'PAID' || order.transferAmount > 0)}">
                        <div class="mt-2 text-warning fw-bold small" style="color: #d97706 !important;">
                            <i class="fas fa-hand-holding-dollar me-1"></i> Do bạn đã thanh toán qua QR, bộ phận CSKH sẽ chủ động liên hệ để hoàn tiền lại số tiền <fmt:formatNumber value="${order.totalMoney}" pattern="#,##0"/> đ cho bạn.
                        </div>
                    </c:if>
                </div>
            </c:when>
            <c:when test="${order.status == 'DELIVERY_FAILED'}">
                <div class="text-danger fw-semibold text-center py-2">
                    <i class="fas fa-triangle-exclamation me-2"></i>Giao hàng thất bại (Không liên lạc được hoặc khách từ chối nhận). Shop sẽ liên hệ lại hoặc xử lý chuyển hoàn.
                </div>
            </c:when>
            <c:when test="${order.status == 'RETURNING'}">
                <div class="text-warning fw-semibold text-center py-2" style="color: #d97706 !important;">
                    <i class="fas fa-truck-ramp-box me-2"></i>Kiện hàng đang trên đường chuyển hoàn trả về shop.
                </div>
            </c:when>
            <c:when test="${order.status == 'RETURNED'}">
                <div class="text-secondary fw-semibold text-center py-2">
                    <i class="fas fa-boxes-packing me-2"></i>Shop đã nhận lại kiện hàng và hoàn lại vào kho. Đơn hàng kết thúc.
                </div>
            </c:when>
            <c:when test="${order.status == 'RETURN_REQUESTED'}">
                <div class="fw-semibold text-center py-2" style="color: #7c3aed;">
                    <i class="fas fa-clock-rotate-left me-2"></i>Yêu cầu đổi trả/hoàn tiền đã được gửi. Shop đang tiếp nhận và xem xét.
                </div>
            </c:when>
            <c:when test="${order.status == 'RETURN_PROCESSING'}">
                <div class="fw-semibold text-center py-2" style="color: #9333ea;">
                    <i class="fas fa-arrows-rotate me-2"></i>Shop đang kiểm tra sản phẩm và xử lý khiếu nại đổi trả cho bạn.
                </div>
            </c:when>
            <c:when test="${order.status == 'EXCHANGED'}">
                <div class="fw-semibold text-center py-2" style="color: #0d9488;">
                    <i class="fas fa-rotate me-2"></i>Shop đã gửi sản phẩm đổi mới cho bạn. Quy trình đổi trả hoàn tất!
                </div>
            </c:when>
            <c:when test="${order.status == 'REFUNDED'}">
                <div class="fw-semibold text-center py-2" style="color: #475569;">
                    <i class="fas fa-hand-holding-dollar me-2"></i>Shop đã hoàn lại tiền cho bạn thành công. Giao dịch kết thúc!
                </div>
            </c:when>
            <c:otherwise>
                <div class="od-steps">
                    <div class="od-step ${step >= 1 ? 'done' : ''} ${step == 1 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-file-lines"></i></span>
                        <div class="od-step-label">Đặt hàng</div>
                    </div>
                    <div class="od-step ${step >= 2 ? 'done' : ''} ${step == 2 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-check"></i></span>
                        <div class="od-step-label">Đã xác nhận</div>
                    </div>
                    <div class="od-step ${step >= 3 ? 'done' : ''} ${step == 3 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-boxes-stacked"></i></span>
                        <div class="od-step-label">Chuẩn bị hàng</div>
                    </div>
                    <div class="od-step ${step >= 4 ? 'done' : ''} ${step == 4 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-dolly"></i></span>
                        <div class="od-step-label">Chờ lấy hàng</div>
                    </div>
                    <div class="od-step ${step >= 5 ? 'done' : ''} ${step == 5 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-truck-fast"></i></span>
                        <div class="od-step-label">Đang giao</div>
                    </div>
                    <div class="od-step ${step >= 6 ? 'done' : ''} ${step == 6 ? 'current' : ''}">
                        <span class="od-dot"><i class="fas fa-box-open"></i></span>
                        <div class="od-step-label">Hoàn thành</div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Đơn chuyển khoản QR chưa được admin xác nhận đã nhận tiền -->
    <c:if test="${order.paymentMethod == 'QR' && order.paymentStatus != 'PAID' && order.status != 'CANCELLED'}">
        <div class="od-pay p-4 mb-4">
            <div class="fw-bold text-danger fs-5 mb-1">
                <i class="fas fa-hourglass-half me-2"></i>Hãy chờ để admin xác nhận đã nhận đủ tiền
            </div>
            <div class="text-dark">
                Số tiền cần chuyển:
                <strong class="text-danger"><fmt:formatNumber value="${order.totalMoney}" pattern="#,##0"/> đ</strong>
            </div>
        </div>
    </c:if>

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
                            <c:when test="${order.paymentMethod == 'QR'}">Chuyển khoản QR (VNPAY)
                                <span class="ms-1"><c:choose><c:when test="${order.paymentStatus == 'PAID'}"><span class="badge bg-success">Đã thanh toán</span></c:when><c:otherwise><span class="badge bg-warning text-dark">Chờ xác nhận tiền</span></c:otherwise></c:choose></span></c:when>
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

    <!-- Sản phẩm -->
    <!-- Sản phẩm & Thanh toán: Bố cục 2 cột ngang hàng cân đối -->
    <div class="row g-4 align-items-stretch mb-4">
        <!-- Cột trái: Sản phẩm đã đặt -->
        <div class="col-lg-8">
            <div class="od-card overflow-hidden h-100">
                <div class="px-4 pt-4 pb-2"><div class="od-title">Sản phẩm đã đặt</div></div>
                <div class="table-responsive">
                    <table class="table od-table mb-0 align-middle">
                        <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th class="text-center" style="width: 140px;">Đơn giá</th>
                            <th class="text-center" style="width: 60px;">SL</th>
                            <th class="text-end" style="width: 150px;">Thành tiền</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${details}" var="item">
                            <tr>
                                <td>
                                    <div class="fw-semibold text-dark">${item.productName}</div>
                                    <c:if test="${not empty item.upgradeInfo}">
                                        <div class="od-upgrade mt-2">
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
            </div>
        </div>

        <!-- Cột phải: Chi tiết thanh toán (đoạn ở ảnh 1 đưa lên ngang bằng) -->
        <div class="col-lg-4">
            <div class="od-card p-4 h-100 d-flex flex-column justify-content-between">
                <div>
                    <div class="od-title mb-3">Chi tiết thanh toán</div>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="text-secondary">Tiền hàng:</span>
                        <span class="fw-semibold text-dark text-nowrap"><fmt:formatNumber value="${order.totalMoney + order.discountAmount - order.shippingFee}" pattern="#,##0"/> đ</span>
                    </div>
                    <c:if test="${order.discountAmount > 0}">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-secondary"><i class="fas fa-ticket text-danger me-1"></i>Voucher giảm giá (${not empty order.voucherCode ? order.voucherCode : 'Ưu đãi'}):</span>
                            <span class="fw-bold text-success text-nowrap">-<fmt:formatNumber value="${order.discountAmount}" pattern="#,##0"/> đ</span>
                        </div>
                    </c:if>
                    <c:if test="${order.shippingFee > 0}">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-secondary"><i class="fas fa-truck-fast text-danger me-1"></i>Phí ship (GHN):</span>
                            <span class="fw-semibold text-primary text-nowrap"><fmt:formatNumber value="${order.shippingFee}" pattern="#,##0"/> đ</span>
                        </div>
                    </c:if>
                </div>
                <div class="pt-3 border-top mt-3">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="fs-5 fw-semibold text-dark">Tổng thanh toán:</span>
                        <span class="text-danger fw-bold fs-3 text-nowrap ms-2"><fmt:formatNumber value="${order.totalMoney}" pattern="#,##0"/> đ</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2">
        <a href="${pageContext.request.contextPath}/Home" class="btn btn-outline-secondary fw-semibold">
            <i class="fas fa-arrow-left me-1"></i> Tiếp tục mua hàng
        </a>

        <div class="d-flex gap-2">
            <c:if test="${order.status == 'PENDING'}">
                <form action="${pageContext.request.contextPath}/client/order-action" method="post"
                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng #${order.id}? Sản phẩm sẽ được hoàn lại kho.');">
                    <input type="hidden" name="id" value="${order.id}">
                    <input type="hidden" name="action" value="cancel">
                    <button type="submit" class="btn btn-danger fw-semibold">
                        <i class="fas fa-ban me-1"></i> Hủy đơn hàng
                    </button>
                </form>
            </c:if>

            <c:if test="${order.status == 'FINISH' || order.status == 'COMPLETED'}">
                <form action="${pageContext.request.contextPath}/client/order-action" method="post"
                      onsubmit="return confirm('Bạn muốn gửi yêu cầu đổi trả / hoàn tiền cho đơn hàng #${order.id}? Shop sẽ kiểm tra và liên hệ hỗ trợ bạn.');">
                    <input type="hidden" name="id" value="${order.id}">
                    <input type="hidden" name="action" value="return_request">
                    <button type="submit" class="btn btn-outline-dark fw-semibold" style="border-color: #7c3aed; color: #7c3aed;">
                        <i class="fas fa-arrows-rotate me-1"></i> Yêu cầu đổi trả / hoàn tiền
                    </button>
                </form>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />
