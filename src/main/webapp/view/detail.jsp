<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<link rel="stylesheet" href="${ctx}/assets/css/style.css?v=3">

<!-- CSS Tùy chỉnh cho phần UPGRADE, PROMO, WARRANTY và BUTTONS -->
<style>
    .upgrade-box, .promo-box { border: 1px solid #e0e0e0; border-radius: 4px; margin-bottom: 20px; overflow: hidden; }
    .upgrade-header, .promo-header { background: #f8f9fa; padding: 10px 15px; font-weight: bold; color: #d9534f; border-bottom: 1px solid #e0e0e0; display: flex; align-items: center; gap: 8px; font-size: 15px;}
    .upgrade-body, .promo-body { padding: 15px; background: #fff; }
    .upgrade-row { display: flex; align-items: center; margin-bottom: 15px; }
    .upgrade-row:last-child { margin-bottom: 0; }
    .upgrade-label { width: 100px; font-weight: 500; font-size: 14px; color: #333; }
    .upgrade-options { display: flex; flex-wrap: wrap; gap: 10px; flex: 1;}
    .opt-btn { position: relative; border: 1px solid #ccc; background: #fff; padding: 6px 12px; border-radius: 4px; font-size: 13px; cursor: pointer; user-select: none; color: #555; transition: all 0.2s;}
    .opt-btn:hover { border-color: #999; }
    .opt-btn.active { border-color: #007bff; color: #007bff; }
    .opt-btn.active::after {
        content: '\f00c'; font-family: "Font Awesome 6 Free"; font-weight: 900;
        position: absolute; bottom: -1px; right: -1px; background: #007bff; color: white;
        font-size: 9px; padding: 2px 3px; border-top-left-radius: 4px; border-bottom-right-radius: 3px; line-height: 1;
    }
    .opt-btn .opt-price { display: block; font-size: 11px; color: #dc3545; font-weight: 600; }
    .promo-body ul { list-style: none; padding: 0; margin: 0; }
    .promo-body li { display: flex; align-items: flex-start; gap: 10px; margin-bottom: 10px; color: #dc3545; font-weight: 500; font-size: 14px;}
    .promo-body li .num { background: #dc3545; color: #fff; width: 22px; height: 22px; display: inline-flex; justify-content: center; align-items: center; border-radius: 50%; font-size: 12px; flex-shrink: 0;}

    /* Style cho khung Bảo hành đặt dưới khuyến mãi */
    .warranty-badge {
        background-color: #ffeb3b;
        color: #1a237e;
        font-weight: bold;
        font-size: 15px;
        border-radius: 0.375rem;
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        padding: 12px 15px;
        cursor: default;
        width: 100%;
    }

    /* Style cho khung Voucher Ưu đãi */
    .voucher-box { border: 1px solid #ffccd0; border-radius: 6px; margin-bottom: 20px; overflow: hidden; background: #fffcfc; }
    .voucher-header { background: #fff2f2; padding: 10px 15px; font-weight: bold; color: #d9534f; border-bottom: 1px solid #ffccd0; display: flex; align-items: center; justify-content: space-between; font-size: 15px;}
    .voucher-body { padding: 14px; }
    .voucher-card {
        border: 1px dashed #dca5a5;
        border-radius: 6px;
        padding: 10px 14px;
        margin-bottom: 8px;
        background: #fff;
        display: flex;
        align-items: center;
        justify-content: space-between;
        transition: all 0.2s ease;
    }
    .voucher-card:hover {
        border-color: #dc3545;
        box-shadow: 0 2px 8px rgba(220,53,69,0.12);
    }
    .voucher-card.selected-voucher {
        border-color: #dc3545;
        border-style: solid;
        background: #fff5f5;
        box-shadow: 0 0 0 1.5px #dc3545;
    }
    .voucher-card.ineligible {
        opacity: 0.6;
        background: #fbfbfb;
    }
    .voucher-tag {
        font-family: monospace;
        font-weight: 700;
        font-size: 13.5px;
        letter-spacing: 0.5px;
        background: #dc3545;
        color: #fff;
        padding: 2px 8px;
        border-radius: 4px;
        display: inline-block;
    }
    .voucher-desc { font-weight: 700; color: #212529; font-size: 13.5px; }
    .voucher-cond { font-size: 12px; color: #6c757d; }

    /* Style cho cụm nút Đặt hàng & Thêm vào giỏ hàng màu đỏ chủ đạo */
    .btn-action-primary {
        background-color: #dc3545;
        border-color: #dc3545;
        color: #fff;
        font-weight: bold;
        border-radius: 0.375rem;
        transition: all 0.2s;
    }
    .btn-action-primary:hover {
        background-color: #bb2d3b;
        border-color: #b02a37;
        color: #fff;
    }
    .btn-action-outline {
        background-color: #fff;
        border-color: #dc3545;
        color: #dc3545;
        font-weight: bold;
        border-radius: 0.375rem;
        transition: all 0.2s;
    }
    .btn-action-outline:hover {
        background-color: #dc3545;
        color: #fff;
        border-color: #dc3545;
    }

    /* Style cho phần SẢN PHẨM TƯƠNG TỰ */
    .related-title { border-left: 4px solid #dc3545; padding-left: 10px; font-weight: bold; margin: 30px 0 15px; }
    .related-wrap { position: relative; }
    .related-track { display: flex; gap: 16px; overflow-x: auto; scroll-snap-type: x mandatory;
        scroll-behavior: smooth; scrollbar-width: none; padding: 4px 2px 8px; }
    .related-track::-webkit-scrollbar { display: none; }
    .related-item { flex: 0 0 calc((100% - 48px) / 4); scroll-snap-align: start; }
    @media (max-width: 768px) { .related-item { flex: 0 0 calc((100% - 16px) / 2); } }
    .related-nav { position: absolute; top: 42%; transform: translateY(-50%); z-index: 5;
        width: 38px; height: 38px; border-radius: 50%; border: 1px solid #dc3545;
        background: #fff; color: #dc3545; font-size: 16px; display: flex;
        align-items: center; justify-content: center; cursor: pointer;
        box-shadow: 0 2px 6px rgba(0,0,0,.2); transition: all .2s; }
    .related-nav:hover:not(:disabled) { background: #dc3545; color: #fff; }
    .related-nav:disabled { opacity: .35; cursor: default; }
    .related-nav.prev { left: -14px; }
    .related-nav.next { right: -14px; }
    .related-card { border: 1px solid #e0e0e0; border-radius: 6px; background: #fff; height: 100%;
        transition: box-shadow .2s, transform .2s; text-decoration: none; display: block; }
    .related-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,.12); transform: translateY(-2px); }
    .related-card img { width: 100%; height: 180px; object-fit: contain; background: #f8f9fa; border-radius: 6px 6px 0 0; }
    .related-card .rc-name { color: #212529; font-weight: 600; font-size: 14px; height: 40px; overflow: hidden; }
    .related-card .rc-price { color: #dc3545; font-weight: bold; font-size: 16px; }

    /* Gallery Styles for Multi-Image */
    .product-gallery-container {
        margin-bottom: 24px;
    }
    .product-main-image-wrap {
        position: relative;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        min-height: 380px;
        max-height: 420px;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        padding: 16px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
    }
    .product-detail-img {
        max-height: 380px;
        max-width: 100%;
        object-fit: contain;
        transition: opacity 0.25s ease, transform 0.25s ease;
    }
    .gallery-nav-btn {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.95);
        border: 1px solid rgba(0, 0, 0, 0.08);
        color: #1e293b;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.12);
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        z-index: 5;
        outline: none;
    }
    .gallery-nav-btn:hover {
        background: #E6021A;
        color: #ffffff;
        border-color: #E6021A;
        transform: translateY(-50%) scale(1.1);
        box-shadow: 0 6px 18px rgba(230, 2, 26, 0.35);
    }
    .gallery-nav-btn.prev-btn { left: 12px; }
    .gallery-nav-btn.next-btn { right: 12px; }

    /* Khay dải ảnh thu nhỏ (Thumbnails Tray) cao cấp */
    .gallery-thumbnails-strip {
        display: flex;
        align-items: center;
        justify-content: safe center;
        gap: 12px;
        margin-top: 14px;
        padding: 10px 14px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        overflow-x: auto;
        scrollbar-width: thin;
        box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.03);
    }
    .gallery-thumbnails-strip::-webkit-scrollbar {
        height: 5px;
    }
    .gallery-thumbnails-strip::-webkit-scrollbar-track {
        background: #f1f5f9;
        border-radius: 999px;
    }
    .gallery-thumbnails-strip::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 999px;
    }
    .gallery-thumbnails-strip::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
    }

    /* Từng thẻ ảnh nhỏ - Tỉ lệ ngang chuẩn tech, bo góc 10px, hiệu ứng đổ bóng */
    .thumb-item {
        width: 88px;
        height: 64px;
        flex-shrink: 0;
        border-radius: 10px;
        border: 2px solid #e2e8f0;
        background: #ffffff;
        overflow: hidden;
        cursor: pointer;
        transition: all 0.22s cubic-bezier(0.4, 0, 0.2, 1);
        padding: 3px;
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
        opacity: 0.72;
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
    }
    .thumb-item img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 7px;
        transition: transform 0.25s ease;
    }
    .thumb-item:hover {
        opacity: 1;
        border-color: #fca5a5;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
    .thumb-item:hover img {
        transform: scale(1.05);
    }
    .thumb-item.active {
        opacity: 1;
        border-color: #E6021A;
        box-shadow: 0 0 0 3px rgba(230, 2, 26, 0.2), 0 6px 16px rgba(230, 2, 26, 0.25);
        transform: translateY(-2px);
        background: #ffffff;
    }
    .thumb-item.active img {
        transform: scale(1.02);
    }
</style>

<div class="container my-4">
    <a href="${ctx}/Home" class="btn btn-outline-dark mb-3 btn-sm fw-semibold">
        &larr; Quay lại trang chủ
    </a>

    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger alert-dismissible fade show mb-3" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i> ${sessionScope.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>

    <div class="row bg-white p-4 rounded-3 border align-items-start shadow-sm">
        <!-- Cột bên trái: Khung ảnh sản phẩm, Khung Khuyến Mãi & Khung Bảo hành -->
        <div class="col-md-6">
            <!-- BỘ SƯU TẬP ẢNH SẢN PHẨM (NHIỀU ẢNH) -->
            <div class="product-gallery-container mb-4">
                <c:set var="firstImg" value="${not empty p.images && fn:length(p.images) > 0 ? p.images[0] : p.image}" />
                <c:set var="mainImgSrc" value="${fn:startsWith(firstImg, 'http') ? firstImg : ctx.concat('/').concat(firstImg)}" />

                <!-- Khung hiển thị ảnh lớn -->
                <div class="product-main-image-wrap">
                    <img id="mainProductImg" src="${mainImgSrc}" class="product-detail-img" alt="${p.name}"
                         referrerpolicy="no-referrer"
                         onerror="this.onerror=null; this.src='https://via.placeholder.com/600x400?text=No+Image';">

                    <c:if test="${not empty p.images && fn:length(p.images) > 1}">
                        <button type="button" class="gallery-nav-btn prev-btn" id="btnGalleryPrev" title="Xem ảnh trước">
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <button type="button" class="gallery-nav-btn next-btn" id="btnGalleryNext" title="Xem ảnh tiếp theo">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                        <span class="badge rounded-pill bg-dark bg-opacity-75 text-white position-absolute bottom-0 end-0 m-3 px-3 py-1" style="font-size: 11px;">
                            <i class="fas fa-camera me-1"></i> <span id="galleryCurrentIdx">1</span> / ${fn:length(p.images)}
                        </span>
                    </c:if>
                </div>

                <!-- Dải thumbnail các ảnh phụ nếu có nhiều ảnh -->
                <c:if test="${not empty p.images && fn:length(p.images) > 1}">
                    <div class="gallery-thumbnails-strip">
                        <c:forEach items="${p.images}" var="imgItem" varStatus="loop">
                            <c:set var="itemSrc" value="${fn:startsWith(imgItem, 'http') ? imgItem : ctx.concat('/').concat(imgItem)}" />
                            <div class="thumb-item ${loop.first ? 'active' : ''}" data-index="${loop.index}" data-src="${itemSrc}">
                                <img src="${itemSrc}" alt="${p.name} - Ảnh ${loop.index + 1}"
                                     referrerpolicy="no-referrer"
                                     onerror="this.onerror=null; this.src='https://via.placeholder.com/80?text=No+Image';">
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </div>

            <!-- Khung Khuyến Mãi -->
            <div class="promo-box shadow-sm">
                <div class="promo-header"><i class="fas fa-gift"></i> KHUYẾN MÃI</div>
                <div class="promo-body">
                    <ul>
                        <li><span class="num">1</span> Quà tặng : Chuột Gaming ASUS TUF M3 GEN II hoặc Chuột gaming Logitech G102 Gen II</li>
                        <li><span class="num">2</span> Upgrade lên Card màn hình ASUS Dual RTX 5060 8GB GDDR7 thêm 500K</li>
                        <li><span class="num">3</span> Upgrade lên SSD 512GB NVME GEN4 thêm 1 triệu</li>
                        <li><span class="num">4</span> Upgrade lên VGA Colorful iGame GeForce RTX 5060 Ultra W DUO OC 8GB (Màu trắng) thêm 2.000K</li>
                        <li><span class="num">5</span> Upgrade lên Mainboard Asus B760M-AYW WIFI DDR4 thêm 690K</li>
                        <li><span class="num">6</span> *** Lưu ý về Hệ điều hành: Máy ráp sẵn tại Độ-PC 67 đã bao gồm Windows 10/11 bản dùng thử trong 30 ngày.</li>
                        <li><span class="num">7</span> Bộ PC này đã áp dụng CTKM SHOCK nên sẽ không được Áp dụng CTKM Chung</li>
                    </ul>
                </div>
            </div>

            <!-- Khung Bảo hành nằm dưới Khuyến Mãi -->
            <div class="warranty-badge shadow-sm">
                <i class="fas fa-shield-alt me-2"></i> Bảo hành 36 Tháng cho toàn bộ linh kiện
            </div>
        </div>

        <!-- Cột bên phải: Thông tin chi tiết, Mô tả, Upgrade và Nút mua hàng -->
        <div class="col-md-6">
            <span class="badge-category mb-2">${not empty p.categoryName ? p.categoryName : 'Chưa phân loại'}</span>

            <!-- Tên sản phẩm & Phần hiển thị nâng cấp động -->
            <h2 class="fw-bold fs-3 text-dark mb-3">
                <span id="baseProductName">${p.name}</span> <span id="upgradeText" class="text-muted fs-5"></span>
            </h2>

            <!-- Giá tiền -->
            <div class="d-flex align-items-baseline flex-wrap gap-2 mb-1">
                <span class="text-muted text-decoration-line-through fs-3 fw-semibold" id="originalPriceDisplay" style="display:none;"></span>
                <span class="text-danger fw-bold fs-1" id="priceDisplay" data-base="${p.price}">
                    <fmt:formatNumber value="${p.price}" pattern="#,##0"/> VNĐ
                </span>
                <span class="badge bg-success fs-6 py-2 px-3" id="discountBadge" style="display:none;"></span>
            </div>
            <div class="text-muted small mb-2" id="priceNote"></div>
            <div class="alert alert-success py-2 px-3 small fw-bold mb-3 align-items-center gap-2" id="voucherAlertNotice" style="display:none;">
                <i class="fas fa-circle-check text-success fs-5"></i>
                <span id="voucherNoticeText"></span>
            </div>

            <!-- MÔ TẢ & THÔNG SỐ SẢN PHẨM (ĐỒNG BỘ CHÍNH XÁC TỪ ADMIN) -->
            <div class="border-top pt-4 mb-4">
                <h5 class="border-start border-4 border-danger ps-2 text-dark fw-bold mb-3">Mô tả sản phẩm</h5>
                <div class="product-specs-box">
                    <c:if test="${not empty p.description}">
                        <div class="mb-3 text-secondary" style="font-size: 15px; font-weight: 500;">
                            <i class="fas fa-info-circle me-1 text-primary"></i>
                            <span>${p.description}</span>
                        </div>
                    </c:if>

                    <c:choose>
                        <c:when test="${not empty p.specList}">
                            <ul class="list-unstyled mt-2 mb-0" id="formattedDescList">
                                <c:forEach items="${p.specList}" var="spec">
                                    <li class="d-flex align-items-start mb-2 text-dark" style="font-size: 15px; font-weight: 500;">
                                        <i class="fas fa-check-circle me-2 mt-1" style="color: #007bff; font-size: 16px;"></i>
                                        <span>${spec}</span>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:when test="${empty p.description}">
                            <div class="text-muted fst-italic">Đang cập nhật thông số chi tiết...</div>
                        </c:when>
                    </c:choose>
                </div>
            </div>

            <!-- ================= KHU VỰC UPGRADE ĐỘNG ================= -->
            <c:if test="${not empty upgradeGroups}">
                <div class="upgrade-box shadow-sm">
                    <div class="upgrade-header"><i class="fas fa-sliders-h"></i> TÙY CHỌN & NÂNG CẤP</div>
                    <div class="upgrade-body">
                        <c:forEach items="${upgradeGroups}" var="g">
                            <div class="upgrade-row" data-label="${g.key}">
                                <div class="upgrade-label">${g.key}</div>
                                <div class="upgrade-options">
                                    <c:forEach items="${g.value}" var="o">
                                        <div class="opt-btn ${o.defaultOption ? 'active' : ''}"
                                             data-id="${o.id}"
                                             data-value="${o.name}"
                                             data-price="${o.priceDelta}"
                                             <c:if test="${o.defaultOption}">data-default="true"</c:if>>
                                                ${o.name}
                                            <c:if test="${not o.defaultOption}">
                                                <c:choose>
                                                    <c:when test="${o.priceDelta > 0}"><span class="opt-price">+<fmt:formatNumber value="${o.priceDelta}" pattern="#,##0"/> đ</span></c:when>
                                                    <c:when test="${o.priceDelta < 0}"><span class="opt-price"><fmt:formatNumber value="${o.priceDelta}" pattern="#,##0"/> đ</span></c:when>
                                                </c:choose>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
            <!-- ================= KẾT THÚC KHU VỰC UPGRADE ================= -->

            <form action="${ctx}/add-to-cart" method="GET" id="cartForm">
                <input type="hidden" name="id" value="${p.id}">
                <input type="hidden" name="voucherCode" id="selectedVoucherCode" value="">

                <!-- ================= KHU VỰC CHỌN VOUCHER GIẢM GIÁ ================= -->
                <div class="voucher-box shadow-sm">
                    <div class="voucher-header">
                        <span><i class="fas fa-ticket-alt me-2 text-danger"></i>MÃ GIẢM GIÁ DÀNH CHO BẠN</span>
                        <span class="badge bg-danger bg-opacity-10 text-danger border border-danger small">Chọn để áp dụng</span>
                    </div>
                    <div class="voucher-body">
                        <c:choose>
                            <c:when test="${not empty voucherList}">
                                <div class="voucher-list mb-2" id="voucherListContainer">
                                    <c:forEach items="${voucherList}" var="v">
                                        <div class="voucher-card" id="vcard-${v.code}"
                                             data-code="${v.code}"
                                             data-type="${v.discountType}"
                                             data-value="${v.discountValue}"
                                             data-max="${v.maxDiscountAmount != null ? v.maxDiscountAmount : 0}"
                                             data-min="${v.minOrderAmount}"
                                             data-formatted-discount="${v.formattedDiscount}">
                                            <div class="d-flex align-items-center gap-3">
                                                <i class="fas fa-tags text-danger fs-3"></i>
                                                <div>
                                                    <div class="d-flex align-items-center gap-2 mb-1">
                                                        <span class="voucher-tag">${v.code}</span>
                                                        <span class="voucher-desc">${v.formattedDiscount}</span>
                                                    </div>
                                                    <div class="voucher-cond">
                                                        <i class="fas fa-circle-info me-1"></i>${v.formattedMinOrder}
                                                        &bull; HSD: ${v.endDateDisplay}
                                                        <span class="ineligible-warning text-danger fw-semibold ms-1" style="display:none;">(Chưa đủ điều kiện)</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="text-end">
                                                <button type="button" class="btn btn-sm btn-outline-danger btn-voucher-toggle fw-semibold text-nowrap"
                                                        data-code="${v.code}">
                                                    Áp dụng
                                                </button>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-muted small py-2 text-center">
                                    Hiện chưa có voucher công khai. Bạn có thể nhập mã ưu đãi riêng bên dưới.
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Ô nhập mã voucher thủ công -->
                        <div class="input-group input-group-sm mt-3">
                            <span class="input-group-text bg-light text-secondary"><i class="fas fa-keyboard"></i></span>
                            <input type="text" id="manualVoucherInput" class="form-control text-uppercase font-monospace"
                                   placeholder="Nhập mã voucher riêng...">
                            <button class="btn btn-dark fw-semibold" type="button" id="btnApplyManual">
                                Áp dụng
                            </button>
                            <button class="btn btn-outline-danger" type="button" id="btnDeselectVoucher" style="display:none;">
                                <i class="fas fa-times me-1"></i>Hủy mã
                            </button>
                        </div>
                        <div id="voucherFeedback" class="small mt-1" style="display:none;"></div>
                    </div>
                </div>
                <!-- ================= KẾT THÚC KHU VỰC VOUCHER ================= -->

                <c:choose>
                    <c:when test="${p.quantity <= 0}">
                        <!-- Thông báo sản phẩm hết hàng -->
                        <div class="alert alert-danger d-flex align-items-center gap-3 p-3 my-3 rounded-3 border-danger shadow-sm">
                            <i class="fas fa-box-open fs-2 text-danger"></i>
                            <div>
                                <h5 class="fw-bold mb-1 text-danger">SẢN PHẨM HIỆN ĐÃ HẾT HÀNG</h5>
                                <div class="small text-secondary">Rất tiếc, sản phẩm này hiện đã tạm hết hàng trong kho. Quý khách vui lòng tham khảo các sản phẩm tương tự bên dưới hoặc liên hệ Hotline để được hỗ trợ đặt trước!</div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3 mb-3 mt-2">
                            <span class="text-dark fw-bold">Tình trạng:</span>
                            <span class="badge bg-danger px-3 py-2 fs-6 fw-bold">HẾT HÀNG</span>
                        </div>

                        <!-- Cụm nút bị vô hiệu hóa -->
                        <div class="row g-2 mt-2">
                            <div class="col-md-6">
                                <button type="button" class="btn btn-secondary w-100 py-3 fs-5 shadow-sm" disabled style="cursor: not-allowed; opacity: 0.65;">
                                    <i class="fas fa-ban me-2"></i> TẠM HẾT HÀNG
                                </button>
                            </div>
                            <div class="col-md-6">
                                <button type="button" class="btn btn-outline-secondary w-100 py-3 fs-5 shadow-sm" disabled style="cursor: not-allowed; opacity: 0.65;">
                                    <i class="fas fa-times me-1"></i> KHÔNG THỂ THÊM VÀO GIỎ
                                </button>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="d-flex align-items-center gap-3 mb-3 mt-2">
                            <span class="text-dark fw-bold">Số lượng:</span>
                            <input type="number" name="quantity" value="1" min="1" max="${p.quantity}" required
                                   class="form-control text-center bg-white text-dark border input-quantity rounded">
                            <span class="text-muted small">Còn hàng: <strong class="text-dark">${p.quantity}</strong> sản phẩm</span>
                        </div>

                        <!-- Cụm 2 nút bấm: ĐẶT HÀNG (Thanh toán) và THÊM VÀO GIỎ -->
                        <div class="row g-2 mt-2">
                            <div class="col-md-6">
                                <button type="submit" name="buyNow" value="1" formaction="${ctx}/add-to-cart" class="btn btn-action-primary w-100 py-3 fs-5 shadow-sm">
                                    <i class="fas fa-shopping-cart me-2"></i> ĐẶT HÀNG
                                </button>
                            </div>
                            <div class="col-md-6">
                                <button type="submit" formaction="${ctx}/add-to-cart" class="btn btn-action-outline w-100 py-3 fs-5 shadow-sm">
                                    <i class="fas fa-plus me-1"></i> THÊM VÀO GIỎ
                                </button>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </form>
        </div>
    </div>

    <!-- ================= SẢN PHẨM TƯƠNG TỰ ================= -->
    <c:if test="${not empty relatedProducts}">
        <h4 class="related-title">SẢN PHẨM TƯƠNG TỰ</h4>
        <div class="related-wrap">
            <button type="button" class="related-nav prev" id="relPrev" aria-label="Trước">
                <i class="fas fa-chevron-left"></i>
            </button>
            <div class="related-track" id="relTrack">
                <c:forEach items="${relatedProducts}" var="r">
                    <c:set var="rImg" value="${fn:startsWith(r.image, 'http') ? r.image : ctx.concat('/').concat(r.image)}" />
                    <div class="related-item">
                        <a href="${ctx}/product/detail?id=${r.id}" class="related-card">
                            <img src="${rImg}" alt="${r.name}">
                            <div class="p-3">
                                <div class="rc-name mb-2">${r.name}</div>
                                <div class="rc-price">
                                    <fmt:formatNumber value="${r.price}" pattern="#,##0"/> VNĐ
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
            <button type="button" class="related-nav next" id="relNext" aria-label="Sau">
                <i class="fas fa-chevron-right"></i>
            </button>
        </div>
    </c:if>
    <!-- ================= KẾT THÚC SẢN PHẨM TƯƠNG TỰ ================= -->
</div>

<!-- Script cho nút Upgrade, Voucher và Cập nhật giá động -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        var upgradeRows = document.querySelectorAll('.upgrade-row');
        var upgradeTextSpan = document.getElementById('upgradeText');
        var priceEl = document.getElementById('priceDisplay');
        var origPriceEl = document.getElementById('originalPriceDisplay');
        var discountBadgeEl = document.getElementById('discountBadge');
        var priceNote = document.getElementById('priceNote');
        var voucherNotice = document.getElementById('voucherAlertNotice');
        var voucherNoticeText = document.getElementById('voucherNoticeText');
        var basePrice = parseFloat(priceEl.getAttribute('data-base')) || 0;
        var cartForm = document.getElementById('cartForm');
        var selectedVoucherInput = document.getElementById('selectedVoucherCode');
        var manualVoucherInput = document.getElementById('manualVoucherInput');
        var btnApplyManual = document.getElementById('btnApplyManual');
        var btnDeselectVoucher = document.getElementById('btnDeselectVoucher');
        var voucherFeedback = document.getElementById('voucherFeedback');

        var currentSelectedVoucher = null;

        function fmt(n) { return Math.round(n).toLocaleString('en-US'); }

        function calculateVoucherDiscount(voucher, amount) {
            if (!voucher || amount < voucher.min) return 0;
            var disc = 0;
            if (voucher.type === 'PERCENT') {
                disc = amount * (voucher.value / 100);
                if (voucher.max > 0) disc = Math.min(disc, voucher.max);
            } else {
                disc = voucher.value;
            }
            return Math.min(disc, amount);
        }

        function refresh() {
            var names = [], extra = 0;
            upgradeRows.forEach(function(row) {
                var btn = row.querySelector('.opt-btn.active');
                if (btn && !btn.hasAttribute('data-default')) {
                    names.push(btn.getAttribute('data-value'));
                    extra += parseFloat(btn.getAttribute('data-price')) || 0;
                }
            });

            var subtotal = basePrice + extra;

            if (names.length === 0) {
                upgradeTextSpan.innerText = upgradeRows.length ? "(Cấu hình gốc)" : "";
                priceNote.innerText = "";
            } else {
                upgradeTextSpan.innerText = "(Tùy chọn: " + names.join(" - ") + ")";
                if (extra > 0) {
                    priceNote.innerText = "Giá gốc " + fmt(basePrice) + " + tùy chọn " + fmt(extra) + " VNĐ";
                } else if (extra < 0) {
                    priceNote.innerText = "Giá gốc " + fmt(basePrice) + " " + fmt(extra) + " VNĐ";
                } else {
                    priceNote.innerText = "";
                }
            }

            // Cập nhật trạng thái điều kiện của từng thẻ voucher trong danh sách
            var voucherCards = document.querySelectorAll('.voucher-card');
            voucherCards.forEach(function(card) {
                var vMin = parseFloat(card.getAttribute('data-min')) || 0;
                var vCode = card.getAttribute('data-code');
                var btn = card.querySelector('.btn-voucher-toggle');
                var warnSpan = card.querySelector('.ineligible-warning');

                if (subtotal < vMin) {
                    card.classList.add('ineligible');
                    if (warnSpan) {
                        warnSpan.style.display = 'inline';
                        warnSpan.innerText = '(Cần đơn từ ' + fmt(vMin) + ' đ)';
                    }
                    if (btn) {
                        btn.disabled = true;
                        btn.innerText = 'Chưa đủ ĐK';
                        btn.className = 'btn btn-sm btn-secondary text-nowrap';
                    }
                } else {
                    card.classList.remove('ineligible');
                    if (warnSpan) warnSpan.style.display = 'none';
                    if (btn) {
                        btn.disabled = false;
                        if (currentSelectedVoucher && currentSelectedVoucher.code === vCode) {
                            card.classList.add('selected-voucher');
                            btn.innerText = 'Đang áp dụng';
                            btn.className = 'btn btn-sm btn-danger text-nowrap';
                        } else {
                            card.classList.remove('selected-voucher');
                            btn.innerText = 'Áp dụng';
                            btn.className = 'btn btn-sm btn-outline-danger text-nowrap';
                        }
                    }
                }
            });

            // Nếu voucher đang chọn mà không còn đủ điều kiện do hạ nâng cấp
            if (currentSelectedVoucher && subtotal < currentSelectedVoucher.min) {
                showFeedback('Mã ' + currentSelectedVoucher.code + ' yêu cầu đơn tối thiểu ' + fmt(currentSelectedVoucher.min) + ' VNĐ. Đã hủy áp dụng mã.', 'danger');
                deselectVoucher();
                return;
            }

            // Tính giá sau voucher nếu có
            if (currentSelectedVoucher) {
                var discount = calculateVoucherDiscount(currentSelectedVoucher, subtotal);
                var finalPrice = Math.max(0, subtotal - discount);

                origPriceEl.innerText = fmt(subtotal) + " VNĐ";
                origPriceEl.style.display = 'inline';

                priceEl.innerText = fmt(finalPrice) + " VNĐ";

                discountBadgeEl.innerText = "Tiết kiệm " + fmt(discount) + " VNĐ";
                discountBadgeEl.style.display = 'inline-block';

                voucherNotice.style.display = 'flex';
                voucherNoticeText.innerText = "Đã áp dụng mã \"" + currentSelectedVoucher.code + "\": Tiết kiệm ngay " + fmt(discount) + " VNĐ khi mua!";

                selectedVoucherInput.value = currentSelectedVoucher.code;
                btnDeselectVoucher.style.display = 'inline-block';
            } else {
                origPriceEl.style.display = 'none';
                discountBadgeEl.style.display = 'none';
                voucherNotice.style.display = 'none';
                priceEl.innerText = fmt(subtotal) + " VNĐ";
                selectedVoucherInput.value = "";
                btnDeselectVoucher.style.display = 'none';
            }
        }

        function showFeedback(msg, type) {
            voucherFeedback.className = 'small mt-1 ' + (type === 'danger' ? 'text-danger' : 'text-success');
            voucherFeedback.innerText = msg;
            voucherFeedback.style.display = 'block';
        }

        function selectVoucher(code, type, value, max, min, formatted) {
            var names = [], extra = 0;
            upgradeRows.forEach(function(row) {
                var btn = row.querySelector('.opt-btn.active');
                if (btn && !btn.hasAttribute('data-default')) {
                    extra += parseFloat(btn.getAttribute('data-price')) || 0;
                }
            });
            var subtotal = basePrice + extra;

            if (subtotal < min) {
                showFeedback('Mã này yêu cầu giá trị tối thiểu là ' + fmt(min) + ' VNĐ (Hiện tại: ' + fmt(subtotal) + ' VNĐ).', 'danger');
                return;
            }

            currentSelectedVoucher = {
                code: code,
                type: type,
                value: parseFloat(value),
                max: parseFloat(max),
                min: parseFloat(min),
                formatted: formatted
            };
            showFeedback('Áp dụng mã voucher ' + code + ' thành công!', 'success');
            refresh();
        }

        function deselectVoucher() {
            currentSelectedVoucher = null;
            document.querySelectorAll('.voucher-card').forEach(function(c) {
                c.classList.remove('selected-voucher');
                var b = c.querySelector('.btn-voucher-toggle');
                if (b && !b.disabled) {
                    b.innerText = 'Áp dụng';
                    b.className = 'btn btn-sm btn-outline-danger text-nowrap';
                }
            });
            manualVoucherInput.value = '';
            refresh();
        }

        // Sự kiện click nút Áp dụng trong danh sách voucher
        document.querySelectorAll('.btn-voucher-toggle').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                var card = this.closest('.voucher-card');
                var code = card.getAttribute('data-code');

                if (currentSelectedVoucher && currentSelectedVoucher.code === code) {
                    deselectVoucher();
                    showFeedback('Đã bỏ chọn mã ' + code, 'danger');
                } else {
                    var type = card.getAttribute('data-type');
                    var value = card.getAttribute('data-value');
                    var max = card.getAttribute('data-max');
                    var min = card.getAttribute('data-min');
                    var fmtDesc = card.getAttribute('data-formatted-discount');
                    selectVoucher(code, type, value, max, min, fmtDesc);
                }
            });
        });

        // Click cả card voucher để chọn nhanh
        document.querySelectorAll('.voucher-card').forEach(function(card) {
            card.addEventListener('click', function() {
                var btn = this.querySelector('.btn-voucher-toggle');
                if (btn && !btn.disabled) btn.click();
            });
        });

        // Sự kiện nhập mã thủ công
        btnApplyManual.addEventListener('click', function() {
            var code = manualVoucherInput.value.trim().toUpperCase();
            if (!code) {
                showFeedback('Vui lòng nhập mã voucher!', 'danger');
                return;
            }
            var targetCard = document.getElementById('vcard-' + code);
            if (targetCard) {
                var btn = targetCard.querySelector('.btn-voucher-toggle');
                if (btn && !btn.disabled) {
                    btn.click();
                } else {
                    showFeedback('Mã này chưa đủ điều kiện áp dụng cho sản phẩm này!', 'danger');
                }
            } else {
                selectVoucher(code, 'PERCENT', 0, 0, 0, code);
                selectedVoucherInput.value = code;
                showFeedback('Đã lưu mã ' + code + ' để kiểm tra khi thanh toán!', 'success');
                btnDeselectVoucher.style.display = 'inline-block';
            }
        });

        btnDeselectVoucher.addEventListener('click', function() {
            deselectVoucher();
            showFeedback('Đã hủy áp dụng mã voucher.', 'danger');
        });

        // Sự kiện chọn linh kiện nâng cấp
        upgradeRows.forEach(function(row) {
            var buttons = row.querySelectorAll('.opt-btn');
            buttons.forEach(function(btn) {
                btn.addEventListener('click', function() {
                    buttons.forEach(function(b) { b.classList.remove('active'); });
                    this.classList.add('active');
                    refresh();
                });
            });
        });

        // 3. Slider sản phẩm tương tự: chuyển qua lại từng sản phẩm
        var relTrack = document.getElementById('relTrack');
        var relPrev = document.getElementById('relPrev');
        var relNext = document.getElementById('relNext');
        if (relTrack && relPrev && relNext) {
            function relStep() {
                var item = relTrack.querySelector('.related-item');
                if (!item) return 0;
                var gap = parseFloat(getComputedStyle(relTrack).columnGap) || 16;
                return item.getBoundingClientRect().width + gap;
            }
            function relAtStart() { return relTrack.scrollLeft <= 2; }
            function relAtEnd() { return relTrack.scrollLeft + relTrack.clientWidth >= relTrack.scrollWidth - 2; }

            relNext.addEventListener('click', function() {
                if (relAtEnd()) {
                    relTrack.scrollTo({ left: 0, behavior: 'smooth' });
                } else {
                    relTrack.scrollBy({ left: relStep(), behavior: 'smooth' });
                }
            });
            relPrev.addEventListener('click', function() {
                if (relAtStart()) {
                    relTrack.scrollTo({ left: relTrack.scrollWidth, behavior: 'smooth' });
                } else {
                    relTrack.scrollBy({ left: -relStep(), behavior: 'smooth' });
                }
            });
        }

        // trước khi submit: tạo input upgradeId cho các linh kiện đang chọn (trừ mặc định)
        cartForm.addEventListener('submit', function() {
            cartForm.querySelectorAll('input[name="upgradeId"]').forEach(function(i) { i.remove(); });
            upgradeRows.forEach(function(row) {
                var btn = row.querySelector('.opt-btn.active');
                if (btn && !btn.hasAttribute('data-default')) {
                    var inp = document.createElement('input');
                    inp.type = 'hidden';
                    inp.name = 'upgradeId';
                    inp.value = btn.getAttribute('data-id');
                    cartForm.appendChild(inp);
                }
            });
        });

        // Bộ sưu tập nhiều ảnh sản phẩm (Interactive Image Gallery)
        const mainImg = document.getElementById('mainProductImg');
        const thumbs = document.querySelectorAll('.thumb-item');
        const prevBtn = document.getElementById('btnGalleryPrev');
        const nextBtn = document.getElementById('btnGalleryNext');
        const counterEl = document.getElementById('galleryCurrentIdx');

        if (thumbs && thumbs.length > 1) {
            let currentGalleryIdx = 0;
            const totalGalleryCount = thumbs.length;

            function showGalleryIndex(idx) {
                if (idx < 0) idx = totalGalleryCount - 1;
                if (idx >= totalGalleryCount) idx = 0;
                currentGalleryIdx = idx;

                const targetThumb = thumbs[currentGalleryIdx];
                const newSrc = targetThumb.getAttribute('data-src');

                if (mainImg) {
                    mainImg.style.opacity = '0.3';
                    setTimeout(function() {
                        mainImg.src = newSrc;
                        mainImg.style.opacity = '1';
                    }, 140);
                }

                thumbs.forEach(function(t) { t.classList.remove('active'); });
                targetThumb.classList.add('active');
                targetThumb.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });

                if (counterEl) counterEl.innerText = (currentGalleryIdx + 1);
            }

            thumbs.forEach(function(thumb) {
                thumb.addEventListener('click', function() {
                    const idx = parseInt(this.getAttribute('data-index'));
                    showGalleryIndex(idx);
                });
                thumb.addEventListener('mouseenter', function() {
                    const idx = parseInt(this.getAttribute('data-index'));
                    showGalleryIndex(idx);
                });
            });

            if (prevBtn) {
                prevBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    showGalleryIndex(currentGalleryIdx - 1);
                });
            }
            if (nextBtn) {
                nextBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    showGalleryIndex(currentGalleryIdx + 1);
                });
            }
        }

        refresh();
    });
</script>

<jsp:include page="footer.jsp" />
