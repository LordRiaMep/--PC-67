<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty p.name ? "Độ-PC 67" : p.name}</title>

    <!-- Bootstrap CSS & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=20261030_0530">

    <style>
        /* Header Background: Đồng bộ chính xác 100% theo mã màu đỏ của logo (#E6021A) */
        .bg-header-red {
            background-color: #E6021A;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
        }

        /* Logo thương hiệu */
        .header-logo-link {
            transition: transform 0.25s ease, opacity 0.2s ease;
            display: inline-flex;
            align-items: center;
        }
        .header-logo-link:hover {
            transform: scale(1.03);
            opacity: 0.95;
        }

        /* Nút Danh mục */
        .btn-category-red {
            background: rgba(0, 0, 0, 0.22);
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.25);
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            padding: 8px 16px;
            transition: all 0.25s ease;
            backdrop-filter: blur(4px);
        }
        .btn-category-red:hover, .btn-category-red:focus, .dropdown:hover .btn-category-red {
            background: rgba(0, 0, 0, 0.38);
            border-color: rgba(255, 255, 255, 0.45);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            color: #ffffff !important;
        }
        .dropdown:hover .dropdown-menu,
        .dropdown-menu:hover {
            display: block;
            margin-top: 6px !important;
            animation: headerFadeIn 0.2s ease forwards;
        }
        /* Cầu nối tàng hình lấp khoảng trống (gap) giữa nút và dropdown menu để không bị mất hover */
        .dropdown-menu::before {
            content: "";
            position: absolute;
            top: -12px;
            left: -5px;
            right: -5px;
            height: 12px;
            display: block;
            background: transparent;
        }
        @keyframes headerFadeIn {
            from { opacity: 0; transform: translateY(-6px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .dropdown-menu {
            border-radius: 12px;
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.15);
            border: 1px solid rgba(0, 0, 0, 0.08);
            padding: 8px;
        }
        .dropdown-menu .dropdown-item {
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.15s ease;
            padding: 8px 12px;
        }
        .dropdown-menu .dropdown-item:hover {
            background-color: #fff1f2;
            color: #E6021A;
            transform: translateX(3px);
        }
        .dropdown-menu .dropdown-item i.category-icon {
            color: #E6021A;
            font-size: 1rem;
        }

        /* Khung tìm kiếm hiện đại */
        .search-box-wrapper {
            position: relative;
            display: flex;
            align-items: center;
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.15);
            border: 2px solid transparent;
            transition: all 0.25s ease;
            overflow: hidden;
            width: 100%;
        }
        .search-box-wrapper:focus-within {
            border-color: #ffd1d6;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.22);
        }
        .search-box-input {
            border: none;
            outline: none;
            box-shadow: none !important;
            padding: 9px 15px;
            font-size: 14px;
            color: #212529;
            flex: 1;
            background: transparent;
        }
        .search-box-input::placeholder {
            color: #8c959f;
            font-size: 13.5px;
        }
        .search-box-btn {
            background: #E6021A;
            color: #ffffff;
            border: none;
            outline: none;
            padding: 0 16px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        .search-box-btn:hover {
            background: #C40216;
            color: #ffffff;
        }
        .search-box-btn i {
            font-size: 15px;
        }

        /* Các nút chức năng Header (Liên hệ, Đơn hàng, Giỏ hàng, Đăng nhập) */
        .nav-icon-btn {
            white-space: nowrap;
            background-color: #111827;
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.18);
            border-radius: 10px;
            padding: 8px 14px;
            text-decoration: none;
            font-weight: 500;
            font-size: 13.5px;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
        }
        .nav-icon-btn i {
            font-size: 1.05rem;
            transition: transform 0.2s ease;
        }
        .nav-icon-btn:hover {
            background-color: #000000;
            border-color: rgba(255, 255, 255, 0.38);
            color: #ffffff !important;
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(0, 0, 0, 0.32);
        }
        .nav-icon-btn:hover i {
            transform: scale(1.15);
        }
        .nav-icon-btn:active {
            transform: translateY(0);
        }

        /* Nút Quản lý của Admin */
        .nav-admin-btn {
            background: linear-gradient(135deg, #7c3aed 0%, #4f46e5 100%) !important;
            border: 1px solid rgba(255, 255, 255, 0.32) !important;
        }
        .nav-admin-btn:hover {
            background: linear-gradient(135deg, #6d28d9 0%, #4338ca 100%) !important;
            border-color: #ffffff !important;
        }

        /* Huy hiệu số lượng Giỏ hàng */
        .cart-badge-gold {
            position: absolute;
            top: -6px;
            right: -6px;
            background: #facc15;
            color: #111827;
            font-size: 11px;
            font-weight: 700;
            padding: 2px 6.5px;
            border-radius: 999px;
            border: 2px solid #E6021A;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.25);
            line-height: 1.2;
            transition: transform 0.2s ease;
        }
        @keyframes badgeBounce {
            0% { transform: scale(1); }
            50% { transform: scale(1.45); }
            100% { transform: scale(1); }
        }
        .badge-bounce {
            animation: badgeBounce 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        /* Toast thông báo thêm giỏ hàng */
        .quick-cart-toast-box {
            display: none;
            width: auto !important;
            min-width: 320px;
            max-width: min(450px, calc(100vw - 32px));
            background: #0f172a !important;
            color: #ffffff;
            border-radius: 14px;
            pointer-events: auto;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.45), 0 8px 10px -6px rgba(0, 0, 0, 0.35);
            border: 1px solid rgba(255, 255, 255, 0.12);
            overflow: hidden;
        }
        .quick-cart-toast-box.show {
            display: flex !important;
            align-items: center;
            animation: toastFadeInUp 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }
        @keyframes toastFadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px) scale(0.96);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        /* Gợi ý tìm kiếm */
        .search-suggest {
            position: absolute;
            top: calc(100% + 6px);
            left: 0;
            right: 0;
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.22);
            overflow: hidden;
            z-index: 2000;
            border: 1px solid rgba(0, 0, 0, 0.08);
        }
        .suggest-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 14px;
            text-decoration: none;
            color: #212529;
            border-bottom: 1px solid #f1f1f1;
            transition: background-color 0.15s ease;
        }
        .suggest-item:hover {
            background-color: #fff1f2;
            color: #212529;
        }
        .suggest-item img {
            width: 55px;
            height: 55px;
            object-fit: contain;
            flex-shrink: 0;
            background: #f8f9fa;
            border-radius: 6px;
            padding: 4px;
        }
        .suggest-name {
            font-size: 13.5px;
            font-weight: 600;
            line-height: 1.35;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            color: #1f2937;
        }
        .suggest-price {
            font-size: 13px;
            font-weight: 700;
            color: #E6021A;
            margin-top: 3px;
        }
        .suggest-all {
            display: block;
            text-align: center;
            padding: 10px;
            font-size: 13px;
            font-weight: 600;
            color: #E6021A;
            text-decoration: none;
            background: #fdf2f2;
            transition: background 0.15s ease;
        }
        .suggest-all:hover {
            background: #fde8e8;
            color: #C40216;
        }
        .suggest-empty {
            padding: 14px;
            font-size: 13px;
            color: #6c757d;
            text-align: center;
        }
    </style>
