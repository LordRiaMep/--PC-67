<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<div class="container mt-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${ctx}/Home" class="text-decoration-none text-danger">Trang chủ</a></li>
            <li class="breadcrumb-item active" aria-current="page">Tìm kiếm</li>
        </ol>
    </nav>

    <!-- Tiêu đề kết quả -->
    <div class="d-flex justify-content-between align-items-center bg-light p-0 rounded mb-4 shadow-sm border overflow-hidden">
        <span class="text-white fw-bold px-4 py-2 text-uppercase d-flex align-items-center"
              style="font-size: 16px; background: linear-gradient(90deg, #b71c1c 0%, #ff5252 100%); clip-path: polygon(0 0, 90% 0, 100% 100%, 0% 100%); padding-right: 35px !important; min-width: 240px;">
            Kết quả tìm kiếm
        </span>
        <span class="me-3 small text-muted">
            <c:choose>
                <c:when test="${empty keyword}">Hãy nhập từ khóa để tìm kiếm</c:when>
                <c:otherwise>
                    Từ khóa: <strong class="text-dark"><c:out value="${keyword}"/></strong>
                    - ${listProducts.size()} sản phẩm
                </c:otherwise>
            </c:choose>
        </span>
    </div>

    <div class="row g-3 mb-5">
        <c:choose>
            <c:when test="${empty listProducts}">
                <div class="col-12 text-center py-5">
                    <h5 class="text-muted">
                        <c:choose>
                            <c:when test="${empty keyword}">Bạn chưa nhập từ khóa tìm kiếm!</c:when>
                            <c:otherwise>Không tìm thấy sản phẩm nào phù hợp với "<c:out value="${keyword}"/>"!</c:otherwise>
                        </c:choose>
                    </h5>
                    <a href="${ctx}/Home" class="btn btn-danger mt-3">Về trang chủ</a>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach items="${listProducts}" var="p">
                    <div class="col-md-3">
                        <div class="card h-100 border rounded shadow-sm bg-white">
                            <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none text-center p-2">
                                <img src="${p.image}" class="card-img-top rounded img-fluid" style="height: 180px; object-fit: contain;" alt="${p.name}">
                            </a>
                            <div class="card-body text-start d-flex flex-column px-2 py-3 mt-1 border-top">
                                <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none mb-2">
                                    <h6 class="card-title text-dark fw-semibold" style="font-size: 14px; min-height: 40px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${p.name}</h6>
                                </a>

                                <div class="bg-light p-2 rounded mb-3" style="font-size: 14px; color: #555;">
                                    <div class="mb-1">Danh mục: <span class="text-dark fw-medium">${p.categoryName}</span></div>
                                    <div class="mb-1">Số lượng kho: <span class="text-dark fw-medium">${p.quantity}</span></div>
                                    <hr class="my-1 border-secondary" style="opacity: 0.2;">
                                    <div class="mt-1" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                            ${p.description}
                                    </div>
                                </div>

                                <div class="mt-auto d-flex justify-content-between align-items-center pt-2 border-top">
                                    <h5 class="text-danger fw-bold m-0" style="font-size: 16px;"><fmt:formatNumber value="${p.price}" pattern="#,###"/> ₫</h5>
                                    <a href="${ctx}/product/detail?id=${p.id}" class="btn btn-danger btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center shadow-sm" style="width: 34px; height: 34px;">
                                        <i class="bi bi-cart-plus fs-6"></i>
                                    </a>
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
