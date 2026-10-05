<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="act" value="${param.active}" />

<aside class="sidebar">
    <div class="py-4 border-bottom border-secondary text-center">
        <h4 class="brand-neon m-0"><i class="fa-solid fa-microchip"></i> ĐỘ PC 67</h4>
        <span class="badge bg-danger mt-2">ADMIN PANEL</span>
    </div>
    <ul class="nav flex-column mt-3 px-2">
        <li><a href="${ctx}/admin/dashboard" class="nav-link rounded ${act == 'dashboard' ? 'active' : ''}"><i class="fa-solid fa-gauge-high"></i> Tổng quan</a></li>
        <li><a href="${ctx}/admin/categories" class="nav-link rounded ${act == 'categories' ? 'active' : ''}"><i class="fa-solid fa-layer-group"></i> Quản lý Danh mục</a></li>
        <li><a href="${ctx}/admin/products" class="nav-link rounded ${act == 'products' ? 'active' : ''}"><i class="fa-solid fa-computer"></i> Quản lý Sản phẩm</a></li>
        <li><a href="${ctx}/admin/orders" class="nav-link rounded ${act == 'orders' ? 'active' : ''}"><i class="fa-solid fa-cart-flatbed"></i> Quản lý Đơn hàng</a></li>
        <li><a href="${ctx}/admin/users" class="nav-link rounded ${act == 'users' ? 'active' : ''}"><i class="fa-solid fa-users"></i> Quản lý Khách hàng</a></li>
    </ul>

    <div class="px-3 mt-4 pt-3" style="border-top: 1px solid var(--border-color);">
        <a href="${ctx}/Home" class="btn btn-outline-danger w-100 fw-semibold">
            <i class="fa-solid fa-store me-2"></i>Về trang bán hàng
        </a>
    </div>
</aside>
