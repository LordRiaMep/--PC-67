<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<div class="container my-5">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb" style="font-size: 13.5px;">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/Home" class="text-decoration-none text-muted">Trang chủ</a></li>
            <li class="breadcrumb-item active text-dark fw-bold" aria-current="page">Lịch sử đơn hàng</li>
        </ol>
    </nav>

    <div class="bg-white p-4 p-lg-5 rounded-4 border shadow-sm">
        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
            <div class="d-flex align-items-center gap-2">
                <span class="d-inline-block rounded-pill" style="width: 5px; height: 22px; background: var(--brand-gradient);"></span>
                <h3 class="fw-bold text-dark mb-0" style="font-size: 20px;">Lịch sử đơn hàng của tôi</h3>
            </div>
            <c:if test="${totalOrders > 0}">
                <span class="badge-category"><i class="bi bi-receipt me-1 text-danger"></i>${totalOrders} đơn hàng</span>
            </c:if>
        </div>

        <c:if test="${not empty sessionScope.orderActionMsg}">
            <div class="alert ${sessionScope.orderActionSuccess ? 'alert-success' : 'alert-danger'} alert-dismissible fade show mb-4 rounded-3" role="alert">
                ${sessionScope.orderActionMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="orderActionMsg" scope="session"/>
            <c:remove var="orderActionSuccess" scope="session"/>
        </c:if>

        <div class="table-responsive rounded-3 border overflow-hidden mb-4 shadow-sm">
            <table class="table table-hover align-middle mb-0" style="border-collapse: separate; border-spacing: 0;">
                <thead class="table-light text-uppercase" style="font-size: 12px; letter-spacing: 0.03em;">
                <tr>
                    <th class="py-3 px-3 text-secondary" style="width: 90px;">Mã đơn</th>
                    <th class="py-3 px-3 text-secondary" style="width: 175px;">Ngày đặt</th>
                    <th class="py-3 px-3 text-secondary" style="width: 140px;">Người nhận</th>
                    <th class="py-3 px-3 text-secondary" style="width: 150px;">Tổng tiền</th>
                    <th class="py-3 px-3 text-secondary text-center" style="width: 120px;">Thanh toán</th>
                    <th class="py-3 px-3 text-secondary text-center" style="width: 140px;">Trạng thái</th>
                    <th class="py-3 px-3 text-secondary text-end" style="width: 180px;">Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${orders}" var="o">
                    <tr id="client-order-row-${o.id}" data-order-id="${o.id}">
                        <td class="px-3 py-3 fw-bold text-dark">
                            <span class="badge bg-light text-dark border px-2 py-1 font-monospace" style="font-size: 13px;">#${o.id}</span>
                        </td>
                        <td class="px-3 py-3 text-secondary small">${o.createdAt}</td>
                        <td class="px-3 py-3 text-dark fw-semibold">${o.receiverName}</td>
                        <td class="px-3 py-3 fw-bold text-danger fs-6">
                            <fmt:formatNumber value="${o.totalMoney}" pattern="#,##0"/> đ
                        </td>
                        <td class="px-3 py-3 text-center">
                            <c:choose>
                                <c:when test="${o.paymentMethod == 'QR'}">
                                    <span class="badge rounded-pill bg-primary bg-opacity-10 text-primary border border-primary px-2 py-1 small">VNPay QR</span>
                                    <div class="mt-1">
                                        <c:choose>
                                            <c:when test="${o.paymentStatus == 'PAID'}">
                                                <span class="badge bg-success small">Đã thanh toán</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning text-dark small">Chờ thanh toán</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge rounded-pill bg-secondary bg-opacity-10 text-secondary border border-secondary px-2 py-1 small">COD</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-3 py-3 text-center">
                            <c:choose>
                                <c:when test="${o.status == 'PENDING'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #d97706;">Chờ xử lý</span>
                                </c:when>
                                <c:when test="${o.status == 'CONFIRMED'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #2563eb;">Đã xác nhận</span>
                                </c:when>
                                <c:when test="${o.status == 'PREPARING'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #6366f1;">Chuẩn bị hàng</span>
                                </c:when>
                                <c:when test="${o.status == 'READY_TO_PICK'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #0284c7;">Chờ lấy hàng</span>
                                </c:when>
                                <c:when test="${o.status == 'SHIPPING'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #0ea5e9;">Đang giao hàng</span>
                                </c:when>
                                <c:when test="${o.status == 'FINISH' || o.status == 'COMPLETED'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #16a34a;">Hoàn thành</span>
                                </c:when>
                                <c:when test="${o.status == 'CANCELLED' || o.status == 'CLIENT_CANCELLED'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #dc2626;">Đã hủy</span>
                                </c:when>
                                <c:when test="${o.status == 'DELIVERY_FAILED'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #b91c1c;">Giao thất bại</span>
                                </c:when>
                                <c:when test="${o.status == 'RETURNING'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #f59e0b;">Đang hoàn hàng</span>
                                </c:when>
                                <c:when test="${o.status == 'RETURNED'}">
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #64748b;">Đã hoàn hàng</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge rounded-pill fw-semibold px-3 py-1 text-white" style="background-color: #6c757d;">${o.statusDisplayName}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-3 py-3 text-end">
                            <c:if test="${o.status == 'PENDING'}">
                                <form action="${pageContext.request.contextPath}/client/order-action" method="post" class="d-inline"
                                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng #${o.id}? Sản phẩm sẽ được hoàn lại kho.');">
                                    <input type="hidden" name="id" value="${o.id}">
                                    <input type="hidden" name="action" value="cancel">
                                    <button type="submit" class="btn btn-outline-danger btn-sm rounded-pill px-2 py-1 me-1 small">Hủy đơn</button>
                                </form>
                            </c:if>
                            <c:if test="${o.paymentMethod == 'QR' && o.paymentStatus != 'PAID' && o.status != 'CANCELLED' && o.status != 'CLIENT_CANCELLED'}">
                                <a href="${pageContext.request.contextPath}/payment-qr?id=${o.id}" class="btn btn-danger btn-sm rounded-pill px-2 py-1 me-1 small">Thanh toán</a>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/order-detail?id=${o.id}" class="btn btn-outline-secondary btn-sm rounded-pill px-3 py-1 small">Chi tiết</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty orders}">
                    <tr>
                        <td colspan="7" class="text-center text-muted py-5">
                            <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>Bạn chưa có đơn hàng nào.
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>

        <c:if test="${totalPages > 1}">
            <nav aria-label="Page navigation" class="mt-4">
                <ul class="pagination justify-content-center mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/orders?page=${currentPage - 1}">Trước</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/orders?page=${i}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/orders?page=${currentPage + 1}">Sau</a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>
</div>

<jsp:include page="footer.jsp" />
