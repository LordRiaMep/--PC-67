<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="zaloUrl" value="https://zalo.me/0904112618" />

<jsp:include page="/view/header.jsp" />

<link rel="stylesheet" href="${ctx}/assets/css/service.css?v=2">

<main class="flex-grow-1 svc-page theme-green pb-5">
    <div class="container pt-4">

        <nav aria-label="breadcrumb" class="svc-crumb mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${ctx}/Home">Trang chủ</a></li>
                <li class="breadcrumb-item active" aria-current="page">Thu cũ đổi mới</li>
            </ol>
        </nav>

        <section class="svc-hero svc-fade">
            <div class="row align-items-center g-4">
                <div class="col-lg-7">
                    <span class="svc-eyebrow"><i class="bi bi-arrow-repeat"></i> Thu cũ đổi mới</span>
                    <h1 class="mt-3 mb-3">Độ PC 67 tới nhà<br><span class="svc-hl">đổi cũ lấy mới mà</span></h1>
                    <p class="svc-lead mb-4">
                        Thu cũ đổi mới PC ngay tại nhà. Không cần mang case ra cửa hàng, kỹ thuật viên đến tận nơi
                        kiểm tra, định giá và nâng cấp cho bạn.
                    </p>
                    <div class="d-flex flex-wrap gap-3 mb-3">
                        <a href="${zaloUrl}" target="_blank" rel="noopener" class="btn-zalo">
                            <span class="zalo-mark">Zalo</span> Liên hệ Zalo định giá
                        </a>
                        <a href="#quy-trinh" class="btn-ghost">Xem quy trình <i class="bi bi-arrow-down"></i></a>
                    </div>
                    <div class="svc-zalo-note"><i class="bi bi-chat-dots-fill me-1"></i> Zalo: 0904 112 618</div>
                </div>

                <div class="col-lg-5 d-none d-lg-block">
                    <div class="svc-visual">
                        <span class="svc-chip c1"><i class="bi bi-box-seam-fill"></i> Không cần mang case</span>
                        <div class="svc-visual-icon"><i class="bi bi-arrow-repeat"></i></div>
                        <ul class="svc-checks">
                            <li><i class="bi bi-check-circle-fill"></i> Kỹ thuật viên đến tận nhà</li>
                            <li><i class="bi bi-check-circle-fill"></i> Định giá rõ ràng tại chỗ</li>
                            <li><i class="bi bi-check-circle-fill"></i> Trừ giá thu cũ vào máy mới</li>
                        </ul>
                        <span class="svc-chip c2"><i class="bi bi-recycle"></i> Thu cũ đổi mới</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="svc-trust svc-fade" style="--d:.15s">
            <div class="row g-0">
                <div class="col-6 col-lg-3">
                    <div class="svc-trust-item">
                        <span class="svc-trust-ico"><i class="bi bi-arrow-repeat"></i></span>
                        <div><b>Thu cũ đổi mới trọn đời</b><small>Linh kiện &amp; Gaming Gear</small></div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="svc-trust-item">
                        <span class="svc-trust-ico"><i class="bi bi-graph-up-arrow"></i></span>
                        <div><b>Miễn phí lên đời</b><small>Trong vòng 15 ngày</small></div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="svc-trust-item">
                        <span class="svc-trust-ico"><i class="bi bi-box-seam-fill"></i></span>
                        <div><b>Đổi mới dễ dàng</b><small>Trong 30 ngày đầu</small></div>
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

        <section>
            <div class="svc-head">
                <span class="tag">Ưu điểm</span>
                <h2>Đổi cũ lấy mới, nhanh gọn tại nhà</h2>
                <p>Bạn chỉ cần ngồi nhà, việc kiểm tra, định giá và nâng cấp để kỹ thuật viên lo.</p>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-box-seam-fill"></i></div>
                        <h3>Không cần mang case ra cửa hàng</h3>
                        <p>Kỹ thuật viên đến tận nhà, bạn không phải tháo hay vận chuyển máy.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-cash-coin"></i></div>
                        <h3>Định giá minh bạch</h3>
                        <p>Kiểm tra tình trạng thực tế và báo giá thu rõ ràng ngay tại chỗ.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="svc-card">
                        <div class="svc-icon-box"><i class="bi bi-lightning-charge-fill"></i></div>
                        <h3>Nâng cấp nhanh gọn</h3>
                        <p>Trừ giá thu cũ vào máy mới, lắp đặt luôn trong cùng buổi hẹn.</p>
                    </div>
                </div>
            </div>
        </section>

        <section>
            <div class="svc-head">
                <span class="tag">Thu mua</span>
                <h2>Chúng tôi nhận thu những gì?</h2>
                <p>Thu linh kiện lẻ hoặc cả bộ PC. Tình trạng và giá thu do kỹ thuật viên kiểm tra trực tiếp.</p>
            </div>
            <div class="row g-3">
                <div class="col-6 col-md-4 col-lg-2">
                    <div class="svc-tile"><div class="svc-icon-box"><i class="bi bi-cpu-fill"></i></div><b>CPU</b></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <div class="svc-tile"><div class="svc-icon-box"><i class="bi bi-motherboard-fill"></i></div><b>Mainboard</b></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <div class="svc-tile"><div class="svc-icon-box"><i class="bi bi-gpu-card"></i></div><b>Card đồ họa (VGA)</b></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <div class="svc-tile"><div class="svc-icon-box"><i class="bi bi-memory"></i></div><b>RAM</b></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <div class="svc-tile"><div class="svc-icon-box"><i class="bi bi-hdd-fill"></i></div><b>SSD / HDD</b></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <div class="svc-tile"><div class="svc-icon-box"><i class="bi bi-plug-fill"></i></div><b>Nguồn &amp; Case</b></div>
                </div>
            </div>
            <div class="svc-note">
                <i class="bi bi-camera-fill"></i>
                Gửi cấu hình hoặc vài tấm ảnh máy cũ qua Zalo để được báo giá sơ bộ nhanh hơn.
            </div>
        </section>

        <section id="quy-trinh">
            <div class="svc-head">
                <span class="tag">Quy trình</span>
                <h2>4 bước thu cũ đổi mới</h2>
                <p>Gọn gàng, minh bạch và hoàn tất ngay trong một buổi hẹn.</p>
            </div>
            <div class="row g-4 svc-steps">
                <div class="col-md-6 col-lg-3">
                    <div class="svc-step">
                        <span class="no">01</span>
                        <div class="ico"><i class="bi bi-chat-left-text-fill"></i></div>
                        <h3>Nhắn Zalo đăng ký</h3>
                        <p>Cho biết cấu hình đang dùng và nhu cầu nâng cấp của bạn.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-step">
                        <span class="no">02</span>
                        <div class="ico"><i class="bi bi-search"></i></div>
                        <h3>Đến nhà kiểm tra</h3>
                        <p>Kỹ thuật viên kiểm tra máy cũ và định giá ngay tại chỗ.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-step">
                        <span class="no">03</span>
                        <div class="ico"><i class="bi bi-cash-coin"></i></div>
                        <h3>Chốt giá, trừ vào máy mới</h3>
                        <p>Giá thu cũ được trừ trực tiếp vào chi phí máy mới.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="svc-step">
                        <span class="no">04</span>
                        <div class="ico"><i class="bi bi-tools"></i></div>
                        <h3>Lắp đặt &amp; bàn giao</h3>
                        <p>Lắp máy mới, chạy thử và bàn giao ngay tại nhà.</p>
                    </div>
                </div>
            </div>
        </section>

        <section>
            <div class="svc-head">
                <span class="tag">Hỏi đáp</span>
                <h2>Câu hỏi thường gặp</h2>
            </div>
            <div class="accordion svc-faq" id="faqTradeIn">
                <div class="accordion-item">
                    <h3 class="accordion-header">
                        <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#t1">
                            Giá thu cũ được tính dựa trên gì?
                        </button>
                    </h3>
                    <div id="t1" class="accordion-collapse collapse show" data-bs-parent="#faqTradeIn">
                        <div class="accordion-body">
                            Dựa trên dòng sản phẩm, thời gian sử dụng và tình trạng thực tế khi kỹ thuật viên kiểm tra.
                        </div>
                    </div>
                </div>
                <div class="accordion-item">
                    <h3 class="accordion-header">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#t2">
                            Tôi có bắt buộc phải mua máy mới không?
                        </button>
                    </h3>
                    <div id="t2" class="accordion-collapse collapse" data-bs-parent="#faqTradeIn">
                        <div class="accordion-body">
                            Bạn nhắn Zalo để được tư vấn hình thức phù hợp. Cửa hàng có chính sách thu cũ đổi mới với linh kiện máy tính và Gaming Gear.
                        </div>
                    </div>
                </div>
                <div class="accordion-item">
                    <h3 class="accordion-header">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#t3">
                            Tôi cần chuẩn bị gì trước khi kỹ thuật viên đến?
                        </button>
                    </h3>
                    <div id="t3" class="accordion-collapse collapse" data-bs-parent="#faqTradeIn">
                        <div class="accordion-body">
                            Hãy sao lưu dữ liệu quan trọng và chuẩn bị sẵn thông tin cấu hình hoặc hóa đơn mua máy (nếu còn) để việc định giá nhanh hơn.
                        </div>
                    </div>
                </div>
                <div class="accordion-item">
                    <h3 class="accordion-header">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#t4">
                            Dữ liệu trong ổ cứng cũ có được bảo mật không?
                        </button>
                    </h3>
                    <div id="t4" class="accordion-collapse collapse" data-bs-parent="#faqTradeIn">
                        <div class="accordion-body">
                            Bạn nên sao lưu và xóa dữ liệu cá nhân trước khi giao máy. Kỹ thuật viên sẽ hướng dẫn nếu bạn cần.
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section id="lien-he" class="svc-cta">
            <h2 class="mb-2">Đổi cũ lấy mới ngay hôm nay</h2>
            <p>Nhắn Zalo để được định giá máy cũ và tư vấn cấu hình mới phù hợp với bạn.</p>
            <div class="actions">
                <a href="${zaloUrl}" target="_blank" rel="noopener" class="btn-zalo btn-zalo-lg">
                    <span class="zalo-mark">Zalo</span> Liên hệ Zalo: 0904 112 618
                </a>
                <a href="${ctx}/Home" class="btn-ghost">Xem sản phẩm</a>
            </div>
        </section>

    </div>

    <a href="${zaloUrl}" target="_blank" rel="noopener" class="zalo-float" aria-label="Chat Zalo với Độ PC 67">Zalo</a>
</main>

<jsp:include page="/view/footer.jsp" />
