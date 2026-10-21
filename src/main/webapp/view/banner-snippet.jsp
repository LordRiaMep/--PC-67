<%-- Dán đoạn này vào trang chủ, thay cho 2 thẻ <img> banner hiện tại --%>
<div class="row g-3 my-3">
    <div class="col-md-6">
        <a href="${ctx}/service/assembly" class="d-block banner-link">
            <img src="${ctx}/assets/images/TEN-ANH-BANNER-RAP-MAY.png"
                 class="img-fluid rounded-3 w-100" alt="Độ PC 67 ráp máy tại nhà">
        </a>
    </div>
    <div class="col-md-6">
        <a href="${ctx}/service/trade-in" class="d-block banner-link">
            <img src="${ctx}/assets/images/TEN-ANH-BANNER-DOI-CU.png"
                 class="img-fluid rounded-3 w-100" alt="Độ PC 67 thu cũ đổi mới tại nhà">
        </a>
    </div>
</div>

<%-- Thêm vào assets/css/style.css để có hiệu ứng khi rê chuột:

.banner-link img { transition: transform .25s ease, box-shadow .25s ease; }
.banner-link:hover img { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,.2); }
--%>
