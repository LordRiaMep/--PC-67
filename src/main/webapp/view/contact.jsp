<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="zaloUrl" value="https://zalo.me/0904112618" />

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    request.setCharacterEncoding("UTF-8");
    // Nếu đã có thông báo từ ContactServlet thì không xử lý lại
    if (request.getAttribute("successMessage") == null && request.getAttribute("errorMessage") == null) {
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String topic = request.getParameter("topic");
        String message = request.getParameter("message");

        String cleanFullName = fullName != null ? fullName.trim() : "";
        String cleanPhone = phone != null ? phone.trim().replaceAll("[\\s.-]", "") : "";
        String cleanEmail = email != null ? email.trim() : "";
        String cleanTopic = topic != null ? topic.trim() : "Tư vấn cấu hình PC Gaming";
        String cleanMessage = message != null ? message.trim() : "";

        request.setAttribute("formFullName", fullName);
        request.setAttribute("formPhone", phone);
        request.setAttribute("formEmail", email);
        request.setAttribute("formTopic", topic);
        request.setAttribute("formMessage", message);

        String vnPhoneRegex = "^(0|\\+84)[35789][0-9]{8}$";
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";

        if (cleanFullName.isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập Họ và tên của bạn!");
        } else if (cleanPhone.isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập Số điện thoại liên hệ!");
        } else if (!cleanPhone.matches(vnPhoneRegex)) {
            request.setAttribute("errorMessage", "Số điện thoại không hợp lệ. Vui lòng nhập đúng số điện thoại theo định dạng Việt Nam (VD: 0904112618 hoặc +84904112618)!");
        } else if (!cleanEmail.isEmpty() && !cleanEmail.matches(emailRegex)) {
            request.setAttribute("errorMessage", "Địa chỉ email không đúng định dạng. Vui lòng nhập email hợp lệ (VD: name@example.com)!");
        } else {
            model.Contact c = new model.Contact();
            c.setFullName(cleanFullName);
            c.setPhone(cleanPhone);
            c.setEmail(cleanEmail);
            c.setTopic(cleanTopic);
            c.setMessage(cleanMessage);
            c.setStatus("Chưa xử lý");
            boolean ok = new dao.ContactDao().insert(c);
            if (ok) {
                util.realtime.RealtimeHub.broadcastContactCreated(c.getId(), c.getFullName(), c.getPhone(), c.getEmail(), c.getTopic(), c.getMessage());
            }

            request.setAttribute("successMessage", "Cảm ơn " + cleanFullName + "! Độ-PC 67 đã tiếp nhận yêu cầu liên hệ của bạn. Chuyên viên tư vấn sẽ liên hệ lại qua số " + cleanPhone + " trong vòng 15 phút.");
            request.setAttribute("submitted", true);
            request.removeAttribute("formFullName");
            request.removeAttribute("formPhone");
            request.removeAttribute("formEmail");
            request.removeAttribute("formMessage");
        }
    }
}
%>

<jsp:include page="header.jsp" />

<style>
.contact-hero {
        background: linear-gradient(135deg, #181c24 0%, #0d1015 100%);
        border-radius: 16px;
        color: #fff;
        padding: 40px 30px;
        position: relative;
        overflow: hidden;
        border: 1px solid rgba(255, 255, 255, 0.08);
    }
    .contact-hero::after {
        content: "";
        position: absolute;
        top: -50px;
        right: -50px;
        width: 250px;
        height: 250px;
        background: radial-gradient(circle, rgba(227, 0, 25, 0.25) 0%, rgba(0,0,0,0) 70%);
        pointer-events: none;
    }
    .contact-card {
        background: #fff;
        border-radius: 14px;
        padding: 24px;
        border: 1px solid #eef0f3;
        transition: all 0.25s ease;
        height: 100%;
        box-shadow: 0 4px 15px rgba(0,0,0,0.03);
    }
    .contact-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(227, 0, 25, 0.1);
        border-color: rgba(227, 0, 25, 0.3);
    }
    .contact-icon-circle {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 26px;
        margin-bottom: 16px;
        flex-shrink: 0;
    }
    .form-box {
        background: #fff;
        border-radius: 16px;
        padding: 32px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.04);
        border: 1px solid #e9ecef;
    }
    .map-box {
        background: #fff;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(0,0,0,0.04);
        border: 1px solid #e9ecef;
        height: 100%;
        display: flex;
        flex-direction: column;
    }
    .map-box iframe {
        width: 100%;
        min-height: 320px;
        flex: 1;
        border: 0;
    }
    .faq-accordion .accordion-button:not(.collapsed) {
        background-color: #fff1f2;
        color: #E30019;
        font-weight: 600;
    }
    .faq-accordion .accordion-button:focus {
        box-shadow: none;
    }
