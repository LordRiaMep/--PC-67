<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<style>
.news-clamp-2 {
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
</style>

<div class="container mt-4 mb-5">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${ctx}/Home" class="text-decoration-none text-danger">Trang chủ</a></li>
            <li class="breadcrumb-item active" aria-current="page">Tin tức</li>
        </ol>
    </nav>

    <c:choose>
        <c:when test="${empty featuredNews and empty listNews}">
            <div class="text-center py-5">
                <h5 class="text-muted">Chưa có tin tức nào!</h5>
                <a href="${ctx}/Home" class="btn btn-danger mt-3">Về trang chủ</a>
            </div>
        </c:when>
        <c:otherwise>

            <c:if test="${not empty featuredNews}">
                <h5 class="fw-bold mb-3 border-start border-danger border-4 ps-2">Nổi Bật Nhất</h5>
                <c:set var="blockList" value="${featuredNews}" scope="request" />
                <jsp:include page="news_block.jsp" />
            </c:if>

            <c:if test="${not empty listNews}">
                <h5 class="fw-bold ${empty featuredNews ? 'mt-0' : 'mt-5'} mb-3 border-start border-danger border-4 ps-2">Tin Tức Mới</h5>
                <c:set var="blockList" value="${listNews}" scope="request" />
                <jsp:include page="news_block.jsp" />
            </c:if>

            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation" class="mt-4">
                    <ul class="pagination justify-content-center">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link ${currentPage == i ? 'text-white bg-danger border-danger' : 'text-danger'}"
                                   href="${ctx}/news?page=${i}">${i}</a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </c:if>

        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="footer.jsp" />
