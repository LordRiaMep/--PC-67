<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp" />

<div class="container my-4" style="max-width: 1140px;">

    <jsp:include page="profile_nav.jsp">
        <jsp:param name="active" value="password"/>
    </jsp:include>

    <c:if test="${not empty sessionScope.pwSuccess}">
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="bi bi-check-circle me-2"></i><c:out value="${sessionScope.pwSuccess}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="pwSuccess" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.pwError}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="bi bi-exclamation-triangle me-2"></i><c:out value="${sessionScope.pwError}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="pwError" scope="session"/>
    </c:if>

    <div class="pf-card p-4 mb-4">
        <div class="pf-card-title mb-1"><i class="bi bi-shield-lock"></i>Đổi mật khẩu</div>
        <p class="text-muted small mb-4">Để bảo vệ tài khoản, hệ thống yêu cầu xác thực mã OTP gửi về Email trước khi cập nhật mật khẩu mới.</p>

        <form method="post" action="${ctx}/change-password" onsubmit="return checkPw();">
            <!-- 3 ô mật khẩu nằm ngang -->
            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <label class="form-label">Mật khẩu hiện tại <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <input type="password" name="oldPassword" id="oldPw" class="form-control" required placeholder="Nhập mật khẩu hiện tại...">
                        <button class="btn btn-outline-secondary pw-toggle" type="button" tabindex="-1"><i class="bi bi-eye"></i></button>
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Mật khẩu mới <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <input type="password" id="newPw" name="newPassword" class="form-control" minlength="6" required placeholder="Tối thiểu 6 ký tự...">
                        <button class="btn btn-outline-secondary pw-toggle" type="button" tabindex="-1"><i class="bi bi-eye"></i></button>
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Nhập lại mật khẩu mới <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <input type="password" id="confirmPw" name="confirmPassword" class="form-control" required placeholder="Nhập lại mật khẩu mới...">
                        <button class="btn btn-outline-secondary pw-toggle" type="button" tabindex="-1"><i class="bi bi-eye"></i></button>
                    </div>
                </div>
            </div>

            <!-- XÁC THỰC MÃ OTP QUA EMAIL -->
            <div class="p-3 rounded-3 border bg-light mb-4">
                <label class="form-label fw-bold text-dark d-block mb-1">
                    <i class="bi bi-envelope-shield text-danger me-1"></i>Xác thực mã OTP gửi qua Email <span class="text-danger">*</span>
                </label>
                <div class="text-muted small mb-2">
                    Mã xác thực 6 chữ số sẽ được gửi tới hộp thư: <strong><c:out value="${sessionScope.USER_LOGIN.email}"/></strong>
                </div>
                <div class="row g-2 align-items-center" style="max-width: 450px;">
                    <div class="col-7">
                        <input type="text" 
                               name="otpCode" 
                               id="otpCode" 
                               class="form-control fw-bold text-center letter-spacing-2" 
                               required 
                               maxlength="6" 
                               placeholder="Nhập 6 số OTP...">
                    </div>
                    <div class="col-5">
                        <button type="button" id="btnSendOtp" class="btn btn-outline-danger w-100 fw-semibold text-nowrap" onclick="sendOtpEmail()">
                            <i class="bi bi-send me-1"></i>Gửi mã OTP
                        </button>
                    </div>
                </div>
                <div id="otpNotice" class="small mt-2" style="display: none;"></div>
            </div>

            <div class="text-end">
                <button type="submit" class="btn btn-brand"><i class="bi bi-key me-1"></i>Xác nhận & Cập nhật mật khẩu</button>
            </div>
        </form>
    </div>
</div>

<script>
    function checkPw() {
        var oldPw = document.getElementById('oldPw').value;
        var newPw = document.getElementById('newPw').value;
        var confirmPw = document.getElementById('confirmPw').value;
        var otp = document.getElementById('otpCode').value.trim();

        if (newPw !== confirmPw) {
            alert('Mật khẩu xác nhận không khớp!');
            return false;
        }
        if (newPw === oldPw) {
            alert('Mật khẩu mới phải khác mật khẩu hiện tại!');
            return false;
        }
        if (!otp || otp.length < 6) {
            alert('Vui lòng nhập đầy đủ mã OTP 6 số nhận từ email!');
            return false;
        }
        return true;
    }

    // Nút hiện / ẩn mật khẩu
    document.querySelectorAll('.pw-toggle').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var input = btn.parentElement.querySelector('input');
            var icon = btn.querySelector('i');
            var show = input.type === 'password';
            input.type = show ? 'text' : 'password';
            icon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
        });
    });

    // Gửi mã OTP qua AJAX
    function sendOtpEmail() {
        var btn = document.getElementById('btnSendOtp');
        var notice = document.getElementById('otpNotice');

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Đang gửi...';

        fetch('${ctx}/send-password-otp', {
            method: 'POST',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (data.success) {
                notice.style.display = 'block';
                notice.className = 'small mt-2 text-success fw-semibold';
                var text = '<i class="bi bi-check-circle me-1"></i>' + data.message;
                notice.innerHTML = text;

                // Đếm ngược 60 giây
                var countdown = 60;
                var timer = setInterval(function() {
                    countdown--;
                    if (countdown <= 0) {
                        clearInterval(timer);
                        btn.disabled = false;
                        btn.innerHTML = '<i class="bi bi-arrow-clockwise me-1"></i>Gửi lại OTP';
                    } else {
                        btn.innerHTML = 'Gửi lại (' + countdown + 's)';
                    }
                }, 1000);
            } else {
                notice.style.display = 'block';
                notice.className = 'small mt-2 text-danger fw-semibold';
                notice.innerHTML = '<i class="bi bi-exclamation-triangle me-1"></i>' + (data.message || 'Không thể gửi OTP!');
                btn.disabled = false;
                btn.innerHTML = '<i class="bi bi-send me-1"></i>Thử lại';
            }
        })
        .catch(function(err) {
            notice.style.display = 'block';
            notice.className = 'small mt-2 text-danger fw-semibold';
            notice.innerHTML = '<i class="bi bi-exclamation-triangle me-1"></i>Lỗi kết nối máy chủ!';
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-send me-1"></i>Gửi mã OTP';
        });
    }
</script>

<jsp:include page="footer.jsp" />
