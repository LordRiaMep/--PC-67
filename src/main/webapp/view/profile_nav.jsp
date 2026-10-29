<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
.pf-banner {
        background: linear-gradient(120deg, #E30019 0%, #b80015 55%, #7a000e 100%);
        border-radius: 20px;
        color: #fff;
        padding: 28px 32px;
        position: relative;
        overflow: hidden;
    }
    .pf-banner::after {
        content: "";
        position: absolute;
        right: -60px; top: -80px;
        width: 260px; height: 260px;
        border-radius: 50%;
        background: rgba(255,255,255,.08);
    }
    .pf-avatar {
        width: 84px; height: 84px;
        border-radius: 50%;
        background: #fff;
        color: #E30019;
        font-size: 36px; font-weight: 800;
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 6px 18px rgba(0,0,0,.25);
        flex-shrink: 0;
    }
    .pf-tabs {
        display: flex; gap: 8px; flex-wrap: wrap;
        background: #fff;
        border-radius: 14px;
        padding: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,.06);
    }
    .pf-tab {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 20px;
        border-radius: 10px;
        text-decoration: none;
        color: #343a40;
        font-weight: 600;
        transition: all .2s ease;
    }
    .pf-tab:hover { background: #f1f3f5; color: #212529; }
    .pf-tab.active { background: #E30019; color: #fff; box-shadow: 0 4px 12px rgba(227,0,25,.35); }
    .pf-tab.logout { color: #dc3545; margin-left: auto; }
    .pf-tab.logout:hover { background: #fdecee; }
    .pf-card {
        background: #fff;
        border: 0;
        border-radius: 16px;
        box-shadow: 0 2px 12px rgba(0,0,0,.06);
    }
    .pf-card-title {
        font-weight: 700;
        font-size: 17px;
        display: flex; align-items: center; gap: 10px;
    }
    .pf-card-title i {
        width: 34px; height: 34px;
        border-radius: 10px;
        background: #fdecee; color: #E30019;
        display: inline-flex; align-items: center; justify-content: center;
    }
    .pf-card .form-label { font-weight: 600; font-size: 14px; color: #495057; }
    .pf-card .form-control { border-radius: 10px; padding: 10px 14px; border-color: #dee2e6; }
    .pf-card .form-control:focus { border-color: #E30019; box-shadow: 0 0 0 .2rem rgba(227,0,25,.12); }
    .btn-brand {
        background: #E30019; color: #fff; border: 0;
        border-radius: 10px; padding: 10px 28px; font-weight: 600;
    }
    .btn-brand:hover { background: #BE0015; color: #fff; }
</style>

<div class="pf-banner mb-3">
    <div class="d-flex align-items-center gap-4 flex-wrap position-relative" style="z-index:1;">
        <div class="pf-avatar">
            <c:out value="${fn:toUpperCase(fn:substring(profile.fullName, 0, 1))}"/>
        </div>
        <div class="flex-grow-1">
            <h4 class="fw-bold mb-1"><c:out value="${profile.fullName}"/></h4>
            <div class="opacity-75"><i class="bi bi-envelope me-2"></i><c:out value="${profile.email}"/></div>
        </div>
        <div class="d-flex gap-4 text-center text-md-start">
            <c:if test="${not empty profile.phone}">
                <div>
                    <div class="small opacity-75">Số điện thoại</div>
                    <div class="fw-semibold"><c:out value="${profile.phone}"/></div>
                </div>
            </c:if>
            <c:if test="${not empty profile.createdAt}">
                <div>
                    <div class="small opacity-75">Thành viên từ</div>
                    <div class="fw-semibold"><fmt:formatDate value="${profile.createdAt}" pattern="dd/MM/yyyy"/></div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<div class="pf-tabs mb-4">
    <a class="pf-tab ${param.active == 'info' ? 'active' : ''}" href="${ctx}/profile">
        <i class="bi bi-person-vcard"></i>Thông tin tài khoản
    </a>
    <a class="pf-tab ${param.active == 'password' ? 'active' : ''}" href="${ctx}/change-password">
        <i class="bi bi-shield-lock"></i>Đổi mật khẩu
    </a>
    <a class="pf-tab logout" href="${ctx}/logout">
        <i class="bi bi-box-arrow-right"></i>Đăng xuất
    </a>
</div>
