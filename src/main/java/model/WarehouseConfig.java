package model;

/**
 * ============================================================================
 * [PHÂN HỆ 1: ĐẶT HÀNG, THANH TOÁN VNPAY & QUẢN TRỊ KHO]
 * Phụ trách: Bạn (Gia Phú)
 * Chức năng: Model thông tin cấu hình kho hàng tích hợp GHN.
 * ============================================================================
 */

import java.sql.Timestamp;

public class WarehouseConfig {
    private int id;
    private int provinceId;
    private String provinceName;
    private int districtId;
    private String districtName;
    private String wardCode;
    private String wardName;
    private String detailAddress;
    private Timestamp updatedAt;

    public WarehouseConfig() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProvinceId() { return provinceId; }
    public void setProvinceId(int provinceId) { this.provinceId = provinceId; }

    public String getProvinceName() { return provinceName; }
    public void setProvinceName(String provinceName) { this.provinceName = provinceName; }

    public int getDistrictId() { return districtId; }
    public void setDistrictId(int districtId) { this.districtId = districtId; }

    public String getDistrictName() { return districtName; }
    public void setDistrictName(String districtName) { this.districtName = districtName; }

    public String getWardCode() { return wardCode; }
    public void setWardCode(String wardCode) { this.wardCode = wardCode; }

    public String getWardName() { return wardName; }
    public void setWardName(String wardName) { this.wardName = wardName; }

    public String getDetailAddress() { return detailAddress; }
    public void setDetailAddress(String detailAddress) { this.detailAddress = detailAddress; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getFullAddress() {
        StringBuilder sb = new StringBuilder();
        if (detailAddress != null && !detailAddress.trim().isEmpty()) {
            sb.append(detailAddress.trim());
        }
        if (wardName != null && !wardName.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(wardName.trim());
        }
        if (districtName != null && !districtName.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(districtName.trim());
        }
        if (provinceName != null && !provinceName.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(provinceName.trim());
        }
        return sb.toString();
    }
}