</style>

<div class="container py-4 flex-grow-1">

    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${ctx}/Home" class="text-decoration-none text-danger">Trang chủ</a></li>
            <li class="breadcrumb-item active" aria-current="page">Liên hệ</li>
        </ol>
    </nav>

    <div class="contact-hero mb-4 shadow-sm">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="badge bg-danger px-3 py-2 text-uppercase mb-2" style="letter-spacing: 0.5px;">
                    <i class="bi bi-headset me-1"></i> Trung tâm hỗ trợ khách hàng
                </span>
                <h2 class="fw-bold text-white mb-2">LIÊN HỆ VỚI ĐỘ-PC 67</h2>
                <p class="text-secondary mb-0" style="font-size: 15px; max-width: 650px;">
                    Chúng tôi luôn sẵn sàng lắng nghe mọi ý kiến đóng góp, giải đáp thắc mắc và đồng hành cùng quý khách để xây dựng dàn PC lý tưởng nhất.
                </p>
            </div>
            <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                <a href="${zaloUrl}" target="_blank" rel="noopener" class="btn btn-outline-light btn-lg px-4 me-2 rounded-pill fw-semibold">
                    <i class="bi bi-chat-dots-fill text-info me-1"></i> Zalo Official
                </a>
                <a href="tel:0904112618" class="btn btn-danger btn-lg px-4 rounded-pill fw-semibold">
                    <i class="bi bi-telephone-fill me-1"></i> Gọi Hotline
                </a>
            </div>
        </div>
    </div>

    <div class="row g-3 mb-4">

        <div class="col-sm-6 col-lg-3">
            <div class="contact-card">
                <div class="contact-icon-circle bg-danger-subtle text-danger">
                    <i class="bi bi-telephone-inbound-fill"></i>
                </div>
                <h6 class="fw-bold mb-1 text-dark">Tư vấn bán hàng</h6>
                <p class="text-muted small mb-2">Hỗ trợ chọn cấu hình, linh kiện & giá cả</p>
                <a href="tel:0904112618" class="fw-bold fs-5 text-danger text-decoration-none d-block">0904 112 618</a>
                <small class="text-secondary d-block mt-1"><i class="bi bi-clock me-1"></i>08:00 - 21:30 hàng ngày</small>
            </div>
        </div>

        <div class="col-sm-6 col-lg-3">
            <div class="contact-card">
                <div class="contact-icon-circle bg-primary-subtle text-primary">
                    <i class="bi bi-tools"></i>
                </div>
                <h6 class="fw-bold mb-1 text-dark">Kỹ thuật & Bảo hành</h6>
                <p class="text-muted small mb-2">Xử lý sự cố, cài đặt & tiếp nhận bảo hành</p>
                <a href="tel:0904112618" class="fw-bold fs-5 text-primary text-decoration-none d-block">0904 112 618</a>
                <small class="text-secondary d-block mt-1"><i class="bi bi-clock me-1"></i>08:30 - 18:00 (Thứ 2 - T7)</small>
            </div>
        </div>

        <div class="col-sm-6 col-lg-3">
            <div class="contact-card">
                <div class="contact-icon-circle bg-success-subtle text-success">
                    <i class="bi bi-geo-alt-fill"></i>
                </div>
                <h6 class="fw-bold mb-1 text-dark">Showroom Hải Phòng</h6>
                <p class="text-muted small mb-2">Trải nghiệm trực tiếp các dàn máy Hi-End</p>
                <span class="fw-semibold text-dark d-block" style="font-size: 14px;">15/2/437 Đà Nẵng, P. Đông Hải</span>
                <small class="text-secondary d-block mt-1"><i class="bi bi-pin-map me-1"></i>Q. Hải An, TP. Hải Phòng</small>
            </div>
        </div>

        <div class="col-sm-6 col-lg-3">
            <div class="contact-card">
                <div class="contact-icon-circle bg-warning-subtle text-warning">
                    <i class="bi bi-envelope-at-fill"></i>
                </div>
                <h6 class="fw-bold mb-1 text-dark">Email & Hợp tác</h6>
                <p class="text-muted small mb-2">Khiếu nại, báo giá dự án, hợp tác kinh doanh</p>
                <a href="mailto:dogiaphu50@gmail.com" class="fw-semibold text-dark text-decoration-none d-block text-truncate" style="font-size: 14px;">dogiaphu50@gmail.com</a>
                <small class="text-secondary d-block mt-1"><i class="bi bi-reply me-1"></i>Phản hồi trong 2-4 giờ</small>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-5">

        <div class="col-lg-7">
            <div class="form-box">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <span class="p-2 bg-danger-subtle text-danger rounded-3"><i class="bi bi-envelope-paper-fill fs-5"></i></span>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark">Gửi yêu cầu hỗ trợ</h4>
                        <small class="text-muted">Chúng tôi sẽ liên hệ lại với bạn trong vòng 15 phút</small>
                    </div>
                </div>

                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success d-flex align-items-center gap-2 mb-4 shadow-sm" role="alert">
                        <i class="bi bi-check-circle-fill fs-4 flex-shrink-0"></i>
                        <div>${successMessage}</div>
                    </div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger d-flex align-items-center gap-2 mb-4 shadow-sm" role="alert">
                        <i class="bi bi-exclamation-triangle-fill fs-4 flex-shrink-0"></i>
                        <div>${errorMessage}</div>
                    </div>
                </c:if>

                <form action="${ctx}/contact/" method="post" id="contactForm" onsubmit="return validateContactForm(event)">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold small text-dark">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" id="contactFullName" class="form-control py-2" placeholder="VD: Nguyễn Văn A" value="${formFullName}" required maxlength="50">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold small text-dark">Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" name="phone" id="contactPhone" class="form-control py-2" placeholder="VD: 0904 112 618" value="${formPhone}" 
                                   pattern="^(0|\+84)[35789][0-9]{8}$" 
                                   title="Số điện thoại Việt Nam gồm 10 chữ số (VD: 0904112618 hoặc +84904112618)" 
                                   required>
                            <div class="form-text text-muted" style="font-size: 11.5px;">Đầu số VN (03, 05, 07, 08, 09 hoặc +84)</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold small text-dark">Địa chỉ Email</label>
                            <input type="email" name="email" id="contactEmail" class="form-control py-2" placeholder="name@example.com" value="${formEmail}"
                                   pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                                   title="Địa chỉ email hợp lệ (VD: name@example.com)">
                            <div class="form-text text-muted" style="font-size: 11.5px;">Ví dụ: name@example.com</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold small text-dark">Nhu cầu cần hỗ trợ</label>
                            <select name="topic" class="form-select py-2">
                                <option value="Tư vấn cấu hình PC Gaming" ${formTopic == 'Tư vấn cấu hình PC Gaming' ? 'selected' : ''}>Tư vấn cấu hình PC Gaming</option>
                                <option value="Tư vấn PC Đồ họa / Workstation" ${formTopic == 'Tư vấn PC Đồ họa / Workstation' ? 'selected' : ''}>Tư vấn PC Đồ họa / Workstation</option>
                                <option value="Dịch vụ ráp máy tại nhà" ${formTopic == 'Dịch vụ ráp máy tại nhà' ? 'selected' : ''}>Dịch vụ ráp máy tại nhà</option>
                                <option value="Dịch vụ thu cũ đổi mới" ${formTopic == 'Dịch vụ thu cũ đổi mới' ? 'selected' : ''}>Dịch vụ thu cũ đổi mới linh kiện</option>
                                <option value="Hỗ trợ kỹ thuật / Bảo hành" ${formTopic == 'Hỗ trợ kỹ thuật / Bảo hành' ? 'selected' : ''}>Hỗ trợ kỹ thuật / Bảo hành</option>
                                <option value="Góp ý & Khiếu nại dịch vụ" ${formTopic == 'Góp ý & Khiếu nại dịch vụ' ? 'selected' : ''}>Góp ý & Khiếu nại dịch vụ</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small text-dark">Nội dung yêu cầu / Ghi chú chi tiết</label>
                            <textarea name="message" class="form-control" rows="4" placeholder="Mô tả cụ thể mong muốn của bạn (ngân sách, tựa game cần chơi, phần mềm đồ họa cần dùng hoặc sự cố kỹ thuật gặp phải)...">${formMessage}</textarea>
                        </div>
                        <div class="col-12 mt-4">
                            <button type="submit" class="btn btn-danger px-4 py-2 fw-semibold w-100 shadow-sm d-flex align-items-center justify-content-center gap-2" style="background-color: #E30019; border: none; border-radius: 8px;">
                                <i class="bi bi-send-fill"></i>
                                <span>Gửi thông tin liên hệ</span>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="map-box">
                <div class="p-3 bg-light border-bottom d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="fw-bold mb-0 text-dark"><i class="bi bi-geo-alt-fill text-danger me-1"></i> Vị trí Showroom Hải Phòng</h6>
                        <small class="text-muted">Số 15/2/437 Đà Nẵng, P. Đông Hải, Q. Hải An</small>
                    </div>
                    <a href="https://maps.google.com/?q=Số+15/2/437+Đà+Nẵng,+Đông+Hải,+Hải+An,+Hải+Phòng" target="_blank" class="btn btn-sm btn-outline-danger">
                        <i class="bi bi-box-arrow-up-right me-1"></i> Google Maps
                    </a>
                </div>

                <iframe
                    src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d14901.782806733235!2d106.7027552!3d20.8652399!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x314a70086d9a04a3%3A0xe54e5653b6cb5922!2zxJDDoCBO4bq1bmcsIEjhuqNpIEFuLCBI4bqjaSBQaMOybmcsIFZp4buHdCBOYW0!5e0!3m2!1svi!2s!4v1700000000000!5m2!1svi!2s"
                    allowfullscreen=""
                    loading="lazy"
                    referrerpolicy="no-referrer-when-downgrade">
                </iframe>

                <div class="p-3 bg-white">
                    <ul class="list-unstyled mb-0 small text-secondary">
                        <li class="mb-2 d-flex align-items-center gap-2">
                            <i class="bi bi-p-circle-fill text-success fs-6"></i>
                            <span>Bãi đỗ xe ô tô và xe máy rộng rãi, hoàn toàn miễn phí.</span>
                        </li>
                        <li class="mb-2 d-flex align-items-center gap-2">
                            <i class="bi bi-display-fill text-primary fs-6"></i>
                            <span>Phòng trải nghiệm thực tế với dàn PC cấu hình đỉnh cao & màn hình 240Hz.</span>
                        </li>
                        <li class="d-flex align-items-center gap-2">
                            <i class="bi bi-shield-fill-check text-danger fs-6"></i>
                            <span>Xem kỹ thuật viên lắp ráp trực tiếp & hướng dẫn test máy tại chỗ.</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-3 mb-5">
        <div class="col-md-6">
            <div class="p-4 rounded-4 text-white d-flex align-items-center justify-content-between" style="background: linear-gradient(135deg, #be0015 0%, #e30019 100%);">
                <div>
                    <span class="badge bg-white text-danger mb-2 fw-bold">Dịch vụ tại nhà</span>
                    <h5 class="fw-bold mb-1">Ráp máy tận nơi Hải Phòng</h5>
                    <p class="small mb-0 text-white-50">Kỹ thuật viên mang linh kiện đến tận nhà lắp ráp và cài đặt.</p>
                </div>
                <a href="${ctx}/service/assembly" class="btn btn-light fw-bold text-danger text-nowrap ms-3">
                    Xem ngay <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </div>
        <div class="col-md-6">
            <div class="p-4 rounded-4 text-white d-flex align-items-center justify-content-between" style="background: linear-gradient(135deg, #1f2937 0%, #111827 100%);">
                <div>
                    <span class="badge bg-danger text-white mb-2 fw-bold">Đổi cũ lấy mới</span>
                    <h5 class="fw-bold mb-1">Thu cũ đổi mới linh kiện</h5>
                    <p class="small mb-0 text-white-50">Định giá linh kiện cũ minh bạch, trợ giá lên đời dàn PC mới.</p>
                </div>
                <a href="${ctx}/service/trade-in" class="btn btn-outline-light fw-bold text-nowrap ms-3">
                    Chi tiết <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </div>
    </div>

    <div class="mb-5">
        <div class="text-center mb-4">
            <span class="text-danger fw-bold text-uppercase small" style="letter-spacing: 1px;">Hỗ trợ khách hàng</span>
            <h3 class="fw-bold text-dark">Câu hỏi thường gặp khi liên hệ</h3>
        </div>

        <div class="accordion faq-accordion shadow-sm rounded-3 overflow-hidden mx-auto" id="contactFaqAccordion" style="max-width: 900px;">
            <div class="accordion-item border-0 border-bottom">
                <h2 class="accordion-header" id="faqHeading1">
                    <button class="accordion-button collapsed py-3" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse1">
                        1. Độ-PC 67 có nhận giao hàng toàn quốc và thanh toán COD không?
                    </button>
                </h2>
                <div id="faqCollapse1" class="accordion-collapse collapse" data-bs-parent="#contactFaqAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        Có. Độ-PC 67 hợp tác cùng Giao Hàng Nhanh (GHN) và Viettel Post để giao hàng toàn quốc. Khách hàng được quyền kiểm tra hàng trước khi thanh toán (COD). Riêng tại khu vực nội thành TP. Hải Phòng, cửa hàng hỗ trợ giao hàng hỏa tốc trong vòng 2 giờ.
                    </div>
                </div>
            </div>

            <div class="accordion-item border-0 border-bottom">
                <h2 class="accordion-header" id="faqHeading2">
                    <button class="accordion-button collapsed py-3" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse2">
                        2. Tôi ở xa có được hỗ trợ kỹ thuật và cài đặt máy không?
                    </button>
                </h2>
                <div id="faqCollapse2" class="accordion-collapse collapse" data-bs-parent="#contactFaqAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        Tất cả các bộ máy bán ra đều được cài đặt sẵn hệ điều hành Windows bản quyền dùng thử, các driver mới nhất và kiểm tra stress test nhiệt độ ổn định. Sau khi nhận máy, kỹ thuật viên Độ-PC 67 sẵn sàng hỗ trợ cài đặt từ xa qua UltraViewer/TeamViewer hoàn toàn miễn phí.
                    </div>
                </div>
            </div>

            <div class="accordion-item border-0 border-bottom">
                <h2 class="accordion-header" id="faqHeading3">
                    <button class="accordion-button collapsed py-3" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse3">
                        3. Chính sách bảo hành và đổi mới khi sản phẩm gặp lỗi như thế nào?
                    </button>
                </h2>
                <div id="faqCollapse3" class="accordion-collapse collapse" data-bs-parent="#contactFaqAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        Độ-PC 67 cam kết 1 đổi 1 trong 30 ngày đầu tiên nếu linh kiện phát sinh lỗi từ nhà sản xuất. Trong suốt thời gian bảo hành chính hãng, khách hàng được cho mượn linh kiện hoặc máy thay thế để không gián đoạn công việc hay học tập.
                    </div>
                </div>
            </div>

            <div class="accordion-item border-0">
                <h2 class="accordion-header" id="faqHeading4">
                    <button class="accordion-button collapsed py-3" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse4">
                        4. Tôi muốn đến trực tiếp showroom test game và chọn case được không?
                    </button>
                </h2>
                <div id="faqCollapse4" class="accordion-collapse collapse" data-bs-parent="#contactFaqAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        Rất hoan nghênh bạn! Showroom tại số 15/2/437 Đà Nẵng, P. Đông Hải, Q. Hải An luôn có sẵn nhiều góc máy gaming cao cấp, các mẫu vỏ case LED RGB thời thượng để quý khách trải nghiệm trực tiếp trước khi quyết định mua hàng.
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

<script>
function validateContactForm(e) {
    const phoneInput = document.getElementById('contactPhone');
    const emailInput = document.getElementById('contactEmail');

    if (phoneInput) {
        const cleanPhone = phoneInput.value.replace(/[\s.-]/g, '');
        const vnPhoneRegex = /^(0|\+84)[35789][0-9]{8}$/;
        if (!vnPhoneRegex.test(cleanPhone)) {
            alert('Số điện thoại không hợp lệ!\nVui lòng nhập đúng số điện thoại theo định dạng Việt Nam (VD: 0904112618 hoặc +84904112618).');
            phoneInput.focus();
            if (e) e.preventDefault();
            return false;
        }
        phoneInput.value = cleanPhone;
    }

    if (emailInput && emailInput.value.trim() !== '') {
        const cleanEmail = emailInput.value.trim();
        const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        if (!emailRegex.test(cleanEmail)) {
            alert('Địa chỉ email không đúng định dạng!\nVui lòng nhập email hợp lệ (VD: name@example.com).');
            emailInput.focus();
            if (e) e.preventDefault();
            return false;
        }
    }

    return true;
}
</script>

<jsp:include page="footer.jsp" />
