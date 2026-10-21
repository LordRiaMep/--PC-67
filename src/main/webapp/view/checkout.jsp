<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="header.jsp" />

<!-- Giao diện thanh toán -->
<div class="container my-5 bg-white p-4 rounded shadow-sm">
  <div class="d-flex align-items-center justify-content-between mb-4 border-bottom pb-3">
    <h2 class="fw-bold text-dark m-0">Thanh toán</h2>
    <span class="badge bg-light text-dark border d-flex align-items-center gap-2 px-3 py-2">
      <i class="fas fa-truck-fast text-danger"></i>
      <span>Giao hàng toàn quốc qua <strong>Giao Hàng Nhanh (GHN)</strong></span>
    </span>
  </div>

  <div class="row g-4">
    <div class="col-md-7">
      <form id="checkoutForm" action="place-order" method="post">
        <!-- Thông tin người nhận -->
        <div class="row g-3 mb-3">
          <div class="col-md-6">
            <label class="form-label fw-semibold text-dark">Họ và tên người nhận <span class="text-danger">*</span></label>
            <input type="text" name="name" value="${sessionScope.USER_LOGIN.fullName}" class="form-control" required placeholder="Nhập tên người nhận">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-semibold text-dark">Số điện thoại <span class="text-danger">*</span></label>
            <input type="tel" name="phone" value="${sessionScope.USER_LOGIN.phone}" class="form-control" required placeholder="Nhập số điện thoại">
          </div>
        </div>

        <!-- Địa chỉ giao hàng chọn qua GHN -->
        <div class="card border-0 bg-light p-3 mb-3 rounded-3">
          <div class="fw-bold text-dark mb-2 d-flex align-items-center gap-2">
            <i class="fas fa-location-dot text-danger"></i> Địa chỉ nhận hàng (Tính cước tự động qua GHN)
          </div>

          <div class="mb-3">
            <label class="form-label small fw-semibold text-secondary">Tỉnh / Thành phố <span class="text-danger">*</span></label>
            <select id="provinceSelect" class="form-select" required>
              <option value="">-- Đang tải danh sách Tỉnh / Thành phố --</option>
            </select>
          </div>

          <div class="row g-2 mb-3">
            <div class="col-md-6">
              <label class="form-label small fw-semibold text-secondary">Quận / Huyện <span class="text-danger">*</span></label>
              <select id="districtSelect" class="form-select" disabled required>
                <option value="">-- Chọn Quận / Huyện --</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label small fw-semibold text-secondary">Phường / Xã <span class="text-danger">*</span></label>
              <select id="wardSelect" class="form-select" disabled required>
                <option value="">-- Chọn Phường / Xã --</option>
              </select>
            </div>
          </div>

          <div>
            <label class="form-label small fw-semibold text-secondary">Số nhà, tên đường cụ thể <span class="text-danger">*</span></label>
            <input type="text" name="detailAddress" id="detailAddress" class="form-control"
                   placeholder="Ví dụ: Số 25 ngõ 102, đường Hoàng Hoa Thám" required>
          </div>
        </div>

        <!-- Hidden input gửi sang server -->
        <input type="hidden" name="provinceId" id="provinceId">
        <input type="hidden" name="provinceName" id="provinceName">
        <input type="hidden" name="districtId" id="districtId">
        <input type="hidden" name="districtName" id="districtName">
        <input type="hidden" name="wardCode" id="wardCode">
        <input type="hidden" name="wardName" id="wardName">
        <input type="hidden" name="shippingFee" id="shippingFeeInput" value="0">
        <input type="hidden" name="address" id="fullAddressInput" value="">
        <input type="hidden" name="voucherCode" id="checkoutFormVoucherCode" value="${appliedVoucher != null ? appliedVoucher.code : ''}">

        <div class="mb-4">
          <label class="form-label fw-semibold text-dark">Ghi chú đơn hàng</label>
          <textarea name="note" class="form-control" rows="2" placeholder="Ghi chú thêm cho shipper hoặc thời gian nhận hàng..."></textarea>
        </div>

        <!-- Phương thức thanh toán -->
        <div class="mb-4">
          <label class="form-label fw-semibold text-dark">Phương thức thanh toán <span class="text-danger">*</span></label>

          <div class="form-check border rounded p-3 mb-2 bg-white">
            <input class="form-check-input ms-0 me-2" type="radio" name="paymentMethod" id="pmCOD" value="COD" checked>
            <label class="form-check-label fw-semibold text-dark" for="pmCOD">
              <i class="fas fa-truck text-secondary me-1"></i> Thanh toán khi nhận hàng (COD)
            </label>
          </div>

          <div class="form-check border rounded p-3 bg-white">
            <input class="form-check-input ms-0 me-2" type="radio" name="paymentMethod" id="pmQR" value="QR">
            <label class="form-check-label fw-semibold text-dark" for="pmQR">
              <i class="fas fa-qrcode text-primary me-1"></i> Thanh toán trực tuyến qua VNPay (QR / thẻ / ngân hàng)
            </label>
          </div>

          <!-- Thông báo khi chọn thanh toán online -->
          <div id="qrBox" class="border rounded p-3 mt-3 text-center bg-light" style="display:none;">
            <p class="mb-2 text-dark fw-semibold">
              <i class="fas fa-shield-alt text-success me-1"></i> Thanh toán an toàn qua cổng VNPay
            </p>
            <p class="mb-2 text-dark small">
              Sau khi bấm <strong>Thanh toán qua VNPay</strong>, bạn sẽ được chuyển sang trang VNPay
              để quét mã QR hoặc thanh toán bằng ngân hàng.
            </p>
            <p class="mb-0 text-dark">
              Số tiền: <strong class="text-danger fs-5" id="qrAmountText"><fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,##0"/> đ</strong>
            </p>
          </div>
        </div>

        <button type="submit" id="btnSubmit" class="btn btn-danger fw-bold px-4 py-2 w-100 fs-5 shadow-sm">
          Xác nhận đặt hàng
        </button>
      </form>
    </div>

    <!-- Cột phải: Chi tiết đơn hàng & tổng tiền -->
    <div class="col-md-5">
      <div class="border rounded p-3 bg-light">
        <h5 class="fw-bold text-dark border-bottom pb-3 mb-3 d-flex justify-content-between align-items-center">
          <span>Đơn hàng của bạn</span>
          <span class="badge bg-secondary">${fn:length(sessionScope.cart.items)} món</span>
        </h5>

        <div style="max-height: 320px; overflow-y: auto;" class="pe-1">
          <c:forEach items="${sessionScope.cart.items}" var="item">
            <div class="mb-3 pb-3 border-bottom">
              <div class="d-flex justify-content-between gap-3">
                <span class="fw-semibold text-dark">${item.product.name} <span class="text-muted">x ${item.quantity}</span></span>
                <span class="fw-bold text-dark text-nowrap"><fmt:formatNumber value="${item.unitPrice * item.quantity}" pattern="#,##0"/> đ</span>
              </div>
              <c:if test="${not empty item.upgradeInfo}">
                <div class="mt-2 small">
                  <span class="fw-semibold text-primary"><i class="fas fa-arrow-up me-1"></i>Linh kiện nâng cấp:</span>
                  <ul class="mb-0 ps-3 text-secondary">
                    <c:forEach items="${fn:split(item.upgradeInfo, '|')}" var="line">
                      <li>${line}</li>
                    </c:forEach>
                  </ul>
                </div>
              </c:if>
            </div>
          </c:forEach>
        </div>

        <!-- Khung chọn Voucher trên trang thanh toán -->
        <div class="border rounded p-3 my-3 bg-white shadow-sm">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="fw-bold text-dark"><i class="fas fa-ticket text-danger me-1"></i> Mã giảm giá Voucher</span>
            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger small">Ưu đãi</span>
          </div>

          <div class="input-group input-group-sm mb-2">
            <input type="text" id="checkoutVoucherInput" class="form-control text-uppercase font-monospace"
                   placeholder="Nhập mã voucher..." value="${appliedVoucher != null ? appliedVoucher.code : ''}">
            <button class="btn btn-dark" type="button" id="btnApplyCheckoutVoucher">Áp dụng</button>
            <button class="btn btn-outline-danger" type="button" id="btnRemoveCheckoutVoucher" style="${appliedVoucher != null ? '' : 'display:none;'}">Hủy</button>
          </div>
          <div id="checkoutVoucherFeedback" class="small mb-2" style="display:none;"></div>

          <c:if test="${not empty voucherList}">
            <div class="accordion accordion-flush" id="voucherAccordion">
              <div class="accordion-item border-0">
                <button class="accordion-button collapsed p-0 pt-1 text-danger small bg-transparent shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseVouchers">
                  <i class="fas fa-tags me-1"></i> Xem danh sách voucher có sẵn (${fn:length(voucherList)})
                </button>
                <div id="flush-collapseVouchers" class="accordion-collapse collapse mt-2" data-bs-parent="#voucherAccordion">
                  <div style="max-height: 200px; overflow-y: auto;" class="d-flex flex-column gap-2 pe-1">
                    <c:forEach items="${voucherList}" var="v">
                      <div class="border rounded p-2 d-flex justify-content-between align-items-center voucher-quick-card ${appliedVoucher.code == v.code ? 'border-danger bg-danger bg-opacity-10' : 'bg-light'}"
                           data-code="${v.code}">
                        <div>
                          <div class="fw-bold font-monospace text-danger small">${v.code} - ${v.formattedDiscount}</div>
                          <div class="text-secondary" style="font-size: 11px;">${v.formattedMinOrder} &bull; HSD: ${v.endDateDisplay}</div>
                        </div>
                        <button type="button" class="btn btn-sm btn-outline-danger btn-pick-checkout-voucher px-2 py-0" style="font-size: 12px;" data-code="${v.code}">
                          ${appliedVoucher.code == v.code ? 'Đang dùng' : 'Chọn'}
                        </button>
                      </div>
                    </c:forEach>
                  </div>
                </div>
              </div>
            </div>
          </c:if>
        </div>

        <!-- Bảng tính tiền chi tiết -->
        <div class="pt-2">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="text-secondary">Tiền hàng:</span>
            <span class="fw-semibold text-dark"><fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,##0"/> đ</span>
          </div>

          <div class="d-flex justify-content-between align-items-center mb-2" id="checkoutVoucherRow" style="display:none;">
            <span class="text-secondary d-flex align-items-center gap-1">
              <i class="fas fa-ticket text-danger"></i> Giảm giá Voucher (<span id="checkoutVoucherCodeLabel"></span>):
            </span>
            <span id="checkoutVoucherDiscountText" class="fw-bold text-success">-0 đ</span>
          </div>

          <div class="d-flex justify-content-between align-items-center mb-3">
            <span class="text-secondary d-flex align-items-center gap-1">
              <i class="fas fa-truck-fast text-danger"></i> Phí vận chuyển (GHN):
            </span>
            <span id="shippingFeeText" class="fw-bold text-primary">
              <span class="badge bg-warning text-dark">Chờ chọn địa chỉ</span>
            </span>
          </div>

          <div class="d-flex justify-content-between align-items-center pt-3 border-top border-2">
            <span class="fs-5 fw-bold text-dark">Tổng thanh toán:</span>
            <span id="totalMoneyText" class="text-danger fw-bold fs-4">
              <fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,##0"/> đ
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  const ctx = '${pageContext.request.contextPath}';
  const cartTotal = ${sessionScope.cart.totalMoney};
  let currentShippingFee = 0;

  // Toggle phương thức thanh toán
  document.querySelectorAll('input[name="paymentMethod"]').forEach(function (r) {
    r.addEventListener('change', function () {
      const isQR = document.getElementById('pmQR').checked;
      document.getElementById('qrBox').style.display = isQR ? 'block' : 'none';
      document.getElementById('btnSubmit').innerText = isQR ? 'Thanh toán qua VNPay' : 'Xác nhận đặt hàng';
    });
  });

  // Tải danh sách Tỉnh/Thành phố và tính toán Voucher khi vào trang
  document.addEventListener('DOMContentLoaded', function () {
    loadProvinces();
    recalculateTotal();
  });

  function loadProvinces() {
    const provSelect = document.getElementById('provinceSelect');
    fetch(ctx + '/shipping-api?action=provinces')
      .then(res => res.json())
      .then(json => {
        if (json.data && json.data.length > 0) {
          // Sắp xếp tỉnh thành theo bảng chữ cái tiếng Việt
          const provinces = json.data.sort((a, b) => a.ProvinceName.localeCompare(b.ProvinceName, 'vi'));
          let html = '<option value="">-- Chọn Tỉnh / Thành phố --</option>';
          provinces.forEach(p => {
            html += '<option value="' + p.ProvinceID + '" data-name="' + escapeHtml(p.ProvinceName) + '">' + p.ProvinceName + '</option>';
          });
          provSelect.innerHTML = html;
        } else {
          provSelect.innerHTML = '<option value="">Không tải được danh sách tỉnh thành</option>';
        }
      })
      .catch(err => {
        console.error('Lỗi tải tỉnh thành:', err);
        provSelect.innerHTML = '<option value="">Lỗi kết nối GHN</option>';
      });
  }

  // Khi chọn Tỉnh / Thành phố -> tải Quận / Huyện
  document.getElementById('provinceSelect').addEventListener('change', function () {
    const provId = this.value;
    const provOption = this.options[this.selectedIndex];
    document.getElementById('provinceId').value = provId;
    document.getElementById('provinceName').value = provOption ? provOption.getAttribute('data-name') : '';

    const distSelect = document.getElementById('districtSelect');
    const wardSelect = document.getElementById('wardSelect');
    distSelect.innerHTML = '<option value="">-- Đang tải Quận / Huyện --</option>';
    distSelect.disabled = true;
    wardSelect.innerHTML = '<option value="">-- Chọn Phường / Xã --</option>';
    wardSelect.disabled = true;

    resetShippingFee();

    if (!provId) {
      distSelect.innerHTML = '<option value="">-- Chọn Quận / Huyện --</option>';
      return;
    }

    fetch(ctx + '/shipping-api?action=districts&provinceId=' + provId)
      .then(res => res.json())
      .then(json => {
        if (json.data && json.data.length > 0) {
          const districts = json.data.sort((a, b) => a.DistrictName.localeCompare(b.DistrictName, 'vi'));
          let html = '<option value="">-- Chọn Quận / Huyện --</option>';
          districts.forEach(d => {
            html += '<option value="' + d.DistrictID + '" data-name="' + escapeHtml(d.DistrictName) + '">' + d.DistrictName + '</option>';
          });
          distSelect.innerHTML = html;
          distSelect.disabled = false;
        } else {
          distSelect.innerHTML = '<option value="">Không có quận huyện</option>';
        }
      })
      .catch(err => {
        console.error('Lỗi tải quận huyện:', err);
        distSelect.innerHTML = '<option value="">Lỗi tải quận huyện</option>';
      });
  });

  // Khi chọn Quận / Huyện -> tải Phường / Xã
  document.getElementById('districtSelect').addEventListener('change', function () {
    const distId = this.value;
    const distOption = this.options[this.selectedIndex];
    document.getElementById('districtId').value = distId;
    document.getElementById('districtName').value = distOption ? distOption.getAttribute('data-name') : '';

    const wardSelect = document.getElementById('wardSelect');
    wardSelect.innerHTML = '<option value="">-- Đang tải Phường / Xã --</option>';
    wardSelect.disabled = true;

    resetShippingFee();

    if (!distId) {
      wardSelect.innerHTML = '<option value="">-- Chọn Phường / Xã --</option>';
      return;
    }

    fetch(ctx + '/shipping-api?action=wards&districtId=' + distId)
      .then(res => res.json())
      .then(json => {
        if (json.data && json.data.length > 0) {
          const wards = json.data.sort((a, b) => a.WardName.localeCompare(b.WardName, 'vi'));
          let html = '<option value="">-- Chọn Phường / Xã --</option>';
          wards.forEach(w => {
            html += '<option value="' + w.WardCode + '" data-name="' + escapeHtml(w.WardName) + '">' + w.WardName + '</option>';
          });
          wardSelect.innerHTML = html;
          wardSelect.disabled = false;
        } else {
          wardSelect.innerHTML = '<option value="">Không có phường xã</option>';
        }
      })
      .catch(err => {
        console.error('Lỗi tải phường xã:', err);
        wardSelect.innerHTML = '<option value="">Lỗi tải phường xã</option>';
      });
  });

  // Khi chọn Phường / Xã -> Tính phí vận chuyển qua GHN
  document.getElementById('wardSelect').addEventListener('change', function () {
    const wardCode = this.value;
    const wardOption = this.options[this.selectedIndex];
    document.getElementById('wardCode').value = wardCode;
    document.getElementById('wardName').value = wardOption ? wardOption.getAttribute('data-name') : '';

    const distId = document.getElementById('districtId').value;
    if (!wardCode || !distId) {
      resetShippingFee();
      return;
    }

    calculateFee(distId, wardCode);
  });

  function calculateFee(distId, wardCode) {
    const feeText = document.getElementById('shippingFeeText');
    feeText.innerHTML = '<span class="spinner-border spinner-border-sm text-primary"></span> Đang tính phí GHN...';

    fetch(ctx + '/shipping-api?action=fee&districtId=' + distId + '&wardCode=' + encodeURIComponent(wardCode))
      .then(res => res.json())
      .then(json => {
        if (json.success && typeof json.fee === 'number') {
          currentShippingFee = json.fee;
          applyShippingFee(currentShippingFee);
        } else {
          currentShippingFee = 30000;
          applyShippingFee(currentShippingFee);
        }
      })
      .catch(err => {
        console.error('Lỗi tính phí:', err);
        currentShippingFee = 30000;
        applyShippingFee(currentShippingFee);
      });
  }

  const availableVouchers = [
    <c:forEach items="${voucherList}" var="v" varStatus="vs">
      {
        code: '${v.code}',
        type: '${v.discountType}',
        value: ${v.discountValue},
        max: ${v.maxDiscountAmount != null ? v.maxDiscountAmount : 0},
        min: ${v.minOrderAmount}
      }${!vs.last ? ',' : ''}
    </c:forEach>
  ];

  let currentVoucher = <c:choose>
    <c:when test="${not empty appliedVoucher}">
      {
        code: '${appliedVoucher.code}',
        type: '${appliedVoucher.discountType}',
        value: ${appliedVoucher.discountValue},
        max: ${appliedVoucher.maxDiscountAmount != null ? appliedVoucher.maxDiscountAmount : 0},
        min: ${appliedVoucher.minOrderAmount}
      }
    </c:when>
    <c:otherwise>null</c:otherwise>
  </c:choose>;

  function recalculateTotal() {
    let discount = 0;
    if (currentVoucher) {
      if (cartTotal >= currentVoucher.min) {
        if (currentVoucher.type === 'PERCENT') {
          discount = cartTotal * (currentVoucher.value / 100);
          if (currentVoucher.max > 0) discount = Math.min(discount, currentVoucher.max);
        } else {
          discount = currentVoucher.value;
        }
        discount = Math.min(discount, cartTotal);
      } else {
        currentVoucher = null;
      }
    }

    const vRow = document.getElementById('checkoutVoucherRow');
    const vCodeLabel = document.getElementById('checkoutVoucherCodeLabel');
    const vDiscountText = document.getElementById('checkoutVoucherDiscountText');
    const formCode = document.getElementById('checkoutFormVoucherCode');
    const btnRemove = document.getElementById('btnRemoveCheckoutVoucher');
    const vInput = document.getElementById('checkoutVoucherInput');

    if (currentVoucher && discount > 0) {
      vRow.style.display = 'flex';
      vCodeLabel.innerText = currentVoucher.code;
      vDiscountText.innerText = '-' + discount.toLocaleString('vi-VN') + ' đ';
      formCode.value = currentVoucher.code;
      vInput.value = currentVoucher.code;
      btnRemove.style.display = 'inline-block';
    } else {
      vRow.style.display = 'none';
      formCode.value = '';
      btnRemove.style.display = 'none';
    }

    document.querySelectorAll('.btn-pick-checkout-voucher').forEach(function(b) {
      const c = b.getAttribute('data-code');
      if (currentVoucher && currentVoucher.code === c) {
        b.innerText = 'Đang dùng';
        b.className = 'btn btn-sm btn-danger btn-pick-checkout-voucher px-2 py-0';
      } else {
        b.innerText = 'Chọn';
        b.className = 'btn btn-sm btn-outline-danger btn-pick-checkout-voucher px-2 py-0';
      }
    });

    const grandTotal = Math.max(0, cartTotal - discount) + currentShippingFee;
    const formattedTotal = grandTotal.toLocaleString('vi-VN') + ' đ';
    document.getElementById('totalMoneyText').innerText = formattedTotal;
    document.getElementById('qrAmountText').innerText = formattedTotal;
  }

  function setCheckoutFeedback(msg, type) {
    const el = document.getElementById('checkoutVoucherFeedback');
    el.className = 'small mb-2 ' + (type === 'danger' ? 'text-danger' : 'text-success');
    el.innerText = msg;
    el.style.display = 'block';
  }

  // Sự kiện chọn voucher trong danh sách
  document.querySelectorAll('.btn-pick-checkout-voucher').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
      e.stopPropagation();
      const code = this.getAttribute('data-code');
      if (currentVoucher && currentVoucher.code === code) {
        currentVoucher = null;
        document.getElementById('checkoutVoucherInput').value = '';
        setCheckoutFeedback('Đã hủy áp dụng voucher.', 'danger');
      } else {
        const found = availableVouchers.find(v => v.code === code);
        if (found) {
          if (cartTotal < found.min) {
            setCheckoutFeedback('Đơn hàng cần đạt tối thiểu ' + found.min.toLocaleString('vi-VN') + ' đ để dùng mã này!', 'danger');
            return;
          }
          currentVoucher = found;
          setCheckoutFeedback('Áp dụng mã ' + code + ' thành công!', 'success');
        }
      }
      recalculateTotal();
    });
  });

  // Sự kiện nhập voucher thủ công
  document.getElementById('btnApplyCheckoutVoucher').addEventListener('click', function() {
    const code = document.getElementById('checkoutVoucherInput').value.trim().toUpperCase();
    if (!code) {
      setCheckoutFeedback('Vui lòng nhập mã voucher!', 'danger');
      return;
    }
    const found = availableVouchers.find(v => v.code === code);
    if (found) {
      if (cartTotal < found.min) {
        setCheckoutFeedback('Đơn hàng cần đạt tối thiểu ' + found.min.toLocaleString('vi-VN') + ' đ để dùng mã này!', 'danger');
        return;
      }
      currentVoucher = found;
      setCheckoutFeedback('Áp dụng mã ' + code + ' thành công!', 'success');
      recalculateTotal();
    } else {
      currentVoucher = { code: code, type: 'PERCENT', value: 0, max: 0, min: 0 };
      document.getElementById('checkoutFormVoucherCode').value = code;
      setCheckoutFeedback('Đã lưu mã ' + code + ', hệ thống sẽ kiểm tra khi đặt hàng!', 'success');
      recalculateTotal();
    }
  });

  document.getElementById('btnRemoveCheckoutVoucher').addEventListener('click', function() {
    currentVoucher = null;
    document.getElementById('checkoutVoucherInput').value = '';
    setCheckoutFeedback('Đã hủy áp dụng voucher.', 'danger');
    recalculateTotal();
  });

  function applyShippingFee(fee) {
    currentShippingFee = fee;
    document.getElementById('shippingFeeInput').value = fee;
    document.getElementById('shippingFeeText').innerHTML = fee.toLocaleString('vi-VN') + ' đ';
    recalculateTotal();
  }

  function resetShippingFee() {
    currentShippingFee = 0;
    document.getElementById('shippingFeeInput').value = 0;
    document.getElementById('shippingFeeText').innerHTML = '<span class="badge bg-warning text-dark">Chờ chọn địa chỉ</span>';
    recalculateTotal();
  }

  // Submit form kiểm tra hợp lệ
  document.getElementById('checkoutForm').addEventListener('submit', function (e) {
    const provName = document.getElementById('provinceName').value;
    const distName = document.getElementById('districtName').value;
    const wardName = document.getElementById('wardName').value;
    const detail = document.getElementById('detailAddress').value;

    if (!provName || !distName || !wardName) {
      alert('Vui lòng chọn đầy đủ Tỉnh/Thành phố, Quận/Huyện và Phường/Xã để tính phí vận chuyển GHN.');
      e.preventDefault();
      return false;
    }

    // Ghép đầy đủ địa chỉ
    document.getElementById('fullAddressInput').value = detail.trim() + ', ' + wardName + ', ' + distName + ', ' + provName;
  });

  function escapeHtml(text) {
    return text ? text.replace(/"/g, '&quot;').replace(/'/g, '&#39;') : '';
  }
</script>

<jsp:include page="footer.jsp" />
