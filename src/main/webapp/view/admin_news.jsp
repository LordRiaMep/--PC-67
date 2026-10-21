<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="url" value="${ctx}/admin/news" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Bài viết - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.snow.css" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
    <style>
        .badge-home-big {
            background: linear-gradient(135deg, #b71c1c, #ff5252);
            color: #fff;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 8px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .badge-home-sub {
            background-color: #0d6efd;
            color: #fff;
            font-size: 11px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .badge-news-only {
            background-color: #f1f3f5;
            color: #495057;
            border: 1px solid #ced4da;
            font-size: 11px;
            font-weight: 500;
            padding: 3px 8px;
            border-radius: 6px;
        }
        .quick-block-btn {
            font-size: 11.5px;
            padding: 3px 8px;
            border-radius: 6px;
            border: 1px solid #dee2e6;
            background: #fff;
            color: #495057;
            cursor: pointer;
            transition: all 0.15s ease;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .quick-block-btn:hover {
            background: #f8f9fa;
            color: var(--brand);
            border-color: var(--brand);
            transform: translateY(-1px);
        }
        .news-thumb {
            width: 72px;
            height: 52px;
            border-radius: 6px;
            object-fit: cover;
            border: 1px solid var(--border-color);
        }
        .summary-clamp-2 {
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            font-size: 12.5px;
            color: #6c757d;
        }
        .info-callout {
            background: linear-gradient(90deg, #fff5f5 0%, #ffffff 100%);
            border-left: 4px solid var(--brand);
            border-radius: 8px;
            padding: 14px 18px;
            margin-bottom: 22px;
            box-shadow: 0 1px 4px rgba(0,0,0,.04);
        }

        /* Quill Rich Text Editor Styles */
        .editor-container {
            border: 1px solid #ced4da;
            border-radius: 8px;
            background: #fff;
            overflow: hidden;
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
        }
        .editor-container.is-focused {
            border-color: var(--brand);
            box-shadow: 0 0 0 0.2rem rgba(227, 0, 25, 0.15);
        }
        .editor-container .ql-toolbar.ql-snow {
            border: none;
            border-bottom: 1px solid #e9ecef;
            background: #fafbfc;
            padding: 8px 10px;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 3px 6px;
        }
        .editor-container .ql-toolbar.ql-snow .ql-formats {
            display: inline-flex;
            align-items: center;
            margin-right: 4px;
            padding-right: 6px;
            border-right: 1px solid #dee2e6;
        }
        .editor-container .ql-toolbar.ql-snow .ql-formats:last-child {
            border-right: none;
            margin-right: 0;
            padding-right: 0;
        }
        .editor-container .ql-toolbar.ql-snow button,
        .editor-container .ql-toolbar.ql-snow .ql-picker-label {
            border-radius: 4px;
            transition: background-color 0.15s, color 0.15s;
        }
        .editor-container .ql-toolbar.ql-snow button:hover,
        .editor-container .ql-toolbar.ql-snow .ql-picker-label:hover {
            background-color: #e9ecef;
        }

        /* Tùy biến hiển thị tiếng Việt tinh tế cho dropdown Tiêu đề */
        .ql-snow .ql-picker.ql-header {
            width: 140px !important;
        }
        .ql-snow .ql-picker.ql-header .ql-picker-label::before,
        .ql-snow .ql-picker.ql-header .ql-picker-item::before {
            content: 'Văn bản thường' !important;
        }
        .ql-snow .ql-picker.ql-header .ql-picker-label[data-value="2"]::before,
        .ql-snow .ql-picker.ql-header .ql-picker-item[data-value="2"]::before {
            content: 'Tiêu đề lớn (H2)' !important;
        }
        .ql-snow .ql-picker.ql-header .ql-picker-label[data-value="3"]::before,
        .ql-snow .ql-picker.ql-header .ql-picker-item[data-value="3"]::before {
            content: 'Tiêu đề vừa (H3)' !important;
        }
        .ql-snow .ql-picker.ql-header .ql-picker-label[data-value="4"]::before,
        .ql-snow .ql-picker.ql-header .ql-picker-item[data-value="4"]::before {
            content: 'Tiêu đề nhỏ (H4)' !important;
        }

        /* Thanh chú giải động tinh tế ngay dưới toolbar */
        .toolbar-hint-bar {
            background: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
            padding: 5px 12px;
            font-size: 12px;
            color: #495057;
            min-height: 30px;
            display: flex;
            align-items: center;
            transition: all 0.2s ease;
        }
        .toolbar-hint-bar.is-active {
            background: #fff8e1;
            color: #795548;
            border-bottom-color: #ffe082;
        }

        .editor-container .ql-container.ql-snow {
            border: none;
            font-size: 14px;
            font-family: inherit;
        }
        .editor-container .ql-editor {
            min-height: 230px;
            max-height: 450px;
            overflow-y: auto;
            line-height: 1.7;
            color: #2b2b2b;
        }
        .editor-container .ql-editor.ql-blank::before {
            color: #adb5bd;
            font-style: italic;
            font-size: 13.5px;
        }

        /* Hộp Callout / Lưu ý nổi bật trong bài viết */
        .news-callout {
            border-left: 4px solid var(--brand);
            background: #fff5f5;
            padding: 10px 14px;
            margin: 12px 0;
            border-radius: 0 6px 6px 0;
        }

        /* Đồng bộ kiểu hiển thị với trang xem chi tiết */
        .news-content {
            font-size: 15px;
            line-height: 1.75;
            color: #222;
        }
        .news-content img, .ql-editor img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 14px auto;
            border-radius: 6px;
        }
        .news-content h2, .news-content h3, .news-content h4,
        .ql-editor h2, .ql-editor h3, .ql-editor h4 {
            font-weight: 700;
            margin: 16px 0 8px;
        }
        .news-content blockquote, .ql-editor blockquote {
            border-left: 4px solid #ced4da;
            padding: 6px 14px;
            margin: 12px 0;
            color: #6c757d;
            font-style: italic;
            background: #f8f9fa;
            border-radius: 0 6px 6px 0;
        }

        /* Chế độ Toàn màn hình (Fullscreen) */
        .editor-wrapper.fullscreen-mode {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            z-index: 10000;
            background: #ffffff;
            padding: 20px 30px;
            display: flex;
            flex-direction: column;
            box-shadow: 0 0 30px rgba(0,0,0,0.3);
        }
        .editor-wrapper.fullscreen-mode .editor-container {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            height: calc(100vh - 140px);
        }
        .editor-wrapper.fullscreen-mode .ql-container {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }
        .editor-wrapper.fullscreen-mode .ql-editor,
        .editor-wrapper.fullscreen-mode #htmlSourceEditor {
            flex-grow: 1;
            max-height: none !important;
            height: 100% !important;
        }
    </style>
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="news"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <div>
            <h3 class="m-0 text-dark fw-bold"><i class="fa-solid fa-newspaper text-danger me-2"></i>Quản lý Bài viết & Tin tức</h3>
            <span class="text-secondary small">Quản lý các bài viết hiển thị ở khối "Tin tức và Kết nối" trang chủ và chuyên trang Tin tức</span>
        </div>
        <div class="d-flex align-items-center gap-2">
            <a href="${ctx}/Home" target="_blank" class="btn btn-outline-danger btn-sm shadow-none" title="Xem hiển thị thực tế trên trang chủ">
                <i class="fa-solid fa-house me-1"></i> Xem Trang chủ
            </a>
            <a href="${ctx}/news" target="_blank" class="btn btn-outline-secondary btn-sm shadow-none" title="Xem chuyên mục tin tức khách hàng">
                <i class="fa-solid fa-arrow-up-right-from-square me-1"></i> Xem Trang Tin tức
            </a>
            <span class="mx-2 text-muted">|</span>
            <span class="me-2 small">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName != null ? sessionScope.USER_LOGIN.fullName : 'Admin'}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i></a>
        </div>
    </header>

    <!-- Hộp thông tin cơ chế hiển thị Trang chủ -->
    <div class="info-callout d-flex flex-wrap align-items-center justify-content-between gap-3">
        <div class="d-flex align-items-start gap-3">
            <div class="fs-3 text-danger"><i class="fa-solid fa-circle-info"></i></div>
            <div>
                <strong class="text-dark d-block mb-1">Cơ chế hiển thị trên Trang chủ (Mục "Tin tức và Kết nối"):</strong>
                <span class="text-secondary small" style="line-height: 1.5;">
                    Trang chủ tự động chọn <strong>5 bài viết mới nhất có trạng thái "HIỂN THỊ" (ACTIVE)</strong>:
                    <span class="badge-home-big mx-1"><i class="fa-solid fa-crown"></i> 1 bài to bên trái</span> (bài ACTIVE mới nhất) và
                    <span class="badge-home-sub mx-1"><i class="fa-solid fa-layer-group"></i> 4 bài nhỏ bên phải</span>.
                    Các bài có trạng thái <strong>"ẨN" (HIDDEN)</strong> sẽ không xuất hiện trên trang chủ.
                </span>
            </div>
        </div>
        <div class="d-flex gap-2">
            <a href="${url}" class="btn btn-sm btn-ghost"><i class="fa-solid fa-arrows-rotate me-1"></i> Tải lại danh sách</a>
        </div>
    </div>

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-circle-check fs-5 me-2"></i>
            <div>${successMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-triangle-exclamation fs-5 me-2"></i>
            <div>${errorMessage}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- 4 Thẻ thống kê số liệu -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="stat-card py-3">
                <div class="icon-box bg-danger bg-opacity-10 text-danger"><i class="fa-solid fa-newspaper"></i></div>
                <div>
                    <div class="muted small mb-1">Tổng số bài viết</div>
                    <div class="fs-4 text-dark fw-bold">${statTotal}</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card py-3">
                <div class="icon-box bg-success bg-opacity-10 text-success"><i class="fa-solid fa-eye"></i></div>
                <div>
                    <div class="muted small mb-1">Đang hiển thị (ACTIVE)</div>
                    <div class="fs-4 text-success fw-bold">${statActive}</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card py-3">
                <div class="icon-box bg-secondary bg-opacity-10 text-secondary"><i class="fa-solid fa-eye-slash"></i></div>
                <div>
                    <div class="muted small mb-1">Đang ẩn (HIDDEN)</div>
                    <div class="fs-4 text-secondary fw-bold">${statHidden}</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card py-3">
                <div class="icon-box bg-warning bg-opacity-10 text-warning"><i class="fa-solid fa-fire"></i></div>
                <div>
                    <div class="muted small mb-1">Bài viết nổi bật</div>
                    <div class="fs-4 text-warning fw-bold">${statFeatured}</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bố cục 2 cột: Cột trái (Form nhập liệu) - Cột phải (Danh sách bài viết) -->
    <div class="row g-4">
        <!-- FORM THÊM / SỬA BÀI VIẾT -->
        <div class="col-xl-5 col-lg-5">
            <form action="${url}" method="post" class="panel sticky-panel" id="newsForm">
                <div class="panel-head">
                    <h5>
                        <i class="fa-solid ${not empty news ? 'fa-pen-to-square' : 'fa-plus'} me-2"></i>
                        ${not empty news ? 'Sửa bài viết' : 'Thêm bài viết mới'}
                    </h5>
                    <c:if test="${not empty news}">
                        <span class="badge bg-danger">#${news.id}</span>
                    </c:if>
                </div>

                <div class="panel-body">
                    <input type="hidden" name="id" value="${news.id != null ? news.id : 0}">
                    <input type="hidden" name="action" value="${not empty news ? 'update' : 'insert'}">
                    <input type="hidden" name="page" value="${currentPage}">
                    <input type="hidden" name="keyword" value="${keyword}">
                    <input type="hidden" name="statusFilter" value="${status}">
                    <input type="hidden" name="featuredFilter" value="${featured}">

                    <!-- Tiêu đề bài viết -->
                    <div class="mb-3">
                        <label class="field-label">Tiêu đề bài viết <span class="text-danger">*</span></label>
                        <input type="text" name="title" class="form-control field shadow-none"
                               value="<c:out value='${news.title}'/>"
                               placeholder="Ví dụ: Top 5 cấu hình máy tính chơi game siêu mượt 2026" required>
                    </div>

                    <!-- Ảnh bìa bài viết & Preview -->
                    <div class="mb-3">
                        <label class="field-label">Ảnh đại diện (URL hoặc đường dẫn)</label>
                        <input type="text" id="newsImageUrl" name="image" class="form-control field shadow-none mb-2"
                               value="<c:out value='${news.image}'/>"
                               placeholder="https://... hoặc ${ctx}/assets/images/...">
                        <div class="img-preview" id="newsImgPreview" style="height: 140px;">
                            <c:choose>
                                <c:when test="${not empty news.image}">
                                    <img src="${news.image}" alt="Preview" onerror="this.onerror=null; this.src='https://placehold.co/600x340/e9ecef/6c757d?text=No+Image';">
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center text-muted">
                                        <i class="fa-regular fa-image fs-1 d-block mb-1"></i>
                                        <small>Nhập link ảnh để xem trước</small>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Tác giả -->
                    <div class="mb-3">
                        <label class="field-label">Tác giả</label>
                        <input type="text" name="author" class="form-control field shadow-none"
                               value="<c:out value='${news.author != null ? news.author : sessionScope.USER_LOGIN.fullName}'/>"
                               placeholder="Độ PC 67">
                    </div>

                    <!-- Tóm tắt ngắn -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <label class="field-label m-0">Tóm tắt ngắn (1-2 câu trích dẫn)</label>
                            <small class="text-muted" id="summaryCharCount">0/500</small>
                        </div>
                        <textarea name="summary" id="summaryInput" class="form-control field shadow-none" rows="2" maxlength="500"
                                  placeholder="Mô tả ngắn gọn nội dung bài viết, hiển thị ở thẻ tin tức và đầu bài chi tiết..."><c:out value='${news.summary}'/></textarea>
                    </div>

                    <!-- Nội dung bài viết chi tiết (WYSIWYG Editor) -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-1 flex-wrap gap-1">
                            <div>
                                <label class="field-label m-0 fw-bold text-dark">
                                    Nội dung chi tiết <span class="text-danger">*</span>
                                </label>
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle ms-1" style="font-size: 10px;" id="editorModeBadge">Soạn trực quan</span>
                            </div>
                            <div class="d-flex align-items-center gap-1">
                                <button type="button" class="btn btn-outline-secondary btn-sm py-0 px-2" id="toggleCodeBtn" onclick="toggleCodeView()" title="Chuyển đổi giữa chế độ trực quan và mã HTML">
                                    <i class="fa-solid fa-code me-1"></i><span id="toggleCodeLabel">Mã HTML</span>
                                </button>
                                <button type="button" class="btn btn-outline-secondary btn-sm py-0 px-2" id="toggleFullscreenBtn" onclick="toggleFullscreenEditor()" title="Mở rộng toàn màn hình để viết bài dễ hơn">
                                    <i class="fa-solid fa-expand" id="fullscreenIcon"></i>
                                </button>
                                <button type="button" class="btn btn-outline-danger btn-sm py-0 px-2" onclick="previewContentModal()" title="Xem trước cách bài viết hiển thị trên website">
                                    <i class="fa-regular fa-eye me-1"></i>Xem trước
                                </button>
                            </div>
                        </div>

                        <!-- Thanh công cụ chèn khối nhanh cho người mới -->
                        <div class="d-flex flex-wrap gap-1 mb-2 align-items-center">
                            <span class="text-muted small me-1" style="font-size: 11px;"><i class="fa-solid fa-wand-magic-sparkles text-danger me-1"></i>Mẫu nhanh:</span>
                            <button type="button" class="quick-block-btn" onclick="insertCustomBlock('heading')" title="Chèn tiêu đề mục mới">
                                <i class="fa-solid fa-heading me-1 text-primary"></i>+ Tiêu đề
                            </button>
                            <button type="button" class="quick-block-btn" onclick="openInsertImageModal()" title="Chèn ảnh từ link hoặc tải từ máy tính">
                                <i class="fa-regular fa-image me-1 text-success"></i>+ Chèn ảnh
                            </button>
                            <button type="button" class="quick-block-btn" onclick="insertCustomBlock('callout')" title="Chèn khung ghi chú / lưu ý nổi bật">
                                <i class="fa-regular fa-lightbulb me-1 text-warning"></i>+ Khung lưu ý
                            </button>
                            <button type="button" class="quick-block-btn" onclick="insertCustomBlock('quote')" title="Chèn đoạn trích dẫn nổi bật">
                                <i class="fa-solid fa-quote-left me-1 text-secondary"></i>+ Trích dẫn
                            </button>
                            <button type="button" class="quick-block-btn" onclick="insertCustomBlock('list')" title="Chèn danh sách ý chính gạch đầu dòng">
                                <i class="fa-solid fa-list-ul me-1 text-info"></i>+ Danh sách
                            </button>
                            <button type="button" class="quick-block-btn text-danger" onclick="clearEditorContent()" title="Xóa trắng nội dung để soạn lại">
                                <i class="fa-regular fa-trash-can me-1"></i>Xóa sạch
                            </button>
                        </div>

                        <!-- Khung soạn thảo chính -->
                        <div id="editorWrapper" class="editor-wrapper">
                            <div class="editor-container" id="editorContainer">
                                <!-- Khung soạn thảo trực quan Quill -->
                                <div id="quillEditor"></div>

                                <!-- Thanh chú giải động tinh tế ngay dưới toolbar -->
                                <div id="toolbarHintBar" class="toolbar-hint-bar">
                                    <span id="toolbarHintText">
                                        <i class="fa-regular fa-lightbulb text-warning me-1"></i>Rê chuột vào biểu tượng bất kỳ trên thanh công cụ để xem tên & hướng dẫn
                                    </span>
                                </div>

                                <!-- Khung xem/sửa mã nguồn HTML -->
                                <textarea id="htmlSourceEditor" class="form-control font-monospace border-0 shadow-none" 
                                          style="display: none; min-height: 250px; font-size: 13px; line-height: 1.5; resize: vertical;" 
                                          placeholder="Xem hoặc chỉnh sửa trực tiếp mã HTML tại đây..."></textarea>
                            </div>

                            <!-- Thống kê số từ & liên kết xem bảng giải thích biểu tượng -->
                            <div class="d-flex justify-content-between align-items-center mt-1 px-1">
                                <small class="text-muted" id="contentStatsCounter" style="font-size: 11.5px;">
                                    <i class="fa-solid fa-pen-nib me-1"></i>0 từ &bull; 0 ký tự
                                </small>
                                <a class="btn btn-link btn-xs text-decoration-none p-0 text-secondary" data-bs-toggle="collapse" href="#toolbarLegendCard" style="font-size: 11px;">
                                    <i class="fa-regular fa-circle-question me-1 text-primary"></i>Giải thích các ký tự
                                </a>
                            </div>

                            <!-- Bảng giải nghĩa các ký tự trên thanh công cụ (Mở ra khi bấm) -->
                            <div class="collapse mt-2" id="toolbarLegendCard">
                                <div class="card card-body bg-light border p-3 small shadow-sm" style="font-size: 11.5px; border-radius: 8px;">
                                    <div class="d-flex justify-content-between align-items-center mb-2 pb-1 border-bottom">
                                        <span class="fw-bold text-dark"><i class="fa-solid fa-book-open text-danger me-1"></i>Ý nghĩa các ký tự trên thanh công cụ</span>
                                        <button type="button" class="btn-close shadow-none" style="font-size: 8px;" data-bs-toggle="collapse" data-bs-target="#toolbarLegendCard"></button>
                                    </div>
                                    <div class="row g-2">
                                        <div class="col-sm-6">
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">Normal ▾</span> <strong>Kiểu chữ:</strong> Chọn tiêu đề (H2, H3, H4) hoặc thường.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">B</span> <strong>In đậm:</strong> Nhấn mạnh chữ quan trọng <em>(Ctrl+B)</em>.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">I</span> <strong>In nghiêng:</strong> Thuật ngữ, trích dẫn <em>(Ctrl+I)</em>.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">U</span> <strong>Gạch chân:</strong> Gạch dưới chân chữ <em>(Ctrl+U)</em>.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">S</span> <strong>Gạch ngang:</strong> Đánh dấu giá cũ hoặc nội dung sửa đổi.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">A_</span> <strong>Màu chữ:</strong> Đổi màu sắc cho chữ.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">A▦</span> <strong>Màu nền:</strong> Tô nền highlight dạ quang cho chữ.</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">1≡</span> <strong>Danh sách số:</strong> Tự động đánh số 1, 2, 3...</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">•≡</span> <strong>Danh sách chấm:</strong> Gạch đầu dòng các ý quan trọng.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">≡</span> <strong>Căn lề:</strong> Căn trái, giữa, phải hoặc căn đều 2 bên.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">”</span> <strong>Trích dẫn:</strong> Đóng khung đoạn văn cần trích lời.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">&lt;/&gt;</span> <strong>Mã code:</strong> Hiển thị cấu hình hoặc mã lập trình.</div>
                                            <div class="mb-1"><span class="badge bg-white text-dark border me-1">🔗 / 🖼️</span> <strong>Link / Ảnh:</strong> Chèn liên kết web hoặc ảnh.</div>
                                            <div class="mb-1"><span class="badge bg-white text-danger border me-1">T_x</span> <strong>Xóa định dạng:</strong> Tẩy sạch format, về chữ gốc.</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Input ẩn để gửi dữ liệu bài viết sang Servlet doPost -->
                        <textarea name="content" id="contentInput" style="display: none;"><c:out value='${news.content}'/></textarea>
                    </div>

                    <!-- Tùy chọn trạng thái & Nổi bật -->
                    <div class="p-3 bg-light rounded border mb-4">
                        <div class="row g-2 align-items-center">
                            <div class="col-7">
                                <label class="field-label mb-1">Trạng thái hiển thị</label>
                                <select name="status" class="form-select field shadow-none">
                                    <option value="ACTIVE" ${news.status == 'ACTIVE' || news.status == null ? 'selected' : ''}>Hiển thị (ACTIVE)</option>
                                    <option value="HIDDEN" ${news.status == 'HIDDEN' ? 'selected' : ''}>Ẩn (HIDDEN)</option>
                                </select>
                            </div>
                            <div class="col-5 pt-3">
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" role="switch" id="isFeaturedSwitch" name="isFeatured" ${news.featured ? 'checked' : ''}>
                                    <label class="form-check-label small fw-semibold" for="isFeaturedSwitch">Bài nổi bật</label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Nút thao tác -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-neon px-4 flex-grow-1">
                            <i class="fa-solid fa-floppy-disk me-1"></i> ${not empty news ? 'Cập nhật bài viết' : 'Lưu bài viết'}
                        </button>
                        <a href="${url}?page=${currentPage}&keyword=${keyword}&status=${status}&featured=${featured}" class="btn btn-ghost px-3" title="Xóa trắng form để thêm mới">
                            Làm mới
                        </a>
                    </div>
                </div>
            </form>
        </div>

        <!-- DANH SÁCH BÀI VIẾT -->
        <div class="col-xl-7 col-lg-7">
            <div class="panel overflow-hidden mb-4">
                <div class="panel-head flex-wrap gap-2">
                    <h5 class="m-0"><i class="fa-solid fa-list me-2"></i>Danh sách bài viết (${totalNews})</h5>

                    <!-- Bộ lọc & Tìm kiếm -->
                    <form action="${url}" method="get" class="d-flex flex-wrap gap-2 align-items-center">
                        <div class="search-box" style="max-width: 220px;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" name="keyword" value="<c:out value='${keyword}'/>" class="form-control field shadow-none" placeholder="Tìm theo tiêu đề, tác giả...">
                        </div>

                        <select name="status" class="form-select form-select-sm field shadow-none" style="width: auto;">
                            <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>-- Tất cả trạng thái --</option>
                            <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Đang hiển thị (ACTIVE)</option>
                            <option value="HIDDEN" ${status == 'HIDDEN' ? 'selected' : ''}>Đang ẩn (HIDDEN)</option>
                        </select>

                        <select name="featured" class="form-select form-select-sm field shadow-none" style="width: auto;">
                            <option value="ALL" ${featured == 'ALL' ? 'selected' : ''}>-- Mọi bài viết --</option>
                            <option value="FEATURED" ${featured == 'FEATURED' ? 'selected' : ''}>Chỉ bài nổi bật</option>
                            <option value="NOT_FEATURED" ${featured == 'NOT_FEATURED' ? 'selected' : ''}>Bài thường</option>
                        </select>

                        <button type="submit" class="btn btn-sm btn-neon px-3 shadow-none"><i class="fa-solid fa-filter me-1"></i> Lọc</button>
                        <c:if test="${not empty keyword || (status != 'ALL' && not empty status) || (featured != 'ALL' && not empty featured)}">
                            <a href="${url}" class="btn btn-sm btn-ghost" title="Xóa bộ lọc"><i class="fa-solid fa-xmark"></i></a>
                        </c:if>
                    </form>
                </div>

                <!-- Bảng danh sách bài viết -->
                <div class="table-responsive">
                    <table class="table tbl align-middle">
                        <thead>
                        <tr>
                            <th style="width: 85px;">Ảnh bìa</th>
                            <th>Tiêu đề bài viết & Vị trí hiển thị</th>
                            <th style="width: 140px;">Tác giả & Ngày đăng</th>
                            <th style="width: 90px;" class="text-center">Lượt xem</th>
                            <th style="width: 110px;" class="text-center">Trạng thái</th>
                            <th style="width: 130px;" class="text-end">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listNews}" var="n">
                            <c:set var="isHomeBig" value="${top5HomeIds != null && top5HomeIds.size() > 0 && top5HomeIds[0] == n.id}" />
                            <c:set var="isHomeSub" value="${top5HomeIds != null && top5HomeIds.size() > 1 && top5HomeIds.contains(n.id) && !isHomeBig}" />

                            <tr class="${news != null && news.id == n.id ? 'row-edit' : ''}">
                                <!-- Ảnh bìa -->
                                <td>
                                    <div class="position-relative">
                                        <img src="${n.image}" alt="" class="news-thumb" onerror="this.onerror=null; this.src='https://placehold.co/120x90/e9ecef/6c757d?text=No+Img';">
                                        <div class="position-absolute bottom-0 start-0 bg-dark bg-opacity-75 text-white px-1 rounded-end" style="font-size: 10px;">
                                            #${n.id}
                                        </div>
                                    </div>
                                </td>

                                <!-- Tiêu đề & Huy hiệu vị trí -->
                                <td>
                                    <div class="prod-name mb-1">
                                        <a href="${ctx}/news/detail?id=${n.id}" target="_blank" class="text-decoration-none text-dark hover-danger fw-bold" title="Bấm để xem bài viết trên website">
                                            <c:out value="${n.title}"/>
                                        </a>
                                    </div>

                                    <c:if test="${not empty n.summary}">
                                        <div class="summary-clamp-2 mb-2"><c:out value="${n.summary}"/></div>
                                    </c:if>

                                    <!-- Các huy hiệu vị trí & đặc tính -->
                                    <div class="d-flex flex-wrap gap-1 align-items-center mt-1">
                                        <!-- Vị trí Trang chủ -->
                                        <c:choose>
                                            <c:when test="${isHomeBig}">
                                                <span class="badge-home-big" title="Đang là bài to chính ở mục Tin tức và Kết nối trên trang chủ">
                                                    <i class="fa-solid fa-crown"></i> Trang chủ: Bài chính
                                                </span>
                                            </c:when>
                                            <c:when test="${isHomeSub}">
                                                <span class="badge-home-sub" title="Đang là 1 trong 4 bài nhỏ hiển thị trên trang chủ">
                                                    <i class="fa-solid fa-house"></i> Trang chủ: Bài phụ
                                                </span>
                                            </c:when>
                                            <c:when test="${n.status == 'ACTIVE'}">
                                                <span class="badge-news-only" title="Hiển thị tại chuyên trang Tin tức">
                                                    <i class="fa-regular fa-newspaper me-1"></i>Trang tin tức
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary" title="Đang ẩn, không xuất hiện ở bất cứ trang nào">
                                                    <i class="fa-solid fa-eye-slash me-1"></i>Đang ẩn
                                                </span>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- Huy hiệu nổi bật -->
                                        <c:if test="${n.featured}">
                                            <span class="badge bg-warning text-dark" title="Đánh dấu tin nổi bật">
                                                <i class="fa-solid fa-fire me-1 text-danger"></i>Nổi bật
                                            </span>
                                        </c:if>
                                    </div>
                                </td>

                                <!-- Tác giả & Ngày đăng -->
                                <td>
                                    <div class="fw-semibold text-dark small"><i class="fa-regular fa-user me-1 text-muted"></i><c:out value="${n.author}"/></div>
                                    <div class="muted small mt-1">
                                        <i class="fa-regular fa-clock me-1"></i><fmt:formatDate value="${n.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </td>

                                <!-- Lượt xem -->
                                <td class="text-center">
                                    <span class="badge bg-light text-dark border px-2 py-1">
                                        <i class="fa-regular fa-eye me-1 text-muted"></i>${n.viewCount}
                                    </span>
                                </td>

                                <!-- Trạng thái & Nút đổi nhanh -->
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${n.status == 'ACTIVE'}">
                                            <a href="${url}?action=toggle_status&id=${n.id}&page=${currentPage}&keyword=${keyword}&status=${status}&featured=${featured}"
                                               class="btn btn-sm btn-outline-success border-0 px-2 py-1 shadow-none"
                                               title="Bấm để ẩn bài viết khỏi trang chủ và website"
                                               onclick="return confirm('Chuyển bài viết #${n.id} sang trạng thái ẨN?');">
                                                <i class="fa-solid fa-circle-check text-success me-1"></i> Hiển thị
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${url}?action=toggle_status&id=${n.id}&page=${currentPage}&keyword=${keyword}&status=${status}&featured=${featured}"
                                               class="btn btn-sm btn-outline-secondary border-0 px-2 py-1 shadow-none text-muted"
                                               title="Bấm để hiển thị lại bài viết trên website"
                                               onclick="return confirm('Chuyển bài viết #${n.id} sang trạng thái HIỂN THỊ?');">
                                                <i class="fa-solid fa-circle-xmark text-secondary me-1"></i> Đang ẩn
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- Thao tác -->
                                <td class="text-end text-nowrap">
                                    <!-- Xem bài ngoài web -->
                                    <a href="${ctx}/news/detail?id=${n.id}" target="_blank" class="btn btn-sm btn-ghost act me-1" title="Xem trên web">
                                        <i class="fa-solid fa-arrow-up-right-from-square"></i>
                                    </a>

                                    <!-- Nút toggle nhanh nổi bật -->
                                    <a href="${url}?action=toggle_featured&id=${n.id}&page=${currentPage}&keyword=${keyword}&status=${status}&featured=${featured}"
                                       class="btn btn-sm ${n.featured ? 'btn-warning text-dark' : 'btn-ghost'} act me-1"
                                       title="${n.featured ? 'Bỏ đánh dấu nổi bật' : 'Đánh dấu nổi bật'}">
                                        <i class="fa-solid fa-star"></i>
                                    </a>

                                    <!-- Nút Sửa -->
                                    <a href="${url}?action=edit&id=${n.id}&page=${currentPage}&keyword=${keyword}&status=${status}&featured=${featured}"
                                       class="btn btn-sm btn-ghost act me-1" title="Chỉnh sửa bài viết">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>

                                    <!-- Nút Xóa -->
                                    <a href="${url}?action=delete&id=${n.id}&page=${currentPage}&keyword=${keyword}&status=${status}&featured=${featured}"
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa bài viết \"${n.title}\"? Thao tác này không thể hoàn tác!');"
                                       class="btn btn-sm btn-outline-danger act" title="Xóa bài viết">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty listNews}">
                            <tr>
                                <td colspan="6" class="text-center muted py-5">
                                    <i class="fa-regular fa-newspaper fs-1 d-block mb-2 text-secondary"></i>
                                    <h6 class="text-secondary">Không tìm thấy bài viết nào phù hợp.</h6>
                                    <c:if test="${not empty keyword || status != 'ALL' || featured != 'ALL'}">
                                        <a href="${url}" class="btn btn-sm btn-outline-danger mt-2">Xóa bộ lọc</a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Phân trang -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-end mb-4">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link shadow-none" href="${url}?page=${currentPage - 1}&keyword=${keyword}&status=${status}&featured=${featured}">Trước</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link shadow-none" href="${url}?page=${i}&keyword=${keyword}&status=${status}&featured=${featured}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link shadow-none" href="${url}?page=${currentPage + 1}&keyword=${keyword}&status=${status}&featured=${featured}">Sau</a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>
    </div>
