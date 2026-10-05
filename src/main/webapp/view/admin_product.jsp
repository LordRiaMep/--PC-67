<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="url" value="${ctx}/admin/products" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Sản phẩm - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="products"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <h3 class="m-0 text-dark fw-bold">Quản lý Sản phẩm</h3>
        <div class="d-flex align-items-center">
            <span class="me-3">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <div class="row g-4">

        <!-- Form thêm / sửa -->
        <div class="col-lg-4">
            <form action="${url}" method="post" class="panel sticky-panel">
                <div class="panel-head">
                    <h5><i class="fa-solid ${not empty product ? 'fa-pen-to-square' : 'fa-plus'} me-2"></i>${not empty product ? 'Sửa sản phẩm' : 'Thêm sản phẩm'}</h5>
                    <c:if test="${not empty product}"><span class="muted small">Mã #${product.id}</span></c:if>
                </div>

                <div class="panel-body">
                    <input type="hidden" name="id" value="${product.id}">
                    <input type="hidden" name="action" value="${not empty product ? 'update' : 'insert'}">

                    <div class="mb-3">
                        <div class="field-label">Danh mục <span class="text-danger">*</span></div>
                        <select name="categoryId" class="form-select field shadow-none" required>
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach items="${listCategories}" var="cat">
                                <option value="${cat.id}" ${product.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <div class="field-label">Tên sản phẩm <span class="text-danger">*</span></div>
                        <input type="text" name="name" class="form-control field shadow-none" value="${product.name}" required>
                    </div>

                    <div class="mb-3">
                        <div class="field-label">Mô tả</div>
                        <textarea name="description" class="form-control field shadow-none" rows="3">${product.description}</textarea>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-7">
                            <div class="field-label">Giá (đ) <span class="text-danger">*</span></div>
                            <input type="number" name="price" min="0" class="form-control field shadow-none" value="${product.price}" required>
                        </div>
                        <div class="col-5">
                            <div class="field-label">Tồn kho <span class="text-danger">*</span></div>
                            <input type="number" name="stock" min="0" class="form-control field shadow-none" value="${product.quantity}" required>
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="field-label">Ảnh sản phẩm (URL)</div>
                        <input type="text" id="imageUrl" name="imageUrl" class="form-control field shadow-none mb-2" value="${product.image}" placeholder="https://...">
                        <div class="img-preview" id="imgPreview">
                            <c:choose>
                                <c:when test="${not empty product.image}"><img src="${product.image}" alt="Ảnh xem trước" onerror="this.remove()"></c:when>
                                <c:otherwise><i class="fa-regular fa-image fs-2"></i></c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-neon px-4 flex-grow-1"><i class="fa-solid fa-floppy-disk me-1"></i> Lưu sản phẩm</button>
                        <a href="${url}" class="btn btn-ghost px-3" title="Xóa trắng form để thêm mới">Làm mới</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Danh sách -->
        <div class="col-lg-8">
            <div class="panel overflow-hidden">
                <div class="panel-head">
                    <h5><i class="fa-solid fa-list me-2"></i>Danh sách sản phẩm</h5>
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="quickSearch" class="form-control field shadow-none" placeholder="Lọc theo tên trong trang này">
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table tbl align-middle" id="prodTable">
                        <thead>
                        <tr>
                            <th style="width: 90px;">Ảnh</th>
                            <th>Sản phẩm</th>
                            <th>Giá</th>
                            <th class="text-center">Kho</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listProducts}" var="p">
                            <tr class="${product != null && product.id == p.id ? 'row-edit' : ''}">
                                <td><div class="thumb"><img src="${p.image}" alt="${p.name}" onerror="this.style.display='none'"></div></td>
                                <td>
                                    <div class="prod-name">${p.name}</div>
                                    <span class="chip mt-1">${p.categoryName}</span>
                                </td>
                                <td class="price"><fmt:formatNumber value="${p.price}" type="number" pattern="#,##0" /> đ</td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${p.quantity <= 0}"><span class="stock stock-out">Hết</span></c:when>
                                        <c:when test="${p.quantity <= 5}"><span class="stock stock-low">${p.quantity}</span></c:when>
                                        <c:otherwise><span class="stock stock-ok">${p.quantity}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a href="${url}?action=edit&id=${p.id}" class="btn btn-sm btn-ghost act me-1" title="Sửa"><i class="fa-solid fa-pen"></i></a>
                                    <a href="${url}?action=delete&id=${p.id}" onclick="return confirm('Xóa sản phẩm này?');" class="btn btn-sm btn-outline-danger act" title="Xóa"><i class="fa-solid fa-trash"></i></a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty listProducts}">
                            <tr><td colspan="5" class="text-center muted py-5">
                                <i class="fa-solid fa-box-open fs-1 d-block mb-2"></i>Chưa có sản phẩm nào. Thêm sản phẩm đầu tiên ở khung bên trái.
                            </td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
                <div id="noMatch" class="text-center muted py-4" style="display:none;">Không có sản phẩm nào khớp trong trang này.</div>
            </div>

            <c:if test="${totalPages > 1}">
                <nav class="mt-4">
                    <ul class="pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}"><a class="page-link shadow-none" href="${url}?page=${currentPage - 1}">Trước</a></li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link shadow-none" href="${url}?page=${i}">${i}</a></li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}"><a class="page-link shadow-none" href="${url}?page=${currentPage + 1}">Sau</a></li>
                    </ul>
                </nav>
            </c:if>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Xem trước ảnh khi nhập URL
    (function () {
        var input = document.getElementById('imageUrl');
        var box = document.getElementById('imgPreview');
        input.addEventListener('input', function () {
            var v = input.value.trim();
            box.innerHTML = '';
            if (!v) { box.innerHTML = '<i class="fa-regular fa-image fs-2"></i>'; return; }
            var img = new Image();
            img.alt = 'Ảnh xem trước';
            img.onerror = function () { box.innerHTML = '<span class="small">Không tải được ảnh từ URL này</span>'; };
            img.src = v;
            box.appendChild(img);
        });
    })();

    // Lọc nhanh theo tên trong trang hiện tại
    (function () {
        var search = document.getElementById('quickSearch');
        var rows = document.querySelectorAll('#prodTable tbody tr');
        var noMatch = document.getElementById('noMatch');
        search.addEventListener('input', function () {
            var q = search.value.trim().toLowerCase(), shown = 0;
            rows.forEach(function (r) {
                var el = r.querySelector('.prod-name');
                if (!el) return;
                var ok = el.textContent.toLowerCase().indexOf(q) !== -1;
                r.style.display = ok ? '' : 'none';
                if (ok) shown++;
            });
            noMatch.style.display = (q && shown === 0) ? 'block' : 'none';
        });
    })();
</script>
</body>
</html>
