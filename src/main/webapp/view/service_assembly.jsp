<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="zaloUrl" value="https://zalo.me/0904112618" />

<jsp:include page="/view/header.jsp" />

<link rel="stylesheet" href="${ctx}/assets/css/service.css?v=2">

<main class="flex-grow-1 svc-page theme-red pb-5">
    <div class="container pt-4">

        <!-- BREADCRUMB -->
        <nav aria-label="breadcrumb" class="svc-crumb mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${ctx}/Home">Trang chủ</a></li>
                <li class="breadcrumb-item active" aria-current="page">Ráp máy tại nhà</li>
            </ol>
        </nav>

        <!-- HERO -->
        <section class="svc-hero svc-fade">
            <div class="row align-items-center g-4">
                <div class="col-lg-7">
                    <span class="svc-eyebrow"><i class="bi bi-stars"></i> Dịch vụ tại nhà</span>
                    <h1 class="mt-3 mb-3">Độ PC 67 <span class="svc-hl">ráp máy tại nhà</span><br>khỏi cần đi xa</h1>
                    <p class="svc-lead mb-4">
                        Mang linh kiện đến tận nhà, lắp đặt tận nơi và tối ưu cấu hình theo nhu cầu học tập,
                        làm việc hay gaming của bạn. Bạn chỉ cần ngồi nhà, phần còn lại để Độ PC 67 lo.
                    </p>
                    <div class="d-flex flex-wrap gap-3 mb-3">
                        <a href="${zaloUrl}" target="_blank" rel="noopener" class="btn-zalo">
                            <span class="zalo-mark">Zalo</span> Liên hệ Zalo tư vấn
                        </a>
                        <a href="#quy-trinh" class="btn-ghost">Xem quy trình <i class="bi bi-arrow-down"></i></a>
                    </div>
                    <div class="svc-zalo-note"><i class="bi bi-chat-dots-fill me-1"></i> Zalo: 0904 112 618</div>
                </div>

                <div class="col-lg-5 d-none d-lg-block">
                    <div class="svc-visual">
                        <span class="svc-chip c1"><i class="bi bi-house-door-fill"></i> Tận nhà</span>
                        <div class="svc-visual-icon"><i class="bi bi-pc-display-horizontal"></i></div>
                        <ul class="svc-checks">
                            <li><i class="bi bi-check-circle-fill"></i> Tư vấn đúng nhu cầu, đúng ngân sách</li>
                            <li><i class="bi bi-check-circle-fill"></i> Lắp đặt, đi dây gọn gàng tại nhà</li>
                            <li><i class="bi bi-check-circle-fill"></i> Cài Windows, driver và chạy thử</li>
                        </ul>
                        <span class="svc-chip c2"><i class="bi bi-shield-check"></i> Chạy thử</span>
                    </div>
                </div>
            </div>
        </section>

        <!-- THANH CAM KẾT -->
        <section class="svc-trust svc-fade" style="--d:.15s">
            <div class="row g-0">
                <div class="col-6 col-lg-3">
                    <div class="svc-trust-item">
                        <span class="svc-trust-ico"><i class="bi bi-headset"></i></span>
                        <div><b>Hỗ trợ nhiệt tình</b><small>Tư vấn miễn phí</small></div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="svc-trust-item">
                        <span class="svc-trust-ico"><i class="bi bi-diagram-3-fill"></i></span>
                        <div><b>Đi dây gọn gàng</b><small>Thẩm mỹ, thoáng gió</small></div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="svc-trust-item">
                        <span class="svc-trust-ico"><i class="bi bi-arrow-left-right"></i></span>
                        <div><b>Cho mượn thiết bị</b><small>Khi bảo hành tại cửa hàng</small></div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="svc-trust-item">
                        <span class="svc-trust-ico"><i class="bi bi-emoji-smile-fill"></i></span>
                        <div><b>Cam kết 100% hài lòng</b><small>Trải nghiệm mua sắm tại Độ PC 67</small></div>
                    </div>
                </div>
            </div>
        </section>

        <!-- LỢI ÍCH -->
        <section>
            <div class="svc-head">
                <span class="tag">Lợi ích</span>
                <h2>Vì sao nên ráp máy tại nhà?</h2>
                <p>Tiết kiệm thời gian, yên tâm về chất lượng và luôn có người hỗ trợ khi bạn cần.</p>
            </div>
            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-chat-dots-fill"></i></div>
                        <h3>Tư vấn đúng nhu cầu</h3>
                        <p>Chọn cấu hình sát ngân sách và mục đích sử dụng, không mua thừa, không thiếu.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-house-door-fill"></i></div>
                        <h3>Lắp đặt tận nhà</h3>
                        <p>Kỹ thuật viên mang linh kiện đến tận nơi, bạn không cần vận chuyển hay chờ đợi.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-patch-check-fill"></i></div>
                        <h3>Kiểm tra &amp; chạy thử</h3>
                        <p>Test hoạt động, nhiệt độ và hiệu năng ngay tại chỗ trước khi bàn giao.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-headset"></i></div>
                        <h3>Hỗ trợ lâu dài</h3>
                        <p>Có vấn đề sau khi sử dụng, chỉ cần nhắn Zalo là có người hỗ trợ.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- PHÙ HỢP NHU CẦU NÀO -->
        <section>
            <div class="svc-head">
                <span class="tag">Nhu cầu</span>
                <h2>Cấu hình phù hợp với mọi nhu cầu</h2>
                <p>Dù học tập, làm việc hay chiến game, Độ PC 67 đều có phương án cho bạn.</p>
            </div>
            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-briefcase-fill"></i></div>
                        <h3>Học tập &amp; Văn phòng</h3>
                        <p>Mượt mà cho Office, học online và công việc hằng ngày.</p>
                        <div class="svc-tags"><span class="svc-tag">Tiết kiệm</span><span class="svc-tag">Êm ái</span></div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-joystick"></i></div>
                        <h3>Gaming</h3>
                        <p>Chiến mượt từ game eSports đến các tựa game nặng.</p>
                        <div class="svc-tags"><span class="svc-tag">FPS cao</span><span class="svc-tag">Tản nhiệt tốt</span></div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-camera-video-fill"></i></div>
                        <h3>Streaming &amp; Sáng tạo</h3>
                        <p>Vừa chơi vừa livestream, dựng video không lo giật lag.</p>
                        <div class="svc-tags"><span class="svc-tag">Livestream</span><span class="svc-tag">Dựng video</span></div>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-pc-display-horizontal"></i></div>
                        <h3>Workstation &amp; Đồ họa</h3>
                        <p>Render, thiết kế 3D và lập trình nặng, chạy ổn định bền bỉ.</p>
                        <div class="svc-tags"><span class="svc-tag">Render</span><span class="svc-tag">3D</span></div>
                    </div>
                </div>
            </div>
        </section>

        <!-- QUY TRÌNH -->
        <section id="quy-trinh">
            <div class="svc-head">
                <span class="tag">Quy trình</span>
                <h2>4 bước nhận PC ngay tại nhà</h2>
                <p>Đơn giản, rõ ràng và không mất công di chuyển.</p>
            </div>
            <div class="row g-4 svc-steps">
                <div class="col-md-6 col-lg-3">
                    <div class="svc-step">
                        <span class="no">01</span>
                        <div class="ico"><i class="bi bi-chat-left-text-fill"></i></div>
                        <h3>Nhắn Zalo tư vấn</h3>
                        <p>Cho biết nhu cầu và ngân sách, bên mình tư vấn và chốt cấu hình cùng bạn.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-step">
                        <span class="no">02</span>
                        <div class="ico"><i class="bi bi-calendar-check-fill"></i></div>
                        <h3>Hẹn lịch đến nhà</h3>
                        <p>Chọn thời gian phù hợp, kỹ thuật viên mang linh kiện đến tận nơi.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-step">
                        <span class="no">03</span>
                        <div class="ico"><i class="bi bi-tools"></i></div>
                        <h3>Ráp máy &amp; cài đặt</h3>
                        <p>Lắp ráp, đi dây gọn gàng, cài Windows và driver cần thiết.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-step">
                        <span class="no">04</span>
                        <div class="ico"><i class="bi bi-patch-check-fill"></i></div>
                        <h3>Chạy thử &amp; bàn giao</h3>
                        <p>Kiểm tra toàn bộ, hướng dẫn sử dụng rồi bàn giao cho bạn.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- CÂU HỎI THƯỜNG GẶP -->
        <section>
            <div class="svc-head">
                <span class="tag">Hỏi đáp</span>
                <h2>Câu hỏi thường gặp</h2>
            </div>
            <div class="accordion svc-faq" id="faqAssembly">
                <div class="accordion-item">
                    <h3 class="accordion-header">
                        <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#a1">
                            Dịch vụ áp dụng ở khu vực nào?
                        </button>
                    </h3>
                    <div id="a1" class="accordion-collapse collapse show" data-bs-parent="#faqAssembly">
                        <div class="accordion-body">
                            Cửa hàng đặt tại quận Hải An, Hải Phòng. Bạn nhắn Zalo để được xác nhận khu vực và lịch phục vụ tận nơi.
                        </div>
                    </div>
                </div>
                <div class="accordion-item">
                    <h3 class="accordion-header">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#a2">
                            Tôi đã có sẵn linh kiện, có ráp giúp được không?
                        </button>
                    </h3>
                    <div id="a2" class="accordion-collapse collapse" data-bs-parent="#faqAssembly">
                        <div class="accordion-body">
                            Được. Bạn chỉ cần gửi danh sách linh kiện qua Zalo, kỹ thuật viên sẽ kiểm tra độ tương thích trước khi đến.
                        </div>
                    </div>
                </div>
                <div class="accordion-item">
                    <h3 class="accordion-header">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#a3">
                            Chi phí dịch vụ được tính như thế nào?
                        </button>
                    </h3>
                    <div id="a3" class="accordion-collapse collapse" data-bs-parent="#faqAssembly">
                        <div class="accordion-body">
                            Chi phí được báo rõ trước khi thực hiện. Nhắn Zalo để được báo giá theo từng trường hợp.
                        </div>
                    </div>
                </div>
                <div class="accordion-item">
                    <h3 class="accordion-header">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#a4">
                            Máy ráp xong có được bảo hành không?
                        </button>
                    </h3>
                    <div id="a4" class="accordion-collapse collapse" data-bs-parent="#faqAssembly">
                        <div class="accordion-body">
                            Sản phẩm được bảo hành theo chính sách của từng linh kiện. Trong thời gian bảo hành tại Độ PC 67,
                            bạn còn được cho mượn miễn phí sản phẩm tương đương để sử dụng tạm.
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- CTA -->
        <section id="lien-he" class="svc-cta">
            <h2 class="mb-2">Sẵn sàng có chiếc PC mơ ước?</h2>
            <p>Nhắn Zalo cho Độ PC 67 để được tư vấn cấu hình và đặt lịch ráp máy tại nhà.</p>
            <div class="actions">
                <a href="${zaloUrl}" target="_blank" rel="noopener" class="btn-zalo btn-zalo-lg">
                    <span class="zalo-mark">Zalo</span> Liên hệ Zalo: 0904 112 618
                </a>
                <a href="${ctx}/Home" class="btn-ghost">Xem sản phẩm</a>
            </div>
        </section>

    </div>

    <!-- NÚT ZALO NỔI -->
    <a href="${zaloUrl}" target="_blank" rel="noopener" class="zalo-float" aria-label="Chat Zalo với Độ PC 67">Zalo</a>
</main>

<jsp:include page="/view/footer.jsp" />
