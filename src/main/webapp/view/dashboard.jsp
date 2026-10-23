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
    <script src="${ctx}/assets/js/chart.umd.min.js"></script>
    <style>
        .live-dot-pulse {
            display: inline-block;
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #22c55e;
            animation: pulseGlow 1.5s infinite;
        }
        @keyframes pulseGlow {
            0% { box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.7); }
            70% { box-shadow: 0 0 0 6px rgba(34, 197, 94, 0); }
            100% { box-shadow: 0 0 0 0 rgba(34, 197, 94, 0); }
        }
        .pulse-border-green {
            box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.4) !important;
            border-color: #22c55e !important;
            transition: all 0.3s ease;
        }
        .pulse-border-red {
            box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.4) !important;
            border-color: #ef4444 !important;
            transition: all 0.3s ease;
        }
        .chart-legend-box {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .chart-legend-box:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }

        /* Hiệu ứng nhảy số khi có đơn hàng mới hoặc hủy */
        @keyframes numberJumpEffect {
            0% { transform: scale(1); filter: brightness(1); }
            35% { transform: scale(1.12); filter: brightness(1.3); text-shadow: 0 0 10px rgba(34, 197, 94, 0.5); }
            100% { transform: scale(1); filter: brightness(1); }
        }
        .number-jumping {
            display: inline-block;
            animation: numberJumpEffect 0.7s ease;
        }

        /* Tùy chỉnh toàn bộ bong bóng chú thích (Tooltip) nền trắng đồng bộ với nền trang */
        .tooltip .tooltip-inner {
            background-color: #ffffff !important;
            color: #1e293b !important;
            border: 1px solid #cbd5e1 !important;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1) !important;
            padding: 8px 12px !important;
            font-size: 12px !important;
            font-weight: 500 !important;
            line-height: 1.4 !important;
            border-radius: 6px !important;
            max-width: 280px !important;
            text-align: left !important;
        }

        /* Mũi tên của Tooltip đồng bộ màu trắng */
        .tooltip.bs-tooltip-top .tooltip-arrow::before {
            border-top-color: #cbd5e1 !important;
        }
        .tooltip.bs-tooltip-bottom .tooltip-arrow::before {
            border-bottom-color: #cbd5e1 !important;
        }
        .tooltip.bs-tooltip-start .tooltip-arrow::before {
            border-left-color: #cbd5e1 !important;
        }
        .tooltip.bs-tooltip-end .tooltip-arrow::before {
            border-right-color: #cbd5e1 !important;
        }
    </style>
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

    <!-- Thống kê nhanh 4 chỉ số -->
    <div class="row g-4">
        <div class="col-md-6 col-xl-3">
            <div class="stat-card">
                <div class="icon-box bg-success bg-opacity-10 text-success"><i class="fa-solid fa-wallet"></i></div>
                <div>
                    <div class="muted small mb-1">Tổng doanh thu</div>
                    <div id="kpi-total-revenue" class="fs-4 text-dark fw-bold"><fmt:formatNumber value="${totalRevenue != null ? totalRevenue : 0}" pattern="#,##0" maxFractionDigits="0"/> đ</div>
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

    <!-- KHU VỰC BIỂU ĐỒ TRÒN LÃI KINH DOANH REALTIME & CHỈ SỐ LỢI NHUẬN -->
    <div class="row g-4 mt-1">
        <!-- CỘT BIỂU ĐỒ HÌNH TRÒN (CHART BY %) - CHUẨN MOCKUP YÊU CẦU -->
        <div class="col-xl-5 col-lg-6">
            <div class="panel h-100" id="profit-chart-panel" style="background:#fff; border-radius:12px; border:1px solid var(--border-color); box-shadow:0 2px 10px rgba(0,0,0,0.04); transition:all 0.35s ease;">
                <div class="panel-head d-flex align-items-center justify-content-between" style="border-bottom: 1px solid #f1f5f9; padding:18px 22px 12px 22px;">
                    <div>
                        <h5 class="fw-bold mb-0 text-dark" style="font-size: 1.15rem; letter-spacing: -0.2px;">
                            Char By %
                        </h5>
                        <span class="text-muted small" style="font-size: 12px;">Cơ cấu Lãi kinh doanh</span>
                    </div>
                    <div class="d-flex align-items-center gap-1">
                        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 py-1 px-2 d-flex align-items-center gap-1" style="font-size: 11px;">
                            <span class="live-dot-pulse"></span>
                            <span>Live WS</span>
                        </span>
                        <div class="dropdown">
                            <button class="btn btn-sm btn-ghost p-1 px-2" type="button" data-bs-toggle="dropdown" aria-expanded="false" title="Tùy chọn">
                                <i class="fa-solid fa-ellipsis-vertical"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 small">
                                <li><h6 class="dropdown-header">Chế độ phân bổ</h6></li>
                                <li><a class="dropdown-item active" href="javascript:void(0)" id="btnModeProfit" onclick="setChartMode('profit')"><i class="fa-solid fa-check me-2 text-danger"></i>Theo Lãi kinh doanh (Profit)</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" id="btnModeRevenue" onclick="setChartMode('revenue')"><i class="fa-solid fa-money-bill-wave me-2 text-primary"></i>Theo Doanh thu (Revenue)</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><h6 class="dropdown-header">Mô phỏng chuyển động</h6></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="simulateOrderEvent('buy')"><i class="fa-solid fa-cart-plus me-2 text-success"></i>Giả lập Khách Mua Hàng</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="simulateOrderEvent('cancel')"><i class="fa-solid fa-ban me-2 text-danger"></i>Giả lập Khách Hủy Đơn</a></li>
                            </ul>
                        </div>
                    </div>
                </div>

                <div class="panel-body p-4">
                    <!-- Khung đồ thị và chú thích: Bên trái Legend, Bên phải Doughnut Chart -->
                    <div class="row align-items-center">
                        <!-- Legend bên trái -->
                        <div class="col-5">
                            <div class="d-flex flex-column gap-3">
                                <!-- Products -->
                                <div class="chart-legend-box p-2 rounded" style="background:#f8fafc; border-left: 3px solid #38bdf8;">
                                    <div class="d-flex align-items-center gap-2 mb-1">
                                        <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background:#38bdf8; flex-shrink:0;"></span>
                                        <span class="fw-semibold text-secondary" style="font-size:13px;">Products</span>
                                        <i class="fa-solid fa-circle-question text-muted ms-auto" style="font-size:11px; cursor:help; opacity:0.65;" data-bs-toggle="tooltip" data-bs-placement="top" title="Lãi phần cứng = Doanh thu máy & linh kiện × 18%"></i>
                                    </div>
                                    <div class="ps-3">
                                        <div class="fs-5 fw-bold text-dark" id="chart-product-pct"><fmt:formatNumber value="${profitStats != null ? profitStats.productPercent : 83}" maxFractionDigits="0"/>%</div>
                                        <div class="text-muted small" id="chart-product-amt" style="font-size:11px;">
                                            <fmt:formatNumber value="${profitStats != null ? profitStats.productProfit : 0}" pattern="#,##0" maxFractionDigits="0"/> đ
                                        </div>
                                    </div>
                                </div>

                                <!-- Services -->
                                <div class="chart-legend-box p-2 rounded" style="background:#f8fafc; border-left: 3px solid #f43f5e;">
                                    <div class="d-flex align-items-center gap-2 mb-1">
                                        <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background:#f43f5e; flex-shrink:0;"></span>
                                        <span class="fw-semibold text-secondary" style="font-size:13px;">Services</span>
                                        <i class="fa-solid fa-circle-question text-muted ms-auto" style="font-size:11px; cursor:help; opacity:0.65;" data-bs-toggle="tooltip" data-bs-placement="top" title="Lãi dịch vụ = Doanh thu nâng cấp (RAM/VGA/AIO) & ship × 65%"></i>
                                    </div>
                                    <div class="ps-3">
                                        <div class="fs-5 fw-bold text-dark" id="chart-service-pct"><fmt:formatNumber value="${profitStats != null ? profitStats.servicePercent : 17}" maxFractionDigits="0"/>%</div>
                                        <div class="text-muted small" id="chart-service-amt" style="font-size:11px;">
                                            <fmt:formatNumber value="${profitStats != null ? profitStats.serviceProfit : 0}" pattern="#,##0" maxFractionDigits="0"/> đ
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Vòng tròn Doughnut Chart bên phải -->
                        <div class="col-7">
                            <div style="position: relative; width: 100%; max-width: 200px; margin: 0 auto; aspect-ratio: 1;">
                                <canvas id="profitDoughnutChart"></canvas>
                                <!-- Tâm rỗng của Doughnut hiển thị tổng lãi (đã bỏ phần phẩy) -->
                                <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; pointer-events: none; width: 85%;">
                                    <div class="text-uppercase text-muted" style="font-size: 10px; letter-spacing: 0.5px; font-weight: 600;" id="donut-center-label">Tổng lãi</div>
                                    <div class="fw-bold text-dark lh-1" style="font-size: 1.05rem;" id="donut-center-val">
                                        <fmt:formatNumber value="${profitStats != null ? profitStats.totalProfit : 0}" pattern="#,##0" maxFractionDigits="0"/>
                                    </div>
                                    <div class="text-muted" style="font-size: 10px;">VNĐ</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CỘT CHI TIẾT LÃI KINH DOANH & TÁC ĐỘNG ĐƠN HỦY -->
        <div class="col-xl-7 col-lg-6">
            <div class="panel h-100" style="background:#fff; border-radius:12px; border:1px solid var(--border-color); box-shadow:0 2px 10px rgba(0,0,0,0.04);">
                <div class="panel-head d-flex align-items-center justify-content-between" style="border-bottom: 1px solid #f1f5f9; padding:18px 22px 12px 22px;">
                    <h5 class="fw-bold mb-0 text-dark" style="font-size: 1.15rem;">
                        <i class="fa-solid fa-chart-line text-danger me-2"></i>Chỉ số Lợi nhuận & Đơn hủy
                    </h5>
                    <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 py-1 px-2" style="font-size: 11px;">
                        Biên lợi nhuận: <strong id="kpi-profit-margin">${profitStats != null ? profitStats.profitMargin : 20.5}%</strong>
                    </span>
                </div>

                <div class="panel-body p-4">
                    <div class="row g-3">
                        <!-- Tổng lãi kinh doanh (Đã loại bỏ số phẩy đằng sau) -->
                        <div class="col-sm-6">
                            <div class="p-3 rounded border h-100" style="background: #f0fdf4; border-color: #bbf7d0 !important;">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="text-success fw-semibold small d-flex align-items-center gap-1">
                                        <i class="fa-solid fa-hand-holding-dollar me-1"></i>Tổng Lãi Kinh Doanh
                                        <i class="fa-solid fa-circle-question text-success ms-1" style="font-size:12px; cursor:help; opacity:0.7;" data-bs-toggle="tooltip" data-bs-placement="top" title="Tổng Lãi = (Lãi Sản phẩm + Lãi Dịch vụ) - Tiền Voucher"></i>
                                    </span>
                                    <span class="badge bg-success text-white" style="font-size: 10px;">Thực tính</span>
                                </div>
                                <div class="fs-4 fw-bold text-success" id="detail-total-profit">
                                    <fmt:formatNumber value="${profitStats != null ? profitStats.totalProfit : 0}" pattern="#,##0" maxFractionDigits="0"/> đ
                                </div>
                                <div class="text-muted small" style="font-size: 11px;">Từ <span id="detail-active-count">${profitStats != null ? profitStats.activeOrdersCount : 0}</span> đơn hàng đang thực hiện</div>
                            </div>
                        </div>

                        <!-- Tác động đơn đã hủy (Đã loại bỏ số phẩy đằng sau) -->
                        <div class="col-sm-6">
                            <div class="p-3 rounded border h-100" style="background: #fef2f2; border-color: #fecaca !important;">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="text-danger fw-semibold small d-flex align-items-center gap-1">
                                        <i class="fa-solid fa-circle-xmark me-1"></i>Tác Động Do Đơn Hủy
                                        <i class="fa-solid fa-circle-question text-danger ms-1" style="font-size:12px; cursor:help; opacity:0.7;" data-bs-toggle="tooltip" data-bs-placement="top" title="Tổng tiền đơn hủy: Đã loại trừ khỏi doanh thu và lãi kinh doanh"></i>
                                    </span>
                                    <span class="badge bg-danger text-white" style="font-size: 10px;">Đã trừ lãi</span>
                                </div>
                                <div class="fs-4 fw-bold text-danger" id="detail-cancelled-amount">
                                    -<fmt:formatNumber value="${profitStats != null ? profitStats.cancelledAmount : 0}" pattern="#,##0" maxFractionDigits="0"/> đ
                                </div>
                                <div class="text-muted small" style="font-size: 11px;">Đã loại trừ <span id="detail-cancelled-count">${profitStats != null ? profitStats.cancelledOrdersCount : 0}</span> đơn hủy khỏi biểu đồ</div>
                            </div>
                        </div>

                        <!-- Lợi nhuận Products (Đã loại bỏ số phẩy đằng sau) -->
                        <div class="col-sm-6">
                            <div class="p-3 rounded border h-100" style="background: #f8fafc; border-color: #e2e8f0 !important;">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="fw-semibold small d-flex align-items-center gap-1" style="color: #0284c7;">
                                        <i class="fa-solid fa-microchip me-1"></i>Lãi từ Sản phẩm (Products)
                                        <i class="fa-solid fa-circle-question text-muted ms-1" style="font-size:12px; cursor:help; opacity:0.7;" data-bs-toggle="tooltip" data-bs-placement="top" title="Lãi Sản phẩm = Doanh thu phần cứng máy & linh kiện × 18%"></i>
                                    </span>
                                    <span class="badge text-white" style="background: #38bdf8; font-size: 10px;" id="badge-prod-pct"><fmt:formatNumber value="${profitStats != null ? profitStats.productPercent : 83}" maxFractionDigits="0"/>%</span>
                                </div>
                                <div class="fs-5 fw-bold text-dark" id="detail-prod-profit">
                                    <fmt:formatNumber value="${profitStats != null ? profitStats.productProfit : 0}" pattern="#,##0" maxFractionDigits="0"/> đ
                                </div>
                                <div class="text-muted small" style="font-size: 11px;">Doanh thu phần cứng: <span id="detail-prod-rev"><fmt:formatNumber value="${profitStats != null ? profitStats.productRevenue : 0}" pattern="#,##0" maxFractionDigits="0"/></span> đ</div>
                            </div>
                        </div>

                        <!-- Lợi nhuận Services (Đã loại bỏ số phẩy đằng sau) -->
                        <div class="col-sm-6">
                            <div class="p-3 rounded border h-100" style="background: #f8fafc; border-color: #e2e8f0 !important;">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="fw-semibold small d-flex align-items-center gap-1" style="color: #e11d48;">
                                        <i class="fa-solid fa-screwdriver-wrench me-1"></i>Lãi Dịch vụ & Nâng cấp (Services)
                                        <i class="fa-solid fa-circle-question text-muted ms-1" style="font-size:12px; cursor:help; opacity:0.7;" data-bs-toggle="tooltip" data-bs-placement="top" title="Lãi Dịch vụ = Doanh thu nâng cấp (RAM/VGA/AIO) & ship × 65%"></i>
                                    </span>
                                    <span class="badge text-white" style="background: #f43f5e; font-size: 10px;" id="badge-serv-pct"><fmt:formatNumber value="${profitStats != null ? profitStats.servicePercent : 17}" maxFractionDigits="0"/>%</span>
                                </div>
                                <div class="fs-5 fw-bold text-dark" id="detail-serv-profit">
                                    <fmt:formatNumber value="${profitStats != null ? profitStats.serviceProfit : 0}" pattern="#,##0" maxFractionDigits="0"/> đ
                                </div>
                                <div class="text-muted small" style="font-size: 11px;">Doanh thu dịch vụ & ship: <span id="detail-serv-rev"><fmt:formatNumber value="${profitStats != null ? profitStats.serviceRevenue : 0}" pattern="#,##0" maxFractionDigits="0"/></span> đ</div>
                            </div>
                        </div>
                    </div>

                    <!-- Thanh tiến trình so sánh trực quan -->
                    <div class="mt-3 pt-2">
                        <div class="d-flex justify-content-between small text-muted mb-1" style="font-size: 11px;">
                            <span><i class="fa-solid fa-circle text-info me-1"></i>Products: <strong id="bar-prod-pct"><fmt:formatNumber value="${profitStats != null ? profitStats.productPercent : 83}" maxFractionDigits="0"/>%</strong></span>
                            <span>Services: <strong id="bar-serv-pct"><fmt:formatNumber value="${profitStats != null ? profitStats.servicePercent : 17}" maxFractionDigits="0"/>%</strong> <i class="fa-solid fa-circle text-danger ms-1"></i></span>
                        </div>
                        <div class="progress" style="height: 8px; border-radius: 6px; overflow: hidden; background: #e2e8f0;">
                            <div id="bar-prod-progress" class="progress-bar" role="progressbar" style="width: ${profitStats != null ? profitStats.productPercent : 83}%; background-color: #38bdf8; transition: width 0.8s ease;" aria-valuenow="${profitStats != null ? profitStats.productPercent : 83}" aria-valuemin="0" aria-valuemax="100"></div>
                            <div id="bar-serv-progress" class="progress-bar" role="progressbar" style="width: ${profitStats != null ? profitStats.servicePercent : 17}%; background-color: #f43f5e; transition: width 0.8s ease;" aria-valuenow="${profitStats != null ? profitStats.servicePercent : 17}" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                    </div>
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
            <table class="table tbl align-middle" id="dashboard-recent-orders-table">
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
                    <tr id="recent-order-row-${o.id}">
                        <td class="fw-bold ps-4">#${o.id}</td>
                        <td>${o.receiverName}</td>
                        <td class="price"><fmt:formatNumber value="${o.totalMoney}" pattern="#,##0" maxFractionDigits="0"/> đ</td>
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
                    <tr id="empty-recent-orders-row"><td colspan="5" class="text-center muted py-5">
                        <i class="fa-solid fa-folder-open fs-1 d-block mb-2"></i>Chưa có đơn hàng nào.
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Script khởi tạo Doughnut Chart và cơ chế TỰ ĐỘNG NHẢY SỐ Realtime khi khách mua / hủy -->
<script>
    (function () {
        // Khởi tạo chú thích Tooltips tinh tế cho các icon (?)
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (el) { return new bootstrap.Tooltip(el); });

        var currentMode = 'profit'; // 'profit' hoặc 'revenue'
        var initialProdPct = Math.round(${profitStats != null ? profitStats.productPercent : 83});
        var initialServPct = Math.round(${profitStats != null ? profitStats.servicePercent : 17});

        // 1. Khởi tạo Chart.js Doughnut Chart
        var canvas = document.getElementById('profitDoughnutChart');
        if (!canvas) return;
        var ctx = canvas.getContext('2d');

        var profitChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Products', 'Services'],
                datasets: [{
                    data: [initialProdPct, initialServPct],
                    backgroundColor: ['#38bdf8', '#f43f5e'],
                    hoverBackgroundColor: ['#0284c7', '#e11d48'],
                    borderWidth: 2,
                    borderColor: '#ffffff',
                    hoverOffset: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                cutout: '68%',
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: '#ffffff',
                        titleColor: '#0f172a',
                        bodyColor: '#334155',
                        borderColor: '#cbd5e1',
                        borderWidth: 1,
                        titleFont: { size: 13, weight: 'bold' },
                        bodyFont: { size: 12 },
                        padding: 10,
                        cornerRadius: 8,
                        boxPadding: 4,
                        callbacks: {
                            label: function (context) {
                                var val = Math.round(context.parsed);
                                return ' ' + context.label + ': ' + val + '%';
                            }
                        }
                    }
                },
                animation: {
                    animateRotate: true,
                    animateScale: true,
                    duration: 1000,
                    easing: 'easeOutQuart'
                }
            }
        });

        // 2. Chuyển đổi giữa chế độ hiển thị Lãi kinh doanh (Profit) vs Doanh thu (Revenue)
        window.setChartMode = function (mode) {
            currentMode = mode;
            var btnP = document.getElementById('btnModeProfit');
            var btnR = document.getElementById('btnModeRevenue');
            var centerLabel = document.getElementById('donut-center-label');

            if (mode === 'revenue') {
                if (btnR) btnR.classList.add('active');
                if (btnP) btnP.classList.remove('active');
                if (centerLabel) centerLabel.textContent = 'Doanh thu';
            } else {
                if (btnP) btnP.classList.add('active');
                if (btnR) btnR.classList.remove('active');
                if (centerLabel) centerLabel.textContent = 'Tổng lãi';
            }
            refreshProfitData(null);
        };

        // 3. Hàm kích hoạt chuyển động biểu đồ và TỰ ĐỘNG NHẢY SỐ khi nhận sự kiện Realtime
        window.updateProfitChart = function (ev) {
            var type = ev ? ev.type : '';
            var data = ev ? (ev.data || {}) : {};

            var panel = document.getElementById('profit-chart-panel');
            var statusPill = document.getElementById('chart-realtime-pill');
            var statusMsg = document.getElementById('chart-realtime-msg');
            var updateTime = document.getElementById('chart-last-update-time');

            if (updateTime) updateTime.textContent = new Date().toLocaleTimeString('vi-VN');

            // Hiệu ứng ánh sáng viền khi khách mua hoặc hủy
            if (type === 'ORDER_CREATED') {
                if (panel) {
                    panel.classList.add('pulse-border-green');
                    setTimeout(function () { panel.classList.remove('pulse-border-green'); }, 3000);
                }
                if (statusPill && statusMsg) {
                    statusPill.className = 'alert alert-success border border-success py-1 px-3 mt-3 mb-0 d-flex align-items-center justify-content-between small';
                    statusMsg.innerHTML = '<i class="fa-solid fa-cart-shopping me-1 text-success"></i> <strong>Khách vừa đặt đơn #' + (data.orderId || '') + '!</strong> Đang tự động nhảy số...';
                }
                addRecentOrderRow(data);
            } else if (type === 'ORDER_CANCELLED') {
                if (panel) {
                    panel.classList.add('pulse-border-red');
                    setTimeout(function () { panel.classList.remove('pulse-border-red'); }, 3000);
                }
                if (statusPill && statusMsg) {
                    statusPill.className = 'alert alert-danger border border-danger py-1 px-3 mt-3 mb-0 d-flex align-items-center justify-content-between small';
                    statusMsg.innerHTML = '<i class="fa-solid fa-ban me-1 text-danger"></i> <strong>Đơn #' + (data.orderId || '') + ' bị hủy!</strong> Đang tự động giảm trừ số liệu...';
                }
                markRecentOrderCancelled(data.orderId);
            } else if (type === 'ORDER_STATUS_CHANGED') {
                if (statusPill && statusMsg) {
                    statusPill.className = 'alert alert-info border border-info py-1 px-3 mt-3 mb-0 d-flex align-items-center justify-content-between small';
                    statusMsg.innerHTML = '<i class="fa-solid fa-arrows-rotate me-1 text-info"></i> Đơn #' + (data.orderId || '') + ' cập nhật trạng thái (' + (data.statusDisplayName || '') + ')';
                }
            }

            // Gọi API lấy dữ liệu mới nhất và kích hoạt hiệu ứng nhảy số
            refreshProfitData(ev);
        };

        // 4. Lấy số liệu mới từ Servlet `/api/admin/profit-stats` và animate biểu đồ
        function refreshProfitData(ev) {
            fetch('${ctx}/api/admin/profit-stats', { cache: 'no-store' })
                .then(function (res) { return res.json(); })
                .then(function (stats) {
                    applyStatsToUI(stats);
                    setTimeout(function () {
                        var statusPill = document.getElementById('chart-realtime-pill');
                        var statusMsg = document.getElementById('chart-realtime-msg');
                        if (statusPill && statusMsg) {
                            statusPill.className = 'alert alert-light border py-1 px-3 mt-3 mb-0 d-flex align-items-center justify-content-between small text-muted';
                            statusMsg.innerHTML = '<i class="fa-solid fa-bolt text-warning me-1"></i> Tự động nhảy số và chuyển động khi có đơn mua / hủy';
                        }
                    }, 4000);
                })
                .catch(function (err) {
                    console.error('[ProfitChart] Lỗi fetch profit-stats:', err);
                });
        }

        // 5. Cập nhật DOM, BỎ HOÀN TOÀN PHẦN PHẨY THẬP PHÂN và KÍCH HOẠT HIỆU ỨNG NHẢY SỐ MƯỢT MÀ
        function applyStatsToUI(stats) {
            if (!stats) return;

            var prodPct = Math.round(currentMode === 'revenue' ? stats.productRevPercent : stats.productPercent);
            var servPct = Math.round(currentMode === 'revenue' ? stats.serviceRevPercent : stats.servicePercent);

            // 1. Chuyển động quay / co dãn biểu đồ hình tròn
            profitChart.data.datasets[0].data = [prodPct, servPct];
            profitChart.update();

            // 2. Tự động nhảy số trong Legend
            var elProdPct = document.getElementById('chart-product-pct');
            var elServPct = document.getElementById('chart-service-pct');
            var elProdAmt = document.getElementById('chart-product-amt');
            var elServAmt = document.getElementById('chart-service-amt');

            if (elProdPct) elProdPct.textContent = prodPct + '%';
            if (elServPct) elServPct.textContent = servPct + '%';

            var amtP = Math.round(currentMode === 'revenue' ? stats.productRevenue : stats.productProfit);
            var amtS = Math.round(currentMode === 'revenue' ? stats.serviceRevenue : stats.serviceProfit);

            if (elProdAmt) animateRollingNumber(elProdAmt, parseNumber(elProdAmt), amtP, ' đ');
            if (elServAmt) animateRollingNumber(elServAmt, parseNumber(elServAmt), amtS, ' đ');

            // 3. Tự động nhảy số ở tâm rỗng của hình tròn
            var centerVal = document.getElementById('donut-center-val');
            var targetCenter = Math.round(currentMode === 'revenue' ? stats.totalRevenue : stats.totalProfit);
            if (centerVal) animateRollingNumber(centerVal, parseNumber(centerVal), targetCenter, '');

            // 4. Tự động nhảy số ở bảng chỉ số bên phải (TẤT CẢ ĐỀU LÀ SỐ NGUYÊN KHÔNG CÓ DẤU PHẨY)
            var dtProfit = document.getElementById('detail-total-profit');
            var dtCancelAmt = document.getElementById('detail-cancelled-amount');
            var dtCancelCnt = document.getElementById('detail-cancelled-count');
            var dtActiveCnt = document.getElementById('detail-active-count');
            var dtProdProfit = document.getElementById('detail-prod-profit');
            var dtServProfit = document.getElementById('detail-serv-profit');
            var dtProdRev = document.getElementById('detail-prod-rev');
            var dtServRev = document.getElementById('detail-serv-rev');
            var kpiMargin = document.getElementById('kpi-profit-margin');
            var badgeProd = document.getElementById('badge-prod-pct');
            var badgeServ = document.getElementById('badge-serv-pct');

            if (dtProfit) animateRollingNumber(dtProfit, parseNumber(dtProfit), Math.round(stats.totalProfit), ' đ');
            if (dtCancelAmt) animateRollingNumber(dtCancelAmt, parseNumber(dtCancelAmt), -Math.round(stats.cancelledAmount), ' đ');
            if (dtCancelCnt) dtCancelCnt.textContent = stats.cancelledOrdersCount;
            if (dtActiveCnt) dtActiveCnt.textContent = stats.activeOrdersCount;
            if (dtProdProfit) animateRollingNumber(dtProdProfit, parseNumber(dtProdProfit), Math.round(stats.productProfit), ' đ');
            if (dtServProfit) animateRollingNumber(dtServProfit, parseNumber(dtServProfit), Math.round(stats.serviceProfit), ' đ');
            if (dtProdRev) animateRollingNumber(dtProdRev, parseNumber(dtProdRev), Math.round(stats.productRevenue), '');
            if (dtServRev) animateRollingNumber(dtServRev, parseNumber(dtServRev), Math.round(stats.serviceRevenue), '');

            if (kpiMargin) kpiMargin.textContent = stats.profitMargin + '%';
            if (badgeProd) badgeProd.textContent = prodPct + '%';
            if (badgeServ) badgeServ.textContent = servPct + '%';

            // 5. Cập nhật thanh so sánh bên dưới
            var barProdPct = document.getElementById('bar-prod-pct');
            var barServPct = document.getElementById('bar-serv-pct');
            var barProdProg = document.getElementById('bar-prod-progress');
            var barServProg = document.getElementById('bar-serv-progress');

            if (barProdPct) barProdPct.textContent = prodPct + '%';
            if (barServPct) barServPct.textContent = servPct + '%';
            if (barProdProg) {
                barProdProg.style.width = prodPct + '%';
                barProdProg.setAttribute('aria-valuenow', prodPct);
            }
            if (barServProg) {
                barServProg.style.width = servPct + '%';
                barServProg.setAttribute('aria-valuenow', servPct);
            }

            // 6. Nhảy số tổng doanh thu trên ô thống kê đầu trang
            var kpiRev = document.getElementById('kpi-total-revenue');
            if (kpiRev && stats.totalRevenue > 0) {
                animateRollingNumber(kpiRev, parseNumber(kpiRev), Math.round(stats.totalRevenue), ' đ');
            }
        }

        // HÀM HIỆU ỨNG NHẢY SỐ MƯỢT MÀ (ROLLING NUMBER COUNTER - 100% SỐ NGUYÊN)
        function animateRollingNumber(element, startVal, endVal, suffix) {
            if (!element) return;
            suffix = suffix || '';
            startVal = Math.round(Number(startVal) || 0);
            endVal = Math.round(Number(endVal) || 0);

            if (startVal === endVal) {
                element.textContent = (endVal < 0 ? '-' : '') + Math.abs(endVal).toLocaleString('vi-VN') + suffix;
                return;
            }

            element.classList.add('number-jumping');
            var duration = 750; // ms
            var startTime = null;

            function step(timestamp) {
                if (!startTime) startTime = timestamp;
                var progress = Math.min((timestamp - startTime) / duration, 1);
                // Easing mượt
                var ease = 1 - Math.pow(1 - progress, 3);
                var current = Math.round(startVal + (endVal - startVal) * ease);

                element.textContent = (current < 0 ? '-' : '') + Math.abs(current).toLocaleString('vi-VN') + suffix;

                if (progress < 1) {
                    window.requestAnimationFrame(step);
                } else {
                    element.textContent = (endVal < 0 ? '-' : '') + Math.abs(endVal).toLocaleString('vi-VN') + suffix;
                    setTimeout(function () { element.classList.remove('number-jumping'); }, 200);
                }
            }
            window.requestAnimationFrame(step);
        }

        function parseNumber(element) {
            if (!element) return 0;
            var isNegative = element.textContent.indexOf('-') !== -1;
            var numStr = element.textContent.replace(/[^\d]/g, '');
            var n = numStr ? parseInt(numStr, 10) : 0;
            return isNegative ? -n : n;
        }

        // 6. Mô phỏng khách mua / hủy phục vụ kiểm thử nhanh
        window.simulateOrderEvent = function (action) {
            fetch('${ctx}/api/admin/profit-stats', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=' + (action === 'buy' ? 'simulate_buy' : 'simulate_cancel')
            })
            .then(function(res) { return res.json(); })
            .then(function(res) {
                console.log('[Simulate]', res);
            })
            .catch(function (err) { console.error(err); });
        };

        // 7. Thêm dòng đơn hàng mới vào bảng Đơn gần đây
        function addRecentOrderRow(data) {
            var tbody = document.querySelector('#dashboard-recent-orders-table tbody');
            if (!tbody) return;
            var emptyRow = document.getElementById('empty-recent-orders-row');
            if (emptyRow) emptyRow.remove();

            var orderId = data.orderId;
            var moneyStr = Math.round(Number(data.totalMoney) || 0).toLocaleString('vi-VN') + ' đ';
            var receiver = data.receiverName || 'Khách hàng mới';

            var tr = document.createElement('tr');
            tr.id = 'recent-order-row-' + orderId;
            tr.className = 'table-success';
            tr.innerHTML = ''
                + '<td class="fw-bold ps-4"><span class="badge bg-danger me-1">MỚI</span>#' + orderId + '</td>'
                + '<td>' + escapeHtml(receiver) + '</td>'
                + '<td class="price">' + moneyStr + '</td>'
                + '<td><span class="badge bg-warning text-dark">Chờ xử lý</span></td>'
                + '<td class="text-end pe-4">'
                + '<a href="${ctx}/admin/orders?id=' + orderId + '" class="btn btn-sm btn-ghost">Chi tiết</a>'
                + '</td>';

            tbody.insertBefore(tr, tbody.firstChild);
            setTimeout(function () { tr.classList.remove('table-success'); }, 3000);
        }

        function markRecentOrderCancelled(orderId) {
            var tr = document.getElementById('recent-order-row-' + orderId);
            if (tr) {
                var badge = tr.querySelector('.badge');
                if (badge) {
                    badge.className = 'badge bg-danger';
                    badge.textContent = 'Đã hủy';
                }
                tr.classList.add('table-danger');
                setTimeout(function () { tr.classList.remove('table-danger'); }, 3000);
            }
        }

        function escapeHtml(text) {
            if (!text) return '';
            return text.replace(/[&<>"']/g, function (m) {
                return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' })[m];
            });
        }
    })();
</script>

</body>
</html>
