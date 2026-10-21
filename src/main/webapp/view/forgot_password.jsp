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

  .demo-box {
    background: #ecfdf5;
    border: 1px dashed #10b981;
    border-radius: 10px;
    padding: 14px;
    margin-bottom: 20px;
    font-size: 13px;
    color: #065f46;
  }
</style>

<div class="flex-grow-1 py-5" style="background-color: #f8f9fa;">
  <div class="container">
    <div class="auth-box-card">

      <h2>QUÊN MẬT KHẨU</h2>
      <p class="sub-text">Nhập email đăng ký để nhận liên kết đặt lại mật khẩu</p>

      <c:if test="${not empty error}">
        <div class="alert alert-danger p-2 text-center small mb-3 rounded-3">${error}</div>
      </c:if>

      <c:if test="${emailSent}">
        <div class="alert alert-success p-3 text-center small mb-3 rounded-3">
          <i class="bi bi-envelope-check-fill fs-4 d-block mb-1 text-success"></i>
          Đã gửi email khôi phục mật khẩu đến: <br>
          <strong class="text-dark"><c:out value="${sentEmail}"/></strong>.<br>
          <span class="text-muted small">Vui lòng kiểm tra hộp thư trong vòng 30 phút để thiết lập mật khẩu mới.</span>
        </div>


      </c:if>

      <form action="${ctx}/forgot-password" method="POST">

        <div class="mb-3">
          <label>Địa chỉ Email tài khoản <span class="text-danger">*</span></label>
          <input type="email" 
                 name="email" 
                 class="form-control custom-auth-input" 
                 required 
                 placeholder="Nhập email tài khoản của bạn..."
                 value="<c:out value='${enteredEmail != null ? enteredEmail : param.email}'/>">
        </div>

        <button type="submit" class="btn-auth-red">
          GỬI LIÊN KẾT XÁC NHẬN
        </button>

        <div class="switch-auth-box">
          Nhớ lại mật khẩu? <a href="${ctx}/login">Quay lại đăng nhập</a>
        </div>

      </form>
    </div>
  </div>
</div>

<jsp:include page="footer.jsp" />
