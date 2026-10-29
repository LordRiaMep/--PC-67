<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<div class="container my-4">

    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb" style="font-size: 13.5px;">
            <li class="breadcrumb-item"><a href="${ctx}/Home" class="text-decoration-none text-muted">Trang chủ</a></li>
            <li class="breadcrumb-item active text-dark fw-bold" aria-current="page">Tìm kiếm</li>
        </ol>
    </nav>

    <!-- Header bar -->
    <div class="d-flex justify-content-between align-items-center bg-white px-4 py-3 rounded-4 mb-4 shadow-sm border flex-wrap gap-2">
        <div class="d-flex align-items-center gap-2">
            <span class="d-inline-block rounded-pill" style="width: 5px; height: 22px; background: var(--brand-gradient);"></span>
            <h4 class="fw-bold m-0 text-dark text-uppercase" style="font-size: 18px; letter-spacing: -0.01em;">Kết quả tìm kiếm</h4>
        </div>
        <span class="small text-muted">
            <c:choose>
                <c:when test="${empty keyword}">Hãy nhập từ khóa để tìm kiếm linh kiện hoặc PC</c:when>
                <c:otherwise>
                    Từ khóa: <strong class="text-dark"><c:out value="${keyword}"/></strong>
                    &bull; Tìm thấy <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2 py-1">${listProducts.size()} sản phẩm</span>
                </c:otherwise>
            </c:choose>
        </span>
    </div>

    <!-- Product Grid -->
    <div class="row g-3 mb-5">
        <c:choose>
            <c:when test="${empty listProducts}">
                <div class="col-12 text-center py-5 bg-white rounded-4 border shadow-sm">
                    <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3" style="width: 72px; height: 72px; background: var(--brand-soft); color: var(--brand-primary); font-size: 32px;">
                        <i class="bi bi-search"></i>
                    </div>
                    <h5 class="fw-bold text-dark mb-2">
                        <c:choose>
                            <c:when test="${empty keyword}">Bạn chưa nhập từ khóa tìm kiếm!</c:when>
                            <c:otherwise>Không tìm thấy sản phẩm nào phù hợp với "<c:out value="${keyword}"/>"!</c:otherwise>
                        </c:choose>
                    </h5>
                    <p class="text-muted small mb-3">Vui lòng thử lại với từ khóa khác (ví dụ: RTX, i5, Gaming, Workstation...).</p>
                    <a href="${ctx}/Home" class="btn btn-danger px-4 py-2 fw-semibold" style="border-radius: var(--radius-sm);">Về trang chủ</a>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach items="${listProducts}" var="p">
                    <div class="col-6 col-md-4 col-lg-3">
                        <div class="card h-100 border-0 bg-white shadow-sm overflow-hidden d-flex flex-column" style="border-radius: var(--radius-lg);">
                            <div class="position-relative p-3 text-center" style="height: 190px; display: flex; align-items: center; justify-content: center; background: #ffffff;">
                                <div class="position-absolute top-0 start-0 m-2 z-1">
                                    <c:choose>
                                        <c:when test="${p.quantity > 0}">
                                            <span class="badge-stock-in"><i class="bi bi-check-circle-fill me-1"></i>Còn ${p.quantity}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2 py-1 small fw-semibold">Hết hàng</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <a href="${ctx}/product/detail?id=${p.id}" class="d-block w-100 text-decoration-none">
                                    <img src="${p.image}" class="card-img-top img-fluid" style="height: 160px; object-fit: contain;" alt="${p.name}">
                                </a>
                            </div>

                            <div class="card-body text-start d-flex flex-column px-3 pt-2 pb-3 border-top">
                                <span class="badge-category mb-2 align-self-start">
                                    <i class="bi bi-tag-fill me-1" style="color: var(--brand-primary); font-size: 10px;"></i>${p.categoryName}
                                </span>

                                <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none mb-2">
                                    <h6 class="card-title text-dark fw-bold mb-0" style="font-size: 14px; min-height: 40px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${p.name}</h6>
                                </a>

                                <div class="bg-light p-2 rounded-3 mb-3 border border-light-subtle" style="font-size: 12.5px; color: #64748b;">
                                    <div class="description-truncate" style="font-size: 12px; line-height: 1.4;">
                                        ${p.description}
                                    </div>
                                </div>

                                <div class="mt-auto d-flex justify-content-between align-items-center pt-2 border-top">
                                    <div>
                                        <div class="text-muted" style="font-size: 11px;">Giá niêm yết:</div>
                                        <span class="price-tag"><fmt:formatNumber value="${p.price}" pattern="#,###"/> ₫</span>
                                    </div>
                                    <c:choose>
                                        <c:when test="${p.quantity > 0}">
                                            <button type="button" class="btn btn-danger btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center shadow-sm quick-add-cart-btn"
                                                    data-id="${p.id}"
                                                    data-name="<c:out value='${p.name}'/>"
                                                    style="width: 36px; height: 36px;"
                                                    title="Thêm ngay vào giỏ hàng">
                                                <i class="bi bi-cart-plus fs-6 text-white"></i>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="btn btn-secondary btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center opacity-50"
                                                    style="width: 36px; height: 36px; cursor: not-allowed;"
                                                    disabled
                                                    title="Sản phẩm tạm hết hàng">
                                                <i class="bi bi-cart-x fs-6 text-white"></i>
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="footer.jsp" />