</main>

<!-- Modal xem trước nội dung HTML bài viết -->
<div class="modal fade" id="contentPreviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold text-danger"><i class="fa-solid fa-eye me-2"></i>Xem trước nội dung bài viết</h5>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <h3 id="modalTitlePreview" class="fw-bold mb-2 text-uppercase" style="font-size: 22px;"></h3>
                <div class="text-muted small pb-2 border-bottom mb-3" id="modalMetaPreview"></div>
                <div id="modalSummaryPreview" class="fst-italic text-secondary mb-3 fw-semibold"></div>
                <div id="modalBodyPreview" class="news-content border rounded p-3 bg-white shadow-sm"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal chèn hình ảnh thông minh cho người mới -->
<div class="modal fade" id="insertImageModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold text-danger">
                    <i class="fa-regular fa-image me-2"></i>Chèn hình ảnh vào bài viết
                </h5>
                <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label small fw-semibold">Cách 1: Nhập link ảnh (URL)</label>
                    <input type="text" id="modalImgUrlInput" class="form-control field shadow-none" 
                           placeholder="https://... hoặc ${ctx}/assets/images/...">
                    <small class="text-muted" style="font-size: 11px;">Khuyên dùng: Link ảnh trực tuyến hoặc ảnh trong thư mục website.</small>
                </div>

                <div class="mb-3 text-center text-muted small position-relative">
                    <hr class="m-0">
                    <span class="bg-white px-2 position-relative" style="top: -10px;">HOẶC</span>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold">Cách 2: Chọn tệp ảnh từ máy tính</label>
                    <input type="file" id="modalImgFileInput" class="form-control field shadow-none" accept="image/*">
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold">Mô tả ảnh / Chú thích (Alt text)</label>
                    <input type="text" id="modalImgAltInput" class="form-control field shadow-none" placeholder="Ví dụ: Trải nghiệm gaming thực tế">
                </div>

                <!-- Khung xem trước ảnh -->
                <div id="modalImgPreviewContainer" class="border rounded p-2 text-center bg-light" style="display: none;">
                    <small class="d-block text-muted mb-1">Xem trước ảnh:</small>
                    <img id="modalImgPreviewEl" src="" alt="Preview" style="max-height: 180px; max-width: 100%; object-fit: contain; border-radius: 4px;">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost btn-sm" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-neon btn-sm px-3" onclick="confirmInsertImage()">
                    <i class="fa-solid fa-check me-1"></i> Chèn vào bài viết
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.min.js"></script>
<script>
    // 1. Xem trước ảnh đại diện tự động khi nhập / dán URL
    const imgUrlInput = document.getElementById('newsImageUrl');
    const imgPreviewBox = document.getElementById('newsImgPreview');
    if (imgUrlInput && imgPreviewBox) {
        imgUrlInput.addEventListener('input', function() {
            const url = this.value.trim();
            if (url) {
                imgPreviewBox.innerHTML = '<img src="' + url + '" alt="Preview" onerror="this.onerror=null; this.src=\'https://placehold.co/600x340/e9ecef/6c757d?text=No+Image\';">';
            } else {
                imgPreviewBox.innerHTML = '<div class="text-center text-muted"><i class="fa-regular fa-image fs-1 d-block mb-1"></i><small>Nhập link ảnh để xem trước</small></div>';
            }
        });
    }

    // 2. Đếm ký tự cho phần tóm tắt ngắn
    const summaryInput = document.getElementById('summaryInput');
    const summaryCount = document.getElementById('summaryCharCount');
    if (summaryInput && summaryCount) {
        const updateSummaryCount = () => {
            summaryCount.innerText = summaryInput.value.length + '/500';
        };
        summaryInput.addEventListener('input', updateSummaryCount);
        updateSummaryCount();
    }

    // 3. Khởi tạo Trình soạn thảo trực quan WYSIWYG (Quill)
    let isCodeView = false;
    let isFullscreen = false;

    const quill = new Quill('#quillEditor', {
        theme: 'snow',
        placeholder: 'Nhập nội dung bài viết chi tiết tại đây... Bạn có thể gõ chữ, định dạng, bôi đậm, chèn ảnh hoặc liên kết như trong Word.',
        modules: {
            toolbar: {
                container: [
                    [{ 'header': [2, 3, 4, false] }],
                    ['bold', 'italic', 'underline', 'strike'],
                    [{ 'color': [] }, { 'background': [] }],
                    [{ 'list': 'ordered'}, { 'list': 'bullet' }, { 'align': [] }],
                    ['blockquote', 'code-block'],
                    ['link', 'image', 'clean']
                ],
                handlers: {
                    'image': function() {
                        openInsertImageModal();
                    }
                }
            }
        }
    });

    // 4. Dữ liệu giải nghĩa chi tiết & Tooltip cho từng ký tự trên thanh công cụ
    const toolbarDescriptions = {
        'ql-header': {
            name: 'Kiểu tiêu đề (Heading)',
            desc: 'Chọn cỡ chữ: Tiêu đề lớn (H2), Tiêu đề vừa (H3), Tiêu đề nhỏ (H4), hoặc Văn bản thường',
            icon: 'fa-solid fa-heading text-dark'
        },
        'ql-bold': {
            name: 'In đậm (Bold)',
            desc: 'Làm đậm nét chữ để nhấn mạnh từ khóa hoặc cụm từ quan trọng',
            hotkey: 'Ctrl + B',
            icon: 'fa-solid fa-bold text-dark'
        },
        'ql-italic': {
            name: 'In nghiêng (Italic)',
            desc: 'Làm nghiêng chữ dùng cho thuật ngữ, trích đoạn hoặc tên riêng',
            hotkey: 'Ctrl + I',
            icon: 'fa-solid fa-italic text-dark'
        },
        'ql-underline': {
            name: 'Gạch chân (Underline)',
            desc: 'Gạch một đường dưới chân chữ để tạo sự chú ý',
            hotkey: 'Ctrl + U',
            icon: 'fa-solid fa-underline text-dark'
        },
        'ql-strike': {
            name: 'Gạch ngang (Strikethrough)',
            desc: 'Gạch ngang qua chữ để biểu thị giá cũ hoặc nội dung sửa đổi',
            icon: 'fa-solid fa-strikethrough text-dark'
        },
        'ql-color': {
            name: 'Màu chữ (Text Color)',
            desc: 'Đổi màu sắc cho chữ được chọn',
            icon: 'fa-solid fa-palette text-danger'
        },
        'ql-background': {
            name: 'Màu nền (Highlight)',
            desc: 'Tô màu nền dạ quang đánh dấu đoạn văn quan trọng',
            icon: 'fa-solid fa-highlighter text-warning'
        },
        'ql-list-ordered': {
            name: 'Danh sách số (Ordered List)',
            desc: 'Tự động đánh số thứ tự tăng dần 1, 2, 3...',
            icon: 'fa-solid fa-list-ol text-primary'
        },
        'ql-list-bullet': {
            name: 'Danh sách chấm (Bullet List)',
            desc: 'Tạo danh sách các ý gạch đầu dòng dấu chấm tròn',
            icon: 'fa-solid fa-list-ul text-primary'
        },
        'ql-align': {
            name: 'Căn lề (Text Align)',
            desc: 'Căn lề văn bản: Căn trái, Căn giữa, Căn phải, hoặc Căn đều hai bên',
            icon: 'fa-solid fa-align-left text-secondary'
        },
        'ql-blockquote': {
            name: 'Đoạn trích dẫn (Quote)',
            desc: 'Đóng khung thụt lề làm nổi bật câu trích dẫn hoặc ý kiến',
            icon: 'fa-solid fa-quote-left text-muted'
        },
        'ql-code-block': {
            name: 'Khối mã code (Code Block)',
            desc: 'Hiển thị đoạn code lập trình hoặc thông số cấu hình máy tính',
            icon: 'fa-solid fa-code text-info'
        },
        'ql-link': {
            name: 'Chèn liên kết (Link)',
            desc: 'Gắn đường dẫn website hoặc bài viết khác vào từ ngữ đã chọn',
            hotkey: 'Ctrl + K',
            icon: 'fa-solid fa-link text-primary'
        },
        'ql-image': {
            name: 'Chèn ảnh (Image)',
            desc: 'Chèn hình ảnh minh họa từ link URL hoặc tải tệp từ máy tính',
            icon: 'fa-regular fa-image text-success'
        },
        'ql-clean': {
            name: 'Xóa định dạng (Clean Format - Tx)',
            desc: 'Tẩy sạch toàn bộ màu sắc, in đậm, in nghiêng... đưa chữ về văn bản thường gốc',
            icon: 'fa-solid fa-eraser text-danger'
        }
    };

    function setupToolbarHints() {
        const toolbar = document.querySelector('.ql-toolbar');
        const hintBar = document.getElementById('toolbarHintBar');
        const hintText = document.getElementById('toolbarHintText');
        if (!toolbar || !hintBar || !hintText) return;

        // Đưa thanh hintBar vào ngay sau thanh toolbar
        toolbar.insertAdjacentElement('afterend', hintBar);

        const defaultHintHtml = '<i class="fa-regular fa-lightbulb text-warning me-1"></i>Rê chuột vào biểu tượng bất kỳ trên thanh công cụ để xem tên & hướng dẫn';

        // Gắn sự kiện và Tooltip cho từng nút
        const items = toolbar.querySelectorAll('button, .ql-picker');
        items.forEach(el => {
            let key = '';
            if (el.classList.contains('ql-header')) key = 'ql-header';
            else if (el.classList.contains('ql-bold')) key = 'ql-bold';
            else if (el.classList.contains('ql-italic')) key = 'ql-italic';
            else if (el.classList.contains('ql-underline')) key = 'ql-underline';
            else if (el.classList.contains('ql-strike')) key = 'ql-strike';
            else if (el.classList.contains('ql-color')) key = 'ql-color';
            else if (el.classList.contains('ql-background')) key = 'ql-background';
            else if (el.classList.contains('ql-list') && el.value === 'ordered') key = 'ql-list-ordered';
            else if (el.classList.contains('ql-list') && el.value === 'bullet') key = 'ql-list-bullet';
            else if (el.classList.contains('ql-align')) key = 'ql-align';
            else if (el.classList.contains('ql-blockquote')) key = 'ql-blockquote';
            else if (el.classList.contains('ql-code-block')) key = 'ql-code-block';
            else if (el.classList.contains('ql-link')) key = 'ql-link';
            else if (el.classList.contains('ql-image')) key = 'ql-image';
            else if (el.classList.contains('ql-clean')) key = 'ql-clean';

            const info = toolbarDescriptions[key];
            if (info) {
                // Thuộc tính title tooltip trình duyệt
                el.setAttribute('title', info.name + (info.hotkey ? ' (' + info.hotkey + ')' : ''));

                // Hiển thị dynamic trên hintBar khi rê chuột
                el.addEventListener('mouseenter', () => {
                    let html = '<i class="' + info.icon + ' me-2"></i><strong>' + info.name + '</strong>: ' + info.desc;
                    if (info.hotkey) {
                        html += ' <span class="badge bg-white text-dark border ms-1 py-0 px-1" style="font-size: 10px;">' + info.hotkey + '</span>';
                    }
                    hintText.innerHTML = html;
                    hintBar.classList.add('is-active');
                });
            }
        });

        toolbar.addEventListener('mouseleave', () => {
            hintText.innerHTML = defaultHintHtml;
            hintBar.classList.remove('is-active');
        });
    }

    // Khởi chạy gắn tooltip và thanh chú giải
    setupToolbarHints();

    // Nạp nội dung cũ khi Sửa bài viết
    const contentHidden = document.getElementById('contentInput');
    if (contentHidden && contentHidden.value.trim().length > 0) {
        quill.clipboard.dangerouslyPasteHTML(contentHidden.value);
        document.getElementById('htmlSourceEditor').value = contentHidden.value;
    }

    // Cập nhật thống kê từ & ký tự thời gian thực
    function updateContentStats() {
        let text = '';
        if (isCodeView) {
            text = document.getElementById('htmlSourceEditor').value;
        } else {
            text = quill.getText().trim();
        }
        const charCount = text.length;
        const wordCount = text ? text.split(/\s+/).filter(Boolean).length : 0;
        const counter = document.getElementById('contentStatsCounter');
        if (counter) {
            counter.innerHTML = '<i class="fa-solid fa-pen-nib me-1"></i>' + wordCount + ' từ &bull; ' + charCount + ' ký tự';
        }
    }
    quill.on('text-change', updateContentStats);
    document.getElementById('htmlSourceEditor').addEventListener('input', updateContentStats);
    updateContentStats();

    // Viền sáng khi đang soạn thảo
    const editorBox = document.getElementById('editorContainer');
    quill.on('selection-change', function(range) {
        if (range) {
            editorBox.classList.add('is-focused');
        } else {
            editorBox.classList.remove('is-focused');
        }
    });

    // 4. Chuyển đổi giữa chế độ Trực quan (WYSIWYG) và Mã nguồn HTML
    function toggleCodeView() {
        const qEditor = document.getElementById('quillEditor');
        const qToolbar = document.querySelector('.ql-toolbar');
        const htmlEditor = document.getElementById('htmlSourceEditor');
        const toggleLabel = document.getElementById('toggleCodeLabel');
        const modeBadge = document.getElementById('editorModeBadge');
        const toggleBtn = document.getElementById('toggleCodeBtn');

        if (!isCodeView) {
            // Chuyển sang xem mã HTML
            htmlEditor.value = quill.root.innerHTML;
            qEditor.style.display = 'none';
            if (qToolbar) qToolbar.style.display = 'none';
            htmlEditor.style.display = 'block';
            toggleLabel.innerText = 'Soạn trực quan';
            modeBadge.innerText = 'Mã HTML';
            modeBadge.className = 'badge bg-secondary-subtle text-secondary border border-secondary-subtle ms-1';
            toggleBtn.classList.remove('btn-outline-secondary');
            toggleBtn.classList.add('btn-secondary');
            isCodeView = true;
            htmlEditor.focus();
        } else {
            // Chuyển lại soạn thảo trực quan
            quill.root.innerHTML = htmlEditor.value;
            htmlEditor.style.display = 'none';
            qEditor.style.display = 'block';
            if (qToolbar) qToolbar.style.display = 'block';
            toggleLabel.innerText = 'Mã HTML';
            modeBadge.innerText = 'Soạn trực quan';
            modeBadge.className = 'badge bg-danger-subtle text-danger border border-danger-subtle ms-1';
            toggleBtn.classList.remove('btn-secondary');
            toggleBtn.classList.add('btn-outline-secondary');
            isCodeView = false;
            quill.focus();
        }
        updateContentStats();
    }

    // 5. Chế độ Toàn màn hình
    function toggleFullscreenEditor() {
        const wrapper = document.getElementById('editorWrapper');
        const icon = document.getElementById('fullscreenIcon');
        const btn = document.getElementById('toggleFullscreenBtn');
        isFullscreen = !isFullscreen;

        if (isFullscreen) {
            wrapper.classList.add('fullscreen-mode');
            icon.className = 'fa-solid fa-compress';
            btn.classList.add('btn-danger');
            btn.classList.remove('btn-outline-secondary');
        } else {
            wrapper.classList.remove('fullscreen-mode');
            icon.className = 'fa-solid fa-expand';
            btn.classList.remove('btn-danger');
            btn.classList.add('btn-outline-secondary');
        }
    }

    // 6. Chèn các khối mẫu nhanh cho người mới
    function insertCustomBlock(type) {
        if (isCodeView) {
            const textarea = document.getElementById('htmlSourceEditor');
            let snippet = '';
            if (type === 'heading') snippet = '<h3>Tiêu đề mục mới</h3>\n<p>Nội dung đoạn văn...</p>\n';
            else if (type === 'callout') snippet = '<div class="news-callout"><strong>💡 Lưu ý:</strong> Nhập nội dung lưu ý hoặc mẹo tại đây.</div>\n<p><br></p>\n';
            else if (type === 'quote') snippet = '<blockquote>"Trích dẫn câu nói hoặc nhận xét nổi bật..."</blockquote>\n<p><br></p>\n';
            else if (type === 'list') snippet = '<ul>\n  <li>Đặc điểm nổi bật 1</li>\n  <li>Đặc điểm nổi bật 2</li>\n  <li>Đặc điểm nổi bật 3</li>\n</ul>\n';

            const start = textarea.selectionStart;
            const end = textarea.selectionEnd;
            textarea.value = textarea.value.substring(0, start) + snippet + textarea.value.substring(end);
            textarea.focus();
            updateContentStats();
            return;
        }

        const range = quill.getSelection(true) || { index: quill.getLength() };
        const idx = range.index;

        if (type === 'heading') {
            quill.insertText(idx, 'Tiêu đề mục mới\n', { 'header': 3, 'bold': true });
            quill.setSelection(idx + 16);
        } else if (type === 'callout') {
            quill.clipboard.dangerouslyPasteHTML(idx, '<div class="news-callout"><strong>💡 Lưu ý:</strong> Nhập nội dung lưu ý hoặc mẹo dành cho bạn đọc tại đây.</div><p><br></p>');
        } else if (type === 'quote') {
            quill.clipboard.dangerouslyPasteHTML(idx, '<blockquote>"Trích dẫn câu nói hoặc nhận xét nổi bật..."</blockquote><p><br></p>');
        } else if (type === 'list') {
            quill.clipboard.dangerouslyPasteHTML(idx, '<ul><li>Đặc điểm nổi bật 1</li><li>Đặc điểm nổi bật 2</li><li>Đặc điểm nổi bật 3</li></ul><p><br></p>');
        }
        updateContentStats();
    }

    // 7. Xóa sạch nội dung soạn thảo
    function clearEditorContent() {
        if (confirm('Bạn có chắc chắn muốn xóa toàn bộ nội dung trong khung soạn thảo không?')) {
            quill.setText('');
            document.getElementById('htmlSourceEditor').value = '';
            updateContentStats();
        }
    }

    // 8. Quản lý Modal Chèn Ảnh
    let imageModalInstance = null;
    function openInsertImageModal() {
        document.getElementById('modalImgUrlInput').value = '';
        document.getElementById('modalImgFileInput').value = '';
        document.getElementById('modalImgAltInput').value = '';
        document.getElementById('modalImgPreviewContainer').style.display = 'none';
        document.getElementById('modalImgPreviewEl').src = '';
        
        if (!imageModalInstance) {
            imageModalInstance = new bootstrap.Modal(document.getElementById('insertImageModal'));
        }
        imageModalInstance.show();
    }

    // Xem trước ảnh trong Modal khi nhập URL
    document.getElementById('modalImgUrlInput').addEventListener('input', function() {
        const url = this.value.trim();
        const previewContainer = document.getElementById('modalImgPreviewContainer');
        const previewEl = document.getElementById('modalImgPreviewEl');
        if (url) {
            previewEl.src = url;
            previewContainer.style.display = 'block';
        } else {
            previewContainer.style.display = 'none';
        }
    });

    // Xem trước ảnh khi chọn file từ máy tính
    document.getElementById('modalImgFileInput').addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(evt) {
                document.getElementById('modalImgPreviewEl').src = evt.target.result;
                document.getElementById('modalImgPreviewContainer').style.display = 'block';
                document.getElementById('modalImgUrlInput').value = ''; // ưu tiên file
            };
            reader.readAsDataURL(file);
        }
    });

    // Xác nhận chèn ảnh vào Editor
    function confirmInsertImage() {
        const urlInput = document.getElementById('modalImgUrlInput').value.trim();
        const fileInput = document.getElementById('modalImgFileInput');
        const altText = document.getElementById('modalImgAltInput').value.trim() || 'Hình ảnh bài viết';
        const previewEl = document.getElementById('modalImgPreviewEl');

        let finalSrc = urlInput;
        if (fileInput.files && fileInput.files[0]) {
            finalSrc = previewEl.src; // base64 DataURL
        }

        if (!finalSrc) {
            alert('Vui lòng nhập đường dẫn URL hoặc chọn file ảnh từ máy tính!');
            return;
        }

        if (isCodeView) {
            const snippet = '<img src="' + finalSrc + '" alt="' + altText + '" class="img-fluid rounded my-3 d-block mx-auto">\n';
            const textarea = document.getElementById('htmlSourceEditor');
            const start = textarea.selectionStart;
            const end = textarea.selectionEnd;
            textarea.value = textarea.value.substring(0, start) + snippet + textarea.value.substring(end);
        } else {
            const range = quill.getSelection(true) || { index: quill.getLength() };
            quill.insertEmbed(range.index, 'image', finalSrc);
            quill.setSelection(range.index + 1);
        }

        updateContentStats();
        if (imageModalInstance) imageModalInstance.hide();
    }

    // 9. Đồng bộ nội dung trước khi Submit Form lên Servlet
    document.getElementById('newsForm').addEventListener('submit', function() {
        const hiddenInput = document.getElementById('contentInput');
        let finalHtml = '';
        if (isCodeView) {
            finalHtml = document.getElementById('htmlSourceEditor').value.trim();
        } else {
            // Nếu editor trống chỉ có thẻ rỗng <p><br></p> thì gán rỗng
            if (quill.getText().trim().length === 0 && !quill.root.querySelector('img')) {
                finalHtml = '';
            } else {
                finalHtml = quill.root.innerHTML.trim();
            }
        }
        hiddenInput.value = finalHtml;
    });

    // 10. Xem trước bài viết trong Modal
    function previewContentModal() {
        const title = document.querySelector('input[name="title"]').value || '(Chưa có tiêu đề)';
        const author = document.querySelector('input[name="author"]').value || 'Độ PC 67';
        const summary = document.getElementById('summaryInput').value;

        let contentHtml = '';
        if (isCodeView) {
            contentHtml = document.getElementById('htmlSourceEditor').value.trim();
        } else {
            contentHtml = (quill.getText().trim().length === 0 && !quill.root.querySelector('img')) ? '' : quill.root.innerHTML.trim();
        }

        document.getElementById('modalTitlePreview').innerText = title;
        document.getElementById('modalMetaPreview').innerHTML = '<i class="fa-regular fa-user me-1"></i>' + author + ' &bull; <i class="fa-regular fa-clock ms-2 me-1"></i>Hôm nay';
        document.getElementById('modalSummaryPreview').innerText = summary;
        document.getElementById('modalBodyPreview').innerHTML = contentHtml || '<span class="text-muted fst-italic">Chưa có nội dung bài viết. Hãy nhập nội dung vào khung soạn thảo.</span>';

        const modal = new bootstrap.Modal(document.getElementById('contentPreviewModal'));
        modal.show();
    }
</script>
</body>
</html>
