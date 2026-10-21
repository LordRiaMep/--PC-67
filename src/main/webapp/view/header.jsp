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
    <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=3">

    <style>
        .dropdown:hover .dropdown-menu {
            display: block;
            margin-top: 0 !important;
            transition: all 0.3s ease;
        }
        .bg-header-red {
            background-color: #E30019;
        }
        .btn-category-red {
            background-color: #BE0015;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
        }
        .btn-category-red:hover, .btn-category-red:focus {
            background-color: #9E0012;
            color: white;
        }
        .search-input-group {
            margin: 0;
            align-items: stretch;
        }
        .search-input-group .form-control {
            border: 0;
            box-shadow: none !important;
            border-top-left-radius: 8px;
            border-bottom-left-radius: 8px;
        }
        .search-input-group .btn-search {
            background-color: white;
            border-top-right-radius: 8px;
            border-bottom-right-radius: 8px;
            color: #6c757d;
        }
        .search-icon-static {
            display: flex;
            align-items: center;
            align-self: stretch;
            background-color: #fff;
            border: 0;
            padding: 0 14px 0 4px;
            cursor: default;
            pointer-events: none;
            user-select: none;
        }
        .nav-icon-btn {
            white-space: nowrap;
            background-color: #000000;
            color: white;
            border-radius: 8px;
            padding: 8px 14px;
            text-decoration: none;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .nav-icon-btn:hover {
            background-color: #212529;
            color: white;
        }
        /* Gợi ý tìm kiếm */
        .search-suggest {
            position: absolute;
            top: calc(100% + 6px);
            left: 0;
            right: 0;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
            overflow: hidden;
            z-index: 2000;
        }
        .suggest-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            text-decoration: none;
            color: #212529;
            border-bottom: 1px solid #f1f1f1;
        }
        .suggest-item:hover {
            background-color: #f8f9fa;
            color: #212529;
        }
        .suggest-item img {
            width: 90px;
            height: 68px;
            object-fit: contain;
            flex-shrink: 0;
        }
        .suggest-name {
            font-size: 13px;
            font-weight: 600;
            line-height: 1.3;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .suggest-price {
            font-size: 13px;
            font-weight: 700;
            color: #dc3545;
        }
        .suggest-all {
            display: block;
            text-align: center;
            padding: 8px;
            font-size: 13px;
            font-weight: 600;
            color: #dc3545;
            text-decoration: none;
            background: #fafafa;
        }
        .suggest-empty {
            padding: 12px;
            font-size: 13px;
            color: #6c757d;
            text-align: center;
        }
    </style>
</head>

<body class="bg-light text-dark d-flex flex-column min-vh-100">

<!-- HEADER BẮT ĐẦU -->
<div class="py-2 shadow-sm position-relative bg-header-red" style="z-index: 1000;">
    <div class="container d-flex justify-content-between align-items-center flex-wrap flex-lg-nowrap gap-3">

        <!-- LOGO & TRANG CHỦ -->
        <a href="${ctx}/Home" class="d-flex align-items-center text-decoration-none flex-shrink-0">
            <img src="${ctx}/assets/images/logo moi.png" alt="Độ PC 67" style="height: 65px; object-fit: contain;">
        </a>

        <!-- NÚT DANH MỤC DROPDOWN -->
        <div class="dropdown flex-shrink-0">
            <button class="btn btn-category-red px-3 py-2 d-flex align-items-center gap-2" type="button" id="dropdownCategory" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-list fs-5"></i>
                <span>Danh mục</span>
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
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item py-2 fw-bold d-flex align-items-center gap-2" href="${ctx}/news">
                        <i class="bi bi-newspaper category-icon"></i>
                        <span>Tin tức công nghệ</span>
                    </a>
                </li>
            </ul>
        </div>

        <!-- Ô TÌM KIẾM (gửi sang SearchServlet tại /search) -->
        <form action="${ctx}/search" method="get" accept-charset="UTF-8" class="flex-grow-1 mx-lg-2 my-0 align-self-center position-relative" style="max-width: 450px; min-width: 120px; margin-top: 0 !important; margin-bottom: 0 !important;" autocomplete="off">
            <div class="input-group search-input-group">
                <input type="text" id="searchInput" name="keyword" class="form-control border-end-0 py-2 ps-3" placeholder="Bạn cần tìm gì?" value="<c:out value='${param.keyword}'/>">
                <span class="btn-search search-icon-static border-start-0 pe-3">
                    <i class="bi bi-search"></i>
                </span>
            </div>
            <div id="searchSuggest" class="search-suggest d-none"></div>
        </form>

        <!-- KHU VỰC CÁC TÍNH NĂNG (ĐƠN HÀNG, LIÊN HỆ, GIỎ HÀNG, TÀI KHOẢN) -->
        <div class="d-flex align-items-center gap-2 flex-wrap flex-lg-nowrap flex-shrink-0">

            <!-- LIÊN HỆ -->
            <a href="${ctx}/contact" class="nav-icon-btn">
                <i class="bi bi-headset fs-5"></i>
                <span>Liên hệ</span>
            </a>

            <!-- NÚT VỀ TRANG QUẢN LÝ (chỉ hiện với admin) -->
            <c:if test="${sessionScope.USER_LOGIN.admin}">
                <a href="${ctx}/admin/dashboard" class="nav-icon-btn" style="background-color:#BE0015; border:1px solid #fff;">
                    <i class="bi bi-speedometer2 fs-5"></i>
                    <span>Quản lý</span>
                </a>
            </c:if>

            <!-- ĐƠN HÀNG -->
            <a href="${ctx}/orders" class="nav-icon-btn">
                <i class="bi bi-box-seam-fill fs-5"></i>
                <span>Đơn hàng</span>
            </a>

            <!-- GIỎ HÀNG VỚI BADGE SỐ LƯỢNG VÀ CHỮ GIỎ HÀNG -->
            <a href="${ctx}/cart" class="nav-icon-btn position-relative ms-1">
                <i class="bi bi-cart3 fs-5"></i>
                <span>Giỏ hàng</span>
                <c:if test="${not empty cartCount && cartCount > 0}">
                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light">
                            ${cartCount}
                    </span>
                </c:if>
            </a>

            <!-- TÀI KHOẢN / ĐĂNG NHẬP -->
            <c:choose>
                <c:when test="${not empty sessionScope.USER_LOGIN}">
                    <div class="dropdown ms-1">
                        <button class="nav-icon-btn dropdown-toggle border-0" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-person-circle fs-5"></i>
                            <span>${sessionScope.USER_LOGIN.fullName}</span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                            <li><a class="dropdown-item py-2" href="${ctx}/profile"><i class="bi bi-person me-2"></i>Trang cá nhân</a></li>
                            <li><a class="dropdown-item py-2" href="${ctx}/orders"><i class="bi bi-clock-history me-2"></i>Lịch sử đơn hàng</a></li>
                            <c:if test="${sessionScope.USER_LOGIN.admin}">
                                <li><a class="dropdown-item py-2 fw-semibold" href="${ctx}/admin/dashboard"><i class="bi bi-speedometer2 me-2"></i>Trang quản lý</a></li>
                            </c:if>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item py-2 text-danger" href="${ctx}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng xuất</a></li>
                        </ul>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${ctx}/login" class="nav-icon-btn ms-1">
                        <i class="bi bi-person fs-5"></i>
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
