<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<style>
    .news-clamp-2 {
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
    /* Nội dung bài viết (HTML do admin nhập) */
    .news-content {
        font-size: 15px;
        line-height: 1.75;
        color: #222;
        overflow-wrap: anywhere;
    }
    .news-content img {
        max-width: 100%;
        height: auto;
        display: block;
        margin: 18px auto;
        border-radius: 6px;
    }
    .news-content h2, .news-content h3, .news-content h4 {
        font-weight: 700;
        text-transform: uppercase;
        margin: 24px 0 10px;
    }
    .news-content table {
        max-width: 100%;
    }
</style>

<div class="container mt-4 mb-5">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${ctx}/Home" class="text-decoration-none text-danger">Trang chủ</a></li>
            <li class="breadcrumb-item"><a href="${ctx}/news" class="text-decoration-none text-danger">Tin tức</a></li>
            <li class="breadcrumb-item active" aria-current="page">Chi tiết</li>
        </ol>
    </nav>

    <div class="bg-white border rounded shadow-sm p-4">
        <h2 class="fw-bold text-uppercase mb-2" style="font-size: 26px;"><c:out value="${news.title}"/></h2>

        <div class="text-muted small pb-2 border-bottom mb-3">
            <i class="bi bi-calendar3 me-1"></i><fmt:formatDate value="${news.createdAt}" pattern="dd-MM-yyyy, HH:mm"/>
            <span class="ms-3"><i class="bi bi-eye me-1"></i>${news.viewCount}</span>
            <span class="ms-3"><i class="bi bi-person me-1"></i><c:out value="${news.author}"/></span>
        </div>

        <c:if test="${not empty news.summary}">
            <p class="fw-semibold fst-italic text-secondary"><c:out value="${news.summary}"/></p>
        </c:if>

        <%-- Nội dung là HTML nên in thẳng (không escape). Chỉ admin được nhập nội dung này. --%>
        <div class="news-content">${news.content}</div>
    </div>

    <!-- Tin liên quan -->
    <c:if test="${not empty relatedNews}">
        <h5 class="fw-bold mt-5 mb-3 border-start border-danger border-4 ps-2">Tin tức liên quan</h5>
        <div class="row g-3">
            <c:forEach items="${relatedNews}" var="n">
                <div class="col-6 col-md-3">
                    <a href="${ctx}/news/detail?id=${n.id}" class="text-decoration-none text-dark d-block h-100">
                        <div class="card h-100 border shadow-sm">
                            <img src="${n.image}" alt="" class="card-img-top" style="height: 130px; object-fit: cover;">
                            <div class="card-body p-2">
                                <div class="fw-semibold news-clamp-2" style="font-size: 13px; min-height: 36px;">
                                    <c:out value="${n.title}"/>
                                </div>
                                <div class="text-muted mt-1" style="font-size: 11px;">
                                    <i class="bi bi-clock me-1"></i><fmt:formatDate value="${n.createdAt}" pattern="dd/MM/yyyy"/>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </c:forEach>
        </div>
    </c:if>
</div>

<jsp:include page="footer.jsp" />
