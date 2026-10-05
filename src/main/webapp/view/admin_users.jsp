<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Khách hàng - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="users"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <h3 class="m-0 text-dark fw-bold">Quản lý Khách hàng</h3>
        <div class="d-flex align-items-center">
            <span class="me-3">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <div class="panel overflow-hidden">
        <div class="panel-head">
            <h5><i class="fa-solid fa-users me-2"></i>Danh sách khách hàng</h5>
            <div class="search-box">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" id="quickSearch" class="form-control field shadow-none" placeholder="Lọc theo tên hoặc email trong trang này">
            </div>
        </div>
        <div class="table-responsive">
            <table class="table tbl align-middle" id="userTable">
                <thead>
                <tr>
                    <th style="width: 70px;">Mã</th>
                    <th>Khách hàng</th>
                    <th>SĐT</th>
                    <th>Địa chỉ</th>
                    <th>Ngày tạo</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${users}" var="u">
                    <tr>
                        <td class="muted">#${u.id}</td>
                        <td>
                            <div class="d-flex align-items-center gap-3">
                                <span class="avatar">${fn:toUpperCase(fn:substring(u.fullName, 0, 1))}</span>
                                <div>
                                    <div class="prod-name user-key">${u.fullName}</div>
                                    <div class="muted small user-key">${u.email}</div>
                                </div>
                            </div>
                        </td>
                        <td>${u.phone}</td>
                        <td>${u.address}</td>
                        <td class="muted">${u.createdAt}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty users}">
                    <tr><td colspan="5" class="text-center muted py-5">
                        <i class="fa-solid fa-users fs-1 d-block mb-2"></i>Chưa có khách hàng nào.
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
        <div id="noMatch" class="text-center muted py-4" style="display:none;">Không có khách hàng nào khớp trong trang này.</div>
    </div>

    <c:if test="${totalPages > 1}">
        <ul class="pagination justify-content-end mt-4 mb-0">
            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}"><a class="page-link shadow-none" href="?page=${currentPage - 1}">Trước</a></li>
            <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link shadow-none" href="?page=${i}">${i}</a></li>
            </c:forEach>
            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}"><a class="page-link shadow-none" href="?page=${currentPage + 1}">Sau</a></li>
        </ul>
    </c:if>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Lọc nhanh theo tên hoặc email trong trang hiện tại
    (function () {
        var search = document.getElementById('quickSearch');
        var rows = document.querySelectorAll('#userTable tbody tr');
        var noMatch = document.getElementById('noMatch');
        search.addEventListener('input', function () {
            var q = search.value.trim().toLowerCase(), shown = 0;
            rows.forEach(function (r) {
                var keys = r.querySelectorAll('.user-key');
                if (!keys.length) return;
                var text = Array.prototype.map.call(keys, function (k) { return k.textContent; }).join(' ').toLowerCase();
                var ok = text.indexOf(q) !== -1;
                r.style.display = ok ? '' : 'none';
                if (ok) shown++;
            });
            noMatch.style.display = (q && shown === 0) ? 'block' : 'none';
        });
    })();
</script>
</body>
</html>
