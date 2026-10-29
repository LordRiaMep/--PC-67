<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cấu hình Kho hàng - Admin Độ PC 67</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
</head>
<body>

<jsp:include page="admin_sidebar.jsp"><jsp:param name="active" value="warehouse"/></jsp:include>

<main class="main-content">
    <header class="topbar">
        <div>
            <h3 class="m-0 text-dark fw-bold"><i class="fa-solid fa-warehouse text-danger me-2"></i>Cấu hình Kho hàng</h3>
            <span class="text-secondary small">Thiết lập địa chỉ xuất kho làm căn cứ tính phí vận chuyển GHN cho toàn bộ đơn hàng</span>
        </div>
        <div class="d-flex align-items-center">
            <span class="me-3">Admin: <strong class="text-danger">${sessionScope.USER_LOGIN.fullName}</strong></span>
            <a href="${ctx}/logout" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-power-off"></i> Thoát</a>
        </div>
    </header>

    <c:if test="${not empty sessionScope.successMsg}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-circle-check fs-5 me-2"></i>
            <div>${sessionScope.successMsg}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMsg" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.errorMsg}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
            <i class="fa-solid fa-circle-exclamation fs-5 me-2"></i>
            <div>${sessionScope.errorMsg}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMsg" scope="session"/>
    </c:if>

    <div class="row g-4">

        <div class="col-lg-7">

            <div class="panel mb-4">
                <div class="panel-head">
                    <h5><i class="fa-solid fa-location-dot me-2"></i>Kho hàng đang áp dụng</h5>
                    <span class="badge bg-success">Đang hoạt động</span>
                </div>
                <div class="panel-body">
                    <div class="p-3 bg-light rounded border mb-3">
                        <div class="fw-bold text-dark fs-5 mb-1">
                            <i class="fa-solid fa-store text-danger me-2"></i>${warehouse.detailAddress}
                        </div>
                        <div class="text-secondary">
                            ${warehouse.wardName}, ${warehouse.districtName}, ${warehouse.provinceName}
                        </div>
                        <div class="mt-2 text-muted small border-top pt-2 d-flex justify-content-between">
                            <span>Mã Quận/Huyện GHN: <strong class="text-dark">${warehouse.districtId}</strong> | Mã Phường/Xã: <strong class="text-dark">${warehouse.wardCode}</strong></span>
                            <span>Cập nhật lúc: <strong class="text-dark"><fmt:formatDate value="${warehouse.updatedAt}" pattern="HH:mm dd/MM/yyyy"/></strong></span>
                        </div>
                    </div>
                    <div class="small text-muted">
                        <i class="fa-solid fa-circle-info text-primary me-1"></i>
                        Hệ thống sẽ dùng tọa độ và địa chỉ này gửi sang GHN làm điểm gửi (<strong>From District &amp; Ward</strong>) để tính cước phí tới địa chỉ của khách hàng khi đặt hàng.
                    </div>
                </div>
            </div>

            <div class="panel">
                <div class="panel-head">
                    <h5><i class="fa-solid fa-pen-to-square me-2"></i>Thay đổi địa chỉ kho hàng</h5>
                </div>
                <div class="panel-body">
                    <form action="${ctx}/admin/warehouse" method="post" id="warehouseForm">
                        <div class="mb-3">
                            <label class="field-label">Tỉnh / Thành phố kho hàng <span class="text-danger">*</span></label>
                            <select id="whProvinceSelect" class="form-select field shadow-none" required>
                                <option value="">-- Đang tải danh sách Tỉnh / Thành phố --</option>
                            </select>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="field-label">Quận / Huyện kho hàng <span class="text-danger">*</span></label>
                                <select id="whDistrictSelect" class="form-select field shadow-none" disabled required>
                                    <option value="">-- Chọn Quận / Huyện --</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="field-label">Phường / Xã kho hàng <span class="text-danger">*</span></label>
                                <select id="whWardSelect" class="form-select field shadow-none" disabled required>
                                    <option value="">-- Chọn Phường / Xã --</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="field-label">Số nhà, tên đường cụ thể của kho <span class="text-danger">*</span></label>
                            <input type="text" name="detailAddress" id="whDetailAddress" class="form-control field shadow-none"
                                   value="${warehouse.detailAddress}" placeholder="Ví dụ: Số 15/2/437 Đà Nẵng" required>
                        </div>

                        <input type="hidden" name="provinceId" id="whProvinceId" value="${warehouse.provinceId}">
                        <input type="hidden" name="provinceName" id="whProvinceName" value="${warehouse.provinceName}">
                        <input type="hidden" name="districtId" id="whDistrictId" value="${warehouse.districtId}">
                        <input type="hidden" name="districtName" id="whDistrictName" value="${warehouse.districtName}">
                        <input type="hidden" name="wardCode" id="whWardCode" value="${warehouse.wardCode}">
                        <input type="hidden" name="wardName" id="whWardName" value="${warehouse.wardName}">

                        <button type="submit" class="btn btn-neon px-4 py-2 fw-bold">
                            <i class="fa-solid fa-floppy-disk me-1"></i> Lưu cấu hình kho hàng
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-5">

            <div class="panel mb-4">
                <div class="panel-head">
                    <h5><i class="fa-solid fa-calculator me-2"></i>Thử nghiệm tính cước phí</h5>
                </div>
                <div class="panel-body">
                    <p class="small text-secondary mb-3">
                        Chọn một địa chỉ khách hàng nhận mẫu để kiểm tra cước ship GHN thực tế được tính từ kho hiện tại:
                    </p>

                    <div class="mb-3">
                        <label class="field-label">Tỉnh / Thành khách nhận</label>
                        <select id="testProvinceSelect" class="form-select field shadow-none">
                            <option value="">-- Chọn Tỉnh / Thành --</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="field-label">Quận / Huyện khách nhận</label>
                        <select id="testDistrictSelect" class="form-select field shadow-none" disabled>
                            <option value="">-- Chọn Quận / Huyện --</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="field-label">Phường / Xã khách nhận</label>
                        <select id="testWardSelect" class="form-select field shadow-none" disabled>
                            <option value="">-- Chọn Phường / Xã --</option>
                        </select>
                    </div>

                    <div class="p-3 bg-light rounded border text-center">
                        <div class="text-secondary small mb-1">Cước vận chuyển GHN dự tính:</div>
                        <div id="testFeeResult" class="fs-4 fw-bold text-danger">Chưa chọn địa chỉ</div>
                    </div>
                </div>
            </div>

            <div class="panel">
                <div class="panel-head">
                    <h5><i class="fa-solid fa-truck-fast me-2"></i>Trạng thái kết nối GHN</h5>
                </div>
                <div class="panel-body">
                    <div class="info-row"><span class="k">Môi trường:</span><span class="badge bg-primary">Production</span></div>
                    <div class="info-row"><span class="k">Shop ID:</span><span class="text-dark fw-bold">6715571</span></div>
                    <div class="info-row"><span class="k">Token:</span><span class="text-muted">8bc2f3c9-***-1253</span></div>
                    <div class="info-row"><span class="k">Cơ chế:</span><span class="text-success fw-semibold"><i class="fa-solid fa-circle-check me-1"></i>Tính cước động theo API</span></div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js">

