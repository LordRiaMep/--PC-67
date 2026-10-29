<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<style>
.auth-box-card {
    background: #ffffff;
    max-width: 460px;
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
    background-color: #E30019;
    border: none;
    color: #ffffff;
    height: 44px;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 700;
    width: 100%;
    margin-top: 10px;
    margin-bottom: 20px;
    cursor: pointer;
    transition: background-color 0.2s ease;
  }

  .btn-auth-red:hover {
    background-color: #c80016;
    color: #ffffff;
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

  .text-danger-msg {
    color: #dc2626;
    font-size: 12.5px;
    margin-top: 4px;
    display: none;
  }
</style>

<div class="flex-grow-1 py-5" style="background-color: #f8f9fa;">
  <div class="container">
    <div class="auth-box-card">

      <h2>ĐẶT LẠI MẬT KHẨU</h2>
      <p class="sub-text">Thiết lập mật khẩu mới cho tài khoản <strong class="text-dark"><c:out value="${resetEmail}"/></strong></p>

      <c:if test="${not empty error}">
        <div class="alert alert-danger p-2 text-center small mb-3 rounded-3">${error}</div>
      </c:if>

      <form action="${ctx}/reset-password" method="POST" id="resetForm">
        <input type="hidden" name="token" value="<c:out value='${token}'/>">

        <div class="mb-3">
          <label>Mật khẩu mới <span class="text-danger">*</span></label>
          <div class="pass-wrapper">
            <input type="password"
                   name="newPassword"
                   id="newPassword"
                   class="form-control custom-auth-input"
                   required
                   minlength="6"
                   placeholder="Nhập mật khẩu mới (tối thiểu 6 ký tự)...">
            <span class="pass-toggle-btn" onclick="togglePass('newPassword', this)" title="Hiện/ẩn mật khẩu">
              <i class="bi bi-eye"></i>
            </span>
          </div>
        </div>

        <div class="mb-3">
          <label>Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
          <div class="pass-wrapper">
            <input type="password"
                   name="confirmPassword"
                   id="confirmPassword"
                   class="form-control custom-auth-input"
                   required
                   placeholder="Nhập lại mật khẩu mới...">
            <span class="pass-toggle-btn" onclick="togglePass('confirmPassword', this)" title="Hiện/ẩn mật khẩu">
              <i class="bi bi-eye"></i>
            </span>
          </div>
          <div class="text-danger-msg" id="passMismatchMsg">Mật khẩu xác nhận không khớp!</div>
        </div>

        <button type="submit" class="btn-auth-red">
          CẬP NHẬT MẬT KHẨU MỚI
        </button>

        <div class="switch-auth-box">
          <a href="${ctx}/login">Hủy bỏ và quay lại đăng nhập</a>
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

  document.getElementById('resetForm').addEventListener('submit', function(e) {
    var pass = document.getElementById('newPassword').value;
    var confirm = document.getElementById('confirmPassword').value;
    var msg = document.getElementById('passMismatchMsg');

    if (pass !== confirm) {
      e.preventDefault();
      msg.style.display = 'block';
      document.getElementById('confirmPassword').focus();
      return false;
    } else {
      msg.style.display = 'none';
    }
  });

  document.getElementById('confirmPassword').addEventListener('input', function() {
    var pass = document.getElementById('newPassword').value;
    var confirm = this.value;
    var msg = document.getElementById('passMismatchMsg');
    if (confirm && pass !== confirm) {
      msg.style.display = 'block';
    } else {
      msg.style.display = 'none';
    }
  });
</script>

<jsp:include page="footer.jsp" />
