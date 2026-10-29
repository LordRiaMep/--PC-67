<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
    <style>
.kpi-card {
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }
        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        .kpi-icon {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }
        .filter-panel {
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 16px 20px;
            margin-bottom: 20px;
        }
        .avatar-circle {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ff416c, #ff4b2b);
            color: #fff;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 15px;
            flex-shrink: 0;
            text-transform: uppercase;
        }
        .avatar-circle.admin {
            background: linear-gradient(135deg, #11998e, #38ef7d);
        }
        .lock-reason-tooltip {
            max-width: 250px;
            font-size: 12px;
            color: #dc3545;
            background: #fff5f5;
            padding: 2px 6px;
            border-radius: 4px;
            border: 1px dashed #feb2b2;
            display: inline-block;
            margin-top: 3px;
        }
        .modal-user-header {
            background: linear-gradient(135deg, #BE0015, #E30019);
            color: #fff;
        }
        .stat-badge-box {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 12px;
            text-align: center;
        }
        .quick-reason-btn {
            font-size: 12px;
            padding: 4px 10px;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.2s;
        }
</style>
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="users"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <div>
            <h3 class="m-0 text-dark fw-bold">Quản lý Khách hàng</h3>
            <span class="text-secondary small">Xem toàn bộ thông tin tài khoản, thống kê mua sắm và quản lý khóa tài khoản</span>
        </div>
        <div class="d-flex align-items-center">
            <span class="me-3">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check fs-5 me-2"></i>
            <div>${successMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-triangle-exclamation fs-5 me-2"></i>
            <div>${errorMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="kpi-card">
                <div>
                    <span class="text-muted small fw-semibold">TỔNG TÀI KHOẢN</span>
                    <h3 class="m-0 fw-bold mt-1 text-dark">${userCounts.total != null ? userCounts.total : 0}</h3>
                </div>
                <div class="kpi-icon bg-primary-subtle text-primary">
                    <i class="fa-solid fa-users"></i>
                </div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="kpi-card">
                <div>
                    <span class="text-muted small fw-semibold">ĐANG HOẠT ĐỘNG</span>
                    <h3 class="m-0 fw-bold mt-1 text-success">${userCounts.active != null ? userCounts.active : 0}</h3>
                </div>
                <div class="kpi-icon bg-success-subtle text-success">
                    <i class="fa-solid fa-user-check"></i>
                </div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="kpi-card">
                <div>
                    <span class="text-muted small fw-semibold">ĐÃ BỊ KHÓA</span>
                    <h3 class="m-0 fw-bold mt-1 text-danger">${userCounts.locked != null ? userCounts.locked : 0}</h3>
                </div>
                <div class="kpi-icon bg-danger-subtle text-danger">
                    <i class="fa-solid fa-user-lock"></i>
                </div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="kpi-card">
                <div>
                    <span class="text-muted small fw-semibold">QUẢN TRỊ VIÊN</span>
                    <h3 class="m-0 fw-bold mt-1 text-info">${userCounts.admin != null ? userCounts.admin : 0}</h3>
                </div>
                <div class="kpi-icon bg-info-subtle text-info">
                    <i class="fa-solid fa-user-shield"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="filter-panel shadow-sm">
        <form action="${ctx}/admin/users" method="GET" class="row g-2 align-items-center">
            <div class="col-12 col-md-5">
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                    <input type="text" name="q" value="<c:out value='${searchKeyword}'/>" class="form-control border-start-0 shadow-none" placeholder="Tìm theo Họ tên, Email hoặc Số điện thoại...">
                </div>
            </div>
            <div class="col-6 col-md-3">
                <select name="status" class="form-select shadow-none">
                    <option value="ALL" ${filterStatus == 'ALL' ? 'selected' : ''}>-- Trạng thái: Tất cả --</option>
                    <option value="ACTIVE" ${filterStatus == 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
                    <option value="PENDING" ${filterStatus == 'PENDING' ? 'selected' : ''}>Chờ kích hoạt email</option>
                    <option value="LOCKED" ${filterStatus == 'LOCKED' ? 'selected' : ''}>Đã bị khóa</option>
                </select>
            </div>
            <div class="col-6 col-md-2">
                <select name="role" class="form-select shadow-none">
                    <option value="ALL" ${filterRole == 'ALL' ? 'selected' : ''}>-- Vai trò: Tất cả --</option>
                    <option value="CUSTOMER" ${filterRole == 'CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
                    <option value="ADMIN" ${filterRole == 'ADMIN' ? 'selected' : ''}>Quản trị viên</option>
                </select>
            </div>
            <div class="col-12 col-md-2 d-flex gap-2">
                <button type="submit" class="btn btn-primary flex-grow-1 shadow-none">
                    <i class="fa-solid fa-filter me-1"></i>Lọc
                </button>
                <c:if test="${not empty searchKeyword || filterStatus != 'ALL' || filterRole != 'ALL'}">
                    <a href="${ctx}/admin/users" class="btn btn-outline-secondary shadow-none" title="Xóa bộ lọc">
                        <i class="fa-solid fa-rotate-right"></i>
                    </a>
                </c:if>
            </div>
        </form>
    </div>

    <div class="panel overflow-hidden">
        <div class="panel-head">
            <h5><i class="fa-solid fa-users me-2"></i>Danh sách tài khoản (${totalUsersCount != null ? totalUsersCount : 0})</h5>
            <div class="text-secondary small">Trang ${currentPage} / ${totalPages > 0 ? totalPages : 1}</div>
        </div>
        <div class="table-responsive">
            <table class="table tbl align-middle mb-0" id="userTable">
                <thead>
                <tr>
                    <th style="width: 60px;">Mã</th>
                    <th>Khách hàng</th>
                    <th>Vai trò</th>
                    <th>Số điện thoại</th>
                    <th>Địa chỉ</th>
                    <th>Trạng thái</th>
                    <th>Ngày tạo</th>
                    <th class="text-end" style="width: 220px;">Hành động</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${users}" var="u">
                    <tr>
                        <td class="muted fw-bold">#${u.id}</td>
                        <td>
                            <div class="d-flex align-items-center gap-2">
                                <span class="avatar-circle ${u.role == 'ADMIN' ? 'admin' : ''}">
                                    ${fn:toUpperCase(fn:substring(u.fullName, 0, 1))}
                                </span>
                                <div>
                                    <div class="prod-name fw-semibold">${u.fullName}</div>
                                    <div class="muted small">${u.email}</div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${u.role == 'ADMIN'}"><span class="badge bg-danger"><i class="fa-solid fa-shield-halved me-1"></i>Quản trị viên</span></c:when>
                                <c:otherwise><span class="badge bg-secondary"><i class="fa-solid fa-user me-1"></i>Khách hàng</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${not empty u.phone ? u.phone : '<span class="text-muted small fst-italic">Chưa cập nhật</span>'}</td>
                        <td>
                            <div class="text-truncate" style="max-width: 220px;" title="${u.address}">
                                ${not empty u.address ? u.address : '<span class="text-muted small fst-italic">Chưa cập nhật</span>'}
                            </div>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${u.status == 'LOCKED'}">
                                    <div>
                                        <span class="badge bg-danger"><i class="fa-solid fa-lock me-1"></i>Đã khóa</span>
                                        <c:if test="${not empty u.lockReason}">
                                            <div class="lock-reason-tooltip text-truncate" title="${fn:escapeXml(u.lockReason)}">
                                                <i class="fa-solid fa-circle-exclamation me-1"></i>${u.lockReason}
                                            </div>
                                        </c:if>
                                    </div>
                                </c:when>
                                <c:when test="${u.status == 'PENDING'}">
                                    <span class="badge bg-warning text-dark"><i class="fa-solid fa-clock me-1"></i>Chờ kích hoạt</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-success"><i class="fa-solid fa-check me-1"></i>Hoạt động</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="muted small text-nowrap"><fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy"/></td>
                        <td class="text-end text-nowrap">

                            <button type="button" class="btn btn-sm btn-outline-primary"
                                    onclick="viewUserDetail(${u.id})"
                                    title="Xem tất cả thông tin tài khoản">
                                <i class="fa-solid fa-eye me-1"></i>Chi tiết
                            </button>

                            <c:choose>
                                <c:when test="${u.role == 'ADMIN'}">
                                    <span class="text-muted small fst-italic ms-1">Bảo vệ</span>
                                </c:when>
                                <c:when test="${u.status == 'LOCKED'}">
                                    <a href="${ctx}/admin/users?action=unlock&id=${u.id}&page=${currentPage}"
                                       onclick="return confirm('Bạn có chắc chắn muốn MỞ KHÓA tài khoản cho khách hàng [${fn:escapeXml(u.fullName)}]?');"
                                       class="btn btn-sm btn-outline-success ms-1"
                                       title="Mở khóa tài khoản">
                                        <i class="fa-solid fa-lock-open me-1"></i>Mở khóa
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="btn btn-sm btn-outline-danger ms-1"
                                            onclick="openLockModal(${u.id}, '${fn:escapeXml(u.fullName)}', '${fn:escapeXml(u.email)}')"
                                            title="Khóa tài khoản kèm lý do">
                                        <i class="fa-solid fa-lock me-1"></i>Khóa
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty users}">
                    <tr>
                        <td colspan="8" class="text-center muted py-5">
                            <i class="fa-solid fa-users-slash fs-1 d-block mb-2 text-secondary"></i>
                            Không tìm thấy tài khoản khách hàng nào phù hợp!
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <c:if test="${totalPages > 1}">
        <ul class="pagination justify-content-end mt-4 mb-0">
            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <a class="page-link shadow-none" href="?page=${currentPage - 1}&q=${fn:escapeXml(searchKeyword)}&status=${filterStatus}&role=${filterRole}">Trước</a>
            </li>
            <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                    <a class="page-link shadow-none" href="?page=${i}&q=${fn:escapeXml(searchKeyword)}&status=${filterStatus}&role=${filterRole}">${i}</a>
                </li>
            </c:forEach>
            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                <a class="page-link shadow-none" href="?page=${currentPage + 1}&q=${fn:escapeXml(searchKeyword)}&status=${filterStatus}&role=${filterRole}">Sau</a>
            </li>
        </ul>
    </c:if>
</main>

<div class="modal fade" id="userDetailModal" tabindex="-1" aria-labelledby="userDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header modal-user-header text-white">
                <div class="d-flex align-items-center gap-2">
                    <i class="fa-solid fa-id-card fs-4"></i>
                    <div>
                        <h5 class="modal-title m-0 fw-bold" id="userDetailModalLabel">Thông Tin Chi Tiết Tài Khoản</h5>
                        <span class="small opacity-75" id="modalUserSubtitle">Đang tải thông tin...</span>
                    </div>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4" id="modalUserBody">
                <div class="text-center py-5" id="modalUserLoading">
                    <div class="spinner-border text-danger" role="status"></div>
                    <div class="text-muted mt-2">Đang tải toàn bộ hồ sơ khách hàng...</div>
                </div>

                <div id="modalUserContent" style="display:none;">

                    <div id="modalLockAlert" class="alert alert-danger border-danger shadow-sm mb-4" style="display:none;">
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <i class="fa-solid fa-triangle-exclamation fs-4 text-danger"></i>
                            <h6 class="m-0 fw-bold text-danger">TÀI KHOẢN NÀY ĐANG BỊ KHÓA</h6>
                        </div>
                        <div class="bg-white p-3 rounded border border-danger-subtle text-dark mb-2">
                            <div class="small fw-bold text-danger mb-1"><i class="fa-solid fa-circle-info me-1"></i>Lý do khóa:</div>
                            <div class="fw-semibold text-break" id="modalLockReason">-</div>
                        </div>
                        <div class="row g-2 small text-muted">
                            <div class="col-sm-6">
                                <i class="fa-solid fa-clock me-1"></i>Thời gian khóa: <strong class="text-dark" id="modalLockedAt">-</strong>
                            </div>
                            <div class="col-sm-6">
                                <i class="fa-solid fa-user-shield me-1"></i>Người thực hiện khóa: <strong class="text-dark" id="modalLockedBy">-</strong>
                            </div>
                        </div>
                    </div>

                    <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">
                        <i class="fa-solid fa-user text-primary me-2"></i>Hồ sơ tài khoản
                    </h6>
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <div class="p-3 bg-light rounded border">
                                <div class="text-muted small">Họ và tên</div>
                                <div class="fw-bold fs-6 text-dark" id="modalFullName">-</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="p-3 bg-light rounded border">
                                <div class="text-muted small">Địa chỉ Email</div>
                                <div class="fw-bold fs-6 text-dark" id="modalEmail">-</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="p-3 bg-light rounded border">
                                <div class="text-muted small">Số điện thoại</div>
                                <div class="fw-bold text-dark" id="modalPhone">-</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="p-3 bg-light rounded border">
                                <div class="text-muted small">Vai trò & Trạng thái</div>
                                <div class="d-flex align-items-center gap-2 mt-1">
                                    <span id="modalRoleBadge" class="badge bg-secondary">-</span>
                                    <span id="modalStatusBadge" class="badge bg-success">-</span>
                                </div>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="p-3 bg-light rounded border">
                                <div class="text-muted small">Địa chỉ giao hàng mặc định</div>
                                <div class="fw-semibold text-dark text-break" id="modalAddress">-</div>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="small text-muted">
                                <i class="fa-solid fa-calendar-days me-1"></i>Ngày đăng ký tài khoản: <strong class="text-dark" id="modalCreatedAt">-</strong>
                            </div>
                        </div>
                    </div>

                    <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">
                        <i class="fa-solid fa-chart-line text-success me-2"></i>Thống kê mua sắm của khách
                    </h6>
                    <div class="row g-3 mb-4">
                        <div class="col-4">
                            <div class="stat-badge-box">
                                <div class="text-muted small">Tổng số đơn hàng</div>
                                <h4 class="fw-bold text-primary m-0 mt-1" id="modalTotalOrders">0</h4>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="stat-badge-box">
                                <div class="text-muted small">Đơn đang chờ xử lý</div>
                                <h4 class="fw-bold text-warning m-0 mt-1" id="modalPendingOrders">0</h4>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="stat-badge-box">
                                <div class="text-muted small">Tổng tiền đã chi</div>
                                <h4 class="fw-bold text-danger m-0 mt-1" id="modalSpentMoney">0 ₫</h4>
                            </div>
                        </div>
                    </div>

                    <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">
                        <i class="fa-solid fa-clock-rotate-left text-info me-2"></i>Đơn hàng gần đây
                    </h6>
                    <div class="table-responsive">
                        <table class="table table-sm table-bordered align-middle mb-0" id="modalOrdersTable">
                            <thead class="table-light">
                            <tr>
                                <th>Mã đơn</th>
                                <th>Ngày đặt</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái đơn</th>
                                <th>Thanh toán</th>
                                <th class="text-center">Xem</th>
                            </tr>
                            </thead>
                            <tbody id="modalOrdersBody">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="modal-footer bg-light" id="modalUserFooter">
                <button type="button" class="btn btn-secondary shadow-none" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="lockModal" tabindex="-1" aria-labelledby="lockModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <form action="${ctx}/admin/users" method="POST" id="lockForm">
                <input type="hidden" name="action" value="lock">
                <input type="hidden" name="id" id="lockUserId" value="">
                <input type="hidden" name="page" value="${currentPage}">

                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title fw-bold" id="lockModalLabel">
                        <i class="fa-solid fa-user-lock me-2"></i>Khóa tài khoản khách hàng
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="alert alert-warning small d-flex align-items-center mb-3">
                        <i class="fa-solid fa-triangle-exclamation fs-5 me-2 text-warning"></i>
                        <div>
                            Tài khoản sau khi bị khóa sẽ <strong>ngay lập tức không thể đăng nhập</strong>. Khi khách cố gắng đăng nhập, hệ thống sẽ hiển thị lý do này kèm thông tin liên hệ hỗ trợ.
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small text-muted fw-semibold">Khách hàng bị khóa:</label>
                        <div class="p-2 bg-light rounded border fw-bold text-dark" id="lockUserDisplay">-</div>
                    </div>

                    <div class="mb-2">
                        <label class="form-label small text-muted fw-semibold d-block">Gợi ý lý do nhanh (bấm để chọn):</label>
                        <div class="d-flex flex-wrap gap-1 mb-2">
                            <span class="badge bg-light text-dark border quick-reason-btn" onclick="selectQuickReason('Bom hàng / Không nhận hàng nhiều lần')">
                                <i class="fa-solid fa-plus me-1"></i>Bom hàng nhiều lần
                            </span>
                            <span class="badge bg-light text-dark border quick-reason-btn" onclick="selectQuickReason('Gian lận đơn hàng / Khuyến mãi')">
                                <i class="fa-solid fa-plus me-1"></i>Gian lận khuyến mãi
                            </span>
                            <span class="badge bg-light text-dark border quick-reason-btn" onclick="selectQuickReason('Spam hoặc vi phạm quy định dịch vụ')">
                                <i class="fa-solid fa-plus me-1"></i>Vi phạm chính sách
                            </span>
                            <span class="badge bg-light text-dark border quick-reason-btn" onclick="selectQuickReason('Nghi vấn tài khoản ảo / không an toàn')">
                                <i class="fa-solid fa-plus me-1"></i>Tài khoản ảo
                            </span>
                            <span class="badge bg-light text-dark border quick-reason-btn" onclick="selectQuickReason('Khách hàng yêu cầu tạm khóa tài khoản')">
                                <i class="fa-solid fa-plus me-1"></i>Theo yêu cầu khách
                            </span>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold text-dark">
                            Lý do khóa chi tiết <span class="text-danger">*</span>
                        </label>
                        <textarea name="reason" id="lockReasonInput" class="form-control shadow-none" rows="3" required
                                  placeholder="Nhập lý do chi tiết (Lý do này sẽ hiển thị trực tiếp cho khách hàng khi họ đăng nhập)..."></textarea>
                        <div class="form-text small">Ví dụ: Vi phạm chính sách giao hàng nhiều lần do không nhận hàng, vui lòng liên hệ hotline để xác minh.</div>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary shadow-none" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-danger fw-bold shadow-none">
                        <i class="fa-solid fa-lock me-1"></i>Xác nhận Khóa
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js">

</script>
<script>
var ctx = '${ctx}';
    var userDetailModal = new bootstrap.Modal(document.getElementById('userDetailModal'));
    var lockModal = new bootstrap.Modal(document.getElementById('lockModal'));

    function formatMoney(amount) {
        if (!amount) return '0 ₫';
        return Number(amount).toLocaleString('vi-VN') + ' ₫';
    }

    function viewUserDetail(userId) {
        document.getElementById('modalUserLoading').style.display = 'block';
        document.getElementById('modalUserContent').style.display = 'none';
        document.getElementById('modalUserSubtitle').innerText = 'Mã tài khoản: #' + userId;

        userDetailModal.show();

        fetch(ctx + '/admin/users?action=detail&id=' + userId + '&format=json', {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (!data.success) {
                alert(data.message || 'Không thể tải thông tin khách hàng!');
                userDetailModal.hide();
                return;
            }

            var u = data.user;
            var stats = data.stats;
            var orders = data.orders;

            document.getElementById('modalUserSubtitle').innerText = 'Mã tài khoản: #' + u.id + ' | Đăng ký: ' + (u.createdAt || 'N/A');
            document.getElementById('modalFullName').innerText = u.fullName || 'Chưa cập nhật';
            document.getElementById('modalEmail').innerText = u.email || 'Chưa cập nhật';
            document.getElementById('modalPhone').innerText = u.phone || 'Chưa cập nhật';
            document.getElementById('modalAddress').innerText = u.address || 'Chưa cập nhật địa chỉ';
            document.getElementById('modalCreatedAt').innerText = u.createdAt || 'Chưa cập nhật';

            var roleBadge = document.getElementById('modalRoleBadge');
            if (u.role === 'ADMIN') {
                roleBadge.className = 'badge bg-danger';
                roleBadge.innerText = 'Quản trị viên';
            } else {
                roleBadge.className = 'badge bg-secondary';
                roleBadge.innerText = 'Khách hàng';
            }

            var statusBadge = document.getElementById('modalStatusBadge');
            var lockAlert = document.getElementById('modalLockAlert');

            if (u.status === 'LOCKED') {
                statusBadge.className = 'badge bg-danger';
                statusBadge.innerHTML = '<i class="fa-solid fa-lock me-1"></i>Đã bị khóa';

                lockAlert.style.display = 'block';
                document.getElementById('modalLockReason').innerText = u.lockReason || 'Vi phạm chính sách của hệ thống.';
                document.getElementById('modalLockedAt').innerText = u.lockedAt || 'Không rõ';
                document.getElementById('modalLockedBy').innerText = u.lockedBy || 'Admin';
            } else {
                statusBadge.className = 'badge bg-success';
                statusBadge.innerHTML = '<i class="fa-solid fa-check me-1"></i>Đang hoạt động';
                lockAlert.style.display = 'none';
            }

            document.getElementById('modalTotalOrders').innerText = stats.total || 0;
            document.getElementById('modalPendingOrders').innerText = stats.pending || 0;
            document.getElementById('modalSpentMoney').innerText = formatMoney(stats.spent || 0);

            var tbody = document.getElementById('modalOrdersBody');
            tbody.innerHTML = '';

            if (orders && orders.length > 0) {
                orders.forEach(function(o) {
                    var tr = document.createElement('tr');
                    tr.innerHTML = '<td><strong>#' + o.id + '</strong></td>'
                        + '<td><span class="small text-muted">' + (o.createdAt || '') + '</span></td>'
                        + '<td class="fw-bold text-danger">' + formatMoney(o.total) + '</td>'
                        + '<td><span class="badge bg-light text-dark border">' + (o.statusName || o.status) + '</span></td>'
                        + '<td><span class="small">' + (o.paymentMethod || '') + ' (' + (o.paymentStatus || 'UNPAID') + ')</span></td>'
                        + '<td class="text-center"><a href="' + ctx + '/order-detail?id=' + o.id + '" target="_blank" class="btn btn-xs btn-outline-info py-0 px-2 small"><i class="fa-solid fa-arrow-up-right-from-square"></i></a></td>';
                    tbody.appendChild(tr);
                });
            } else {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-3">Khách hàng chưa có đơn hàng nào.</td></tr>';
            }

            var footer = document.getElementById('modalUserFooter');
            footer.innerHTML = '<button type="button" class="btn btn-secondary shadow-none" data-bs-dismiss="modal">Đóng</button>';

            if (u.role !== 'ADMIN') {
                if (u.status === 'LOCKED') {
                    var unlockBtn = document.createElement('a');
                    unlockBtn.href = ctx + '/admin/users?action=unlock&id=' + u.id + '&page=${currentPage}';
                    unlockBtn.className = 'btn btn-success shadow-none';
                    unlockBtn.innerHTML = '<i class="fa-solid fa-lock-open me-1"></i>Mở khóa tài khoản';
                    unlockBtn.onclick = function() { return confirm('Mở khóa tài khoản cho ' + u.fullName + '?'); };
                    footer.appendChild(unlockBtn);
                } else {
                    var lockBtn = document.createElement('button');
                    lockBtn.type = 'button';
                    lockBtn.className = 'btn btn-danger shadow-none';
                    lockBtn.innerHTML = '<i class="fa-solid fa-lock me-1"></i>Khóa tài khoản này';
                    lockBtn.onclick = function() {
                        userDetailModal.hide();
                        openLockModal(u.id, u.fullName, u.email);
                    };
                    footer.appendChild(lockBtn);
                }
            }

            document.getElementById('modalUserLoading').style.display = 'none';
            document.getElementById('modalUserContent').style.display = 'block';
        })
        .catch(function(err) {
            console.error(err);
            alert('Lỗi kết nối khi tải dữ liệu người dùng!');
            userDetailModal.hide();
        });
    }

    function openLockModal(userId, fullName, email) {
        document.getElementById('lockUserId').value = userId;
        document.getElementById('lockUserDisplay').innerText = fullName + ' (' + email + ')';
        document.getElementById('lockReasonInput').value = '';
        lockModal.show();
    }

    function selectQuickReason(text) {
        document.getElementById('lockReasonInput').value = text;
    }
</script>
</body>
</html>