</head>

<body class="bg-light text-dark d-flex flex-column min-vh-100">

<!-- HEADER BẮT ĐẦU -->
<div class="py-2 bg-header-red position-relative" style="z-index: 1000;">
    <div class="container d-flex justify-content-between align-items-center flex-wrap flex-lg-nowrap gap-3">

        <!-- LOGO & TRANG CHỦ -->
        <a href="${ctx}/Home" class="header-logo-link text-decoration-none flex-shrink-0" title="Độ PC 67 - Trang chủ">
            <img src="${ctx}/assets/images/logo moi.png" alt="Độ PC 67" style="height: 60px; object-fit: contain;">
        </a>

        <!-- NÚT DANH MỤC DROPDOWN -->
        <div class="dropdown flex-shrink-0">
            <button class="btn btn-category-red d-flex align-items-center gap-2" type="button" id="dropdownCategory" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-grid-fill"></i>
                <span>Danh mục</span>
                <i class="bi bi-chevron-down" style="font-size: 11px; opacity: 0.85;"></i>
            </button>
            <ul class="dropdown-menu shadow border-0" aria-labelledby="dropdownCategory">
                <c:forEach items="${listCategories}" var="c">
                    <%-- Chọn icon theo tên danh mục (AMD phải đứng trước Gaming) --%>
                    <c:choose>
                        <c:when test="${fn:containsIgnoreCase(c.name, 'Streaming')}">
                            <c:set var="icon" value="bi-controller" />
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(c.name, 'Workstation')}">
                            <c:set var="icon" value="bi-pc-display-horizontal" />
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(c.name, 'AMD')}">
                            <c:set var="icon" value="bi-cpu-fill" />
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(c.name, 'Văn Phòng')}">
                            <c:set var="icon" value="bi-briefcase-fill" />
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(c.name, 'Linh Kiện')}">
                            <c:set var="icon" value="bi-motherboard-fill" />
                        </c:when>
                        <c:when test="${fn:containsIgnoreCase(c.name, 'Gaming')}">
                            <c:set var="icon" value="bi-joystick" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="icon" value="bi-pc-display" />
                        </c:otherwise>
                    </c:choose>
                    <li>
                        <a class="dropdown-item py-2 d-flex align-items-center gap-2" href="${ctx}/Home?cid=${c.id}">
                            <i class="bi ${icon} category-icon"></i>
                            <span>${c.name}</span>
                        </a>
                    </li>
                </c:forEach>
                <c:if test="${empty listCategories}">
                    <li><span class="dropdown-item py-2 text-muted">Chưa có danh mục</span></li>
                </c:if>
                <li><hr class="dropdown-divider my-1"></li>
                <li>
                    <a class="dropdown-item py-2 fw-bold d-flex align-items-center gap-2" href="${ctx}/news">
                        <i class="bi bi-newspaper category-icon"></i>
                        <span>Tin tức công nghệ</span>
                    </a>
                </li>
            </ul>
        </div>

        <!-- Ô TÌM KIẾM (gửi sang SearchServlet tại /search) -->
        <form action="${ctx}/search" method="get" accept-charset="UTF-8" class="flex-grow-1 mx-lg-2 my-0 align-self-center position-relative" style="max-width: 460px; min-width: 140px;" autocomplete="off">
            <div class="search-box-wrapper">
                <input type="text" id="searchInput" name="keyword" class="search-box-input" placeholder="Bạn cần tìm linh kiện, PC gì?..." value="<c:out value='${param.keyword}'/>">
                <button type="submit" class="search-box-btn" title="Tìm kiếm">
                    <i class="bi bi-search"></i>
                </button>
            </div>
            <div id="searchSuggest" class="search-suggest d-none"></div>
        </form>

        <!-- KHU VỰC CÁC TÍNH NĂNG (ĐƠN HÀNG, LIÊN HỆ, GIỎ HÀNG, TÀI KHOẢN) -->
        <div class="d-flex align-items-center gap-2 flex-wrap flex-lg-nowrap flex-shrink-0">

            <!-- LIÊN HỆ -->
            <a href="${ctx}/contact" class="nav-icon-btn" title="Hỗ trợ & Liên hệ">
                <i class="bi bi-headset"></i>
                <span>Liên hệ</span>
            </a>

            <!-- NÚT VỀ TRANG QUẢN LÝ (chỉ hiện với admin) -->
            <c:if test="${sessionScope.USER_LOGIN.admin}">
                <a href="${ctx}/admin/dashboard" class="nav-icon-btn nav-admin-btn" title="Khu vực quản trị Admin">
                    <i class="bi bi-shield-shaded"></i>
                    <span>Quản lý</span>
                </a>
            </c:if>

            <!-- ĐƠN HÀNG -->
            <a href="${ctx}/orders" class="nav-icon-btn" title="Theo dõi đơn hàng">
                <i class="bi bi-box-seam-fill"></i>
                <span>Đơn hàng</span>
            </a>

            <!-- GIỎ HÀNG VỚI BADGE SỐ LƯỢNG VÀ CHỮ GIỎ HÀNG -->
            <c:set var="headerCartCount" value="${not empty sessionScope.cart ? sessionScope.cart.totalQuantity : 0}" />
            <a href="${ctx}/cart" class="nav-icon-btn position-relative" title="Xem giỏ hàng" id="headerCartBtn">
                <i class="bi bi-cart3"></i>
                <span>Giỏ hàng</span>
                <span class="cart-badge-gold ${headerCartCount <= 0 ? 'd-none' : ''}" id="globalCartCountBadge">
                    ${headerCartCount}
                </span>
            </a>

            <!-- TÀI KHOẢN / ĐĂNG NHẬP -->
            <c:choose>
                <c:when test="${not empty sessionScope.USER_LOGIN}">
                    <div class="dropdown">
                        <button class="nav-icon-btn dropdown-toggle border-0" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-person-circle"></i>
                            <span class="text-truncate" style="max-width: 120px;">${sessionScope.USER_LOGIN.fullName}</span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                            <li><a class="dropdown-item py-2" href="${ctx}/profile"><i class="bi bi-person me-2 text-primary"></i>Trang cá nhân</a></li>
                            <li><a class="dropdown-item py-2" href="${ctx}/orders"><i class="bi bi-clock-history me-2 text-primary"></i>Lịch sử đơn hàng</a></li>
                            <c:if test="${sessionScope.USER_LOGIN.admin}">
                                <li><a class="dropdown-item py-2 fw-semibold text-danger" href="${ctx}/admin/dashboard"><i class="bi bi-shield-shaded me-2"></i>Trang quản lý</a></li>
                            </c:if>
                            <li><hr class="dropdown-divider my-1"></li>
                            <li><a class="dropdown-item py-2 text-danger" href="${ctx}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
                        </ul>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${ctx}/login" class="nav-icon-btn" title="Đăng nhập / Đăng ký">
                        <i class="bi bi-person-fill"></i>
                        <span>Đăng nhập</span>
                    </a>
                </c:otherwise>
            </c:choose>

        </div>
    </div>
