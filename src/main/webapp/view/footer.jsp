<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<!-- Trust Assurances Bar -->
<div class="container-fluid bg-white border-top border-bottom py-4 mt-5">
    <div class="container">
        <div class="row g-4">
            <div class="col-6 col-lg-3">
                <div class="trust-badge-card">
                    <div class="trust-icon-box">
                        <i class="fas fa-truck-fast"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-1 text-dark" style="font-size: 13.5px; letter-spacing: -0.01em;">GIAO HÀNG TOÀN QUỐC</h6>
                        <small class="text-muted" style="font-size: 12px;">Đồng kiểm trước, nhận hàng COD</small>
                    </div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="trust-badge-card">
                    <div class="trust-icon-box">
                        <i class="fas fa-box-open"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-1 text-dark" style="font-size: 13.5px; letter-spacing: -0.01em;">ĐỔI TRẢ DỄ DÀNG</h6>
                        <small class="text-muted" style="font-size: 12px;">1 đổi 1 trong 30 ngày đầu</small>
                    </div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="trust-badge-card">
                    <div class="trust-icon-box">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-1 text-dark" style="font-size: 13.5px; letter-spacing: -0.01em;">THANH TOÁN TIỆN LỢI</h6>
                        <small class="text-muted" style="font-size: 12px;">QR VNPay, thẻ, trả góp 0%</small>
                    </div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="trust-badge-card">
                    <div class="trust-icon-box">
                        <i class="fas fa-headset"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-1 text-dark" style="font-size: 13.5px; letter-spacing: -0.01em;">HỖ TRỢ NHIỆT TÌNH</h6>
                        <small class="text-muted" style="font-size: 12px;">Tư vấn kỹ thuật chuyên sâu 24/7</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Commitments Section -->
