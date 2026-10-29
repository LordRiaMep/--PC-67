<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
    <style>
.group-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 10px; overflow: hidden; }
        .group-header { background: #f8fafc; padding: 8px 12px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: space-between; }
        .group-title { font-weight: 700; font-size: 13px; color: #1e293b; display: flex; align-items: center; gap: 6px; }
        .group-body { padding: 10px 12px; }
        .opt-item-row { display: grid; grid-template-columns: 28px 1fr 125px 32px; gap: 6px; align-items: center; margin-bottom: 8px; }
        .opt-item-row:last-child { margin-bottom: 0; }
        .opt-radio-wrap { display: flex; align-items: center; justify-content: center; }
        .opt-radio-wrap input[type="radio"] { cursor: pointer; width: 16px; height: 16px; accent-color: var(--brand); }
        .btn-xs { padding: 3px 8px; font-size: 11px; border-radius: 4px; font-weight: 600; }
        .opt-col-label { font-size: 11px; font-weight: 600; color: #64748b; margin-bottom: 4px; }
</style>
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="products"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <div>
            <h3 class="m-0 text-dark fw-bold">Quản lý Sản phẩm</h3>
            <span class="text-secondary small">Quản lý kho hàng, thông số kỹ thuật, giá bán và tùy chọn nâng cấp / đổi màu</span>
        </div>
        <div class="d-flex align-items-center">
            <span class="me-3">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <div id="dynamicAlertArea"></div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-circle-check fs-5 me-2"></i>
            <div>${successMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-triangle-exclamation fs-5 me-2"></i>
            <div>${errorMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row g-4">

        <div class="col-lg-5 col-xl-5">
            <form action="${url}" method="post" id="productForm" class="panel sticky-panel">
                <div class="panel-head">
                    <h5><i class="fa-solid ${not empty product ? 'fa-pen-to-square' : 'fa-plus'} me-2"></i>${not empty product ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới'}</h5>
                    <c:if test="${not empty product}"><span class="badge bg-danger">#${product.id}</span></c:if>
                </div>

                <div class="panel-body">
                    <input type="hidden" name="id" value="${product.id}">
                    <input type="hidden" name="page" value="${currentPage}">
                    <input type="hidden" name="action" value="${not empty product ? 'update' : 'insert'}">

                    <input type="hidden" name="upgradeOptionsJson" id="upgradeOptionsJson" value="">
                    <input type="hidden" name="imagesJson" id="imagesJson" value="">

                    <div class="mb-3">
                        <label class="field-label">Danh mục <span class="text-danger">*</span></label>
                        <select name="categoryId" class="form-select field shadow-none" required>
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach items="${listCategories}" var="cat">
                                <option value="${cat.id}" ${product.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="field-label">Tên sản phẩm <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control field shadow-none" value="${product.name}" placeholder="Ví dụ: PC Gaming RTX 4070 Ti Super" required>
                    </div>

                    <div class="mb-3">
                        <label class="field-label">Mô tả ngắn</label>
                        <textarea name="description" class="form-control field shadow-none" rows="2" placeholder="Tóm tắt đặc điểm nổi bật...">${product.description}</textarea>
                    </div>

                    <div class="mb-3">
                        <label class="field-label">Thông số kỹ thuật chi tiết (mỗi dòng 1 thông số)</label>
                        <textarea name="specDetail" class="form-control field shadow-none" rows="4"
                                  placeholder="CPU Intel Core i5-13400F&#10;RAM 16GB DDR5&#10;SSD 1TB NVMe&#10;VGA RTX 4060 Ti&#10;Nguồn 650W Bronze"><c:out value="${product.specText}"/></textarea>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-7">
                            <label class="field-label">Giá gốc bán ra (VNĐ) <span class="text-danger">*</span></label>
                            <fmt:formatNumber value="${product.price}" pattern="#0" var="plainPrice" />
                            <input type="number" name="price" min="0" step="1000" class="form-control field shadow-none" value="${not empty product ? plainPrice : ''}" required>
                        </div>
                        <div class="col-5">
                            <label class="field-label">Tồn kho <span class="text-danger">*</span></label>
                            <input type="number" name="stock" min="0" class="form-control field shadow-none" value="${product.quantity != null ? product.quantity : 1}" required>
                        </div>
                    </div>

                    <!-- BỘ SƯU TẬP ẢNH SẢN PHẨM (NHIỀU ẢNH) -->
                    <div class="mb-4 p-3 bg-light border rounded-3">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <label class="field-label m-0 text-dark fw-bold d-flex align-items-center gap-2">
                                <i class="fa-solid fa-images text-danger"></i>
                                <span>Bộ sưu tập ảnh sản phẩm</span>
                            </label>
                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1" id="imageCountBadge">0 ảnh</span>
                        </div>
                        <div class="text-secondary small mb-3" style="font-size: 12px; line-height: 1.4;">
                            Thêm được nhiều ảnh cho sản phẩm. Ảnh đầu tiên được đánh dấu <strong>Ảnh chính</strong> (hiển thị ở trang chủ, giỏ hàng). Khách hàng vào trang chi tiết sẽ xem được đầy đủ tất cả các ảnh.
                        </div>

                        <!-- Ô nhập link ảnh đơn lẻ -->
                        <div class="input-group mb-2">
                            <input type="text" id="newImageUrlInput" class="form-control field shadow-none" placeholder="Dán link ảnh (https://... hoặc /assets/images/...)">
                            <button type="button" class="btn btn-danger" id="btnAddSingleImageBtn">
                                <i class="fa-solid fa-plus me-1"></i>Thêm ảnh
                            </button>
                        </div>

                        <!-- Nút bật khung dán nhiều ảnh cùng lúc -->
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <button type="button" class="btn btn-xs btn-outline-secondary" id="btnToggleBatchBox">
                                <i class="fa-solid fa-list-check me-1"></i>Nhập nhiều link ảnh cùng lúc
                            </button>
                            <span class="text-muted" style="font-size: 11px;">Hỗ trợ link web hoặc ảnh nội bộ</span>
                        </div>

                        <!-- Khung dán nhiều link ảnh (ẩn mặc định) -->
                        <div id="batchBoxContainer" class="d-none mb-3 p-2 bg-white border rounded-2">
                            <label class="form-label small fw-bold mb-1">Dán danh sách link ảnh (mỗi dòng 1 link URL):</label>
                            <textarea id="batchUrlsInput" class="form-control field shadow-none mb-2" rows="3" placeholder="https://cdn.../hinh1.jpg&#10;https://cdn.../hinh2.jpg&#10;https://cdn.../hinh3.jpg"></textarea>
                            <div class="d-flex justify-content-end gap-2">
                                <button type="button" class="btn btn-xs btn-secondary" id="btnCancelBatch">Hủy</button>
                                <button type="button" class="btn btn-xs btn-danger" id="btnApplyBatch">Nạp danh sách ảnh</button>
                            </div>
                        </div>

                        <!-- Danh sách các thẻ ảnh đã thêm -->
                        <div id="galleryCardsList" class="d-flex flex-column gap-2 mb-2" style="max-height: 320px; overflow-y: auto;">
                            <!-- Render bằng JavaScript -->
                        </div>

                        <!-- Input ẩn lưu link ảnh đại diện chính (tương thích backward) -->
                        <input type="hidden" id="imageUrl" name="imageUrl" value="${product.image}">
                    </div>

                    <div class="opt-builder-box mb-4">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <label class="field-label m-0 text-dark fw-bold d-flex align-items-center gap-1">
                                <i class="fa-solid fa-sliders text-danger"></i> Tùy chọn & Nâng cấp (Màu / Linh kiện)
                            </label>
                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle badge-count" id="formOptionBadge">0 tùy chọn</span>
                        </div>

                        <div class="text-secondary small mb-3" style="font-size: 12px; line-height: 1.4;">
                            Tùy biến linh hoạt theo từng sản phẩm: Cho phép khách chọn đổi màu (Đen, Trắng...) hoặc nâng cấp linh kiện (CPU, RAM, SSD, VGA...). Có thể để trống nếu sản phẩm không có tùy chọn.
                        </div>

                        <div class="d-flex flex-wrap gap-1 mb-3">
                            <span class="text-secondary small align-self-center me-1" style="font-size: 11px; font-weight: 600;">Mẫu nhanh:</span>
                            <button type="button" class="btn btn-xs btn-outline-danger" onclick="formBuilder.addPreset('color')" title="Tạo nhóm Màu sắc: Đen (Mặc định) và Trắng">
                                <i class="fa-solid fa-palette me-1"></i>+ Màu sắc
                            </button>
                            <button type="button" class="btn btn-xs btn-outline-primary" onclick="formBuilder.addPreset('ram')" title="Tạo nhóm nâng cấp RAM">
                                <i class="fa-solid fa-memory me-1"></i>+ RAM
                            </button>
                            <button type="button" class="btn btn-xs btn-outline-success" onclick="formBuilder.addPreset('storage')" title="Tạo nhóm nâng cấp Ổ cứng SSD">
                                <i class="fa-solid fa-hard-drive me-1"></i>+ Ổ cứng SSD
                            </button>
                            <button type="button" class="btn btn-xs btn-outline-dark" onclick="formBuilder.addPreset('pc_full')" title="Tạo trọn bộ mẫu Màu sắc, RAM, SSD">
                                <i class="fa-solid fa-wand-magic-sparkles me-1"></i>+ Bộ PC đầy đủ
                            </button>
                        </div>

                        <div id="formGroupsContainer"></div>

                        <div class="input-group input-group-sm mt-2">
                            <input type="text" id="customGroupNameInput" class="form-control field shadow-none" placeholder="Tên nhóm mới (VD: Màu sắc, CPU, RAM, Vỏ case...)">
                            <button type="button" class="btn btn-outline-danger" id="btnAddCustomGroupBtn">
                                <i class="fa-solid fa-plus me-1"></i>Thêm nhóm
                            </button>
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-neon px-4 flex-grow-1"><i class="fa-solid fa-floppy-disk me-1"></i> Lưu sản phẩm</button>
                        <a href="${url}?page=${currentPage}" class="btn btn-ghost px-3" title="Xóa trắng form để thêm mới">Làm mới</a>
                    </div>
                </div>
            </form>
        </div>

        <div class="col-lg-7 col-xl-7">
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
                            <th style="width: 70px;">Ảnh</th>
                            <th>Sản phẩm</th>
                            <th>Giá</th>
                            <th class="text-center" style="width: 120px;">Tùy chọn</th>
                            <th class="text-center" style="width: 70px;">Kho</th>
                            <th class="text-end" style="width: 120px;">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listProducts}" var="p">
                            <tr class="${product != null && product.id == p.id ? 'row-edit' : ''}">
                                <td>
                                    <div class="thumb position-relative" style="width: 52px; height: 52px;">
                                        <img src="${p.image}" alt="${p.name}" onerror="this.src='https://via.placeholder.com/60?text=No+Image'">
                                        <c:set var="subCount" value="${imageCountMap[p.id]}" />
                                        <c:if test="${not empty subCount && subCount > 0}">
                                            <span class="position-absolute bottom-0 end-0 badge rounded-pill bg-danger border border-light" style="font-size: 9px; padding: 2px 4px;" title="Sản phẩm có ${subCount} ảnh">
                                                <i class="fa-solid fa-images"></i> ${subCount}
                                            </span>
                                        </c:if>
                                    </div>
                                </td>
                                <td>
                                    <div class="prod-name">${p.name}</div>
                                    <span class="chip mt-1">${p.categoryName}</span>
                                </td>
                                <td class="price"><fmt:formatNumber value="${p.price}" pattern="#,##0" /> đ</td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${optionCountMap[p.id] != null && optionCountMap[p.id] > 0}">
                                            <button type="button" class="btn btn-xs btn-outline-danger fw-semibold" id="opt-badge-${p.id}" onclick="openQuickModal(${p.id}, '${fn:escapeXml(p.name)}')" title="Xem và chỉnh sửa tùy chọn">
                                                <i class="fa-solid fa-sliders me-1"></i>${optionCountMap[p.id]} tùy chọn
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="btn btn-xs btn-ghost text-muted" id="opt-badge-${p.id}" onclick="openQuickModal(${p.id}, '${fn:escapeXml(p.name)}')" title="Thêm tùy chọn linh kiện / màu sắc cho sản phẩm này">
                                                <i class="fa-solid fa-plus me-1"></i>Thiết lập
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${p.quantity <= 0}"><span class="stock stock-out">Hết</span></c:when>
                                        <c:when test="${p.quantity <= 5}"><span class="stock stock-low">${p.quantity}</span></c:when>
                                        <c:otherwise><span class="stock stock-ok">${p.quantity}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <button type="button" class="btn btn-sm btn-ghost act me-1" title="Quản lý tùy chọn & nâng cấp nhanh" onclick="openQuickModal(${p.id}, '${fn:escapeXml(p.name)}')"><i class="fa-solid fa-sliders text-danger"></i></button>
                                    <a href="${url}?action=edit&id=${p.id}&page=${currentPage}" class="btn btn-sm btn-ghost act me-1" title="Sửa thông tin sản phẩm"><i class="fa-solid fa-pen"></i></a>
                                    <a href="${url}?action=delete&id=${p.id}&page=${currentPage}" onclick="return confirm('Bạn có chắc chắn muốn xóa/ẩn sản phẩm \"${p.name}\"?');" class="btn btn-sm btn-outline-danger act" title="Xóa"><i class="fa-solid fa-trash"></i></a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty listProducts}">
                            <tr><td colspan="6" class="text-center muted py-5">
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

<div class="modal fade" id="quickOptionsModal" tabindex="-1" aria-labelledby="quickOptionsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-light">
                <div>
                    <h5 class="modal-title fw-bold text-dark mb-0" id="quickOptionsModalLabel">
                        <i class="fa-solid fa-sliders text-danger me-2"></i>Tùy chọn & Nâng cấp: <span id="modalProdTitle" class="text-danger"></span>
                    </h5>
                    <div class="text-secondary small mt-1">Cấu hình linh kiện nâng cấp, màu sắc và các tùy biến theo sản phẩm</div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-3">
                <div id="modalLoading" class="text-center py-5">
                    <div class="spinner-border text-danger" role="status"></div>
                    <div class="text-secondary small mt-2">Đang tải tùy chọn...</div>
                </div>

                <div id="modalContent" style="display:none;">

                    <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 p-2 bg-light rounded-3 mb-3 border">
                        <div class="d-flex flex-wrap gap-1 align-items-center">
                            <span class="text-secondary small me-1" style="font-size: 11px; font-weight: 600;">Mẫu nhanh:</span>
                            <button type="button" class="btn btn-xs btn-outline-danger" onclick="modalBuilder.addPreset('color')"><i class="fa-solid fa-palette me-1"></i>+ Màu sắc</button>
                            <button type="button" class="btn btn-xs btn-outline-primary" onclick="modalBuilder.addPreset('ram')"><i class="fa-solid fa-memory me-1"></i>+ RAM</button>
                            <button type="button" class="btn btn-xs btn-outline-success" onclick="modalBuilder.addPreset('storage')"><i class="fa-solid fa-hard-drive me-1"></i>+ Ổ cứng SSD</button>
                            <button type="button" class="btn btn-xs btn-outline-dark" onclick="modalBuilder.addPreset('pc_full')"><i class="fa-solid fa-wand-magic-sparkles me-1"></i>+ Bộ PC đầy đủ</button>
                        </div>
                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle badge-count" id="modalOptionsBadge">0 lựa chọn</span>
                    </div>

                    <div id="modalGroupsContainer"></div>

                    <div class="input-group input-group-sm mt-3">
                        <input type="text" id="modalGroupNameInput" class="form-control field shadow-none" placeholder="Tên nhóm mới (VD: Màu sắc, CPU, RAM, Vỏ case...)">
                        <button type="button" class="btn btn-outline-danger" id="btnAddModalGroupBtn">
                            <i class="fa-solid fa-plus me-1"></i>Thêm nhóm
                        </button>
                    </div>
                </div>
            </div>
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-ghost px-3" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-neon px-4" id="btnSaveModalOptions">
                    <i class="fa-solid fa-floppy-disk me-1"></i>Lưu tùy chọn
                </button>
            </div>
        </div>
    </div>
</div>

<script id="initialProductOptionsData" type="application/json">
    <c:out value="${empty productOptionsJson ? '[]' : productOptionsJson}" escapeXml="false" />
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js">

</script>
<script>
const imgInput = document.getElementById('imageUrl');
    const previewBox = document.getElementById('imgPreview');
    if (imgInput && previewBox) {
        imgInput.addEventListener('input', function () {
            const val = this.value.trim();
            if (val) {
                previewBox.innerHTML = '<img src="' + val + '" alt="Xem trước" onerror="this.src=\'https://via.placeholder.com/150?text=Lỗi+Ảnh\'">';
            } else {
                previewBox.innerHTML = '<i class="fa-regular fa-image fs-2"></i>';
            }
        });
    }

    const quickSearch = document.getElementById('quickSearch');
    if (quickSearch) {
        quickSearch.addEventListener('input', function () {
            const term = this.value.toLowerCase().trim();
            const rows = document.querySelectorAll('#prodTable tbody tr');
            let hasMatch = false;
            rows.forEach(r => {
                const nameEl = r.querySelector('.prod-name');
                if (nameEl) {
                    const match = nameEl.textContent.toLowerCase().includes(term);
                    r.style.display = match ? '' : 'none';
                    if (match) hasMatch = true;
                }
            });
            document.getElementById('noMatch').style.display = (term && !hasMatch) ? 'block' : 'none';
        });
    }

    class OptionsBuilder {
        constructor(containerId, badgeId, prefix) {
            this.container = document.getElementById(containerId);
            this.badge = document.getElementById(badgeId);
            this.prefix = prefix;
            this.groups = {};
        }

        loadData(optionsList) {
            this.groups = {};
            if (Array.isArray(optionsList)) {
                optionsList.forEach(opt => {
                    const g = (opt.groupName || '').trim();
                    if (!g) return;
                    if (!this.groups[g]) this.groups[g] = [];
                    this.groups[g].push({
                        name: (opt.name || '').trim(),
                        priceDelta: parseFloat(opt.priceDelta) || 0,
                        defaultOption: Boolean(opt.defaultOption)
                    });
                });
            }
            this.ensureDefaults();
            this.render();
        }

        ensureDefaults() {
            Object.keys(this.groups).forEach(g => {
                const list = this.groups[g];
                if (list.length > 0) {
                    const hasDef = list.some(o => o.defaultOption);
                    if (!hasDef) list[0].defaultOption = true;
                }
            });
        }

        addGroup(groupName) {
            const g = (groupName || '').trim();
            if (!g) return;
            if (!this.groups[g]) {
                this.groups[g] = [];
                this.render();
            }
        }

        removeGroup(groupName) {
            if (confirm('Bạn có chắc chắn muốn xóa toàn bộ nhóm tùy chọn "' + groupName + '"?')) {
                delete this.groups[groupName];
                this.render();
            }
        }

        addOption(groupName, name, priceDelta, isDefault) {
            if (!this.groups[groupName]) this.groups[groupName] = [];
            const isFirst = this.groups[groupName].length === 0;
            this.groups[groupName].push({
                name: (name || '').trim(),
                priceDelta: parseFloat(priceDelta) || 0,
                defaultOption: isDefault !== undefined ? isDefault : isFirst
            });
            this.ensureDefaults();
            this.render();
        }

        removeOption(groupName, index) {
            if (this.groups[groupName] && this.groups[groupName][index] !== undefined) {
                const wasDefault = this.groups[groupName][index].defaultOption;
                this.groups[groupName].splice(index, 1);
                if (wasDefault && this.groups[groupName].length > 0) {
                    this.groups[groupName][0].defaultOption = true;
                }
                this.render();
            }
        }

        setDefault(groupName, index) {
            if (this.groups[groupName]) {
                this.groups[groupName].forEach((opt, idx) => {
                    opt.defaultOption = (idx === index);
                });
                this.render();
            }
        }

        updateName(groupName, index, val) {
            if (this.groups[groupName] && this.groups[groupName][index]) {
                this.groups[groupName][index].name = val;
                this.updateBadge();
            }
        }

        updatePrice(groupName, index, val) {
            if (this.groups[groupName] && this.groups[groupName][index]) {
                this.groups[groupName][index].priceDelta = parseFloat(val) || 0;
            }
        }

        addPreset(type) {
            if (type === 'color') {
                if (!this.groups['Màu sắc']) this.groups['Màu sắc'] = [];
                if (this.groups['Màu sắc'].length === 0) {
                    this.groups['Màu sắc'].push({ name: 'Màu Đen (Black)', priceDelta: 0, defaultOption: true });
                    this.groups['Màu sắc'].push({ name: 'Màu Trắng (White)', priceDelta: 0, defaultOption: false });
                }
            } else if (type === 'ram') {
                if (!this.groups['RAM']) this.groups['RAM'] = [];
                if (this.groups['RAM'].length === 0) {
                    this.groups['RAM'].push({ name: '16GB DDR5 5600MHz (Cơ bản)', priceDelta: 0, defaultOption: true });
                    this.groups['RAM'].push({ name: '32GB (2x16GB) DDR5 5600MHz', priceDelta: 1200000, defaultOption: false });
                }
            } else if (type === 'storage') {
                if (!this.groups['Ổ cứng SSD']) this.groups['Ổ cứng SSD'] = [];
                if (this.groups['Ổ cứng SSD'].length === 0) {
                    this.groups['Ổ cứng SSD'].push({ name: 'SSD 512GB M.2 NVMe (Cơ bản)', priceDelta: 0, defaultOption: true });
                    this.groups['Ổ cứng SSD'].push({ name: 'SSD 1TB M.2 NVMe Gen 4', priceDelta: 900000, defaultOption: false });
                }
            } else if (type === 'pc_full') {
                this.addPreset('color');
                this.addPreset('ram');
                this.addPreset('storage');
            }
            this.ensureDefaults();
            this.render();
        }

        getIcon(groupName) {
            const g = (groupName || '').toLowerCase();
            if (g.includes('màu') || g.includes('color')) return 'fa-palette text-danger';
            if (g.includes('ram') || g.includes('memory')) return 'fa-memory text-primary';
            if (g.includes('ổ cứng') || g.includes('ssd') || g.includes('hdd')) return 'fa-hard-drive text-success';
            if (g.includes('cpu') || g.includes('chip')) return 'fa-microchip text-warning';
            if (g.includes('vga') || g.includes('card')) return 'fa-gamepad text-info';
            return 'fa-sliders text-secondary';
        }

        getData() {
            const result = [];
            Object.keys(this.groups).forEach(g => {
                const list = this.groups[g];
                list.forEach(opt => {
                    const name = (opt.name || '').trim();
                    if (name) {
                        result.push({
                            groupName: g.trim(),
                            name: name,
                            priceDelta: parseFloat(opt.priceDelta) || 0,
                            defaultOption: Boolean(opt.defaultOption),
                            status: 'ACTIVE'
                        });
                    }
                });
            });
            return result;
        }

        updateBadge() {
            let total = 0;
            Object.keys(this.groups).forEach(g => {
                this.groups[g].forEach(opt => {
                    if ((opt.name || '').trim()) total++;
                });
            });
            if (this.badge) {
                this.badge.innerText = total + ' tùy chọn';
            }
        }

        render() {
            if (!this.container) return;
            const groupNames = Object.keys(this.groups);
            if (groupNames.length === 0) {
                this.container.innerHTML = '<div class="text-secondary small py-3 text-center fst-italic border rounded-2 bg-white mb-2">Chưa có tùy chọn nào. Bấm nút Mẫu nhanh ở trên hoặc Thêm nhóm bên dưới.</div>';
                this.updateBadge();
                return;
            }

            let html = '';
            groupNames.forEach((g, gIdx) => {
                const opts = this.groups[g];
                const icon = this.getIcon(g);
                const radioName = this.prefix + '_def_' + gIdx;

                html += '<div class="group-card shadow-sm">';

                html += '  <div class="group-header">';
                html += '    <div class="group-title"><i class="fa-solid ' + icon + '"></i> ' + this.escapeHtml(g) + ' <span class="badge bg-secondary-subtle text-secondary small" style="font-size:11px;">' + opts.length + ' mục</span></div>';
                html += '    <div class="d-flex gap-1">';
                html += '      <button type="button" class="btn btn-xs btn-outline-primary" onclick="' + this.prefix + '.addOption(\'' + this.escapeJs(g) + '\', \'\', 0, false)"><i class="fa-solid fa-plus me-1"></i>Thêm mục</button>';
                html += '      <button type="button" class="btn btn-xs btn-outline-danger" onclick="' + this.prefix + '.removeGroup(\'' + this.escapeJs(g) + '\')" title="Xóa nhóm này"><i class="fa-solid fa-trash"></i></button>';
                html += '    </div>';
                html += '  </div>';

                html += '  <div class="group-body">';
                if (opts.length > 0) {
                    html += '    <div class="d-grid opt-col-label" style="grid-template-columns: 28px 1fr 125px 32px; gap: 6px;">';
                    html += '      <span class="text-center" title="Mặc định / Cấu hình gốc">Gốc</span>';
                    html += '      <span>Tên lựa chọn / màu sắc</span>';
                    html += '      <span class="text-end">Chênh giá (+VNĐ)</span>';
                    html += '      <span></span>';
                    html += '    </div>';
                }

                opts.forEach((o, oIdx) => {
                    html += '    <div class="opt-item-row">';
                    html += '      <div class="opt-radio-wrap" title="Chọn làm mặc định / Cấu hình gốc">';
                    html += '        <input type="radio" name="' + radioName + '" ' + (o.defaultOption ? 'checked' : '') + ' onchange="' + this.prefix + '.setDefault(\'' + this.escapeJs(g) + '\', ' + oIdx + ')">';
                    html += '      </div>';
                    html += '      <div>';
                    html += '        <input type="text" class="form-control form-control-sm field shadow-none" value="' + this.escapeHtml(o.name) + '" placeholder="VD: Trắng, Core i7-14700F..." oninput="' + this.prefix + '.updateName(\'' + this.escapeJs(g) + '\', ' + oIdx + ', this.value)">';
                    html += '      </div>';
                    html += '      <div>';
                    html += '        <input type="number" step="1000" class="form-control form-control-sm field shadow-none text-end" value="' + o.priceDelta + '" placeholder="0" oninput="' + this.prefix + '.updatePrice(\'' + this.escapeJs(g) + '\', ' + oIdx + ', this.value)">';
                    html += '      </div>';
                    html += '      <div>';
                    html += '        <button type="button" class="btn btn-sm btn-outline-danger w-100 p-0 py-1" onclick="' + this.prefix + '.removeOption(\'' + this.escapeJs(g) + '\', ' + oIdx + ')" title="Xóa lựa chọn này"><i class="fa-solid fa-xmark"></i></button>';
                    html += '      </div>';
                    html += '    </div>';
                });

                if (opts.length === 0) {
                    html += '    <div class="text-muted small py-2 text-center fst-italic">Chưa có lựa chọn nào trong nhóm này. Bấm "+ Thêm mục" ở trên.</div>';
                }

                html += '  </div>';
                html += '</div>';
            });

            this.container.innerHTML = html;
            this.updateBadge();
        }

        escapeHtml(str) {
            return String(str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }
        escapeJs(str) {
            return String(str || '').replace(/\\/g, '\\\\').replace(/'/g, "\\'");
        }
    }

    const formBuilder = new OptionsBuilder('formGroupsContainer', 'formOptionBadge', 'formBuilder');

    try {
        const rawJson = document.getElementById('initialProductOptionsData').textContent.trim();
        if (rawJson && rawJson !== '[]') {
            const parsed = JSON.parse(rawJson);
            formBuilder.loadData(parsed);
        } else {
            formBuilder.loadData([]);
        }
    } catch (e) {
        console.error('Lỗi khởi tạo options cho form:', e);
        formBuilder.loadData([]);
    }

    const btnAddCustomGroupBtn = document.getElementById('btnAddCustomGroupBtn');
    const customGroupNameInput = document.getElementById('customGroupNameInput');
    if (btnAddCustomGroupBtn && customGroupNameInput) {
        btnAddCustomGroupBtn.addEventListener('click', function() {
            const val = customGroupNameInput.value.trim();
            if (val) {
                formBuilder.addGroup(val);
                customGroupNameInput.value = '';
            } else {
                customGroupNameInput.focus();
            }
        });
        customGroupNameInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                btnAddCustomGroupBtn.click();
            }
        });
    }

    // QUẢN LÝ BỘ SƯU TẬP NHIỀU ẢNH CHO SẢN PHẨM
    let galleryImages = [];
    try {
        const preloadedJson = '${productImagesJson}';
        if (preloadedJson && preloadedJson.trim() !== '' && preloadedJson !== 'null') {
            galleryImages = JSON.parse(preloadedJson);
        } else {
            const singleImg = '${product.image}';
            if (singleImg && singleImg.trim() !== '') {
                galleryImages = [singleImg.trim()];
            }
        }
    } catch (e) {
        console.error('Lỗi parse productImagesJson:', e);
        galleryImages = [];
    }

    const galleryListEl = document.getElementById('galleryCardsList');
    const imageCountBadge = document.getElementById('imageCountBadge');
    const newImageUrlInput = document.getElementById('newImageUrlInput');
    const btnAddSingleImageBtn = document.getElementById('btnAddSingleImageBtn');
    const btnToggleBatchBox = document.getElementById('btnToggleBatchBox');
    const batchBoxContainer = document.getElementById('batchBoxContainer');
    const batchUrlsInput = document.getElementById('batchUrlsInput');
    const btnCancelBatch = document.getElementById('btnCancelBatch');
    const btnApplyBatch = document.getElementById('btnApplyBatch');
    const hiddenImageUrl = document.getElementById('imageUrl');
    const hiddenImagesJson = document.getElementById('imagesJson');

    function renderGalleryCards() {
        if (!galleryListEl) return;
        galleryListEl.innerHTML = '';

        if (galleryImages.length === 0) {
            galleryListEl.innerHTML = '<div class="text-center p-3 text-muted bg-white border border-dashed rounded-2" style="font-size: 12.5px;">' +
                '<i class="fa-regular fa-image fs-3 d-block mb-1 text-secondary opacity-50"></i>' +
                'Chưa có ảnh nào. Hãy dán link ảnh vào ô trên rồi nhấn <strong>+ Thêm ảnh</strong>.' +
                '</div>';
            if (imageCountBadge) imageCountBadge.innerText = '0 ảnh';
            if (hiddenImageUrl) hiddenImageUrl.value = '';
            if (hiddenImagesJson) hiddenImagesJson.value = '[]';
            return;
        }

        if (imageCountBadge) imageCountBadge.innerText = galleryImages.length + ' ảnh';
        if (hiddenImageUrl) hiddenImageUrl.value = galleryImages[0] || '';
        if (hiddenImagesJson) hiddenImagesJson.value = JSON.stringify(galleryImages);

        galleryImages.forEach(function(url, idx) {
            const card = document.createElement('div');
            card.className = 'd-flex align-items-center gap-2 p-2 bg-white border rounded-2 shadow-xs';
            card.style.fontSize = '13px';

            const isMain = (idx === 0);

            card.innerHTML =
                '<div style="width: 52px; height: 52px; flex-shrink: 0; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; overflow: hidden; display: flex; align-items: center; justify-content: center;">' +
                '  <img src="' + url + '" style="max-width: 100%; max-height: 100%; object-fit: contain;" onerror="this.src=\'https://via.placeholder.com/60?text=Error\'">' +
                '</div>' +
                '<div class="flex-grow-1 overflow-hidden">' +
                '  <div class="d-flex align-items-center gap-1 mb-1">' +
                (isMain ? '    <span class="badge bg-danger" style="font-size: 10px;"><i class="fa-solid fa-star me-1"></i>Ảnh chính</span>'
                        : '    <span class="badge bg-secondary" style="font-size: 10px;">Ảnh phụ #' + (idx + 1) + '</span>') +
                '  </div>' +
                '  <div class="text-truncate text-secondary" style="font-size: 11.5px; font-family: monospace;" title="' + url + '">' + url + '</div>' +
                '</div>' +
                '<div class="d-flex gap-1 flex-shrink-0">' +
                (!isMain ? '  <button type="button" class="btn btn-xs btn-outline-warning" title="Đặt làm ảnh chính" onclick="setAsMainImage(' + idx + ')"><i class="fa-regular fa-star"></i></button>' : '') +
                '  <button type="button" class="btn btn-xs btn-outline-danger" title="Xóa ảnh này" onclick="removeGalleryImage(' + idx + ')"><i class="fa-solid fa-trash-can"></i></button>' +
                '</div>';

            galleryListEl.appendChild(card);
        });
    }

    window.setAsMainImage = function(idx) {
        if (idx <= 0 || idx >= galleryImages.length) return;
        const chosen = galleryImages.splice(idx, 1)[0];
        galleryImages.unshift(chosen);
        renderGalleryCards();
    };

    window.removeGalleryImage = function(idx) {
        if (idx < 0 || idx >= galleryImages.length) return;
        galleryImages.splice(idx, 1);
        renderGalleryCards();
    };

    if (btnAddSingleImageBtn && newImageUrlInput) {
        btnAddSingleImageBtn.addEventListener('click', function() {
            const val = newImageUrlInput.value.trim();
            if (val) {
                if (!galleryImages.includes(val)) {
                    galleryImages.push(val);
                    renderGalleryCards();
                }
                newImageUrlInput.value = '';
            } else {
                newImageUrlInput.focus();
            }
        });
        newImageUrlInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                btnAddSingleImageBtn.click();
            }
        });
    }

    if (btnToggleBatchBox && batchBoxContainer) {
        btnToggleBatchBox.addEventListener('click', function() {
            batchBoxContainer.classList.toggle('d-none');
            if (!batchBoxContainer.classList.contains('d-none')) {
                batchUrlsInput.focus();
            }
        });
    }
    if (btnCancelBatch && batchBoxContainer) {
        btnCancelBatch.addEventListener('click', function() {
            batchBoxContainer.classList.add('d-none');
        });
    }
    if (btnApplyBatch && batchUrlsInput) {
        btnApplyBatch.addEventListener('click', function() {
            const lines = batchUrlsInput.value.split(/\r?\n/);
            lines.forEach(function(line) {
                const clean = line.trim();
                if (clean && !galleryImages.includes(clean)) {
                    galleryImages.push(clean);
                }
            });
            batchUrlsInput.value = '';
            batchBoxContainer.classList.add('d-none');
            renderGalleryCards();
        });
    }

    renderGalleryCards();

    const productForm = document.getElementById('productForm');
    if (productForm) {
        productForm.addEventListener('submit', function() {
            const data = formBuilder.getData();
            document.getElementById('upgradeOptionsJson').value = JSON.stringify(data);
            if (hiddenImagesJson) {
                hiddenImagesJson.value = JSON.stringify(galleryImages);
            }
            if (hiddenImageUrl) {
                hiddenImageUrl.value = galleryImages.length > 0 ? galleryImages[0] : '';
            }
        });
    }

    const modalBuilder = new OptionsBuilder('modalGroupsContainer', 'modalOptionsBadge', 'modalBuilder');
    let currentModalProductId = null;
    let quickModalInstance = null;

    function openQuickModal(productId, productName) {
        currentModalProductId = productId;
        document.getElementById('modalProdTitle').innerText = productName;
        document.getElementById('modalLoading').style.display = 'block';
        document.getElementById('modalContent').style.display = 'none';

        if (!quickModalInstance) {
            quickModalInstance = new bootstrap.Modal(document.getElementById('quickOptionsModal'));
        }
        quickModalInstance.show();

        fetch('${url}?action=get_options_ajax&productId=' + productId)
            .then(res => res.json())
            .then(data => {
                modalBuilder.loadData(data);
                document.getElementById('modalLoading').style.display = 'none';
                document.getElementById('modalContent').style.display = 'block';
            })
            .catch(err => {
                console.error(err);
                document.getElementById('modalLoading').innerHTML = '<div class="text-danger">Không thể tải dữ liệu tùy chọn. Vui lòng thử lại.</div>';
            });
    }

    const btnAddModalGroupBtn = document.getElementById('btnAddModalGroupBtn');
    const modalGroupNameInput = document.getElementById('modalGroupNameInput');
    if (btnAddModalGroupBtn && modalGroupNameInput) {
        btnAddModalGroupBtn.addEventListener('click', function() {
            const val = modalGroupNameInput.value.trim();
            if (val) {
                modalBuilder.addGroup(val);
                modalGroupNameInput.value = '';
            } else {
                modalGroupNameInput.focus();
            }
        });
        modalGroupNameInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                btnAddModalGroupBtn.click();
            }
        });
    }

    const btnSaveModalOptions = document.getElementById('btnSaveModalOptions');
    if (btnSaveModalOptions) {
        btnSaveModalOptions.addEventListener('click', function() {
            if (!currentModalProductId) return;
            const options = modalBuilder.getData();

            btnSaveModalOptions.disabled = true;
            btnSaveModalOptions.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Đang lưu...';

            const params = new URLSearchParams();
            params.append('action', 'quick_save_options');
            params.append('productId', currentModalProductId);
            params.append('optionsJson', JSON.stringify(options));

            fetch('${url}', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: params.toString()
            })
                .then(res => res.json())
                .then(res => {
                    btnSaveModalOptions.disabled = false;
                    btnSaveModalOptions.innerHTML = '<i class="fa-solid fa-floppy-disk me-1"></i>Lưu tùy chọn';
                    if (res.success) {

                        const badgeBtn = document.getElementById('opt-badge-' + currentModalProductId);
                        if (badgeBtn) {
                            if (options.length > 0) {
                                badgeBtn.className = 'btn btn-xs btn-outline-danger fw-semibold';
                                badgeBtn.innerHTML = '<i class="fa-solid fa-sliders me-1"></i>' + options.length + ' tùy chọn';
                            } else {
                                badgeBtn.className = 'btn btn-xs btn-ghost text-muted';
                                badgeBtn.innerHTML = '<i class="fa-solid fa-plus me-1"></i>Thiết lập';
                            }
                        }

                        const formId = document.querySelector('input[name="id"]');
                        if (formId && formId.value == currentModalProductId) {
                            formBuilder.loadData(options);
                        }

                        quickModalInstance.hide();
                        showDynamicAlert('Đã cập nhật ' + options.length + ' tùy chọn cho sản phẩm thành công!', 'success');
                    } else {
                        alert('Lỗi lưu tùy chọn: ' + (res.error || 'Vui lòng kiểm tra lại.'));
                    }
                })
                .catch(err => {
                    console.error(err);
                    btnSaveModalOptions.disabled = false;
                    btnSaveModalOptions.innerHTML = '<i class="fa-solid fa-floppy-disk me-1"></i>Lưu tùy chọn';
                    alert('Lỗi kết nối máy chủ khi lưu tùy chọn!');
                });
        });
    }

    function showDynamicAlert(msg, type) {
        const area = document.getElementById('dynamicAlertArea');
        if (!area) return;
        area.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible fade show d-flex align-items-center mb-4" role="alert">' +
            '<i class="fa-solid fa-circle-check fs-5 me-2"></i>' +
            '<div>' + msg + '</div>' +
            '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
            '</div>';
    }
</script>
</body>
</html>
