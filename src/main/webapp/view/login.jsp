<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<style>
.auth-box-card {
    background: #ffffff;
    max-width: 440px;
    width: 100%;
    margin: 0 auto;
    padding: 35px 30px;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.07);
    border: 1px solid #e5e7eb;
  }

  .auth-box-card h2 {
    color: #E30019;
    font-weight: 700;
    font-size: 24px;
    text-align: center;
    margin-bottom: 6px;
  }

  .auth-box-card .sub-text {
    text-align: center;
    color: #6c757d;
    font-size: 14px;
    margin-bottom: 24px;
  }

  .auth-box-card label {
    font-size: 13.5px;
    font-weight: 600;
    color: #374151;
    margin-bottom: 6px;
    display: block;
  }

  .custom-auth-input {
    height: 44px;
    border: 1px solid #ced4da !important;
    border-radius: 8px !important;
    font-size: 14px;
    color: #1f2937;
    background-color: #ffffff !important;
    box-shadow: none !important;
    outline: none !important;
    transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
  }

  .custom-auth-input:focus {
    border-color: #E30019 !important;
    box-shadow: 0 0 0 0.2rem rgba(227, 0, 25, 0.15) !important;
    outline: none !important;
  }

  .custom-auth-input:-webkit-autofill,
  .custom-auth-input:-webkit-autofill:hover,
  .custom-auth-input:-webkit-autofill:focus,
  .custom-auth-input:-webkit-autofill:active {
    -webkit-box-shadow: 0 0 0 1000px #ffffff inset !important;
    -webkit-text-fill-color: #1f2937 !important;
    box-shadow: 0 0 0 1000px #ffffff inset !important;
    transition: background-color 5000s ease-in-out 0s;
  }

  .pass-wrapper {
    position: relative;
  }

  .pass-wrapper .custom-auth-input {
    padding-right: 40px !important;
  }

  .pass-toggle-btn {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    cursor: pointer;
    color: #6c757d;
    font-size: 16px;
    padding: 4px;
    line-height: 1;
    user-select: none;
    transition: color 0.15s ease;
  }

  .pass-toggle-btn:hover {
    color: #E30019;
  }

  .btn-auth-red {
    background-color: #E30019 !important;
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%) !important;
    border: none !important;
    color: #ffffff !important;
    height: 46px;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 700;
    width: 100%;
    margin-top: 10px;
    margin-bottom: 20px;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(227, 0, 25, 0.3) !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    transition: all 0.2s ease;
  }

  .btn-auth-red:hover {
    background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%) !important;
    background-color: #b91c1c !important;
    color: #ffffff !important;
    transform: translateY(-1.5px);
    box-shadow: 0 6px 18px rgba(220, 38, 38, 0.45) !important;
  }

  .switch-auth-box {
    text-align: center;
    font-size: 14px;
    color: #6c757d;
    padding-top: 16px;
    border-top: 1px solid #f1f3f5;
  }

  .switch-auth-box a {
    color: #E30019;
    font-weight: 600;
    text-decoration: none;
  }

  .switch-auth-box a:hover {
    text-decoration: underline;
  }

  .auth-remember-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 13.5px;
    margin-bottom: 12px;
  }

  .auth-remember-row label {
    font-size: 13.5px;
    margin-bottom: 0;
    cursor: pointer;
    color: #4b5563;
    display: inline-flex;
    align-items: center;
    gap: 6px;
  }

  .auth-remember-row input[type="checkbox"] {
    accent-color: #E30019;
    cursor: pointer;
  }

  .auth-remember-row a {
    color: #E30019;
    text-decoration: none;
    font-weight: 500;
  }

  .auth-remember-row a:hover {
    text-decoration: underline;
  }

  .lock-alert-box {
    background-color: #fff1f2;
    border: 1px solid #fecdd3;
    border-radius: 8px;
    padding: 14px;
    color: #9f1239;
    margin-bottom: 18px;
    font-size: 13.5px;
  }

  .lock-reason-inner {
    background-color: #ffffff;
    border-left: 3px solid #e11d48;
    padding: 6px 10px;
    margin: 6px 0;
    color: #1f2937;
    border-radius: 4px;
  }
</style>

