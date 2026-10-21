<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng quan - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="dashboard"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <div>
            <h3 class="m-0 text-dark fw-bold">Tổng quan</h3>
            <span class="text-secondary small">Thống kê hoạt động kinh doanh và tình trạng đơn hàng</span>
        </div>
        <div class="d-flex align-items-center gap-2">
            <a href="${ctx}/admin/dashboard" class="btn btn-ghost btn-sm" title="Cập nhật số liệu mới nhất"><i class="fa-solid fa-arrows-rotate me-1"></i> Làm mới</a>
            <span class="ms-2 me-2 text-muted">|</span>
            <span class="me-2">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName != null ? sessionScope.USER_LOGIN.fullName : 'Admin'}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <!-- Thống kê -->
    <div class="row g-4">
        <div class="col-md-6 col-xl-3">
            <div class="stat-card">
                <div class="icon-box bg-success bg-opacity-10 text-success"><i class="fa-solid fa-wallet"></i></div>
                <div>
                    <div class="muted small mb-1">Tổng doanh thu</div>
                    <div id="kpi-total-revenue" class="fs-4 text-dark fw-bold"><fmt:formatNumber value="${totalRevenue != null ? totalRevenue : 0}" pattern="#,##0"/> đ</div>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-xl-3">
            <div class="stat-card">
                <div class="icon-box bg-warning bg-opacity-10 text-warning"><i class="fa-solid fa-box-open"></i></div>
                <div>
                    <div class="muted small mb-1">Tổng đơn hàng</div>
                    <div id="kpi-total-orders" class="fs-4 text-dark fw-bold">${totalOrders != null ? totalOrders : 0} đơn</div>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-xl-3">
            <div class="stat-card">
                <div class="icon-box bg-danger bg-opacity-10 text-danger"><i class="fa-solid fa-computer"></i></div>
                <div>
                    <div class="muted small mb-1">Tổng sản phẩm</div>
                    <div class="fs-4 text-dark fw-bold">${totalProducts != null ? totalProducts : 0} sản phẩm</div>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-xl-3">
            <div class="stat-card">
                <div class="icon-box bg-primary bg-opacity-10 text-primary"><i class="fa-solid fa-users"></i></div>
                <div>
                    <div class="muted small mb-1">Tổng khách hàng</div>
                    <div class="fs-4 text-dark fw-bold">${totalUsers != null ? totalUsers : 0} người</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Đơn hàng gần đây -->
    <div class="panel overflow-hidden mt-4">
        <div class="panel-head">
            <h5><i class="fa-solid fa-clock-rotate-left me-2"></i>Đơn hàng gần đây</h5>
            <a href="${ctx}/admin/orders" class="btn btn-ghost btn-sm">Xem tất cả đơn hàng</a>
        </div>
        <div class="table-responsive">
            <table class="table tbl align-middle">
                <thead>
                <tr>
                    <th class="ps-4">Mã đơn</th>
                    <th>Khách hàng</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                    <th class="text-end pe-4">Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${recentOrders}" var="o">
                    <tr>
                        <td class="fw-bold ps-4">#${o.id}</td>
                        <td>${o.receiverName}</td>
                        <td class="price"><fmt:formatNumber value="${o.totalMoney}" pattern="#,##0"/> đ</td>
                        <td>
                            <c:choose>
                                <c:when test="${o.status == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ xử lý</span></c:when>
                                <c:when test="${o.status == 'CONFIRMED'}"><span class="badge bg-primary">Đã xác nhận</span></c:when>
                                <c:when test="${o.status == 'SHIPPING'}"><span class="badge bg-info text-dark">Đang giao</span></c:when>
                                <c:when test="${o.status == 'FINISH' || o.status == 'COMPLETED'}"><span class="badge bg-success">Hoàn thành</span></c:when>
                                <c:otherwise><span class="badge bg-danger">Đã hủy</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end pe-4">
                            <a href="${ctx}/admin/orders?id=${o.id}" class="btn btn-sm btn-ghost">Chi tiết</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty recentOrders}">
                    <tr><td colspan="5" class="text-center muted py-5">
                        <i class="fa-solid fa-folder-open fs-1 d-block mb-2"></i>Chưa có đơn hàng nào.
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