</div>
<!-- HEADER KẾT THÚC -->

<script>
    (function () {
        var ctx = '${ctx}';
        var input = document.getElementById('searchInput');
        var box = document.getElementById('searchSuggest');
        if (!input || !box) return;

        var timer = null;
        var controller = null;

        function esc(str) {
            return String(str == null ? '' : str)
                .replace(/&/g, '&amp;').replace(/</g, '&lt;')
                .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        function hide() {
            box.classList.add('d-none');
            box.innerHTML = '';
        }

        function render(items, keyword) {
            if (!items.length) {
                box.innerHTML = '<div class="suggest-empty">Không tìm thấy sản phẩm phù hợp</div>';
                box.classList.remove('d-none');
                return;
            }
            var html = '';
            items.forEach(function (it) {
                html += '<a class="suggest-item" href="' + ctx + '/product/detail?id=' + it.id + '">'
                    +  '<img src="' + esc(it.image) + '" alt="">'
                    +  '<div><div class="suggest-name">' + esc(it.name) + '</div>'
                    +  '<div class="suggest-price">' + Number(it.price).toLocaleString('vi-VN') + ' ₫</div></div>'
                    +  '</a>';
            });
            html += '<a class="suggest-all" href="' + ctx + '/search?keyword=' + encodeURIComponent(keyword) + '">'
                +  'Xem tất cả kết quả cho "' + esc(keyword) + '"</a>';
            box.innerHTML = html;
            box.classList.remove('d-none');
        }

        function fetchSuggest(keyword) {
            if (controller) controller.abort();
            controller = new AbortController();
            fetch(ctx + '/search-suggest?keyword=' + encodeURIComponent(keyword), { signal: controller.signal })
                .then(function (res) { return res.json(); })
                .then(function (data) { render(data, keyword); })
                .catch(function (err) { if (err.name !== 'AbortError') hide(); });
        }

        input.addEventListener('input', function () {
            var kw = input.value.trim();
            clearTimeout(timer);
            if (kw.length < 1) { hide(); return; }
            timer = setTimeout(function () { fetchSuggest(kw); }, 250); // chờ 250ms sau khi ngừng gõ
        });

        input.addEventListener('focus', function () {
            var kw = input.value.trim();
            if (kw.length >= 1) fetchSuggest(kw);
        });

        document.addEventListener('click', function (e) {
            if (!box.contains(e.target) && e.target !== input) hide();
        });

        input.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') hide();
        });
    })();
