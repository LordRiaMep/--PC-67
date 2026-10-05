<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="header.jsp" />

<div class="container my-5 bg-white p-4 rounded shadow-sm">
    <h2 class="fw-bold text-dark mb-4">Đơn hàng của tôi</h2>

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
            <tr>
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
                            <div class="mt-1"><c:choose><c:when test="${o.paymentStatus == 'PAID'}"><span class="badge bg-success">Đã thanh toán</span></c:when><c:otherwise><span class="badge bg-danger">Chưa thanh toán</span></c:otherwise></c:choose></div>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-secondary px-2 py-2">COD</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <c:choose>
                        <c:when test="${o.status == 'PENDING'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #d97706;">
                                Chờ xử lý
                            </span>
                        </c:when>
                        <c:when test="${o.status == 'CONFIRMED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #2563eb;">
                                Đã xác nhận
                            </span>
                        </c:when>
                        <c:when test="${o.status == 'SHIPPING'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #0284c7;">
                                Đang giao hàng
                            </span>
                        </c:when>
                        <c:when test="${o.status == 'FINISH' || o.status == 'COMPLETED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #16a34a;">
                                Hoàn thành
                            </span>
                        </c:when>
                        <c:when test="${o.status == 'CANCELLED'}">
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #dc2626;">
                                Đã hủy
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge fw-bold px-3 py-2 text-white" style="background-color: #6c757d;">
                                    ${o.status}
                            </span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td class="text-end">
                    <a href="${pageContext.request.contextPath}/order-detail?id=${o.id}" class="btn btn-outline-dark btn-sm fw-bold">Chi tiết</a>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>

<jsp:include page="footer.jsp" />
