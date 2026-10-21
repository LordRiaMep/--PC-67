<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="act" value="${param.active}" />

<aside class="sidebar">
    <div class="py-4 border-bottom border-secondary text-center">
        <h4 class="brand-neon m-0"><i class="fa-solid fa-microchip"></i> ĐỘ PC 67</h4>
        <div class="mt-2 d-flex align-items-center justify-content-center gap-1">
            <span class="badge bg-danger">ADMIN PANEL</span>
            <span id="realtime-status-dot" style="display:inline-block; width:9px; height:9px; border-radius:50%; background-color:#22c55e; box-shadow:0 0 8px #22c55e;" title="Đang đồng bộ Realtime (0ms)"></span>
        </div>
    </div>
    <ul class="nav flex-column mt-3 px-2">
        <li><a href="${ctx}/admin/dashboard" class="nav-link rounded ${act == 'dashboard' ? 'active' : ''}"><i class="fa-solid fa-gauge-high"></i> Tổng quan</a></li>
        <li><a href="${ctx}/admin/categories" class="nav-link rounded ${act == 'categories' ? 'active' : ''}"><i class="fa-solid fa-layer-group"></i> Quản lý Danh mục</a></li>
        <li><a href="${ctx}/admin/products" class="nav-link rounded ${act == 'products' ? 'active' : ''}"><i class="fa-solid fa-computer"></i> Quản lý Sản phẩm</a></li>
        <li><a href="${ctx}/admin/news" class="nav-link rounded ${act == 'news' ? 'active' : ''}"><i class="fa-solid fa-newspaper"></i> Quản lý Bài viết</a></li>
        <li><a href="${ctx}/admin/orders" class="nav-link rounded ${act == 'orders' ? 'active' : ''}"><i class="fa-solid fa-cart-flatbed"></i> Quản lý Đơn hàng</a></li>
        <li><a href="${ctx}/admin/vouchers" class="nav-link rounded ${act == 'vouchers' ? 'active' : ''}"><i class="fa-solid fa-ticket"></i> Quản lý Voucher</a></li>
        <li><a href="${ctx}/admin/users" class="nav-link rounded ${act == 'users' ? 'active' : ''}"><i class="fa-solid fa-users"></i> Quản lý Khách hàng</a></li>
        <li><a href="${ctx}/admin/warehouse" class="nav-link rounded ${act == 'warehouse' ? 'active' : ''}"><i class="fa-solid fa-warehouse"></i> Cấu hình Kho hàng</a></li>
        <li><a href="${ctx}/admin/contacts" class="nav-link rounded ${act == 'contacts' ? 'active' : ''}"><i class="fa-solid fa-headset"></i> Quản lý Liên hệ</a></li>
    </ul>

    <div class="px-3 mt-4 pt-3" style="border-top: 1px solid var(--border-color);">
        <a href="${ctx}/Home" class="btn btn-outline-danger w-100 fw-semibold">
            <i class="fa-solid fa-store me-2"></i>Về trang bán hàng
        </a>
    </div>
</aside>

<!-- Realtime Dual-Sync Admin Engine -->
<script src="${ctx}/assets/js/realtime-sync.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (window.RealtimeSync) {
            window.RealtimeSync.init({
                role: 'admin',
                userId: '${sessionScope.USER_LOGIN != null ? sessionScope.USER_LOGIN.id : 0}',
                ctx: '${ctx}'
            });
        }
    });
</script>