<div class="container-fluid bg-light py-5 mb-0">
    <div class="container text-center">
        <div class="d-inline-flex align-items-center justify-content-center mb-3 rounded-circle shadow-sm" style="width: 60px; height: 60px; background: #ffffff; border: 1.5px solid var(--border-subtle); color: var(--brand-primary); font-size: 24px;">
            <i class="fas fa-shield-halved"></i>
        </div>

        <h6 class="text-muted fw-semibold small text-uppercase tracking-wider mb-1">Trải nghiệm mua sắm tại Độ-PC 67</h6>
        <h3 class="fw-bold text-dark mb-4" style="letter-spacing: -0.02em;">Cam Kết Dịch Vụ Hàng Đầu</h3>

        <div class="accordion text-start mx-auto shadow-sm rounded-4 overflow-hidden border bg-white" id="camKetAccordion" style="max-width: 900px;">

            <div class="accordion-item border-0 border-bottom">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed fw-semibold text-dark py-3" type="button" data-bs-toggle="collapse" data-bs-target="#ck1" style="font-size: 14px;">
                        01. Liên hệ Chăm sóc khách hàng dễ dàng & nhanh chóng
                    </button>
                </h2>
                <div id="ck1" class="accordion-collapse collapse" data-bs-parent="#camKetAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        <p>Bạn đang cần hỗ trợ hay cần đóng góp ý kiến cho Độ-PC 67 trong quá trình mua hàng. Hãy liên hệ với Độ-PC 67 trong bất cứ khi nào 24/07 qua số Hotline hoặc dịch vụ Chat trực tuyến miễn phí. Độ-PC 67 sẽ cung cấp giải pháp hỗ trợ quý khách các vấn đề liên quan đến sản phẩm mua hàng tại Độ-PC 67 của bạn nhanh chóng.</p>
                        <p>Hotline chăm sóc và hỗ trợ khách mua hàng (chỉ hoạt động trong giờ hành chính): <strong>0904 112 618</strong></p>
                        <p class="mb-0">Ngoài ra khách hàng có thể liên hệ với Độ-PC 67 thông qua rất nhiều kênh khác nhau như: Email, Chat, Để lại đánh giá, bình luận ở các kênh mạng xã hội của Độ-PC 67.</p>
                    </div>
                </div>
            </div>

            <div class="accordion-item border-0 border-bottom">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed fw-semibold text-dark py-3" type="button" data-bs-toggle="collapse" data-bs-target="#ck2" style="font-size: 14px;">
                        02. Giao hàng nhanh trong 2 giờ nội thành Hải Phòng
                    </button>
                </h2>
                <div id="ck2" class="accordion-collapse collapse" data-bs-parent="#camKetAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        <p>Độ-PC 67 hiểu rằng khách hàng khi đặt mua các sản phẩm của Độ-PC 67 trên các nền tảng thương mại đều mong muốn nhận được hàng của mình nhanh, vì thế Độ-PC 67 với đội ngũ kỹ thuật viên giao hàng chuyên hợp tác với các đơn vị vận chuyển hàng đầu đáp ứng các yêu cầu sau:</p>
                        <ul class="mb-0 ps-3">
                            <li class="mb-2">Cam kết giao hàng nhanh trong vòng 2 giờ đến tay khách hàng (kể từ khi giao dịch được hoàn thành) trong khu vực nội thành TP. Hải Phòng mà không thu thêm bất kỳ một khoản phí nào.</li>
                            <li>Cam kết đóng hàng (theo chuẩn đóng gói linh kiện điện tử của các trang TMĐT) và gửi hàng đến các đơn vị vận chuyển trên thành phố Hải Phòng chỉ trong vòng 2 giờ, kể từ khi đơn hàng được kích hoạt trạng thái sẵn sàng giao trên các trang TMĐT.</li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="accordion-item border-0 border-bottom">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed fw-semibold text-dark py-3" type="button" data-bs-toggle="collapse" data-bs-target="#ck3" style="font-size: 14px;">
                        03. Miễn phí lên đời và trải nghiệm sản phẩm trong vòng 15 ngày
                    </button>
                </h2>
                <div id="ck3" class="accordion-collapse collapse" data-bs-parent="#camKetAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        <p>Đây chắc chắn là một đặc quyền chỉ có Độ-PC 67 đem đến cho các khách hàng của mình, Độ-PC 67 cam kết cho khách hàng được trải nghiệm và miễn phí sản phẩm lên đời trong vòng 15 ngày (tính từ ngày kích hoạt sản phẩm).</p>
                        <p class="mb-0"><em>Ví dụ:</em> Khi khách hàng mua 1 sản phẩm GPU tại Độ-PC 67 nhưng sử dụng không đáp ứng được thông số kỳ vọng sẽ được Độ-PC 67 hỗ trợ thu mua bằng giá khi xuất hoá đơn cho khách hàng và hỗ trợ khách hàng nâng cấp đời cao hơn.</p>
                    </div>
                </div>
            </div>

            <div class="accordion-item border-0 border-bottom">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed fw-semibold text-dark py-3" type="button" data-bs-toggle="collapse" data-bs-target="#ck4" style="font-size: 14px;">
                        04. Cam kết thu cũ đổi mới trọn đời với Gaming Gear & Linh kiện
                    </button>
                </h2>
                <div id="ck4" class="accordion-collapse collapse" data-bs-parent="#camKetAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        <p>Độ-PC 67 luôn muốn khách hàng của mình được trải nghiệm những sản phẩm công nghệ mới trên thị trường và muốn được đồng hành khách hàng, hỗ trợ khách hàng trọn đời sản phẩm khi mua hàng tại Độ-PC 67.</p>
                        <p class="mb-0">Vì vậy Độ-PC 67 cam kết thu cũ các sản phẩm của quý khách hàng với giá tốt và hỗ trợ nâng đời mới cho khách hàng với các sản phẩm Linh kiện máy tính.</p>
                    </div>
                </div>
            </div>

            <div class="accordion-item border-0">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed fw-semibold text-dark py-3" type="button" data-bs-toggle="collapse" data-bs-target="#ck5" style="font-size: 14px;">
                        05. Cho mượn linh kiện miễn phí thay thế trong thời gian bảo hành
                    </button>
                </h2>
                <div id="ck5" class="accordion-collapse collapse" data-bs-parent="#camKetAccordion">
                    <div class="accordion-body text-secondary small" style="line-height: 1.7;">
                        <p class="mb-0">Đối với các khách hàng khi bảo hành sản phẩm tại Độ-PC 67, sẽ được cửa hàng cung cấp cho mượn miễn phí sản phẩm tương đương trong thời gian bảo hành sản phẩm (Áp dụng đối với tất cả các sản phẩm khi mua hàng tại Độ-PC 67).</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.footer-pro {
        background-color: #ffffff;
        color: #4b5563;
        font-size: 13.5px;
        border-top: 1px solid #e5e7eb;
    }
    .footer-pro .footer-title {
        color: #111827;
        font-size: 13.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 16px;
    }
    .footer-contact-list {
        list-style: none;
        padding-left: 0;
        margin-bottom: 0;
    }
    .footer-contact-list li {
        margin-bottom: 10px;
        line-height: 1.5;
        display: flex;
        align-items: flex-start;
        gap: 8px;
    }
    .footer-clean-links {
        list-style: none;
        padding-left: 0;
        margin-bottom: 0;
    }
    .footer-clean-links li {
        margin-bottom: 8px;
    }
    .footer-clean-links a {
        color: #4b5563;
        text-decoration: none;
        font-size: 13.5px;
        display: inline-block;
        transition: color 0.15s ease, transform 0.15s ease;
    }
    .footer-clean-links a:hover {
        color: #e30019;
        transform: translateX(3px);
    }
    .footer-social-btn {
        width: 34px;
        height: 34px;
        border-radius: 50%;
        background-color: #f3f4f6;
        color: #4b5563;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        font-size: 14px;
        transition: all 0.2s ease;
    }
    .footer-social-btn:hover {
        background-color: #e30019;
        color: #ffffff;
        transform: translateY(-2px);
    }
    .footer-chip {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 4px 8px;
        background: #f9fafb;
        border: 1px solid #e5e7eb;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 600;
        color: #4b5563;
        height: 26px;
        min-width: 50px;
    }
