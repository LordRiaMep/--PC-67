<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<div class="container my-5 bg-white p-4 rounded shadow-sm">
    <h2 class="fw-bold text-dark mb-4">Đơn hàng của tôi</h2>

    <c:if test="${not empty sessionScope.orderActionMsg}">
        <div class="alert ${sessionScope.orderActionSuccess ? 'alert-success' : 'alert-danger'} alert-dismissible fade show mb-4" role="alert">
            ${sessionScope.orderActionMsg}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="orderActionMsg" scope="session"/>
        <c:remove var="orderActionSuccess" scope="session"/>
    </c:if>

    <table class="table table-bordered table-hover align-middle">
        <thead class="table-light">
        <tr>
            <th class="py-3 text-dark">Mã</th>
            <th class="py-3 text-dark">Ngày đặt</th>
            <th class="py-3 text-dark">Người nhận</th>
            <th class="py-3 text-dark">Tổng tiền</th>
            <th class="py-3 text-dark">Thanh toán</th>
            <th class="py-3 text-dark">Trạng thái</th>
            <th class="py-3 text-end text-dark">Hành động</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${orders}" var="o">
            <tr id="client-order-row-${o.id}" data-order-id="${o.id}">
                <td class="fw-bold text-dark">#${o.id}</td>
                <td class="text-dark">${o.createdAt}</td>
                <td class="text-dark">${o.receiverName}</td>
                <td class="fw-bold text-danger">
                    <fmt:formatNumber value="${o.totalMoney}" pattern="#,##0"/> đ
                </td>
                <td>
                    <c:choose>
                        <c:when test="${o.paymentMethod == 'QR'}">
                            <span class="badge bg-info text-dark px-2 py-2">QR code</span>
                            <div class="mt-1"><c:choose><c:when test="${o.paymentStatus == 'PAID'}"><span class="badge bg-success">Đã thanh toán</span></c:when><c:otherwise><span class="badge bg-warning text-dark">Chờ xác nhận tiền</span></c:otherwise></c:choose></div>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-secondary px-2 py-2">COD</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <c:choose>
                        <c:when test="${o.status == 'PENDING'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #d97706;">Chờ xử lý</span>
                        </c:when>
                        <c:when test="${o.status == 'CONFIRMED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #2563eb;">Đã xác nhận</span>
                        </c:when>
                        <c:when test="${o.status == 'PREPARING'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #6366f1;">Chuẩn bị hàng</span>
                        </c:when>
                        <c:when test="${o.status == 'READY_TO_PICK'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #0284c7;">Chờ lấy hàng</span>
                        </c:when>
                        <c:when test="${o.status == 'SHIPPING'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #0ea5e9;">Đang giao hàng</span>
                        </c:when>
                        <c:when test="${o.status == 'FINISH' || o.status == 'COMPLETED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #16a34a;">Hoàn thành</span>
                        </c:when>
                        <c:when test="${o.status == 'CANCELLED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #dc2626;">Đã hủy</span>
                        </c:when>
                        <c:when test="${o.status == 'CLIENT_CANCELLED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #dc2626;">Khách hủy đơn</span>
                        </c:when>
                        <c:when test="${o.status == 'DELIVERY_FAILED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #b91c1c;">Giao thất bại</span>
                        </c:when>
                        <c:when test="${o.status == 'RETURNING'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #f59e0b;">Đang hoàn hàng</span>
                        </c:when>
                        <c:when test="${o.status == 'RETURNED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #64748b;">Đã hoàn hàng</span>
                        </c:when>
                        <c:when test="${o.status == 'RETURN_REQUESTED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #7c3aed;">Yêu cầu đổi trả</span>
                        </c:when>
                        <c:when test="${o.status == 'RETURN_PROCESSING'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #9333ea;">Đang xử lý đổi</span>
                        </c:when>
                        <c:when test="${o.status == 'EXCHANGED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #0d9488;">Đã đổi hàng</span>
                        </c:when>
                        <c:when test="${o.status == 'REFUNDED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #475569;">Đã hoàn tiền</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #6c757d;">${o.statusDisplayName}</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td class="text-end">
                    <c:if test="${o.status == 'PENDING'}">
                        <form action="${pageContext.request.contextPath}/client/order-action" method="post" class="d-inline"
                              onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng #${o.id}? Sản phẩm sẽ được hoàn lại kho.');">
                            <input type="hidden" name="id" value="${o.id}">
                            <input type="hidden" name="action" value="cancel">
                            <button type="submit" class="btn btn-outline-danger btn-sm fw-bold me-1">Hủy đơn</button>
                        </form>
                    </c:if>
                    <c:if test="${o.paymentMethod == 'QR' && o.paymentStatus != 'PAID' && o.status != 'CANCELLED' && o.status != 'CLIENT_CANCELLED'}">
                        <a href="${pageContext.request.contextPath}/payment-qr?id=${o.id}" class="btn btn-danger btn-sm fw-bold me-1">Thanh toán</a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/order-detail?id=${o.id}" class="btn btn-outline-dark btn-sm fw-bold">Chi tiết</a>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>

<jsp:include page="footer.jsp" />
