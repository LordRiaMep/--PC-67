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
</style>

<div class="container my-4">
    <a href="${ctx}/Home" class="btn btn-outline-dark mb-3 btn-sm fw-semibold">
        &larr; Quay lại trang chủ
    </a>

    <div class="row bg-white p-4 rounded-3 border align-items-start shadow-sm">
        <!-- Cột bên trái: Khung ảnh sản phẩm, Khung Khuyến Mãi & Khung Bảo hành -->
        <div class="col-md-6">
            <div class="text-center mb-4">
                <c:set var="imgUrl" value="${fn:startsWith(p.image, 'http') ? p.image : ctx.concat('/').concat(p.image)}" />
                <img src="${imgUrl}" class="img-fluid rounded product-detail-img w-100 bg-light border" alt="${p.name}">
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
            <div class="text-danger fw-bold fs-1 mb-1" id="priceDisplay"
                 data-base="${p.price}">
                <fmt:formatNumber value="${p.price}" pattern="#,##0"/> VNĐ
            </div>
            <div class="text-muted small mb-4" id="priceNote"></div>

            <!-- MÔ TẢ SẢN PHẨM -->
            <div class="border-top pt-4 mb-4">
                <h5 class="border-start border-4 border-danger ps-2 text-dark fw-bold mb-3">Mô tả sản phẩm</h5>
                <div class="product-specs-box">
                    <div id="rawDescription" style="display: none;">
                        ${not empty p.description ? p.description : ''}
                        | Nguồn máy tính SSTC 550F - 550W
                        | Vỏ Case XIGMATEK AQUA MS BLACK - KÈM 3 FAN ARGB
                        | Tản nhiệt khí JONSBO CR-1000 EVO
                    </div>
                    <ul class="list-unstyled mt-3" id="formattedDescList"></ul>
                </div>
            </div>

            <!-- ================= KHU VỰC UPGRADE ĐỘNG ================= -->
            <c:if test="${not empty upgradeGroups}">
                <div class="upgrade-box shadow-sm">
                    <div class="upgrade-header"><i class="fas fa-cog"></i> UPGRADE</div>
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
                                                <span class="opt-price">+<fmt:formatNumber value="${o.priceDelta}" pattern="#,##0"/> đ</span>
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
            </form>
        </div>
    </div>
</div>

<!-- Script cho nút Upgrade, Mô tả sản phẩm và Cập nhật tiêu đề động -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // 1. Script tự động format danh sách cấu hình
        var rawDescElem = document.getElementById("rawDescription");
        var listElem = document.getElementById("formattedDescList");

        if (rawDescElem && listElem) {
            var rawText = rawDescElem.innerText.trim();
            if (rawText !== "") {
                var items = rawText.split(/\||\n/);
                var listHtml = "";
                items.forEach(function(item) {
                    var cleanItem = item.trim().replace(/^-\s*/, '');
                    if (cleanItem.length > 0) {
                        var textUpper = cleanItem.toUpperCase();
                        if (!textUpper.includes("CPU") && (textUpper.includes("CORE ") || textUpper.includes("RYZEN") || textUpper.includes("INTEL") || textUpper.includes("AMD"))) {
                            cleanItem = "CPU " + cleanItem;
                        } else if (!textUpper.includes("VGA") && !textUpper.includes("CARD") && (textUpper.includes("RTX") || textUpper.includes("GTX") || textUpper.includes("RX "))) {
                            cleanItem = "VGA " + cleanItem;
                        } else if (!textUpper.includes("Ổ CỨNG") && (textUpper.includes("SSD") || textUpper.includes("HDD"))) {
                            cleanItem = "Ổ cứng " + cleanItem;
                        } else if (!textUpper.includes("RAM") && (textUpper.includes("DDR4") || textUpper.includes("DDR5") || textUpper.includes("BUS"))) {
                            cleanItem = "RAM " + cleanItem;
                        } else if (!textUpper.includes("MAINBOARD") && !textUpper.includes("MAIN") && /(H610|B760|Z790|H510|B660|Z690|A320|B450|B550|X570|A520)/.test(textUpper)) {
                            cleanItem = "Mainboard " + cleanItem;
                        } else if (!textUpper.includes("NGUỒN") && /(450W|500W|550W|600W|650W|700W|750W|850W|1000W)/.test(textUpper)) {
                            cleanItem = "Nguồn máy tính " + cleanItem;
                        }
                        listHtml += '<li class="d-flex align-items-start mb-2 text-dark" style="font-size: 15px; font-weight: 500;">' +
                            '<i class="fas fa-check-circle me-2 mt-1" style="color: #007bff; font-size: 16px;"></i>' +
                            '<span>' + cleanItem + '</span></li>';
                    }
                });
                listElem.innerHTML = listHtml;
            } else {
                listElem.innerHTML = '<li class="text-muted">Đang cập nhật cấu hình chi tiết...</li>';
            }
        }

        // 2. Chọn linh kiện nâng cấp: đổi tên + giá, gửi id lên server khi thêm giỏ
        var upgradeRows = document.querySelectorAll('.upgrade-row');
        var upgradeTextSpan = document.getElementById('upgradeText');
        var priceEl = document.getElementById('priceDisplay');
        var priceNote = document.getElementById('priceNote');
        var basePrice = parseFloat(priceEl.getAttribute('data-base')) || 0;
        var cartForm = document.getElementById('cartForm');

        function fmt(n) { return Math.round(n).toLocaleString('en-US'); }

        function refresh() {
            var names = [], extra = 0;
            upgradeRows.forEach(function(row) {
                var btn = row.querySelector('.opt-btn.active');
                if (btn && !btn.hasAttribute('data-default')) {
                    names.push(btn.getAttribute('data-value'));
                    extra += parseFloat(btn.getAttribute('data-price')) || 0;
                }
            });
            if (names.length === 0) {
                upgradeTextSpan.innerText = upgradeRows.length ? "(Cấu hình gốc)" : "";
                priceNote.innerText = "";
            } else {
                upgradeTextSpan.innerText = "(Nâng cấp: " + names.join(" - ") + ")";
                priceNote.innerText = "Giá gốc " + fmt(basePrice) + " + nâng cấp " + fmt(extra) + " VNĐ";
            }
            priceEl.innerText = fmt(basePrice + extra) + " VNĐ";
        }
        refresh();

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
    });
</script>

<jsp:include page="footer.jsp" />