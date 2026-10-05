<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="url" value="${ctx}/admin/categories" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Danh mục - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="categories"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <h3 class="m-0 text-dark fw-bold">Quản lý Danh mục</h3>
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
                    <h5><i class="fa-solid ${not empty category ? 'fa-pen-to-square' : 'fa-plus'} me-2"></i>${not empty category ? 'Sửa danh mục' : 'Thêm danh mục'}</h5>
                    <c:if test="${not empty category}"><span class="muted small">Mã #${category.id}</span></c:if>
                </div>
                <div class="panel-body">
                    <input type="hidden" name="id" value="${category.id}">
                    <input type="hidden" name="action" value="${not empty category ? 'update' : 'insert'}">

                    <div class="mb-3">
                        <div class="field-label">Tên danh mục <span class="text-danger">*</span></div>
                        <input type="text" name="name" class="form-control field shadow-none" value="${category.name}" required>
                    </div>
                    <div class="mb-4">
                        <div class="field-label">Mô tả</div>
                        <textarea name="description" class="form-control field shadow-none" rows="4">${category.description}</textarea>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-neon px-4 flex-grow-1"><i class="fa-solid fa-floppy-disk me-1"></i> Lưu danh mục</button>
                        <a href="${url}" class="btn btn-ghost px-3" title="Xóa trắng form để thêm mới">Làm mới</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Danh sách -->
        <div class="col-lg-8">
            <div class="panel overflow-hidden">
                <div class="panel-head">
                    <h5><i class="fa-solid fa-list me-2"></i>Danh sách danh mục</h5>
                </div>
                <div class="table-responsive">
                    <table class="table tbl align-middle">
                        <thead>
                        <tr>
                            <th style="width: 70px;">Mã</th>
                            <th>Tên danh mục</th>
                            <th>Mô tả</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listCategories}" var="c">
                            <tr class="${category != null && category.id == c.id ? 'row-edit' : ''}">
                                <td class="muted">#${c.id}</td>
                                <td class="prod-name">${c.name}</td>
                                <td class="muted">${c.description}</td>
                                <td class="text-end text-nowrap">
                                    <a href="${url}?action=edit&id=${c.id}&page=${tag}" class="btn btn-sm btn-ghost act me-1" title="Sửa"><i class="fa-solid fa-pen"></i></a>
                                    <a href="${url}?action=delete&id=${c.id}" onclick="return confirm('Xóa danh mục này?');" class="btn btn-sm btn-outline-danger act" title="Xóa"><i class="fa-solid fa-trash"></i></a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty listCategories}">
                            <tr><td colspan="4" class="text-center muted py-5">
                                <i class="fa-solid fa-layer-group fs-1 d-block mb-2"></i>Chưa có danh mục nào.
                            </td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <c:if test="${endPage > 1}">
                <ul class="pagination justify-content-end mt-4 mb-0">
                    <c:forEach begin="1" end="${endPage}" var="i">
                        <li class="page-item ${tag == i ? 'active' : ''}"><a class="page-link shadow-none" href="${url}?page=${i}">${i}</a></li>
                    </c:forEach>
                </ul>
            </c:if>
        </div>
    </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
