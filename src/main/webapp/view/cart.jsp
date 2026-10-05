<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="header.jsp" />

<!-- Thẻ container nền trắng, chữ đen, bo góc và đổ bóng nhẹ -->
<div class="container my-5 bg-white p-4 rounded shadow-sm">
    <h2 class="fw-bold text-dark mb-4">Giỏ hàng của tôi</h2>

    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger" role="alert">
                ${sessionScope.error}
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>

    <c:choose>
        <c:when test="${empty sessionScope.cart.items}">
            <!-- Thông báo giỏ hàng trống giao diện sáng Bootstrap -->
            <div class="alert alert-warning d-flex align-items-center justify-content-between p-3 rounded-3 my-4">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-cart-x fs-4 text-warning"></i>
                    <span class="fs-6 fw-semibold text-dark">Giỏ hàng của bạn đang trống.</span>
                </div>
                <a href="${pageContext.request.contextPath}/Home" class="btn btn-danger btn-sm fw-bold px-3">
                    Đi mua sắm ngay
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Bảng sản phẩm đóng khung, màu sáng -->
            <table class="table table-bordered table-hover align-middle">
                <thead class="table-light">
                <tr>
                    <th class="py-3 text-dark text-center" style="width: 80px;">Ảnh</th>
                    <th class="py-3 text-dark">Tên sản phẩm</th>
                    <th class="py-3 text-dark">Giá</th>
                    <th class="py-3 text-dark" style="width: 140px;">Số lượng</th>
                    <th class="py-3 text-dark">Tạm tính</th>
                    <th class="py-3 text-dark text-center" style="width: 100px;">Hành động</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${sessionScope.cart.items}" var="item">
                    <tr>
                        <td class="text-center">
                            <img src="${item.product.image}" class="rounded border" width="60" height="60" style="object-fit: cover;">
                        </td>

                        <td class="fw-semibold text-dark">
                                ${item.product.name}
                            <c:if test="${not empty item.upgradeInfo}">
                                <div class="mt-1 small fw-normal text-primary">
                                    <i class="fas fa-arrow-up me-1"></i>Linh kiện nâng cấp:
                                    <ul class="mb-0 ps-3">
                                        <c:forEach items="${fn:split(item.upgradeInfo, '|')}" var="line">
                                            <li>${line}</li>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                        </td>

                        <td class="text-dark">
                            <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0" /> đ
                        </td>

                        <td>
                            <form action="update-cart" method="post" class="d-flex align-items-center gap-1">
                                <input type="hidden" name="productId" value="${item.product.id}">
                                <input type="hidden" name="upgradeKey" value="${item.upgradeKey}">
                                <input type="number" name="quantity" value="${item.quantity}" min="1" max="${item.product.quantity}" class="form-control form-control-sm text-center" style="width: 65px;">
                                <button type="submit" class="btn btn-sm btn-outline-secondary">Lưu</button>
                            </form>
                        </td>

                        <td class="text-danger fw-bold">
                            <fmt:formatNumber value="${item.unitPrice * item.quantity}" pattern="#,##0" /> đ
                        </td>

                        <td class="text-center">
                            <a href="remove-from-cart?id=${item.product.id}&key=${item.upgradeKey}" class="btn btn-sm btn-outline-danger">
                                <i class="bi bi-trash me-1"></i>Xóa
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>

            <!-- Tổng tiền và nút thao tác -->
            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
                <a href="${pageContext.request.contextPath}/Home" class="btn btn-outline-secondary fw-semibold">
                    <i class="bi bi-arrow-left me-1"></i> Tiếp tục mua hàng
                </a>
                <div class="text-end">
                    <h4 class="mb-3 text-dark">Tổng tiền:
                        <span class="text-danger fw-bold fs-3 ms-2">
                            <fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,##0" /> đ
                        </span>
                    </h4>
                    <a href="checkout" class="btn btn-danger btn-lg fw-bold px-4">Xác Nhận Đặt Hàng</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="footer.jsp" />