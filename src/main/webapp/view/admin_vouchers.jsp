<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="url" value="${ctx}/admin/vouchers" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Voucher Giảm Giá - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
    <style>
        .voucher-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fff0f0;
            color: #d32f2f;
            border: 1px dashed #d32f2f;
            padding: 4px 10px;
            border-radius: 6px;
            font-family: monospace;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        .voucher-badge .copy-btn {
            border: none;
            background: none;
            color: #999;
            cursor: pointer;
            padding: 0;
            font-size: 12px;
        }
        .voucher-badge .copy-btn:hover {
            color: #d32f2f;
        }
        .stat-card {
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 16px 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04);
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }
    </style>
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="vouchers"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <div>
            <h3 class="m-0 text-dark fw-bold"><i class="fa-solid fa-ticket text-danger me-2"></i>Quản lý Voucher &amp; Mã Giảm Giá</h3>
            <span class="text-secondary small">Tạo và cấu hình các chương trình ưu đãi, giảm giá trực tiếp cho khách mua máy và linh kiện</span>
        </div>
        <div class="d-flex align-items-center">
            <span class="me-3">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <!-- Thống kê nhanh -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icon bg-danger bg-opacity-10 text-danger">
                    <i class="fa-solid fa-ticket"></i>
                </div>
                <div>
                    <div class="text-secondary small fw-semibold">Tổng số Voucher</div>
                    <div class="fs-4 fw-bold text-dark">${countTotal}</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icon bg-success bg-opacity-10 text-success">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
                <div>
                    <div class="text-secondary small fw-semibold">Đang hoạt động &amp; Có thể dùng</div>
                    <div class="fs-4 fw-bold text-success">${countActive}</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icon bg-secondary bg-opacity-10 text-secondary">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                </div>
                <div>
                    <div class="text-secondary small fw-semibold">Đã hết hạn / Hết lượt dùng</div>
                    <div class="fs-4 fw-bold text-secondary">${countExpiredOrFull}</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Thông báo kết quả -->
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
        <!-- Form thêm / sửa Voucher -->
        <div class="col-xl-4 col-lg-5">
            <form action="${url}" method="post" class="panel sticky-panel" id="voucherForm">
                <div class="panel-head">
                    <h5>
                        <i class="fa-solid ${not empty voucher ? 'fa-pen-to-square' : 'fa-plus'} me-2"></i>
                        ${not empty voucher ? 'Sửa thông tin Voucher' : 'Tạo Voucher ưu đãi mới'}
                    </h5>
                    <c:if test="${not empty voucher}">
                        <span class="badge bg-danger">#${voucher.id}</span>
                    </c:if>
                </div>
                <div class="panel-body">
                    <input type="hidden" name="id" value="${voucher.id}">
                    <input type="hidden" name="page" value="${currentPage}">
                    <input type="hidden" name="action" value="${not empty voucher ? 'update' : 'insert'}">

                    <!-- Mã voucher -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <label class="field-label m-0">Mã Voucher <span class="text-danger">*</span></label>
                            <button type="button" class="btn btn-link btn-sm p-0 text-decoration-none text-danger small fw-semibold" id="btnGenCode">
                                <i class="fa-solid fa-wand-magic-sparkles me-1"></i>Tạo mã ngẫu nhiên
                            </button>
                        </div>
                        <input type="text" name="code" id="voucherCode" class="form-control field shadow-none text-uppercase fw-bold font-monospace"
                               value="${voucher.code}" placeholder="Ví dụ: SALE50K, GAMING10..." required maxlength="30">
                        <div class="form-text small text-muted">Tự động viết hoa, viết liền không dấu.</div>
                    </div>

                    <!-- Tên chương trình -->
                    <div class="mb-3">
                        <label class="field-label">Tên chương trình ưu đãi <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control field shadow-none"
                               value="${voucher.name}" placeholder="Ví dụ: Giảm 5% khi mua máy Gaming" required maxlength="255">
                    </div>

                    <!-- Loại giảm & Mức giảm -->
                    <div class="row g-2 mb-3">
                        <div class="col-sm-6">
                            <label class="field-label">Loại giảm giá <span class="text-danger">*</span></label>
                            <select name="discountType" id="discountTypeSelect" class="form-select field shadow-none" required>
                                <option value="PERCENT" ${voucher.discountType == 'PERCENT' || empty voucher ? 'selected' : ''}>Theo Phần trăm (%)</option>
                                <option value="FIXED" ${voucher.discountType == 'FIXED' ? 'selected' : ''}>Số tiền cố định (VNĐ)</option>
                            </select>
                        </div>
                        <div class="col-sm-6">
                            <label class="field-label" id="discountValueLabel">Mức giảm (%) <span class="text-danger">*</span></label>
                            <input type="number" step="any" name="discountValue" id="discountValueInput" class="form-control field shadow-none"
                                   value="${voucher.discountValue > 0 ? voucher.discountValue : ''}" placeholder="10" required min="1">
                        </div>
                    </div>

                    <!-- Giảm tối đa (Chỉ áp dụng khi chọn %) -->
                    <div class="mb-3" id="maxDiscountGroup">
                        <label class="field-label">Giảm tối đa (VNĐ)</label>
                        <input type="number" step="1000" name="maxDiscountAmount" class="form-control field shadow-none"
                               value="${voucher.maxDiscountAmount}" placeholder="Ví dụ: 1000000 (Để trống nếu không giới hạn)">
                        <div class="form-text small text-muted">Tránh giảm quá sâu cho đơn hàng giá trị cao.</div>
                    </div>

                    <!-- Giá trị đơn hàng tối thiểu -->
                    <div class="mb-3">
                        <label class="field-label">Giá trị sản phẩm/đơn tối thiểu (VNĐ)</label>
                        <input type="number" step="1000" name="minOrderAmount" class="form-control field shadow-none"
                               value="${voucher.minOrderAmount}" placeholder="0 (Áp dụng mọi đơn)">
                        <div class="form-text small text-muted">Sản phẩm hoặc đơn hàng phải có giá trị từ mức này mới được dùng mã.</div>
                    </div>

                    <!-- Số lượng mã phát hành -->
                    <div class="mb-3">
                        <label class="field-label">Số lượng lượt dùng tối đa <span class="text-danger">*</span></label>
                        <input type="number" name="usageLimit" class="form-control field shadow-none"
                               value="${voucher.usageLimit > 0 ? voucher.usageLimit : 100}" required min="1">
                        <div class="form-text small text-muted">Khi khách dùng hết số lượt này, mã sẽ tự động hết hạn.</div>
                    </div>

                    <!-- Thời hạn hiệu lực -->
                    <div class="row g-2 mb-3">
                        <div class="col-sm-6">
                            <label class="field-label">Bắt đầu từ ngày</label>
                            <input type="date" name="startDate" id="startDateInput" class="form-control field shadow-none"
                                   value="${voucher.startDateFormatted}">
                        </div>
                        <div class="col-sm-6">
                            <label class="field-label">Hết hạn vào ngày</label>
                            <input type="date" name="endDate" id="endDateInput" class="form-control field shadow-none"
                                   value="${voucher.endDateFormatted}">
                        </div>
                    </div>

                    <!-- Trạng thái -->
                    <div class="mb-4">
                        <label class="field-label">Trạng thái phát hành</label>
                        <select name="status" class="form-select field shadow-none">
                            <option value="ACTIVE" ${voucher.status == 'ACTIVE' || empty voucher ? 'selected' : ''}>Kích hoạt (ACTIVE - Khách thấy và dùng được)</option>
                            <option value="INACTIVE" ${voucher.status == 'INACTIVE' ? 'selected' : ''}>Tạm dừng (INACTIVE - Ẩn khỏi hệ thống)</option>
                        </select>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-neon px-4 flex-grow-1">
                            <i class="fa-solid fa-floppy-disk me-1"></i> Lưu thông tin Voucher
                        </button>
                        <a href="${url}?page=${currentPage}" class="btn btn-ghost px-3" title="Làm mới form">Hủy</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Danh sách Voucher -->
        <div class="col-xl-8 col-lg-7">
            <div class="panel overflow-hidden">
                <div class="panel-head flex-wrap gap-2">
                    <h5 class="m-0"><i class="fa-solid fa-list me-2"></i>Danh sách Voucher (${totalItems})</h5>

                    <!-- Tìm kiếm -->
                    <form action="${url}" method="get" class="d-flex gap-2 ms-auto">
                        <input type="text" name="keyword" class="form-control form-control-sm field"
                               placeholder="Tìm mã hoặc tên..." value="${keyword}" style="width: 200px;">
                        <button type="submit" class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-magnifying-glass"></i></button>
                        <c:if test="${not empty keyword}">
                            <a href="${url}" class="btn btn-sm btn-ghost" title="Xóa bộ lọc"><i class="fa-solid fa-xmark"></i></a>
                        </c:if>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="table tbl align-middle">
                        <thead>
                        <tr>
                            <th>Mã Voucher</th>
                            <th>Thông tin ưu đãi</th>
                            <th class="text-center">Mức giảm</th>
                            <th class="text-center" style="width: 140px;">Lượt dùng</th>
                            <th class="text-center">Hiệu lực</th>
                            <th class="text-center">Trạng thái</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listVouchers}" var="v">
                            <tr class="${voucher != null && voucher.id == v.id ? 'row-edit' : ''}">
                                <td>
                                    <div class="voucher-badge">
                                        <i class="fa-solid fa-tag"></i>
                                        <span>${v.code}</span>
                                        <button type="button" class="copy-btn" onclick="copyCode('${v.code}')" title="Sao chép mã">
                                            <i class="fa-regular fa-copy"></i>
                                        </button>
                                    </div>
                                    <div class="small text-muted mt-1">ID: #${v.id}</div>
                                </td>
                                <td>
                                    <div class="prod-name mb-1">${v.name}</div>
                                    <div class="small muted">
                                        <i class="fa-solid fa-cart-shopping me-1 text-danger"></i>${v.formattedMinOrder}
                                        <c:if test="${v.percent && v.maxDiscountAmount > 0}">
                                            &bull; Tối đa <fmt:formatNumber value="${v.maxDiscountAmount}" pattern="#,##0"/> đ
                                        </c:if>
                                    </div>
                                </td>
                                <td class="text-center text-nowrap">
                                    <c:choose>
                                        <c:when test="${v.percent}">
                                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger fs-6 px-2 py-1">
                                                -${v.discountValue}%
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-primary bg-opacity-10 text-primary border border-primary fs-6 px-2 py-1">
                                                -<fmt:formatNumber value="${v.discountValue}" pattern="#,##0"/> đ
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <div class="small fw-semibold mb-1">${v.usedCount} / ${v.usageLimit}</div>
                                    <c:set var="usedPercent" value="${(v.usedCount * 100) / (v.usageLimit > 0 ? v.usageLimit : 1)}" />
                                    <div class="progress" style="height: 6px;" title="Đã dùng ${v.usedCount}/${v.usageLimit}">
                                        <div class="progress-bar ${usedPercent >= 90 ? 'bg-danger' : (usedPercent >= 60 ? 'bg-warning' : 'bg-success')}"
                                             role="progressbar" style="width: ${usedPercent}%;"></div>
                                    </div>
                                    <span class="small muted" style="font-size: 11px;">Còn ${v.remainingUsage} lượt</span>
                                </td>
                                <td class="text-center small text-nowrap">
                                    <div class="fw-semibold text-dark">${v.startDateDisplay}</div>
                                    <div class="muted">đến ${v.endDateDisplay}</div>
                                    <c:choose>
                                        <c:when test="${v.expired}">
                                            <span class="badge bg-secondary">Hết hạn</span>
                                        </c:when>
                                        <c:when test="${v.notStarted}">
                                            <span class="badge bg-info text-dark">Sắp tới</span>
                                        </c:when>
                                        <c:when test="${v.usageExceeded}">
                                            <span class="badge bg-danger">Hết lượt</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-success">Đang chạy</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center text-nowrap">
                                    <a href="${url}?action=toggle&id=${v.id}&page=${currentPage}"
                                       class="btn btn-sm ${v.active ? 'btn-success' : 'btn-secondary'} rounded-pill px-3 py-1 text-decoration-none"
                                       title="Bấm để ${v.active ? 'Tạm ngưng' : 'Kích hoạt'} voucher">
                                        <i class="fa-solid ${v.active ? 'fa-toggle-on' : 'fa-toggle-off'} me-1"></i>
                                        ${v.active ? 'Bật' : 'Tắt'}
                                    </a>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a href="${url}?action=edit&id=${v.id}&page=${currentPage}" class="btn act btn-ghost" title="Chỉnh sửa voucher">
                                        <i class="fa-solid fa-pen text-primary"></i>
                                    </a>
                                    <a href="${url}?action=delete&id=${v.id}&page=${currentPage}"
                                       class="btn act btn-ghost text-danger" title="Xóa voucher"
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa voucher ${v.code}? Nếu voucher đã có khách dùng trong đơn hàng, hệ thống sẽ tự động tắt kích hoạt để bảo toàn dữ liệu.');">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty listVouchers}">
                            <tr>
                                <td colspan="7" class="text-center py-5 muted">
                                    <i class="fa-solid fa-ticket fs-1 text-secondary opacity-50 d-block mb-3"></i>
                                    Chưa có mã voucher nào phù hợp. Bạn có thể tạo mã mới ở khung bên trái.
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Phân trang -->
                <c:if test="${totalPages > 1}">
                    <div class="p-3 border-top d-flex justify-content-center">
                        <nav>
                            <ul class="pagination pagination-sm m-0">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${url}?page=${currentPage - 1}&keyword=${keyword}">Trước</a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <li class="page-item ${currentPage == p ? 'active' : ''}">
                                        <a class="page-link" href="${url}?page=${p}&keyword=${keyword}">${p}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${url}?page=${currentPage + 1}&keyword=${keyword}">Sau</a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 1. Chuyển đổi nhãn và ẩn hiện khung "Giảm tối đa" theo loại giảm giá
    const typeSelect = document.getElementById('discountTypeSelect');
    const valueLabel = document.getElementById('discountValueLabel');
    const valueInput = document.getElementById('discountValueInput');
    const maxGroup = document.getElementById('maxDiscountGroup');

    function updateDiscountTypeUI() {
        if (typeSelect.value === 'FIXED') {
            valueLabel.innerHTML = 'Số tiền giảm (VNĐ) <span class="text-danger">*</span>';
            valueInput.placeholder = 'Ví dụ: 100000, 200000...';
            valueInput.max = '';
            maxGroup.style.display = 'none';
        } else {
            valueLabel.innerHTML = 'Mức giảm (%) <span class="text-danger">*</span>';
            valueInput.placeholder = 'Ví dụ: 5, 10, 15...';
            valueInput.max = '100';
            maxGroup.style.display = 'block';
        }
    }
    typeSelect.addEventListener('change', updateDiscountTypeUI);
    updateDiscountTypeUI();

    // 2. Tự động sinh mã nhanh
    document.getElementById('btnGenCode').addEventListener('click', function() {
        const prefixes = ['DEAL', 'SALE', 'VIP', 'GAMING', 'HOT', 'PC'];
        const p = prefixes[Math.floor(Math.random() * prefixes.length)];
        const nums = Math.floor(10 + Math.random() * 90);
        document.getElementById('voucherCode').value = p + nums;
    });

    // 3. Khởi tạo ngày mặc định nếu thêm mới
    const startInput = document.getElementById('startDateInput');
    const endInput = document.getElementById('endDateInput');
    if (!startInput.value) {
        const today = new Date().toISOString().split('T')[0];
        startInput.value = today;
    }
    if (!endInput.value) {
        const nextMonth = new Date();
        nextMonth.setDate(nextMonth.getDate() + 30);
        endInput.value = nextMonth.toISOString().split('T')[0];
    }

    // 4. Copy mã voucher
    function copyCode(code) {
        navigator.clipboard.writeText(code).then(function() {
            alert('Đã sao chép mã voucher: ' + code);
        });
    }
</script>
</body>
</html>
