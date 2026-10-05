<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="header.jsp" />

<!-- Giao diện sáng giống trang giỏ hàng: nền trắng, chữ đen -->
<div class="container my-5 bg-white p-4 rounded shadow-sm">
  <h2 class="fw-bold text-dark mb-4">Thanh toán</h2>

  <div class="row g-4">
    <div class="col-md-7">
      <form action="place-order" method="post">
        <div class="mb-3">
          <label class="form-label fw-semibold text-dark">Người nhận <span class="text-danger">*</span></label>
          <input type="text" name="name" value="${sessionScope.USER_LOGIN.fullName}" class="form-control" required>
        </div>
        <div class="mb-3">
          <label class="form-label fw-semibold text-dark">Số điện thoại <span class="text-danger">*</span></label>
          <input type="tel" name="phone" value="${sessionScope.USER_LOGIN.phone}" class="form-control" required>
        </div>
        <div class="mb-3">
          <label class="form-label fw-semibold text-dark">Địa chỉ nhận hàng <span class="text-danger">*</span></label>
          <textarea name="address" class="form-control" rows="2" required></textarea>
        </div>
        <div class="mb-4">
          <label class="form-label fw-semibold text-dark">Ghi chú</label>
          <textarea name="note" class="form-control" rows="3"></textarea>
        </div>

        <!-- Phương thức thanh toán -->
        <div class="mb-4">
          <label class="form-label fw-semibold text-dark">Phương thức thanh toán <span class="text-danger">*</span></label>

          <div class="form-check border rounded p-3 mb-2">
            <input class="form-check-input ms-0 me-2" type="radio" name="paymentMethod" id="pmCOD" value="COD" checked>
            <label class="form-check-label fw-semibold text-dark" for="pmCOD">
              <i class="fas fa-truck me-1"></i> Thanh toán khi nhận hàng (COD)
            </label>
          </div>

          <div class="form-check border rounded p-3">
            <input class="form-check-input ms-0 me-2" type="radio" name="paymentMethod" id="pmQR" value="QR">
            <label class="form-check-label fw-semibold text-dark" for="pmQR">
              <i class="fas fa-qrcode me-1"></i> Thanh toán trực tuyến qua QR code
            </label>
          </div>

          <div id="qrBox" class="border rounded p-3 mt-3 text-center bg-light" style="display:none;">
            <p class="mb-2 text-dark fw-semibold">Quét mã QR để chuyển khoản</p>
            <img src="${pageContext.request.contextPath}/assets/images/qr_payment.png"
                 alt="QR thanh toán" style="max-width:260px; width:100%;">
            <p class="mt-2 mb-0 text-dark">
              Số tiền: <strong class="text-danger"><fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,##0"/> đ</strong>
            </p>
            <p class="small text-muted mb-0">Nội dung chuyển khoản: <strong>Tên + SĐT đặt hàng</strong>. Shop sẽ xác nhận sau khi nhận được tiền.</p>
          </div>
        </div>

        <button type="submit" class="btn btn-danger fw-bold px-4 py-2">Xác nhận đặt hàng</button>
      </form>
    </div>

    <div class="col-md-5">
      <div class="border rounded p-3 bg-light">
        <h5 class="fw-bold text-dark border-bottom pb-3 mb-3">Đơn hàng</h5>
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
        <div class="d-flex justify-content-between align-items-center pt-1">
          <span class="fs-5 fw-semibold text-dark">Tổng:</span>
          <span class="text-danger fw-bold fs-4"><fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,##0"/> đ</span>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  document.querySelectorAll('input[name="paymentMethod"]').forEach(function (r) {
    r.addEventListener('change', function () {
      document.getElementById('qrBox').style.display =
              document.getElementById('pmQR').checked ? 'block' : 'none';
    });
  });
</script>

<jsp:include page="footer.jsp" />