</script>

<c:if test="${not empty sessionScope.USER_LOGIN}">
<script>
    (function () {
        var authCheckTimer = setInterval(function () {
            fetch('${ctx}/check-auth')
                .then(function (res) { return res.json(); })
                .then(function (data) {
                    if (data && !data.loggedIn) {
                        clearInterval(authCheckTimer);
                        if (data.reason === 'password_changed') {
                            alert('Mật khẩu của bạn vừa được thay đổi từ một thiết bị hoặc trình duyệt khác. Hệ thống sẽ tự động đăng xuất để bảo vệ an toàn!');
                            window.location.href = '${ctx}/login?error=password_changed';
                        } else if (data.reason === 'account_locked') {
                            alert('Tài khoản của bạn đã bị khóa bởi Quản trị viên!');
                            window.location.href = '${ctx}/login?error=account_locked';
                        } else {
                            window.location.href = '${ctx}/login?error=need_login';
                        }
                    }
                })
                .catch(function () {});
        }, 3000); // Quét kiểm tra định kỳ mỗi 3 giây
    })();
</script>
</c:if>

<!-- Realtime Dual-Sync Client Engine -->
<script src="${ctx}/assets/js/realtime-sync.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (window.RealtimeSync) {
            window.RealtimeSync.init({
                role: 'client',
                userId: '${sessionScope.USER_LOGIN != null ? sessionScope.USER_LOGIN.id : 0}',
                ctx: '${ctx}'
            });
        }
    });
