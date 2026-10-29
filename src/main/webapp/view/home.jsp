<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.ProductDao" %>
<%@ page import="model.Product" %>
<%@ page import="dao.NewsDao" %>
<%@ page import="model.News" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
.hide-scroll {
        -ms-overflow-style: none;
        scrollbar-width: none;
        overflow-x: auto;
    }
    .hide-scroll::-webkit-scrollbar {
        display: none;
    }
    .news-clamp-2 {
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
    .news-date-badge {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        min-width: 56px;
        padding: 3px 14px 3px 8px;
        color: #fff;
        font-size: 12px;
        line-height: 1.2;
        background: linear-gradient(135deg, #b71c1c, #ff5252);
        clip-path: polygon(0 0, 100% 0, 85% 100%, 0 100%);
    }
    .banner-link img { transition: transform .25s ease, box-shadow .25s ease; }
    .banner-link:hover img { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,.2) !important; }
    .slider-product-card {
        width: calc(25% - 12px) !important;
        min-width: 250px;
        transition: transform 0.25s ease, box-shadow 0.25s ease;
    }
    .slider-product-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0,0,0,0.08) !important;
    }
    @media (max-width: 992px) {
        .slider-product-card {
            width: calc(33.333% - 11px) !important;
            min-width: 220px;
        }
    }
    @media (max-width: 576px) {
        .slider-product-card {
            width: calc(50% - 8px) !important;
            min-width: 170px;
        }
    }
    .slider-nav-btn {
        width: 38px !important;
        height: 38px !important;
        border-radius: 50% !important;
        background-color: #E30019 !important;
        color: #ffffff !important;
        border: none !important;
        box-shadow: 0 4px 12px rgba(227, 0, 25, 0.35) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        position: absolute !important;
        top: 50% !important;
        transform: translateY(-50%) !important;
        z-index: 10 !important;
        cursor: pointer;
        transition: transform 0.15s ease, background-color 0.15s ease;
    }
    .slider-nav-btn:hover {
        background-color: #BE0015 !important;
        transform: translateY(-50%) scale(1.08) !important;
    }
    .cat-title-badge {
        font-size: 15px;
        background: linear-gradient(90deg, #b71c1c 0%, #ff5252 100%);
        clip-path: polygon(0 0, 90% 0, 100% 100%, 0% 100%);
        padding-right: 35px !important;
        min-width: 240px;
        cursor: pointer;
    }
</style>

<jsp:include page="header.jsp" />

<div class="container my-4">
    <c:choose>

        <c:when test="${not empty cid}">

            <nav aria-label="breadcrumb" class="mb-3">
                <ol class="breadcrumb" style="font-size: 13.5px;">
                    <li class="breadcrumb-item"><a href="${ctx}/Home" class="text-decoration-none text-muted">Trang chủ</a></li>
                    <li class="breadcrumb-item active text-dark fw-bold" aria-current="page">${categoryTitle}</li>
                </ol>
            </nav>

            <!-- Tiêu đề danh mục -->
            <div class="d-flex justify-content-between align-items-center bg-light p-0 rounded-3 mb-4 shadow-sm border overflow-hidden">
                <span class="text-white fw-bold px-4 py-2 text-uppercase d-flex align-items-center cat-title-badge" style="font-size: 16px;">
                    ${categoryTitle}
                </span>
                <span class="text-muted small me-3 d-none d-md-inline">Cấu hình cao cấp & linh kiện chính hãng</span>
            </div>

            <div class="row g-3 mb-5">
                <c:choose>
                    <c:when test="${empty listProducts}">
                        <div class="col-12 text-center py-5 bg-white rounded-3 border shadow-sm">
                            <i class="bi bi-inbox fs-1 text-muted d-block mb-2"></i>
                            <h5 class="text-muted">Không có sản phẩm nào trong danh mục này!</h5>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${listProducts}" var="p">
                            <div id="prod-card-${p.id}" data-product-id="${p.id}" class="col-6 col-md-4 col-lg-3">
                                <div class="card h-100 border bg-white shadow-sm overflow-hidden d-flex flex-column" style="border-radius: 12px;">
                                    <div class="p-3 text-center" style="height: 190px; display: flex; align-items: center; justify-content: center; background: #ffffff;">
                                        <a href="${ctx}/product/detail?id=${p.id}" class="d-block w-100 text-decoration-none">
                                            <img src="${p.image}" class="card-img-top img-fluid" style="height: 160px; object-fit: contain;" alt="${p.name}">
                                        </a>
                                    </div>

                                    <div class="card-body text-start d-flex flex-column px-3 pt-2 pb-3 border-top">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <span class="badge-category m-0" style="font-size: 11px;">
                                                <i class="bi bi-tag-fill me-1 text-danger"></i>${p.categoryName}
                                            </span>
                                            <c:choose>
                                                <c:when test="${p.quantity > 0}">
                                                    <span class="text-success small fw-semibold" style="font-size: 11.5px;">
                                                        <i class="bi bi-check-circle-fill me-1"></i>Còn ${p.quantity}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-danger small fw-semibold" style="font-size: 11.5px;">
                                                        <i class="bi bi-x-circle-fill me-1"></i>Hết hàng
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none mb-2">
                                            <h6 class="card-title text-dark fw-bold mb-0" style="font-size: 14px; min-height: 40px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${p.name}</h6>
                                        </a>

                                        <div class="bg-light p-2 rounded-2 mb-3 border border-light-subtle" style="font-size: 12px; color: #475569;">
                                            <div class="description-truncate" style="font-size: 12px; line-height: 1.4;">
                                                ${p.description}
                                            </div>
                                        </div>

                                        <div class="mt-auto d-flex justify-content-between align-items-center pt-2 border-top">
                                            <div>
                                                <div class="text-muted" style="font-size: 11px;">Giá niêm yết:</div>
                                                <span class="text-danger fw-bold" style="font-size: 16px;"><fmt:formatNumber value="${p.price}" pattern="#,###"/> ₫</span>
                                            </div>
                                            <c:choose>
                                                <c:when test="${p.quantity > 0}">
                                                    <button type="button" class="btn btn-danger btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center shadow-sm quick-add-cart-btn"
                                                            data-id="${p.id}"
                                                            data-name="<c:out value='${p.name}'/>"
                                                            style="width: 36px; height: 36px;"
                                                            title="Thêm ngay vào giỏ hàng">
                                                        <i class="bi bi-cart-plus fs-6 text-white"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button" class="btn btn-secondary btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center opacity-50"
                                                            style="width: 36px; height: 36px; cursor: not-allowed;"
                                                            disabled
                                                            title="Sản phẩm tạm hết hàng">
                                                        <i class="bi bi-cart-x fs-6 text-white"></i>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:if test="${endPage > 1}">
                <nav aria-label="Page navigation" class="my-4">
                    <ul class="pagination justify-content-center">
                        <c:forEach begin="1" end="${endPage}" var="i">
                            <li class="page-item ${tag == i ? 'active' : ''}">
                                <a class="page-link" href="${ctx}/Home?cid=${cid}&page=${i}">${i}</a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </c:if>
        </c:when>

        <c:otherwise>
            <%
                ProductDao productDao = new ProductDao();
                List<String> listCategories = productDao.getPCCategoryNames();
                Map<String, List<Product>> categoryProductMap = new LinkedHashMap<>();

                if (listCategories != null) {
                    for (String catName : listCategories) {
                        List<Product> list8Products = productDao.getTop8ProductsByCategoryName(catName);
                        if (list8Products != null && !list8Products.isEmpty()) {
                            categoryProductMap.put(catName, list8Products);
                        }
                    }
                }
                request.setAttribute("categoryProductMap", categoryProductMap);

                request.setAttribute("homeNews", new NewsDao().getLatestNews(5));
            %>

            <!-- Showcase Video Banner -->
            <div class="showcase-video-box mb-4">
                <video autoplay muted loop playsinline class="w-100 d-block" style="height: 440px; object-fit: cover;">
                    <source src="${ctx}/assets/images/video.mp4" type="video/mp4">
                </video>
            </div>

            <!-- 3 Service Feature Banners -->
            <div class="row g-3 mb-5">
                <div class="col-md-4">
                    <a href="${ctx}/Home?cid=1" class="banner-link">
                        <img src="${ctx}/assets/images/pc-gaming-premium.jpg" class="img-fluid w-100" style="height: 190px; object-fit: cover;" alt="PC Gaming Cao Cấp">
                    </a>
                </div>
                <div class="col-md-4">
                    <a href="${ctx}/service/assembly" class="banner-link">
                        <img src="${ctx}/assets/images/banner2.png" alt="Độ PC 67 ráp máy tại nhà" class="img-fluid w-100" style="height: 190px; object-fit: cover; background-color: #000;">
                    </a>
                </div>
                <div class="col-md-4">
                    <a href="${ctx}/service/trade-in" class="banner-link">
                        <img src="${ctx}/assets/images/banner.png" alt="Độ PC 67 thu cũ đổi mới tại nhà" class="img-fluid w-100" style="height: 190px; object-fit: cover;">
                    </a>
                </div>
            </div>

            <!-- Categories Horizontal Showcase Sliders -->
            <c:forEach items="${categoryProductMap}" var="entry" varStatus="catStatus">
                <c:set var="catId" value="${entry.value[0].categoryId}" />
                <c:url value="/Home" var="categoryUrl">
                    <c:param name="cid" value="${catId}" />
                </c:url>

                <div class="bg-white border rounded-3 shadow-sm mb-5 mt-4 overflow-hidden">
                    <div class="d-flex justify-content-between align-items-center border-bottom bg-light">
                        <div class="d-flex align-items-center h-100">
                            <a href="${categoryUrl}" class="text-decoration-none">
                                <span class="text-white fw-bold px-4 py-2 text-uppercase d-flex align-items-center cat-title-badge">
                                    ${entry.key}
                                </span>
                            </a>
                        </div>
                        <a href="${categoryUrl}" class="text-danger text-decoration-none fw-bold me-3 small d-flex align-items-center gap-1">
                            <span>XEM TẤT CẢ</span>
                            <i class="bi bi-chevron-right small"></i>
                        </a>
                    </div>

                    <div class="position-relative p-3">
                        <div id="slider_cat_${catStatus.index}" class="d-flex gap-3 hide-scroll pb-2" style="scroll-behavior: smooth;">
                            <c:forEach items="${entry.value}" var="p">
                                <div id="prod-card-${p.id}" data-product-id="${p.id}" class="card border bg-white shadow-sm flex-shrink-0 slider-product-card" style="border-radius: 12px;">
                                    <div class="p-3 text-center" style="height: 180px; display: flex; align-items: center; justify-content: center;">
                                        <a href="${ctx}/product/detail?id=${p.id}" class="d-block w-100 text-decoration-none">
                                            <img src="${p.image}" class="card-img-top img-fluid" style="height: 150px; object-fit: contain;" alt="${p.name}">
                                        </a>
                                    </div>

                                    <div class="card-body text-start d-flex flex-column px-3 pt-2 pb-3 border-top">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <span class="badge-category m-0" style="font-size: 11px;">
                                                <i class="bi bi-tag-fill me-1 text-danger"></i>${p.categoryName}
                                            </span>
                                            <c:choose>
                                                <c:when test="${p.quantity > 0}">
                                                    <span class="text-success small fw-semibold" style="font-size: 11.5px;">
                                                        <i class="bi bi-check-circle-fill me-1"></i>Còn ${p.quantity}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-danger small fw-semibold" style="font-size: 11.5px;">
                                                        <i class="bi bi-x-circle-fill me-1"></i>Hết hàng
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none mb-2">
                                            <h6 class="card-title text-dark fw-bold mb-0" style="font-size: 13.5px; min-height: 40px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${p.name}</h6>
                                        </a>

                                        <div class="bg-light p-2 rounded-2 mb-3 border border-light-subtle" style="font-size: 12px; color: #475569;">
                                            <div class="description-truncate" style="font-size: 12px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                                ${p.description}
                                            </div>
                                        </div>

                                        <div class="mt-auto d-flex justify-content-between align-items-center pt-2 border-top">
                                            <div>
                                                <div class="text-muted" style="font-size: 11px;">Giá niêm yết:</div>
                                                <span class="text-danger fw-bold" style="font-size: 16px;"><fmt:formatNumber value="${p.price}" pattern="#,###"/> ₫</span>
                                            </div>
                                            <c:choose>
                                                <c:when test="${p.quantity > 0}">
                                                    <button type="button" class="btn btn-danger btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center shadow-sm quick-add-cart-btn"
                                                            data-id="${p.id}"
                                                            data-name="<c:out value='${p.name}'/>"
                                                            style="width: 36px; height: 36px;"
                                                            title="Thêm ngay vào giỏ hàng">
                                                        <i class="bi bi-cart-plus fs-6 text-white"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="button" class="btn btn-secondary btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center opacity-50"
                                                            style="width: 36px; height: 36px; cursor: not-allowed;"
                                                            disabled
                                                            title="Sản phẩm tạm hết hàng">
                                                        <i class="bi bi-cart-x fs-6 text-white"></i>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        <c:if test="${entry.value.size() > 4}">
                            <button type="button" onclick="slideProducts('slider_cat_${catStatus.index}', 'prev')" class="btn btn-danger rounded-circle position-absolute shadow d-flex justify-content-center align-items-center slider-nav-btn" style="width: 38px; height: 38px; top: 105px; left: -10px; transform: translateY(-50%); z-index: 10;" title="Trước"><i class="bi bi-chevron-left text-white fw-bold"></i></button>
                            <button type="button" onclick="slideProducts('slider_cat_${catStatus.index}', 'next')" class="btn btn-danger rounded-circle position-absolute shadow d-flex justify-content-center align-items-center slider-nav-btn" style="width: 38px; height: 38px; top: 105px; right: -10px; transform: translateY(-50%); z-index: 10;" title="Sau"><i class="bi bi-chevron-right text-white fw-bold"></i></button>
                        </c:if>
                    </div>
                </div>
            </c:forEach>

            <!-- Latest News Modern Grid -->
            <c:if test="${not empty homeNews}">
                <div class="bg-white border rounded-4 shadow-sm p-4 mb-5 mt-4">
                    <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-4">
                        <div class="d-flex align-items-center gap-2">
                            <span class="d-inline-block rounded-pill" style="width: 5px; height: 22px; background: var(--brand-gradient);"></span>
                            <h4 class="fw-bold m-0 text-dark" style="font-size: 18px;">TIN TỨC CÔNG NGHỆ & ĐÁNH GIÁ</h4>
                        </div>
                        <a href="${ctx}/news" class="section-more-link">
                            <span>XEM TẤT CẢ</span>
                            <i class="bi bi-arrow-right-short fs-5"></i>
                        </a>
                    </div>

                    <c:set var="bigNews" value="${homeNews[0]}" />
                    <div class="row g-4">
                        <div class="col-lg-6">
                            <a href="${ctx}/news/detail?id=${bigNews.id}" class="text-decoration-none text-dark d-block card border-0 shadow-sm h-100 overflow-hidden">
                                <div class="overflow-hidden" style="height: 280px;">
                                    <img src="${bigNews.image}" alt="" class="w-100 h-100 object-fit-cover card-img-top">
                                </div>
                                <div class="p-3">
                                    <div class="d-flex align-items-center gap-2 mb-2">
                                        <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2 py-1 small fw-semibold">
                                            <fmt:formatDate value="${bigNews.createdAt}" pattern="dd/MM/yyyy"/>
                                        </span>
                                    </div>
                                    <h5 class="fw-bold m-0 news-clamp-2" style="font-size: 16.5px; line-height: 1.4;">
                                        <c:out value="${bigNews.title}"/>
                                    </h5>
                                </div>
                            </a>
                        </div>

                        <div class="col-lg-6">
                            <div class="row g-3">
                                <c:forEach items="${homeNews}" var="n" begin="1" end="4">
                                    <div class="col-6">
                                        <a href="${ctx}/news/detail?id=${n.id}" class="text-decoration-none text-dark d-block card border-0 shadow-sm h-100 overflow-hidden">
                                            <div class="overflow-hidden" style="height: 110px;">
                                                <img src="${n.image}" alt="" class="w-100 h-100 object-fit-cover card-img-top">
                                            </div>
                                            <div class="p-2">
                                                <small class="text-muted d-block mb-1" style="font-size: 11px;">
                                                    <fmt:formatDate value="${n.createdAt}" pattern="dd/MM/yyyy"/>
                                                </small>
                                                <div class="fw-bold news-clamp-2 text-dark" style="font-size: 12.5px; line-height: 1.35;">
                                                    <c:out value="${n.title}"/>
                                                </div>
                                            </div>
                                        </a>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </c:otherwise>
    </c:choose>
</div>

<script>
function slideProducts(sliderId, direction) {
    const slider = document.getElementById(sliderId);
    if (!slider) return;

    const step = slider.clientWidth > 0 ? (slider.clientWidth * 0.75) : 300;
    const tolerance = 15;
    const maxScroll = slider.scrollWidth - slider.clientWidth;

    if (direction === 'next') {
        if (slider.scrollLeft >= maxScroll - tolerance) {
            slider.scrollTo({ left: 0, behavior: 'smooth' });
        } else {
            slider.scrollBy({ left: step, behavior: 'smooth' });
        }
    } else {
        if (slider.scrollLeft <= tolerance) {
            slider.scrollTo({ left: maxScroll, behavior: 'smooth' });
        } else {
            slider.scrollBy({ left: -step, behavior: 'smooth' });
        }
    }
}
</script>

<jsp:include page="footer.jsp" />
