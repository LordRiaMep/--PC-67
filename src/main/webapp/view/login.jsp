<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Đăng nhập</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="auth-page d-flex flex-column min-vh-100">

<jsp:include page="header.jsp" />

<div class="auth-wrapper flex-grow-1">
  <div class="auth-card">
    <h2 class="text-center text-white mb-4">Đăng nhập</h2>

    <% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-danger p-2 text-center small mb-3">
      <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <form action="${pageContext.request.contextPath}/login" method="POST">
      <div class="mb-3">
        <label>Email <span class="text-danger">*</span></label>
        <input type="email" name="email" class="form-control" required placeholder="Nhập email...">
      </div>
      <div class="mb-4">
        <label>Mật khẩu <span class="text-danger">*</span></label>
        <input type="password" name="password" class="form-control" required placeholder="Nhập mật khẩu...">
      </div>

      <button type="submit" class="btn btn-primary w-100 mb-3 fw-bold">ĐĂNG NHẬP</button>

      <div class="text-center mb-3">
        <span class="text-secondary">Chưa có tài khoản?</span>
        <a href="${pageContext.request.contextPath}/register" class="text-primary text-decoration-none">Đăng ký ngay</a>
      </div>

      <hr class="border-secondary my-3">

      <div class="small">
        <div class="mb-1">
        </div>
      </div>
    </form>
  </div>
</div>

<jsp:include page="footer.jsp" />

</body>
</html>