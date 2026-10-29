<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="header.jsp" />

<div class="container my-5">
    <!-- Breadcrumb & Step progress -->
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0" style="font-size: 13.5px;">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/Home" class="text-decoration-none text-muted">Trang chủ</a></li>
                <li class="breadcrumb-item active text-dark fw-bold" aria-current="page">Giỏ hàng của tôi</li>
            </ol>
        </nav>
        <div class="d-flex align-items-center gap-2 small">
            <span class="badge rounded-pill bg-danger text-white px-3 py-2 fw-semibold shadow-sm">1. Giỏ hàng</span>
            <i class="bi bi-chevron-right text-muted"></i>
            <span class="badge rounded-pill bg-white text-muted border px-3 py-2">2. Thanh toán</span>
            <i class="bi bi-chevron-right text-muted"></i>
            <span class="badge rounded-pill bg-white text-muted border px-3 py-2">3. Hoàn tất</span>
        </div>
    </div>

    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>

    <c:choose>
        <c:when test="${empty sessionScope.cart.items}">
            <div class="bg-white p-5 rounded-4 border shadow-sm text-center">
                <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3" style="width: 80px; height: 80px; background: rgba(220, 38, 38, 0.08); color: #dc2626; font-size: 36px;">
                    <i class="bi bi-cart-x"></i>
                </div>
                <h4 class="fw-bold text-dark mb-2">Giỏ hàng của bạn đang trống!</h4>
                <p class="text-muted small mb-4">Hãy dạo một vòng cửa hàng để chọn cho mình cấu hình máy tính ưng ý nhé.</p>
                <a href="${pageContext.request.contextPath}/Home" class="btn btn-danger btn-lg px-4 fw-semibold" style="font-size: 14.5px;">
                    <i class="bi bi-bag-plus me-1"></i> Khám phá sản phẩm ngay
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row g-4">
                <!-- Cart Items Table (Left Column) -->
                <div class="col-lg-8">
                    <div class="bg-white p-4 rounded-4 border shadow-sm mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                            <div class="d-flex align-items-center gap-2">
                                <span class="d-inline-block rounded-pill" style="width: 4px; height: 20px; background: #dc2626;"></span>
                                <h4 class="fw-bold text-dark mb-0" style="font-size: 18px;">Danh sách sản phẩm</h4>
                            </div>
                            <c:if test="${totalItems > 0}">
                                <span class="badge bg-light text-secondary border px-3 py-2 fw-semibold" style="font-size: 12.5px;">
                                    <i class="bi bi-box-seam me-1 text-danger"></i>${totalItems} sản phẩm
                                </span>
                            </c:if>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0" style="border-collapse: separate; border-spacing: 0;">
                                <thead class="table-light text-uppercase" style="font-size: 11.5px; letter-spacing: 0.04em;">
                                <tr>
                                    <th class="py-3 px-3 text-secondary" style="min-width: 250px;">Sản phẩm</th>
                                    <th class="py-3 px-3 text-secondary" style="width: 130px;">Đơn giá</th>
                                    <th class="py-3 px-3 text-secondary text-center" style="width: 140px;">Số lượng</th>
                                    <th class="py-3 px-3 text-secondary" style="width: 140px;">Thành tiền</th>
                                    <th class="py-3 px-3 text-secondary text-center" style="width: 50px;"></th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach items="${not empty cartItems ? cartItems : sessionScope.cart.items}" var="item">
                                    <tr>
                                        <td class="px-3 py-3">
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="p-1 rounded-3 border bg-light flex-shrink-0" style="width: 68px; height: 68px; display: flex; align-items: center; justify-content: center;">
                                                    <img src="${item.product.image}" class="rounded" style="max-width: 100%; max-height: 100%; object-fit: contain;">
                                                </div>
                                                <div>
                                                    <a href="${pageContext.request.contextPath}/product/detail?id=${item.product.id}" class="text-decoration-none text-dark fw-bold hover-danger" style="font-size: 14px; line-height: 1.35; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                                        ${item.product.name}
                                                    </a>
                                                    <c:choose>
                                                        <c:when test="${item.product.quantity <= 0}">
                                                            <span class="badge bg-danger mt-1 small"><i class="bi bi-exclamation-triangle me-1"></i>Hết hàng</span>
                                                        </c:when>
                                                        <c:when test="${item.quantity > item.product.quantity}">
                                                            <span class="badge bg-warning text-dark mt-1 small"><i class="bi bi-exclamation-circle me-1"></i>Chỉ còn ${item.product.quantity}</span>
                                                        </c:when>
                                                    </c:choose>
                                                    <c:if test="${not empty item.upgradeInfo}">
                                                        <div class="p-2 rounded-2 border bg-light small text-secondary mt-2" style="font-size: 11.5px;">
                                                            <div class="fw-semibold text-primary mb-1"><i class="bi bi-cpu me-1"></i>Tùy chọn nâng cấp:</div>
                                                            <ul class="mb-0 ps-3">
                                                                <c:forEach items="${fn:split(item.upgradeInfo, '|')}" var="line">
                                                                    <li>${line}</li>
                                                                </c:forEach>
                                                            </ul>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </td>

                                        <td class="px-3 py-3 text-secondary fw-semibold">
                                            <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0" /> đ
                                        </td>

                                        <td class="px-3 py-3 text-center">
                                            <form action="update-cart" method="post" class="d-inline-flex align-items-center gap-1 justify-content-center">
                                                <input type="hidden" name="productId" value="${item.product.id}">
                                                <input type="hidden" name="upgradeKey" value="${item.upgradeKey}">
                                                <input type="hidden" name="page" value="${currentPage}">
                                                <input type="number" name="quantity" value="${item.quantity}" min="1" max="${item.product.quantity}" class="form-control form-control-sm text-center fw-bold" style="width: 54px; height: 34px; border-radius: 6px;">
                                                <button type="submit" class="btn btn-sm btn-outline-secondary" style="height: 34px; width: 34px; padding: 0;" title="Cập nhật">
                                                    <i class="bi bi-arrow-repeat"></i>
                                                </button>
                                            </form>
                                        </td>

                                        <td class="px-3 py-3 text-danger fw-bold fs-6">
                                            <fmt:formatNumber value="${item.unitPrice * item.quantity}" pattern="#,##0" /> đ
                                        </td>

                                        <td class="px-3 py-3 text-center">
                                            <a href="remove-from-cart?id=${item.product.id}&key=${item.upgradeKey}&page=${currentPage}" class="btn btn-sm text-danger rounded-circle p-0 d-inline-flex align-items-center justify-content-center" style="background: #fef2f2; width: 34px; height: 34px; transition: background 0.2s;" title="Xóa khỏi giỏ" onmouseover="this.style.background='#fee2e2'" onmouseout="this.style.background='#fef2f2'">
                                                <i class="bi bi-trash3"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <c:if test="${totalPages > 1}">
                            <nav aria-label="Cart pagination" class="my-3">
                                <ul class="pagination justify-content-center mb-0">
                                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/cart?page=${currentPage - 1}">Trước</a>
                                    </li>
                                    <c:forEach begin="1" end="${totalPages}" var="i">
                                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                                            <a class="page-link" href="${pageContext.request.contextPath}/cart?page=${i}">${i}</a>
                                        </li>
                                    </c:forEach>
                                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/cart?page=${currentPage + 1}">Sau</a>
                                    </li>
                                </ul>
                            </nav>
                        </c:if>

                        <div class="pt-3 mt-3 border-top">
                            <a href="${pageContext.request.contextPath}/Home" class="btn btn-outline-secondary px-3 py-2 fw-semibold" style="font-size: 13.5px;">
                                <i class="bi bi-arrow-left me-1"></i> Tiếp tục chọn sản phẩm khác
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Order Summary (Right Column) -->
                <div class="col-lg-4">
                    <div class="bg-white p-4 rounded-4 border shadow-sm sticky-top" style="top: 20px;">
                        <h5 class="fw-bold text-dark mb-3 pb-3 border-bottom d-flex align-items-center gap-2">
                            <i class="bi bi-receipt text-danger"></i> Tóm tắt đơn hàng
                        </h5>

                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-secondary small">Tạm tính:</span>
                            <span class="fw-semibold text-dark">
                                <fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,##0" /> đ
                            </span>
                        </div>

                        <c:if test="${not empty sessionScope.APPLIED_VOUCHER}">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="text-secondary small">Voucher:</span>
                                <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2 py-1 small fw-semibold">
                                    ${sessionScope.APPLIED_VOUCHER}
                                </span>
                            </div>
                        </c:if>

                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="text-secondary small">Phí vận chuyển:</span>
                            <span class="text-muted small fst-italic">Tính khi thanh toán</span>
                        </div>

                        <hr class="my-3">

                        <div class="d-flex justify-content-between align-items-baseline mb-3">
                            <span class="fw-bold text-dark">Tổng thanh toán:</span>
                            <div class="text-end">
                                <div class="text-danger fw-extrabold fs-3" style="line-height: 1;">
                                    <fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,##0" /> đ
                                </div>
                                <small class="text-muted" style="font-size: 11px;">(Đã bao gồm VAT nếu có)</small>
                            </div>
                        </div>

                        <a href="checkout" class="btn btn-danger btn-lg w-100 py-3 fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2 mb-3" style="border-radius: 10px;">
                            <span>TIẾN HÀNH ĐẶT HÀNG</span>
                            <i class="bi bi-arrow-right fs-5"></i>
                        </a>

                        <div class="p-3 bg-light rounded-3 border border-light-subtle small text-secondary">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <i class="bi bi-shield-check text-success fs-6"></i>
                                <span>Chính hãng 100% - Bảo hành tận nơi</span>
                            </div>
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <i class="bi bi-arrow-repeat text-primary fs-6"></i>
                                <span>Đổi mới trong 30 ngày nếu phát sinh lỗi</span>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-truck text-danger fs-6"></i>
                                <span>Giao hàng toàn quốc - Đồng kiểm khi nhận</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="footer.jsp" />