</script>

<!-- Quick Add to Cart Toast Notification -->
<div id="quickCartToastContainer" class="position-fixed bottom-0 end-0 p-3" style="z-index: 100000; pointer-events: none;">
    <div id="quickCartToast" class="quick-cart-toast-box" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex p-3 align-items-center w-100" style="overflow: hidden;">
            <div id="quickCartToastIcon" class="me-3 fs-3 d-flex align-items-center justify-content-center flex-shrink-0" style="width: 42px; height: 42px; background: rgba(34, 197, 94, 0.18); color: #22c55e; border-radius: 12px;">
                <i class="bi bi-cart-check-fill"></i>
            </div>
            <div style="flex: 1 1 auto; min-width: 0; overflow: hidden;" class="me-3">
                <div class="fw-bold text-white mb-0" id="quickCartToastTitle" style="font-size: 13.5px; line-height: 1.3; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Đã thêm vào giỏ hàng!</div>
                <div class="text-white-50" id="quickCartToastMsg" style="font-size: 12px; margin-top: 3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Sản phẩm đã được cập nhật</div>
            </div>
            <div class="d-flex align-items-center gap-2 flex-shrink-0">
                <a href="${ctx}/cart" id="quickCartToastViewBtn" class="btn btn-danger btn-sm fw-semibold text-nowrap px-3 py-1.5" style="font-size: 12px; border-radius: 8px;">Xem giỏ</a>
                <button type="button" class="btn-close btn-close-white" style="font-size: 10px;" onclick="closeQuickCartToast()" aria-label="Close"></button>
            </div>
        </div>
    </div>
</div>

