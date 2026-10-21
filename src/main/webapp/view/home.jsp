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
</style>

<jsp:include page="header.jsp" />

<div class="container mt-4">
    <c:choose>
        <%-- ================= TRƯỜNG HỢP 1: NGƯỜI DÙNG ẤN VÀO DANH MỤC (CÓ CID) ================= --%>
        <c:when test="${not empty cid}">
            <!-- Breadcrumb (Đường dẫn điều hướng) -->
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${ctx}/Home" class="text-decoration-none text-danger">Trang chủ</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${categoryTitle}</li>
                </ol>
            </nav>

            <!-- Tiêu đề danh mục -->
            <div class="d-flex justify-content-between align-items-center bg-light p-0 rounded mb-4 shadow-sm border overflow-hidden">
                <span class="text-white fw-bold px-4 py-2 text-uppercase d-flex align-items-center"
                      style="font-size: 16px; background: linear-gradient(90deg, #b71c1c 0%, #ff5252 100%); clip-path: polygon(0 0, 90% 0, 100% 100%, 0% 100%); padding-right: 35px !important; min-width: 240px;">
                        ${categoryTitle}
                </span>
            </div>

            <!-- Lưới hiển thị toàn bộ sản phẩm của Danh mục này -->
            <div class="row g-3 mb-5">
                <c:choose>
                    <c:when test="${empty listProducts}">
                        <div class="col-12 text-center py-5">
                            <h5 class="text-muted">Không có sản phẩm nào trong danh mục này!</h5>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${listProducts}" var="p">
                            <div id="prod-card-${p.id}" data-product-id="${p.id}" class="col-md-3">
                                <div class="card h-100 border rounded shadow-sm bg-white">
                                    <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none text-center p-2">
                                        <img src="${p.image}" class="card-img-top rounded img-fluid" style="height: 180px; object-fit: contain;" alt="${p.name}">
                                    </a>
                                    <div class="card-body text-start d-flex flex-column px-2 py-3 mt-1 border-top">
                                        <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none mb-2">
                                            <h6 class="card-title text-dark fw-semibold" style="font-size: 14px; min-height: 40px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${p.name}</h6>
                                        </a>

                                        <!-- Phần hiển thị Danh mục, Số lượng kho và Mô tả ngắn gọn -->
                                        <div class="bg-light p-2 rounded mb-3" style="font-size: 14px; color: #555;">
                                            <div class="mb-1">Danh mục: <span class="text-dark fw-medium">${p.categoryName}</span></div>
                                            <div class="mb-1">Số lượng kho: <span class="text-dark fw-medium">${p.quantity}</span></div>
                                            <hr class="my-1 border-secondary" style="opacity: 0.2;">
                                            <div class="mt-1" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                                    ${p.description}
                                            </div>
                                        </div>

                                        <div class="mt-auto d-flex justify-content-between align-items-center pt-2 border-top">
                                            <h5 class="text-danger fw-bold m-0" style="font-size: 16px;"><fmt:formatNumber value="${p.price}" pattern="#,###"/> ₫</h5>
                                            <a href="${ctx}/product/detail?id=${p.id}" class="btn btn-danger btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center shadow-sm" style="width: 34px; height: 34px;">
                                                <i class="bi bi-cart-plus fs-6"></i>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Phân trang -->
            <c:if test="${endPage > 1}">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        <c:forEach begin="1" end="${endPage}" var="i">
                            <li class="page-item ${tag == i ? 'active' : ''}">
                                <a class="page-link ${tag == i ? 'text-white bg-danger border-danger' : 'text-danger'}" href="${ctx}/Home?cid=${cid}&page=${i}">${i}</a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </c:if>
        </c:when>

        <%-- ================= TRƯỜNG HỢP 2: KHÔNG CÓ CID (TRANG CHỦ MẶC ĐỊNH) ================= --%>
        <c:otherwise>
            <%
                // Xử lý lấy dữ liệu cho slider trang chủ
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

                // Tin tức mới nhất cho trang chủ (1 bài to + 4 bài nhỏ)
                request.setAttribute("homeNews", new NewsDao().getLatestNews(5));
            %>

            <!-- Banner chính (Video) -->
            <video autoplay muted loop playsinline class="rounded mb-3 w-100 shadow" style="height: 480px; object-fit: cover;">
                <source src="${ctx}/assets/images/video.mp4" type="video/mp4">
            </video>

            <!-- 3 Banner phụ -->
            <div class="row g-3 mb-5">
                <div class="col-md-4">
                    <a href="${ctx}/Home?cid=1" class="d-block">
                        <img src="${ctx}/assets/images/pc-gaming-premium.jpg" class="img-fluid rounded border border-light w-100 shadow-sm" style="height: 200px; object-fit: cover;">
                    </a>
                </div>
                <div class="col-md-4">
                    <a href="${ctx}/service/assembly" class="d-block banner-link">
                        <img src="${ctx}/assets/images/banner2.png" alt="Độ PC 67 ráp máy tại nhà" class="img-fluid rounded border border-light w-100 shadow-sm" style="height: 200px; object-fit: contain; background-color: #000;">
                    </a>
                </div>
                <div class="col-md-4">
                    <a href="${ctx}/service/trade-in" class="d-block banner-link">
                        <img src="${ctx}/assets/images/banner.png" alt="Độ PC 67 thu cũ đổi mới tại nhà" class="img-fluid rounded border border-light w-100 shadow-sm" style="height: 200px; object-fit: cover;">
                    </a>
                </div>
            </div>

            <!-- Slider Danh Mục -->
            <c:forEach items="${categoryProductMap}" var="entry" varStatus="catStatus">
                <c:set var="catId" value="${entry.value[0].categoryId}" />
                <c:url value="/Home" var="categoryUrl">
                    <c:param name="cid" value="${catId}" />
                </c:url>

                <div class="bg-white border rounded shadow-sm mb-5 mt-4 overflow-hidden">
                    <div class="d-flex justify-content-between align-items-center border-bottom bg-light">
                        <div class="d-flex align-items-center h-100">
                            <a href="${categoryUrl}" class="text-decoration-none">
                                <span class="text-white fw-bold px-4 py-2 text-uppercase d-flex align-items-center"
                                      style="font-size: 16px; background: linear-gradient(90deg, #b71c1c 0%, #ff5252 100%); clip-path: polygon(0 0, 90% 0, 100% 100%, 0% 100%); padding-right: 35px !important; min-width: 240px; cursor: pointer;">
                                        ${entry.key}
                                </span>
                            </a>
                        </div>
                        <a href="${categoryUrl}" class="text-danger text-decoration-none fw-bold me-3 small">XEM TẤT CẢ +</a>
                    </div>

                    <div class="position-relative p-3">
                        <div id="slider_cat_${catStatus.index}" class="d-flex gap-3 hide-scroll pb-2" style="scroll-behavior: smooth;">
                            <c:forEach items="${entry.value}" var="p">
                                <div id="prod-card-${p.id}" data-product-id="${p.id}" class="card h-100 border-0 bg-white shadow-sm flex-shrink-0" style="width: calc(25% - 12px);">
                                    <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none text-center d-block px-3 pt-3">
                                        <img src="${p.image}" class="card-img-top rounded w-100" style="height: 180px; object-fit: contain;">
                                    </a>
                                    <div class="card-body text-start d-flex flex-column px-3 pt-2 pb-3">
                                        <a href="${ctx}/product/detail?id=${p.id}" class="text-decoration-none mb-2">
                                            <h6 class="card-title text-dark fw-semibold" style="font-size: 14px; min-height: 40px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${p.name}</h6>
                                        </a>

                                        <!-- Phần hiển thị Danh mục, Số lượng kho và Mô tả ngắn gọn -->
                                        <div class="bg-light p-2 rounded mb-3" style="font-size: 14px; color: #555;">
                                            <div class="mb-1">Danh mục: <span class="text-dark fw-medium">${p.categoryName}</span></div>
                                            <div class="mb-1">Số lượng kho: <span class="text-dark fw-medium">${p.quantity}</span></div>
                                            <hr class="my-1 border-secondary" style="opacity: 0.2;">
                                            <div class="mt-1" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                                    ${p.description}
                                            </div>
                                        </div>

                                        <div class="mt-auto d-flex justify-content-between align-items-center pt-2 border-top">
                                            <h5 class="text-danger fw-bold m-0" style="font-size: 16px;"><fmt:formatNumber value="${p.price}" pattern="#,###"/> ₫</h5>
                                            <a href="${ctx}/product/detail?id=${p.id}" class="btn btn-danger btn-sm rounded-circle p-0 d-flex align-items-center justify-content-center shadow-sm" style="width: 34px; height: 34px;">
                                                <i class="bi bi-cart-plus fs-6"></i>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        <c:if test="${entry.value.size() > 4}">
                            <button onclick="slideProducts('slider_cat_${catStatus.index}', 'prev')" class="btn btn-danger rounded-circle position-absolute shadow d-flex justify-content-center align-items-center" style="width: 38px; height: 38px; top: 130px; left: -5px; transform: translateY(-50%); z-index: 10;"><i class="bi bi-chevron-left text-white fw-bold"></i></button>
                            <button onclick="slideProducts('slider_cat_${catStatus.index}', 'next')" class="btn btn-danger rounded-circle position-absolute shadow d-flex justify-content-center align-items-center" style="width: 38px; height: 38px; top: 130px; right: -5px; transform: translateY(-50%); z-index: 10;"><i class="bi bi-chevron-right text-white fw-bold"></i></button>
                        </c:if>
                    </div>
                </div>
            </c:forEach>

            <!-- ================= TIN TỨC VÀ KẾT NỐI ================= -->
            <c:if test="${not empty homeNews}">
                <div class="mb-5 mt-4">
                    <div class="d-flex justify-content-between align-items-end border-bottom pb-1 mb-3">
                        <div>
                            <h4 class="fw-bold m-0">Tin tức và Kết nối</h4>
                            <small class="text-muted">Cập nhật thông tin công nghệ từ Độ PC 67</small>
                        </div>
                        <a href="${ctx}/news" class="text-danger text-decoration-none fw-bold small">XEM TẤT CẢ +</a>
                    </div>

                    <c:set var="bigNews" value="${homeNews[0]}" />
                    <div class="row g-3">
                        <!-- Bài to bên trái -->
                        <div class="col-lg-6">
                            <a href="${ctx}/news/detail?id=${bigNews.id}" class="text-decoration-none text-dark d-block">
                                <img src="${bigNews.image}" alt="" class="w-100 rounded shadow-sm" style="height: 340px; object-fit: cover;">
                                <div class="d-flex align-items-center gap-2 mt-2">
                                    <div class="news-date-badge">
                                        <span><fmt:formatDate value="${bigNews.createdAt}" pattern="dd.MM"/></span>
                                        <b><fmt:formatDate value="${bigNews.createdAt}" pattern="yyyy"/></b>
                                    </div>
                                    <h5 class="fw-bold text-uppercase m-0 news-clamp-2" style="font-size: 17px;">
                                        <c:out value="${bigNews.title}"/>
                                    </h5>
                                </div>
                            </a>
                        </div>

                        <!-- 4 bài nhỏ bên phải -->
                        <div class="col-lg-6">
                            <div class="row g-3">
                                <c:forEach items="${homeNews}" var="n" begin="1" end="4">
                                    <div class="col-6">
                                        <a href="${ctx}/news/detail?id=${n.id}" class="text-decoration-none text-dark d-block">
                                            <img src="${n.image}" alt="" class="w-100 rounded shadow-sm" style="height: 150px; object-fit: cover;">
                                            <div class="d-flex align-items-start gap-2 mt-2">
                                                <div class="news-date-badge">
                                                    <span><fmt:formatDate value="${n.createdAt}" pattern="dd.MM"/></span>
                                                    <b><fmt:formatDate value="${n.createdAt}" pattern="yyyy"/></b>
                                                </div>
                                                <div class="fw-bold news-clamp-2" style="font-size: 13px;">
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
    // Cuộn slider; hết sản phẩm cuối thì quay lại đầu (và ngược lại)
    function slideProducts(sliderId, direction) {
        const slider = document.getElementById(sliderId);
        if (!slider) return;

        const step = 290;       // khoảng cuộn mỗi lần bấm
        const tolerance = 5;    // sai số vài pixel
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