<div class="flex-grow-1 py-5" style="background-color: #f8f9fa;">
  <div class="container">
    <div class="auth-box-card">

      <h2>ĐĂNG NHẬP</h2>
      <p class="sub-text">Chào mừng bạn quay lại với Độ-PC 67</p>

      <c:if test="${accountLocked}">
        <div class="lock-alert-box">
          <div class="fw-bold mb-1"><i class="bi bi-shield-x me-1"></i>Tài khoản đã bị tạm khóa!</div>
          <div>Lý do:</div>
          <div class="lock-reason-inner">
            <c:out value="${lockReason}" />
          </div>
          <c:if test="${not empty lockedAt}">
            <div class="text-muted small mb-1">
              Thời gian khóa: <strong><fmt:formatDate value="${lockedAt}" pattern="dd/MM/yyyy HH:mm:ss" /></strong>
            </div>
          </c:if>
          <div class="pt-1 mt-1 border-top border-danger-subtle small">
            Hotline hỗ trợ: <a href="tel:${supportHotline}" class="fw-bold text-danger">${supportHotline}</a> (8:00 - 21:00)
          </div>
        </div>
      </c:if>

      <c:if test="${not empty successMessage}">
        <div class="alert alert-success p-3 text-center small mb-3 rounded-3 shadow-sm border-0" style="background-color: #d1fae5; color: #065f46;">
          <i class="bi bi-check-circle-fill me-1 fs-6"></i> ${successMessage}
        </div>
      </c:if>

      <c:if test="${accountPending}">
        <div class="alert alert-warning p-3 small mb-3 rounded-3" style="background-color: #fef3c7; border: 1px solid #fde68a; color: #92400e;">
          <div class="fw-bold mb-1"><i class="bi bi-envelope-exclamation-fill me-1 text-warning"></i>Tài khoản chưa được kích hoạt!</div>
          <div class="mb-2">Tài khoản này chưa hoàn tất xác thực email. Vui lòng kiểm tra hộp thư (inbox/spam) để nhấn xác nhận.</div>
          <div class="pt-2 border-top border-warning-subtle text-end">
            <a href="${ctx}/resend-verification?email=${pendingEmail}" class="btn btn-sm btn-outline-dark fw-semibold">
              <i class="bi bi-send me-1"></i>Gửi lại email xác nhận
            </a>
          </div>
        </div>
      </c:if>

      <c:if test="${tempLocked}">
        <div class="lock-alert-box mb-3">
          <div class="fw-bold mb-1 text-danger"><i class="bi bi-shield-lock-fill me-1"></i>Tài khoản tạm thời bị khóa!</div>
          <div class="lock-reason-inner text-dark">
            <c:out value="${error}" />
          </div>
          <div class="pt-2 mt-2 border-top border-danger-subtle small d-flex justify-content-between align-items-center">
            <span>Bạn đã quên mật khẩu?</span>
            <a href="${ctx}/forgot-password?email=${enteredEmail}" class="btn btn-sm btn-danger fw-semibold text-white">
              <i class="bi bi-key me-1"></i>Khôi phục mật khẩu
            </a>
          </div>
        </div>
      </c:if>

      <c:if test="${not empty error && !accountLocked && !accountPending && !tempLocked}">
        <div class="alert alert-danger p-2 text-center small mb-3 rounded-3">${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm">

        <div class="mb-3">
          <label>Email <span class="text-danger">*</span></label>
          <input type="email"
                 name="email"
                 id="loginEmail"
                 class="form-control custom-auth-input"
                 required
                 placeholder="Nhập email..."
                 autocomplete="email"
                 value="<c:out value='${enteredEmail}'/>">
        </div>

        <div class="mb-3">
          <label>Mật khẩu <span class="text-danger">*</span></label>
          <div class="pass-wrapper">
            <input type="password"
                   name="password"
                   id="loginPassword"
                   class="form-control custom-auth-input"
                   required
                   placeholder="Nhập mật khẩu..."
                   autocomplete="current-password">
            <span class="pass-toggle-btn" onclick="togglePass('loginPassword', this)" title="Hiện/ẩn mật khẩu">
              <i class="bi bi-eye"></i>
            </span>
          </div>
        </div>

        <div class="auth-remember-row">
          <label>
            <input type="checkbox" id="rememberMe"> Ghi nhớ đăng nhập
          </label>
          <a href="${ctx}/forgot-password">
            Quên mật khẩu?
          </a>
        </div>

        <button type="submit" class="btn-auth-red">
          ĐĂNG NHẬP
        </button>

        <div class="switch-auth-box">
          Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a>
        </div>

      </form>
    </div>
  </div>
</div>

<script>
function togglePass(inputId, el) {
    var input = document.getElementById(inputId);
    if (!input) return;
    var icon = el.querySelector('i');
    if (input.type === 'password') {
      input.type = 'text';
      if (icon) {
        icon.classList.remove('bi-eye');
        icon.classList.add('bi-eye-slash');
      }
    } else {
      input.type = 'password';
      if (icon) {
        icon.classList.remove('bi-eye-slash');
        icon.classList.add('bi-eye');
      }
    }
  }

  document.addEventListener("DOMContentLoaded", function() {
    var emailInput = document.getElementById("loginEmail");
    var rememberCheck = document.getElementById("rememberMe");
    var savedEmail = localStorage.getItem("dopc_saved_email");

    if (savedEmail && emailInput && !emailInput.value) {
      emailInput.value = savedEmail;
      if (rememberCheck) rememberCheck.checked = true;
    }

    var form = document.getElementById("loginForm");
    if (form) {
      form.addEventListener("submit", function() {
        if (rememberCheck && rememberCheck.checked && emailInput) {
          localStorage.setItem("dopc_saved_email", emailInput.value.trim());
        } else {
          localStorage.removeItem("dopc_saved_email");
        }
      });
    }
  });
</script>

<jsp:include page="footer.jsp" />