<script>
    var _quickCartToastTimer = null;

    function closeQuickCartToast() {
        var toastEl = document.getElementById('quickCartToast');
        if (toastEl) {
            toastEl.classList.remove('show');
            toastEl.style.display = 'none';
        }
    }

    function showQuickCartToast(title, msg, isSuccess, showViewCart) {
        var toastEl = document.getElementById('quickCartToast');
        if (!toastEl) return;
        var titleEl = document.getElementById('quickCartToastTitle');
        var msgEl = document.getElementById('quickCartToastMsg');
        var iconEl = document.getElementById('quickCartToastIcon');
        var viewBtn = document.getElementById('quickCartToastViewBtn');

        if (titleEl) titleEl.textContent = title;
        if (msgEl) msgEl.textContent = msg;
        if (iconEl) {
            if (isSuccess) {
                iconEl.style.background = 'rgba(34, 197, 94, 0.18)';
                iconEl.style.color = '#22c55e';
                iconEl.innerHTML = '<i class="bi bi-cart-check-fill"></i>';
            } else {
                iconEl.style.background = 'rgba(239, 68, 68, 0.18)';
                iconEl.style.color = '#ef4444';
                iconEl.innerHTML = '<i class="bi bi-exclamation-circle-fill"></i>';
            }
        }
        if (viewBtn) {
            viewBtn.style.display = showViewCart ? 'inline-block' : 'none';
        }

        clearTimeout(_quickCartToastTimer);
        toastEl.classList.remove('show');
        void toastEl.offsetWidth; // trigger reflow
        toastEl.classList.add('show');

        _quickCartToastTimer = setTimeout(function () {
            closeQuickCartToast();
        }, 4000);
    }

    function updateGlobalCartCount(count) {
        var badge = document.getElementById('globalCartCountBadge');
        if (!badge) return;
        badge.textContent = count;
        if (count > 0) {
            badge.classList.remove('d-none');
            badge.classList.remove('badge-bounce');
            void badge.offsetWidth; // reflow
            badge.classList.add('badge-bounce');
        } else {
            badge.classList.add('d-none');
        }
    }

    document.addEventListener('click', function (e) {
        var btn = e.target.closest('.quick-add-cart-btn');
        if (!btn) return;

        e.preventDefault();
        e.stopPropagation();

        var productId = btn.getAttribute('data-id');
        var productName = btn.getAttribute('data-name') || 'Sản phẩm';
        if (!productId) return;

        if (btn.disabled) return;
        btn.disabled = true;

        var origHtml = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm text-white" style="width: 14px; height: 14px;" role="status"></span>';

        fetch('${ctx}/add-to-cart?id=' + encodeURIComponent(productId) + '&quantity=1&ajax=1', {
            method: 'GET',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(function (res) {
            return res.json();
        })
        .then(function (data) {
            if (data.requireLogin) {
                btn.innerHTML = origHtml;
                btn.disabled = false;
                showQuickCartToast('Cần đăng nhập', 'Vui lòng đăng nhập để thêm sản phẩm vào giỏ!', false, false);
                setTimeout(function () {
                    window.location.href = data.loginUrl || ('${ctx}/login?error=need_login');
                }, 800);
                return;
            }

            if (!data.success) {
                btn.innerHTML = origHtml;
                btn.disabled = false;
                showQuickCartToast('Thông báo', data.message || 'Không thể thêm vào giỏ hàng!', false, false);
                return;
            }

            // Đổi nút sang trạng thái thành công
            btn.classList.remove('btn-danger');
            btn.classList.add('btn-success');
            btn.innerHTML = '<i class="bi bi-check-lg fs-6 text-white"></i>';

            updateGlobalCartCount(data.cartCount);
            showQuickCartToast('Đã thêm vào giỏ hàng!', productName, true, true);

            setTimeout(function () {
                btn.classList.remove('btn-success');
                btn.classList.add('btn-danger');
                btn.innerHTML = origHtml;
                btn.disabled = false;
            }, 1200);
        })
        .catch(function (err) {
            console.error('Quick add to cart error:', err);
            btn.innerHTML = origHtml;
            btn.disabled = false;
            showQuickCartToast('Lỗi kết nối', 'Không thể thêm vào giỏ hàng, vui lòng thử lại!', false, false);
        });
    });
</script>
