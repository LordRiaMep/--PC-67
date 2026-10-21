<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- header.jsp đã mở <html><head><body> và có Bootstrap + Bootstrap Icons --%>
<jsp:include page="header.jsp" />

<div class="container my-4" style="max-width: 1140px;">

    <jsp:include page="profile_nav.jsp">
        <jsp:param name="active" value="info"/>
    </jsp:include>

    <c:if test="${not empty sessionScope.profileSuccess}">
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check-circle me-2"></i><c:out value="${sessionScope.profileSuccess}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="profileSuccess" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.profileError}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-exclamation-triangle me-2"></i><c:out value="${sessionScope.profileError}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="profileError" scope="session"/>
    </c:if>

    <!-- THỐNG KÊ: 3 ô nằm ngang -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="pf-card p-3 d-flex align-items-center gap-3 h-100">
                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width:52px;height:52px;background:#e8f0fe;color:#2563eb;">
                    <i class="bi bi-bag-check fs-4"></i>
                </div>
                <div>
                    <div class="fs-4 fw-bold lh-1">${stats.total}</div>
                    <div class="small text-muted mt-1">Tổng đơn hàng</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="pf-card p-3 d-flex align-items-center gap-3 h-100">
                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width:52px;height:52px;background:#fff4e0;color:#d97706;">
                    <i class="bi bi-hourglass-split fs-4"></i>
                </div>
                <div>
                    <div class="fs-4 fw-bold lh-1">${stats.pending}</div>
                    <div class="small text-muted mt-1">Đang chờ xử lý</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="pf-card p-3 d-flex align-items-center gap-3 h-100">
                <div class="rounded-3 d-flex align-items-center justify-content-center" style="width:52px;height:52px;background:#fdecee;color:#E30019;">
                    <i class="bi bi-wallet2 fs-4"></i>
                </div>
                <div>
                    <div class="fs-4 fw-bold lh-1"><fmt:formatNumber value="${stats.spent}" pattern="#,##0"/> ₫</div>
                    <div class="small text-muted mt-1">Đã chi tiêu</div>
                </div>
            </div>
        </div>
    </div>

    <!-- FORM THÔNG TIN: các ô nằm ngang -->
    <div class="pf-card p-4 mb-4">
        <div class="pf-card-title mb-4"><i class="bi bi-person-lines-fill"></i>Thông tin cá nhân</div>
        <form method="post" action="${ctx}/profile" accept-charset="UTF-8">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Họ và tên</label>
                    <input type="text" name="fullName" class="form-control" required maxlength="100"
                           value="<c:out value='${profile.fullName}'/>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Email <span class="text-muted fw-normal">(không thể thay đổi)</span></label>
                    <input type="email" class="form-control bg-light" value="<c:out value='${profile.email}'/>" disabled>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Số điện thoại <span class="text-muted fw-normal small">(VD: 0912345678 hoặc +84912345678)</span></label>
                    <input type="tel" name="phone" id="profilePhone" class="form-control" maxlength="12" placeholder="0912345678 hoặc +84912345678"
                           pattern="^(0|\+84)[35789][0-9]{8}$" title="Vui lòng nhập đúng định dạng số điện thoại Việt Nam (VD: 0912345678 hoặc +84912345678)"
                           value="<c:out value='${profile.phone}'/>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Địa chỉ nhận hàng</label>
                    <input type="text" name="address" class="form-control" maxlength="255" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành"
                           value="<c:out value='${profile.address}'/>">
                </div>
            </div>
            <div class="text-end mt-4">
                <button type="submit" class="btn btn-brand"><i class="bi bi-check2 me-1"></i>Lưu thay đổi</button>
            </div>
        </form>
    </div>

    <!-- ĐƠN HÀNG GẦN ĐÂY -->
    <div class="pf-card mb-4 overflow-hidden">
        <div class="d-flex justify-content-between align-items-center p-4 pb-3">
            <div class="pf-card-title"><i class="bi bi-receipt"></i>Đơn hàng gần đây</div>
            <a href="${ctx}/orders" class="small fw-semibold text-danger text-decoration-none">Xem tất cả <i class="bi bi-arrow-right"></i></a>
        </div>
        <c:choose>
            <c:when test="${empty recentOrders}">
                <div class="text-muted text-center pb-4">Bạn chưa có đơn hàng nào.</div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table align-middle mb-0">
                        <thead class="table-light">
                        <tr><th class="ps-4">Mã đơn</th><th>Ngày đặt</th><th class="text-end">Tổng tiền</th><th>Trạng thái</th><th class="pe-4"></th></tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${recentOrders}" var="o">
                            <tr>
                                <td class="ps-4"><a class="fw-bold text-dark text-decoration-none" href="${ctx}/order-detail?id=${o.id}">#${o.id}</a></td>
                                <td><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                <td class="text-end fw-semibold text-danger"><fmt:formatNumber value="${o.totalMoney}" pattern="#,##0"/> ₫</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${o.status == 'PENDING'}"><span class="badge rounded-pill px-3 py-2 text-white" style="background-color:#d97706;">Chờ xử lý</span></c:when>
                                        <c:when test="${o.status == 'CONFIRMED'}"><span class="badge rounded-pill px-3 py-2 text-white" style="background-color:#2563eb;">Đã xác nhận</span></c:when>
                                        <c:when test="${o.status == 'SHIPPING'}"><span class="badge rounded-pill px-3 py-2 text-white" style="background-color:#0284c7;">Đang giao hàng</span></c:when>
                                        <c:when test="${o.status == 'FINISH' || o.status == 'COMPLETED'}"><span class="badge rounded-pill px-3 py-2 text-white" style="background-color:#16a34a;">Hoàn thành</span></c:when>
                                        <c:when test="${o.status == 'CANCELLED' || o.status == 'CANCELED'}"><span class="badge rounded-pill px-3 py-2 text-white" style="background-color:#dc2626;">Đã hủy</span></c:when>
                                        <c:otherwise><span class="badge rounded-pill px-3 py-2 text-white" style="background-color:#6c757d;"><c:out value="${o.status}"/></span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end pe-4">
                                    <a href="${ctx}/order-detail?id=${o.id}" class="btn btn-outline-dark btn-sm">Chi tiết</a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="footer.jsp" />