</style>

<footer class="footer-pro pt-5 mt-auto">
    <div class="container pb-4">
        <div class="row g-4">

            <div class="col-lg-3 col-md-6">
                <h6 class="footer-title">VỀ ĐỘ-PC 67</h6>
                <p class="text-muted mb-3" style="font-size: 13px; line-height: 1.6;">
                    Hệ thống máy tính Hi-End, PC Gaming, Workstation đồ họa và linh kiện máy tính chính hãng tại Hải Phòng.
                </p>
                <ul class="footer-contact-list text-muted" style="font-size: 13px;">
                    <li>
                        <i class="bi bi-geo-alt text-danger mt-1"></i>
                        <span>15/2/437 Đà Nẵng, P. Đông Hải, Q. Hải An, TP. Hải Phòng</span>
                    </li>
                    <li>
                        <i class="bi bi-clock text-danger mt-1"></i>
                        <span>08:00 - 21:30 (Mở cửa tất cả các ngày)</span>
                    </li>
                    <li>
                        <i class="bi bi-envelope text-danger mt-1"></i>
                        <span>dogiaphu50@gmail.com</span>
                    </li>
                </ul>
            </div>

            <div class="col-lg-3 col-md-6">
                <h6 class="footer-title">TỔNG ĐÀI HỖ TRỢ</h6>
                <div class="mb-3">
                    <div class="text-muted small">Tư vấn mua hàng:</div>
                    <a href="tel:0904112618" class="text-danger fw-bold fs-5 text-decoration-none">0904 112 618</a>
                    <div class="text-muted" style="font-size: 11.5px;">(08:00 - 21:30)</div>
                </div>
                <div class="mb-3">
                    <div class="text-muted small">Hỗ trợ kỹ thuật & bảo hành:</div>
                    <a href="tel:0904112618" class="text-dark fw-bold text-decoration-none">0904 112 618</a>
                    <div class="text-muted" style="font-size: 11.5px;">(08:30 - 18:00)</div>
                </div>
                <div class="pt-1">
                    <a href="${ctx}/contact" class="btn btn-sm btn-outline-danger rounded-pill px-3 py-1 fw-medium" style="font-size: 12.5px;">
                        <i class="bi bi-chat-dots me-1"></i> Gửi phản hồi / Liên hệ
                    </a>
                </div>
            </div>

            <div class="col-lg-3 col-md-6">
                <h6 class="footer-title">CHÍNH SÁCH & DỊCH VỤ</h6>
                <ul class="footer-clean-links">
                    <li><a href="${ctx}/contact">Liên hệ & Bản đồ showroom</a></li>
                    <li><a href="${ctx}/service/assembly">Dịch vụ ráp máy tại nhà</a></li>
                    <li><a href="${ctx}/service/trade-in">Chính sách thu cũ đổi mới</a></li>
                    <li><a href="${ctx}/orders">Tra cứu tình trạng đơn hàng</a></li>
                    <li><a href="${ctx}/Home">Chính sách bảo hành 30 ngày</a></li>
                    <li><a href="${ctx}/Home">Chính sách giao hàng toàn quốc</a></li>
                    <li><a href="${ctx}/Home">Chính sách bảo mật thông tin</a></li>
                </ul>
            </div>

            <div class="col-lg-3 col-md-6">
                <h6 class="footer-title">KẾT NỐI & THANH TOÁN</h6>

                <div class="d-flex align-items-center gap-2 mb-3">
                    <a href="https://facebook.com" target="_blank" rel="noopener" class="footer-social-btn" title="Facebook"><i class="fab fa-facebook-f"></i></a>
                    <a href="https://youtube.com" target="_blank" rel="noopener" class="footer-social-btn" title="YouTube"><i class="fab fa-youtube"></i></a>
                    <a href="https://tiktok.com" target="_blank" rel="noopener" class="footer-social-btn" title="TikTok"><i class="fab fa-tiktok"></i></a>
                    <a href="https://zalo.me/0904112618" target="_blank" rel="noopener" class="footer-social-btn" title="Zalo"><i class="bi bi-chat-dots-fill"></i></a>
                </div>

                <div class="mb-3">
                    <div class="text-muted small mb-2" style="font-size: 12px;">Hỗ trợ thanh toán:</div>
                    <div class="d-flex flex-wrap gap-1">
                        <span class="footer-chip">VNPAY</span>
                        <span class="footer-chip">VISA</span>
                        <span class="footer-chip">Master</span>
                        <span class="footer-chip">MoMo</span>
                        <span class="footer-chip">COD</span>
                    </div>
                </div>

                <div class="pt-1">
                    <a href="http://online.gov.vn" target="_blank" rel="noopener" class="text-decoration-none d-inline-flex align-items-center gap-2 px-2 py-1 border rounded bg-white" style="border-color: #cbd5e1 !important; font-size: 11px; color: #1e3a8a;">
                        <i class="bi bi-patch-check-fill text-primary fs-6"></i>
                        <span><strong>ĐÃ THÔNG BÁO</strong> &bull; BỘ CÔNG THƯƠNG</span>
                    </a>
                </div>
            </div>

        </div>
    </div>

    <div class="py-3" style="background-color: #f9fafb; border-top: 1px solid #e5e7eb; font-size: 12px; color: #6b7280;">
        <div class="container d-flex flex-column flex-md-row justify-content-between align-items-center gap-2 text-center text-md-start">
            <div>
                © 2026 <strong>ĐỘ-PC 67</strong>. Tất cả quyền được bảo lưu.
            </div>
            <div class="text-muted" style="font-size: 11.5px;">
                Chất Lượng Vượt Ngân Hà &bull; Hotline: <strong class="text-dark">0904 112 618</strong>
            </div>
        </div>
    </div>
</footer>

<jsp:include page="chatbot_widget.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js">

</script>
</body>
</html>
