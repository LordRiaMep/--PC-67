<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký tài khoản</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
</head>
<body class="auth-page d-flex flex-column min-vh-100">

<jsp:include page="header.jsp" />

<div class="auth-wrapper flex-grow-1 d-flex justify-content-center align-items-center my-5">
    <div class="auth-card w-100" style="max-width: 500px;">
        <h2 class="text-white mb-4 text-center">Đăng ký tài khoản</h2>

        <c:if test="${not empty error}">
            <div class="alert alert-danger p-2 text-center small mb-3">${error}</div>
        </c:if>

        <form action="${ctx}/register" method="POST"
              onsubmit="if(password.value !== confirmPassword.value){ alert('Mật khẩu xác nhận không khớp!'); return false; }">

            <div class="mb-3">
                <label>Họ tên <span class="text-danger">*</span></label>
                <input type="text" name="fullName" class="form-control" required placeholder="Nhập họ và tên...">
            </div>

            <div class="mb-3">
                <label>Email <span class="text-danger">*</span></label>
                <input type="email" name="email" class="form-control" required placeholder="Nhập email...">
            </div>

            <div class="mb-3">
                <label>Mật khẩu <span class="text-danger">*</span></label>
                <input type="password" name="password" id="password" class="form-control" required placeholder="Nhập mật khẩu...">
            </div>

            <div class="mb-3">
                <label>Xác nhận mật khẩu <span class="text-danger">*</span></label>
                <input type="password" id="confirmPassword" class="form-control" required placeholder="Nhập lại mật khẩu...">
            </div>

            <div class="mb-3">
                <label>Số điện thoại</label>
                <input type="text" name="phone" class="form-control" placeholder="Nhập số điện thoại...">
            </div>

            <div class="mb-4">
                <label>Địa chỉ</label>
                <textarea name="address" class="form-control" rows="3" placeholder="Nhập địa chỉ..."></textarea>
            </div>

            <button type="submit" class="btn btn-primary w-100 mb-3 fw-bold">ĐĂNG KÝ</button>

            <div class="text-center">
                <span class="text-secondary">Đã có tài khoản?</span>
                <a href="${ctx}/login" class="text-primary text-decoration-none">Đăng nhập</a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="footer.jsp" />

</body>
</html>