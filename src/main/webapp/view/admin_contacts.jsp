<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="url" value="${ctx}/admin/contacts" />
<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String _action = request.getParameter("action");
        dao.ContactDao _daoPost = new dao.ContactDao();
        if ("update".equalsIgnoreCase(_action)) {
            try {
                int _id = Integer.parseInt(request.getParameter("id"));
                String _st = request.getParameter("status");
                String _note = request.getParameter("adminNote");
                _daoPost.updateStatusAndNote(_id, _st, _note);
                util.realtime.RealtimeHub.broadcastContactUpdated(_id, _st, _note);
                session.setAttribute("successMessage", "Đã cập nhật trạng thái & ghi chú phản hồi cho yêu cầu #" + _id + " thành công!");
            } catch (Exception ignored) {}
        } else if ("delete".equalsIgnoreCase(_action)) {
            try {
                int _id = Integer.parseInt(request.getParameter("id"));
                _daoPost.delete(_id);
                session.setAttribute("successMessage", "Đã xóa yêu cầu liên hệ #" + _id + "!");
            } catch (Exception ignored) {}
        }
        response.sendRedirect(request.getContextPath() + "/admin/contacts");
        return;
    }

    if (request.getAttribute("contactList") == null) {
        dao.ContactDao _dao = new dao.ContactDao();
        String _status = request.getParameter("status");
        if (_status == null || _status.trim().isEmpty()) _status = "ALL";
        String _kw = request.getParameter("keyword");
        if (_kw == null) _kw = "";

        request.setAttribute("contactList", _dao.getAll(_status, _kw));
        request.setAttribute("currentStatus", _status);
        request.setAttribute("keyword", _kw);
        request.setAttribute("totalContacts", _dao.countTotal());
        request.setAttribute("pendingCount", _dao.countByStatus("Chưa xử lý"));
        request.setAttribute("contactingCount", _dao.countByStatus("Đang liên hệ"));
        request.setAttribute("completedCount", _dao.countByStatus("Đã hoàn thành"));
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Yêu cầu Liên hệ - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
    <style>
.stat-card {
            background: #fff;
            border-radius: 10px;
            padding: 20px;
            border: 1px solid var(--border-color);
            box-shadow: 0 2px 8px rgba(0,0,0,.04);
            display: flex;
            align-items: center;
            gap: 16px;
            transition: transform 0.2s;
        }
        .stat-card:hover { transform: translateY(-3px); }
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            flex-shrink: 0;
        }
        .badge-status {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .badge-pending { background-color: #ffe5e7; color: #dc3545; border: 1px solid #f5c2c7; }
        .badge-processing { background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .badge-completed { background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
        .contact-msg {
            max-width: 280px;
            white-space: normal;
            font-size: 13px;
            line-height: 1.5;
            color: #495057;
        }
</style>
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="contacts"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <div>
            <h3 class="m-0 text-dark fw-bold"><i class="fa-solid fa-headset text-danger me-2"></i>Quản lý Yêu cầu Liên hệ</h3>
            <span class="text-secondary small">Tiếp nhận thông tin tư vấn và ghi chú phản hồi cho khách hàng</span>
        </div>
        <div class="d-flex align-items-center">
            <span class="me-3">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-circle-check fs-5 me-2"></i>
            <div>${sessionScope.successMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-triangle-exclamation fs-5 me-2"></i>
            <div>${sessionScope.errorMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="stat-card">
                <div class="stat-icon bg-primary-subtle text-primary"><i class="fa-solid fa-inbox"></i></div>
                <div>
                    <span class="text-muted small">Tổng yêu cầu</span>
                    <h4 class="fw-bold mb-0 text-dark">${totalContacts}</h4>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="stat-card">
                <div class="stat-icon bg-danger-subtle text-danger"><i class="fa-solid fa-clock-rotate-left"></i></div>
                <div>
                    <span class="text-muted small">Chưa xử lý</span>
                    <h4 id="pending-count-badge" class="fw-bold mb-0 text-danger">${pendingCount}</h4>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="stat-card">
                <div class="stat-icon bg-warning-subtle text-warning"><i class="fa-solid fa-phone-volume"></i></div>
                <div>
                    <span class="text-muted small">Đang liên hệ</span>
                    <h4 class="fw-bold mb-0 text-warning">${contactingCount}</h4>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="stat-card">
                <div class="stat-icon bg-success-subtle text-success"><i class="fa-solid fa-circle-check"></i></div>
                <div>
                    <span class="text-muted small">Đã hoàn thành</span>
                    <h4 class="fw-bold mb-0 text-success">${completedCount}</h4>
                </div>
            </div>
        </div>
    </div>

    <div class="panel">
        <div class="panel-head">
            <div class="d-flex align-items-center gap-2 flex-wrap">

                <a href="${url}?status=ALL&keyword=${keyword}" class="btn btn-sm ${currentStatus == 'ALL' ? 'btn-neon' : 'btn-ghost'}">Tất cả (${totalContacts})</a>
                <a href="${url}?status=Chưa xử lý&keyword=${keyword}" class="btn btn-sm ${currentStatus == 'Chưa xử lý' ? 'btn-danger' : 'btn-ghost'}">Chưa xử lý (${pendingCount})</a>
                <a href="${url}?status=Đang liên hệ&keyword=${keyword}" class="btn btn-sm ${currentStatus == 'Đang liên hệ' ? 'btn-warning text-dark' : 'btn-ghost'}">Đang liên hệ (${contactingCount})</a>
                <a href="${url}?status=Đã hoàn thành&keyword=${keyword}" class="btn btn-sm ${currentStatus == 'Đã hoàn thành' ? 'btn-success' : 'btn-ghost'}">Đã hoàn thành (${completedCount})</a>
            </div>

            <form action="${url}" method="get" class="d-flex gap-2">
                <input type="hidden" name="status" value="${currentStatus}">
                <input type="text" name="keyword" class="form-control form-control-sm field" placeholder="Tìm tên, SĐT, email..." value="${keyword}" style="width: 220px;">
                <button type="submit" class="btn btn-sm btn-ghost"><i class="fa-solid fa-magnifying-glass"></i></button>
            </form>
        </div>

        <div class="panel-body p-0">
            <div class="table-responsive">
                <table class="table tbl align-middle mb-0">
                    <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th style="width: 220px;">Khách hàng</th>
                        <th style="width: 170px;">Chủ đề tư vấn</th>
                        <th>Nội dung yêu cầu</th>
                        <th style="width: 130px;">Trạng thái</th>
                        <th style="width: 220px;">Ghi chú phản hồi</th>
                        <th style="width: 110px;" class="text-center">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty contactList}">
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="fa-regular fa-folder-open fs-1 mb-2 d-block text-secondary"></i>
                                    Không có yêu cầu liên hệ nào phù hợp!
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${contactList}" var="c">
                                <tr id="contact-row-${c.id}" data-contact-id="${c.id}">
                                    <td>
                                        <strong class="text-muted">#${c.id}</strong>
                                        <div class="text-muted" style="font-size: 11px;"><fmt:formatDate value="${c.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark">${c.fullName}</div>
                                        <div class="d-flex align-items-center gap-2 mt-1">
                                            <a href="tel:${c.phone}" class="btn btn-sm btn-outline-danger py-0 px-2" style="font-size: 11px;" title="Gọi điện">
                                                <i class="fa-solid fa-phone me-1"></i>${c.phone}
                                            </a>
                                            <a href="https://zalo.me/${c.phone}" target="_blank" class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: 11px;" title="Nhắn Zalo">
                                                <i class="fa-solid fa-comment-dots me-1"></i>Zalo
                                            </a>
                                        </div>
                                        <c:if test="${not empty c.email}">
                                            <small class="text-muted d-block mt-1"><i class="fa-regular fa-envelope me-1"></i>${c.email}</small>
                                        </c:if>
                                    </td>
                                    <td>
                                        <span class="chip text-dark"><i class="fa-solid fa-tag text-danger me-1"></i>${c.topic}</span>
                                    </td>
                                    <td>
                                        <div class="contact-msg">${c.message}</div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.status == 'Đang liên hệ'}">
                                                <span class="badge-status badge-processing"><i class="fa-solid fa-spinner fa-spin"></i> Đang liên hệ</span>
                                            </c:when>
                                            <c:when test="${c.status == 'Đã hoàn thành'}">
                                                <span class="badge-status badge-completed"><i class="fa-solid fa-check"></i> Đã hoàn thành</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status badge-pending"><i class="fa-solid fa-circle-exclamation"></i> Chưa xử lý</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty c.adminNote}">
                                                <div class="small text-success fw-semibold"><i class="fa-solid fa-note-sticky me-1"></i>${c.adminNote}</div>
                                                <small class="text-muted" style="font-size: 10px;">Cập nhật: <fmt:formatDate value="${c.updatedAt}" pattern="dd/MM HH:mm"/></small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted small fst-italic">Chưa có ghi chú</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <button type="button" class="btn btn-sm btn-neon me-1" title="Xử lý & Phản hồi"
                                                onclick="openReplyModal(${c.id}, '${c.fullName}', '${c.phone}', '${c.status}', `${c.adminNote != null ? c.adminNote : ''}`)">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-outline-danger" title="Xóa"
                                                onclick="confirmDelete(${c.id})">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<div class="modal fade" id="replyModal" tabindex="-1" aria-labelledby="replyModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <form action="${url}" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" id="modalContactId">

                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title fw-bold" id="replyModalLabel"><i class="fa-solid fa-headset me-2"></i>Xử lý Yêu cầu Liên hệ</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3 p-3 bg-light rounded border">
                        <div class="row">
                            <div class="col-6">
                                <small class="text-muted d-block">Khách hàng:</small>
                                <strong id="modalCustomerName" class="text-dark"></strong>
                            </div>
                            <div class="col-6">
                                <small class="text-muted d-block">Số điện thoại:</small>
                                <strong id="modalCustomerPhone" class="text-danger"></strong>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="field-label">Trạng thái xử lý <span class="text-danger">*</span></label>
                        <select name="status" id="modalStatus" class="form-select field py-2">
                            <option value="Chưa xử lý">Chưa xử lý</option>
                            <option value="Đang liên hệ">Đang liên hệ</option>
                            <option value="Đã hoàn thành">Đã hoàn thành</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="field-label">Ghi chú xử lý / Nội dung phản hồi của Admin</label>
                        <textarea name="adminNote" id="modalAdminNote" class="form-control field" rows="4" placeholder="VD: Đã gọi điện lúc 10h15 tư vấn cấu hình i5 13400F + RTX 4060, khách hẹn qua showroom xem máy..."></textarea>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-ghost" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-neon px-4"><i class="fa-solid fa-floppy-disk me-1"></i> Lưu cập nhật</button>
                </div>
            </form>
        </div>
    </div>
</div>

<form id="deleteForm" action="${url}" method="post" style="display:none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" id="deleteContactId">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js">

</script>
<script>
var replyModalObj = null;

    function openReplyModal(id, name, phone, status, note) {
        document.getElementById('modalContactId').value = id;
        document.getElementById('modalCustomerName').textContent = name;
        document.getElementById('modalCustomerPhone').textContent = phone;
        document.getElementById('modalStatus').value = status;
        document.getElementById('modalAdminNote').value = note;

        if (!replyModalObj) {
            replyModalObj = new bootstrap.Modal(document.getElementById('replyModal'));
        }
        replyModalObj.show();
    }

    function confirmDelete(id) {
        if (confirm('Bạn có chắc chắn muốn xóa yêu cầu liên hệ #' + id + ' này không?')) {
            document.getElementById('deleteContactId').value = id;
            document.getElementById('deleteForm').submit();
        }
    }
</script>
</body>
</html>
