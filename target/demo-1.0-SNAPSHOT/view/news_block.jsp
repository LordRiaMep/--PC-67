<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- Khối "1 bài to bên trái + 4 bài nhỏ bên phải". Dữ liệu lấy từ requestScope.blockList --%>
<c:if test="${not empty blockList}">
    <c:set var="big" value="${blockList[0]}" />
    <div class="row g-3">

        <!-- Bài to -->
        <div class="col-lg-7">
            <a href="${ctx}/news/detail?id=${big.id}"
               class="d-block position-relative rounded overflow-hidden shadow-sm text-decoration-none"
               style="height: 376px;">
                <img src="${big.image}" alt="" class="w-100 h-100" style="object-fit: cover;">
                <div class="position-absolute bottom-0 start-0 end-0 p-3 text-white"
                     style="background: linear-gradient(transparent, rgba(0,0,0,0.88));">
                    <h5 class="fw-bold mb-1 news-clamp-2"><c:out value="${big.title}"/></h5>
                    <p class="small mb-1 opacity-75 news-clamp-2"><c:out value="${big.summary}"/></p>
                    <small class="opacity-75">
                        <i class="bi bi-clock me-1"></i><fmt:formatDate value="${big.createdAt}" pattern="dd/MM/yyyy"/>
                        &bull; <c:out value="${big.author}"/>
                    </small>
                </div>
            </a>
        </div>

        <!-- 4 bài nhỏ -->
        <div class="col-lg-5">
            <div class="row g-3">
                <c:forEach items="${blockList}" var="n" begin="1" end="4">
                    <div class="col-6">
                        <a href="${ctx}/news/detail?id=${n.id}" class="text-decoration-none text-dark d-block h-100">
                            <div class="card h-100 border shadow-sm">
                                <img src="${n.image}" alt="" class="card-img-top" style="height: 110px; object-fit: cover;">
                                <div class="card-body p-2">
                                    <div class="fw-semibold news-clamp-2" style="font-size: 13px; min-height: 36px;">
                                        <c:out value="${n.title}"/>
                                    </div>
                                    <div class="text-muted mt-1" style="font-size: 11px;">
                                        <i class="bi bi-clock me-1"></i><fmt:formatDate value="${n.createdAt}" pattern="dd/MM/yyyy"/>
                                        &bull; <c:out value="${n.author}"/>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</c:if>
