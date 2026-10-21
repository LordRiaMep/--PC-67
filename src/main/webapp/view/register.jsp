<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<style>
  /* Khung Card Đăng Ký - Thuận mắt, gọn gàng */
  .auth-box-card {
    background: #ffffff;
    max-width: 480px;
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

  /* Ô input - Ghi đè triệt để mọi viền xanh & outline xanh của Bootstrap */
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

  /* Xóa màu nền xanh nhạt khi Chrome / Edge tự động điền (Autofill) */
  .custom-auth-input:-webkit-autofill,
  .custom-auth-input:-webkit-autofill:hover,
  .custom-auth-input:-webkit-autofill:focus,
  .custom-auth-input:-webkit-autofill:active {
    -webkit-box-shadow: 0 0 0 1000px #ffffff inset !important;
    -webkit-text-fill-color: #1f2937 !important;
    box-shadow: 0 0 0 1000px #ffffff inset !important;
    transition: background-color 5000s ease-in-out 0s;
  }

  /* Nút con mắt ẩn/hiện mật khẩu nằm gọn gàng góc phải */
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

  /* Nút bấm Đăng Ký màu đỏ thương hiệu Độ-PC 67 */
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

  /* Dòng chuyển hướng sang Đăng nhập */
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

      <h2>ĐĂNG KÝ TÀI KHOẢN</h2>
      <p class="sub-text">Tạo tài khoản thành viên tại Độ-PC 67</p>

      <c:if test="${not empty error}">
        <div class="alert alert-danger p-2 text-center small mb-3 rounded-3">${error}</div>
      </c:if>

      <form action="${ctx}/register" method="POST" id="regForm">

        <div class="mb-3">
          <label>Họ và tên <span class="text-danger">*</span> <span class="text-muted fw-normal small">(Tối đa 25 ký tự)</span></label>
          <input type="text" 
                 name="fullName" 
                 id="fullName" 
                 maxlength="25"
                 class="form-control custom-auth-input" 
                 required 
                 placeholder="Nhập họ và tên (tối đa 25 ký tự)..."
                 value="<c:out value='${param.fullName}'/>">
          <div class="text-danger-msg" id="nameErrorMsg">Họ tên tối đa 25 ký tự và không được chứa số, icon hoặc ký tự lạ!</div>
        </div>

        <div class="mb-3">
          <label>Số điện thoại <span class="text-muted fw-normal small">(Định dạng Việt Nam: 0912345678 hoặc +84912345678)</span></label>
          <input type="tel" 
                 name="phone" 
                 id="phone" 
                 class="form-control custom-auth-input" 
                 placeholder="VD: 0912345678 hoặc +84912345678"
                 value="<c:out value='${param.phone}'/>">
          <div class="text-danger-msg" id="phoneErrorMsg">Số điện thoại phải thuộc vùng Việt Nam (VD: 0912345678 hoặc +84912345678)!</div>
        </div>

        <div class="mb-3">
          <label>Địa chỉ Email <span class="text-danger">*</span></label>
          <input type="email" 
                 name="email" 
                 id="email" 
                 class="form-control custom-auth-input" 
                 required 
                 placeholder="Nhập địa chỉ email..."
                 value="<c:out value='${param.email}'/>">
        </div>

        <div class="mb-3">
          <label>Mật khẩu <span class="text-danger">*</span></label>
          <div class="pass-wrapper">
            <input type="password" 
                   name="password" 
                   id="password" 
                   class="form-control custom-auth-input" 
                   required 
                   placeholder="Tối thiểu 6 ký tự, không chứa icon/ký tự lạ...">
            <span class="pass-toggle-btn" onclick="togglePass('password', this)" title="Hiện/ẩn mật khẩu">
              <i class="bi bi-eye"></i>
            </span>
          </div>
          <div class="text-danger-msg" id="passErrorMsg">Mật khẩu tối thiểu 6 ký tự, không chứa khoảng trắng, icon hoặc ký tự lạ!</div>
        </div>

        <div class="mb-3">
          <label>Xác nhận mật khẩu <span class="text-danger">*</span></label>
          <div class="pass-wrapper">
            <input type="password" 
                   id="confirmPassword" 
                   class="form-control custom-auth-input" 
                   required 
                   placeholder="Nhập lại mật khẩu...">
            <span class="pass-toggle-btn" onclick="togglePass('confirmPassword', this)" title="Hiện/ẩn mật khẩu">
              <i class="bi bi-eye"></i>
            </span>
          </div>
          <div class="text-danger-msg" id="passMismatchMsg">Mật khẩu xác nhận không khớp!</div>
        </div>

        <div class="mb-4">
          <label>Địa chỉ nhận hàng</label>
          <textarea name="address" 
                    id="address" 
                    class="form-control custom-auth-input" 
                    rows="2" 
                    style="height: auto;" 
                    placeholder="Nhập địa chỉ giao hàng..."><c:out value='${param.address}'/></textarea>
        </div>

        <button type="submit" class="btn-auth-red">
          ĐĂNG KÝ
        </button>

        <div class="switch-auth-box">
          Đã có tài khoản? <a href="${ctx}/login">Đăng nhập</a>
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

  document.getElementById('regForm').addEventListener('submit', function(e) {
    var valid = true;

    // Họ và tên: tối đa 25 ký tự, chỉ chữ cái và khoảng trắng, không icon ký tự lạ
    var name = document.getElementById('fullName').value.trim();
    var nameMsg = document.getElementById('nameErrorMsg');
    var nameRegex = /^[\p{L}\s]{1,25}$/u;
    if (name.length === 0 || name.length > 25 || !nameRegex.test(name)) {
      nameMsg.style.display = 'block';
      document.getElementById('fullName').focus();
      valid = false;
    } else {
      nameMsg.style.display = 'none';
    }

    // Số điện thoại Việt Nam (0912345678 hoặc +84912345678)
    var phone = document.getElementById('phone').value.trim();
    var phoneMsg = document.getElementById('phoneErrorMsg');
    var phoneRegex = /^(0|\+84)[35789][0-9]{8}$/;
    if (phone && !phoneRegex.test(phone)) {
      phoneMsg.style.display = 'block';
      if (valid) { document.getElementById('phone').focus(); valid = false; }
    } else {
      phoneMsg.style.display = 'none';
    }

    // Mật khẩu: tối thiểu 6 ký tự, chuẩn ký tự bàn phím, không icon ký tự lạ
    var pass = document.getElementById('password').value;
    var passMsg = document.getElementById('passErrorMsg');
    var passRegex = /^[\x21-\x7E]{6,}$/;
    if (!pass || !passRegex.test(pass)) {
      passMsg.style.display = 'block';
      if (valid) { document.getElementById('password').focus(); valid = false; }
    } else {
      passMsg.style.display = 'none';
    }

    // Khớp mật khẩu
    var confirm = document.getElementById('confirmPassword').value;
    var mismatchMsg = document.getElementById('passMismatchMsg');
    if (pass !== confirm) {
      mismatchMsg.style.display = 'block';
      if (valid) { document.getElementById('confirmPassword').focus(); valid = false; }
    } else {
      mismatchMsg.style.display = 'none';
    }

    if (!valid) {
      e.preventDefault();
      return false;
    }
  });

  document.getElementById('confirmPassword').addEventListener('input', function() {
    var pass = document.getElementById('password').value;
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