</script>
<script>
const ctx = '${ctx}';
    const currentProvId = ${warehouse.provinceId};
    const currentDistId = ${warehouse.districtId};
    const currentWardCode = '${warehouse.wardCode}';

    document.addEventListener('DOMContentLoaded', function () {
        loadWarehouseProvinces();
        loadTestProvinces();
    });

    function loadWarehouseProvinces() {
        const provSelect = document.getElementById('whProvinceSelect');
        fetch(ctx + '/shipping-api?action=provinces')
            .then(res => res.json())
            .then(json => {
                if (json.data && json.data.length > 0) {
                    const provinces = json.data.sort((a, b) => a.ProvinceName.localeCompare(b.ProvinceName, 'vi'));
                    let html = '<option value="">-- Chọn Tỉnh / Thành phố --</option>';
                    provinces.forEach(p => {
                        const selected = (p.ProvinceID == currentProvId) ? ' selected' : '';
                        html += '<option value="' + p.ProvinceID + '" data-name="' + escapeHtml(p.ProvinceName) + '"' + selected + '>' + p.ProvinceName + '</option>';
                    });
                    provSelect.innerHTML = html;

                    if (currentProvId) {
                        loadWarehouseDistricts(currentProvId, currentDistId);
                    }
                }
            })
            .catch(err => console.error(err));
    }

    document.getElementById('whProvinceSelect').addEventListener('change', function () {
        const pId = this.value;
        const opt = this.options[this.selectedIndex];
        document.getElementById('whProvinceId').value = pId;
        document.getElementById('whProvinceName').value = opt ? opt.getAttribute('data-name') : '';
        loadWarehouseDistricts(pId, null);
    });

    function loadWarehouseDistricts(provId, preselectDistId) {
        const distSelect = document.getElementById('whDistrictSelect');
        const wardSelect = document.getElementById('whWardSelect');
        distSelect.innerHTML = '<option value="">-- Đang tải Quận / Huyện --</option>';
        distSelect.disabled = true;
        wardSelect.innerHTML = '<option value="">-- Chọn Phường / Xã --</option>';
        wardSelect.disabled = true;

        if (!provId) return;

        fetch(ctx + '/shipping-api?action=districts&provinceId=' + provId)
            .then(res => res.json())
            .then(json => {
                if (json.data && json.data.length > 0) {
                    const districts = json.data.sort((a, b) => a.DistrictName.localeCompare(b.DistrictName, 'vi'));
                    let html = '<option value="">-- Chọn Quận / Huyện --</option>';
                    districts.forEach(d => {
                        const selected = (preselectDistId && d.DistrictID == preselectDistId) ? ' selected' : '';
                        html += '<option value="' + d.DistrictID + '" data-name="' + escapeHtml(d.DistrictName) + '"' + selected + '>' + d.DistrictName + '</option>';
                    });
                    distSelect.innerHTML = html;
                    distSelect.disabled = false;

                    if (preselectDistId) {
                        loadWarehouseWards(preselectDistId, currentWardCode);
                    }
                }
            })
            .catch(err => console.error(err));
    }

    document.getElementById('whDistrictSelect').addEventListener('change', function () {
        const dId = this.value;
        const opt = this.options[this.selectedIndex];
        document.getElementById('whDistrictId').value = dId;
        document.getElementById('whDistrictName').value = opt ? opt.getAttribute('data-name') : '';
        loadWarehouseWards(dId, null);
    });

    function loadWarehouseWards(distId, preselectWardCode) {
        const wardSelect = document.getElementById('whWardSelect');
        wardSelect.innerHTML = '<option value="">-- Đang tải Phường / Xã --</option>';
        wardSelect.disabled = true;

        if (!distId) return;

        fetch(ctx + '/shipping-api?action=wards&districtId=' + distId)
            .then(res => res.json())
            .then(json => {
                if (json.data && json.data.length > 0) {
                    const wards = json.data.sort((a, b) => a.WardName.localeCompare(b.WardName, 'vi'));
                    let html = '<option value="">-- Chọn Phường / Xã --</option>';
                    wards.forEach(w => {
                        const selected = (preselectWardCode && w.WardCode == preselectWardCode) ? ' selected' : '';
                        html += '<option value="' + w.WardCode + '" data-name="' + escapeHtml(w.WardName) + '"' + selected + '>' + w.WardName + '</option>';
                    });
                    wardSelect.innerHTML = html;
                    wardSelect.disabled = false;
                }
            })
            .catch(err => console.error(err));
    }

    document.getElementById('whWardSelect').addEventListener('change', function () {
        const wCode = this.value;
        const opt = this.options[this.selectedIndex];
        document.getElementById('whWardCode').value = wCode;
        document.getElementById('whWardName').value = opt ? opt.getAttribute('data-name') : '';
    });

    function loadTestProvinces() {
        const provSelect = document.getElementById('testProvinceSelect');
        fetch(ctx + '/shipping-api?action=provinces')
            .then(res => res.json())
            .then(json => {
                if (json.data && json.data.length > 0) {
                    const provinces = json.data.sort((a, b) => a.ProvinceName.localeCompare(b.ProvinceName, 'vi'));
                    let html = '<option value="">-- Chọn Tỉnh / Thành --</option>';
                    provinces.forEach(p => {
                        html += '<option value="' + p.ProvinceID + '">' + p.ProvinceName + '</option>';
                    });
                    provSelect.innerHTML = html;
                }
            })
            .catch(err => console.error(err));
    }

    document.getElementById('testProvinceSelect').addEventListener('change', function () {
        const pId = this.value;
        const distSelect = document.getElementById('testDistrictSelect');
        const wardSelect = document.getElementById('testWardSelect');
        distSelect.innerHTML = '<option value="">-- Đang tải --</option>';
        distSelect.disabled = true;
        wardSelect.innerHTML = '<option value="">-- Chọn Phường / Xã --</option>';
        wardSelect.disabled = true;
        document.getElementById('testFeeResult').innerText = 'Chưa chọn địa chỉ';

        if (!pId) return;

        fetch(ctx + '/shipping-api?action=districts&provinceId=' + pId)
            .then(res => res.json())
            .then(json => {
                if (json.data && json.data.length > 0) {
                    const districts = json.data.sort((a, b) => a.DistrictName.localeCompare(b.DistrictName, 'vi'));
                    let html = '<option value="">-- Chọn Quận / Huyện --</option>';
                    districts.forEach(d => {
                        html += '<option value="' + d.DistrictID + '">' + d.DistrictName + '</option>';
                    });
                    distSelect.innerHTML = html;
                    distSelect.disabled = false;
                }
            });
    });

    document.getElementById('testDistrictSelect').addEventListener('change', function () {
        const dId = this.value;
        const wardSelect = document.getElementById('testWardSelect');
        wardSelect.innerHTML = '<option value="">-- Đang tải --</option>';
        wardSelect.disabled = true;
        document.getElementById('testFeeResult').innerText = 'Chưa chọn địa chỉ';

        if (!dId) return;

        fetch(ctx + '/shipping-api?action=wards&districtId=' + dId)
            .then(res => res.json())
            .then(json => {
                if (json.data && json.data.length > 0) {
                    const wards = json.data.sort((a, b) => a.WardName.localeCompare(b.WardName, 'vi'));
                    let html = '<option value="">-- Chọn Phường / Xã --</option>';
                    wards.forEach(w => {
                        html += '<option value="' + w.WardCode + '">' + w.WardName + '</option>';
                    });
                    wardSelect.innerHTML = html;
                    wardSelect.disabled = false;
                }
            });
    });

    document.getElementById('testWardSelect').addEventListener('change', function () {
        const wCode = this.value;
        const dId = document.getElementById('testDistrictSelect').value;
        const resultEl = document.getElementById('testFeeResult');

        if (!wCode || !dId) {
            resultEl.innerText = 'Chưa chọn địa chỉ';
            return;
        }

        resultEl.innerHTML = '<span class="spinner-border spinner-border-sm text-danger"></span> Đang tính...';

        fetch(ctx + '/shipping-api?action=fee&districtId=' + dId + '&wardCode=' + encodeURIComponent(wCode))
            .then(res => res.json())
            .then(json => {
                if (json.success && typeof json.fee === 'number') {
                    resultEl.innerText = json.fee.toLocaleString('vi-VN') + ' đ';
                } else {
                    resultEl.innerText = 'Không tính được';
                }
            })
            .catch(() => {
                resultEl.innerText = 'Lỗi kết nối';
            });
    });

    function escapeHtml(text) {
        return text ? text.replace(/"/g, '&quot;').replace(/'/g, '&#39;') : '';
    }
</script>
</body>
</html>
