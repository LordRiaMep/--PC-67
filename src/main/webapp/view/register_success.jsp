<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<style>
.auth-box-card {
    background: #ffffff;
    max-width: 520px;
    width: 100%;
    margin: 0 auto;
    padding: 40px 30px;
    border-radius: 14px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    border: 1px solid #e5e7eb;
    text-align: center;
  }

  .mail-icon-wrap {
    width: 80px;
    height: 80px;
    background: #fff1f2;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 20px;
    color: #E30019;
    font-size: 38px;
    border: 2px dashed #fca5a5;
  }

  .auth-box-card h2 {
    color: #1f2937;
    font-weight: 700;
    font-size: 22px;
    margin-bottom: 10px;
  }

  .email-highlight {
    background: #f3f4f6;
    padding: 6px 14px;
    border-radius: 30px;
    display: inline-block;
    color: #E30019;
    font-weight: 700;
    font-size: 15px;
    margin: 10px 0 16px;
    word-break: break-all;
    border: 1px solid #e5e7eb;
  }

  .step-instructions {
    text-align: left;
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 10px;
    padding: 18px 20px;
    margin: 20px 0;
    font-size: 14px;
    color: #4b5563;
  }

  .step-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 12px;
  }

  .step-item:last-child {
    margin-bottom: 0;
  }

  .step-badge {
    background: #E30019;
    color: #ffffff;
    width: 22px;
    height: 22px;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-weight: bold;
    flex-shrink: 0;
    margin-top: 2px;
  }

  .btn-auth-red {
    background-color: #E30019;
    border: none;
    color: #ffffff;
    height: 44px;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 700;
    width: 100%;
    margin-top: 10px;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: background-color 0.2s ease;
  }

  .btn-auth-red:hover {
    background-color: #c80016;
    color: #ffffff;
  }

  .demo-box {
    background: #ecfdf5;
    border: 1px dashed #10b981;
    border-radius: 10px;
    padding: 16px;
    margin-top: 24px;
    text-align: left;
    font-size: 13.5px;
    color: #065f46;
  }
</style>

<div class="flex-grow-1 py-5" style="background-color: #f8f9fa;">
  <div class="container">
    <div class="auth-box-card">

      <div class="mail-icon-wrap">
        <i class="bi bi-envelope-check"></i>
      </div>

      <h2>XÁC NHẬN TẠO TÀI KHOẢN</h2>
      <p class="text-muted small mb-1">Chúng tôi đã gửi email xác thực kích hoạt tài khoản đến:</p>

      <div class="email-highlight">
        <i class="bi bi-envelope me-1"></i><c:out value="${registeredEmail != null ? registeredEmail : 'email của bạn'}" />
      </div>

      <c:if test="${resentSuccess}">
        <div class="alert alert-success py-2 small mb-3 rounded-3">
          <i class="bi bi-check-circle me-1"></i> Đã gửi lại email xác nhận mới! Vui lòng kiểm tra hộp thư.
        </div>
      </c:if>

      <div class="step-instructions">
        <div class="step-item">
          <span class="step-badge">1</span>
          <div>Mở hộp thư đến (InBox) của email trên (kiểm tra cả mục <strong>Spam / Thư rác</strong> nếu chưa thấy).</div>
        </div>
        <div class="step-item">
          <span class="step-badge">2</span>
          <div>Mở email từ <strong>Độ-PC 67 Store</strong> và bấm vào nút <strong>"XÁC NHẬN TẠO TÀI KHOẢN"</strong>.</div>
        </div>
        <div class="step-item">
          <span class="step-badge">3</span>
          <div>Hệ thống sẽ tự động kích hoạt tài khoản và chuyển bạn về lại trang đăng nhập để bắt đầu mua sắm!</div>
        </div>
      </div>

      <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
        <a href="${ctx}/resend-verification?email=${registeredEmail}" class="text-decoration-none small text-danger fw-semibold">
          <i class="bi bi-arrow-clockwise me-1"></i>Gửi lại email xác nhận
        </a>
        <a href="${ctx}/login" class="text-decoration-none small text-secondary">
          Quay lại Đăng nhập
        </a>
      </div>

    </div>
  </div>
</div>

<jsp:include page="footer.jsp" />
