# 🖥️ HỆ THỐNG THƯƠNG MẠI ĐIỆN TỬ PC GAMING & DỊCH VỤ CÔNG NGHỆ (SD2001)

Dự án tốt nghiệp / Đồ án chuyên ngành xây dựng website thương mại điện tử chuyên cung cấp máy tính chơi game, cấu hình PC Gaming cao cấp, linh kiện phần cứng, tích hợp **Trợ lý ảo AI Google Gemini**, **WebSocket Real-time Event Hub**, **Cổng thanh toán VNPay** và **Vận chuyển Giao Hàng Nhanh (GHN)**.

---

## 🛠️ Công Nghệ Sử Dụng (Tech Stack)

* **Backend:** Java Servlet (Jakarta EE 6), Multi-threaded Safe JDBC, Gson 2.10.1.
* **Database:** Microsoft SQL Server (`SD2001_DATN_DEMO3`).
* **Real-time:** Jakarta WebSocket API (`RealtimeWebSocket`, `RealtimeHub`) + Fallback Polling (`/api/realtime-sync`).
* **AI Integration:** Google Gemini API (Gemini Flash / Pro) + Tri thức cấu hình PC chuyên sâu.
* **Third-Party Integrations:**
  * **Cổng thanh toán:** VNPay (HMAC-SHA512 Checksum, IPN & Return URL).
  * **Vận chuyển:** GHN (Giao Hàng Nhanh API v2).
  * **Bảo mật & Mail:** JavaMail SMTP (Xác thực tài khoản qua OTP / Token).
* **Frontend:** JSP, JSTL, HTML5, CSS3, JavaScript (AJAX, Audio Notification, Modals).

---

## 👥 BẢN ĐỒ PHÂN CHIA CHỨC NĂNG & THÀNH VIÊN PHỤ TRÁCH

Hệ thống được thiết kế theo mô hình **Chuỗi giá trị liên thông (Interconnected Value Chain)**, trong đó 5 phân hệ có sự phối hợp, trao đổi dữ liệu và kích hoạt sự kiện qua lại lẫn nhau:

```
[BƯỚC 1: PHONG]     Đăng ký / Đăng nhập / Xác thực OTP -> Cung cấp User Session & Profile
       ↓
[BƯỚC 2: NHÂN HIẾU] Chatbot Gemini tư vấn cấu hình -> Chọn tùy chọn Nâng cấp RAM/VGA/Màu sắc
       ↓
[BƯỚC 3: BẢO]       Bỏ giỏ hàng -> Áp mã Voucher giảm giá -> Tự động tính cước ship GHN
       ↓
[BƯỚC 4: BẠN (PHÚ)] Đặt hàng -> Cổng VNPay quét mã QR -> Xác nhận thanh toán & Trừ/Hoàn tồn kho
       ↓
[BƯỚC 5: QUANG]     WebSocket Hub nổ chuông TingTing -> Tự động nhảy số Doanh thu trên Dashboard Realtime
```

---

### 1. 💳 Phân hệ 1: Đặt hàng, Cổng thanh toán VNPay & Quản trị Đơn hàng - Tồn kho
* **Phụ trách:** **Bạn (Gia Phú)** *(Độ khó: 9.5/10 - Khó nhất)*
* **Nhiệm vụ chính:** Quản trị vòng đời đơn hàng, tích hợp cổng VNPay, xử lý thanh toán QR và cơ chế tự động trừ/hoàn tồn kho khi đơn hủy hoặc đổi trả.
* **Danh sách file code phụ trách:**
  * **Controllers:**
    * `src/main/java/Controller/Cilent/PlaceOrderServlet.java` — Xử lý chốt đơn hàng từ giỏ.
    * `src/main/java/Controller/Cilent/OrderDetailServlet.java` — Xem chi tiết đơn hàng khách.
    * `src/main/java/Controller/Cilent/MyOrderServlet.java` — Lịch sử đơn hàng cá nhân.
    * `src/main/java/Controller/Cilent/ClientOrderActionServlet.java` — Khách hủy đơn / yêu cầu đổi trả.
    * `src/main/java/Controller/Cilent/VnpayPayServlet.java` — Khởi tạo giao dịch thanh toán VNPay.
    * `src/main/java/Controller/Cilent/VnpayReturnServlet.java` — Nhận phản hồi thanh toán VNPay.
    * `src/main/java/Controller/Admin/AdminOrderServlet.java` — Quản trị trạng thái đơn Admin.
    * `src/main/java/Controller/Admin/ConfirmPaymentServlet.java` — Xác nhận thanh toán chuyển khoản/QR.
    * `src/main/java/Controller/Admin/AdminWarehouseServlet.java` — Cấu hình kho gửi hàng GHN.
  * **DAOs & Models:**
    * `src/main/java/dao/OrderDao.java`
    * `src/main/java/dao/WarehouseDao.java`
    * `src/main/java/model/Order.java`
    * `src/main/java/model/OrderDetail.java`
    * `src/main/java/model/WarehouseConfig.java`
  * **Utils & Views:**
    * `src/main/java/util/VnpayConfig.java`, `src/main/java/util/VnpayUtil.java`
    * `src/main/webapp/view/my_orders.jsp`, `src/main/webapp/view/order_detail.jsp`
    * `src/main/webapp/view/admin_orders.jsp`, `src/main/webapp/view/admin_warehouse.jsp`

---

### 2. ⚡ Phân hệ 2: Realtime WebSocket Hub, Dashboard Doanh thu, Tin tức & CSKH
* **Phụ trách:** **Quang** *(Độ khó: 8.5/10 - Khó nhì)*
* **Nhiệm vụ chính:** Xây dựng trục xương sống WebSocket thời gian thực, tổng hợp số liệu Dashboard tài chính/bán chạy và cổng tin tức/khiếu nại.
* **Danh sách file code phụ trách:**
  * **Controllers:**
    * `src/main/java/Controller/RealtimeSyncServlet.java` — Fallback Long-polling khi rớt WS.
    * `src/main/java/Controller/Admin/AdminDashboardServlet.java` — Dashboard thống kê doanh thu.
    * `src/main/java/Controller/Admin/AdminNewsServlet.java` — Quản trị tin tức công nghệ.
    * `src/main/java/Controller/Admin/AdminContactServlet.java` — Xử lý khiếu nại khách hàng.
    * `src/main/java/Controller/Cilent/NewsServlet.java` & `NewsDetailServlet.java` — Trang tin tức.
    * `src/main/java/Controller/Cilent/ContactServlet.java` — Gửi liên hệ/góp ý dịch vụ.
  * **DAOs, Hub & Models:**
    * `src/main/java/dao/DashboardDAO.java`
    * `src/main/java/dao/NewsDao.java`
    * `src/main/java/dao/ContactDao.java`
    * `src/main/java/util/realtime/RealtimeHub.java`
    * `src/main/java/util/realtime/RealtimeWebSocket.java`
    * `src/main/java/util/realtime/RealtimeEvent.java`
    * `src/main/java/model/News.java`, `src/main/java/model/Contact.java`
  * **Views & Scripts:**
    * `src/main/webapp/assets/js/realtime-sync.js`
    * `src/main/webapp/view/dashboard.jsp`, `src/main/webapp/view/admin_news.jsp`, `src/main/webapp/view/admin_contacts.jsp`
    * `src/main/webapp/view/news.jsp`, `src/main/webapp/view/news_detail.jsp`, `src/main/webapp/view/contact.jsp`

---

### 3. 🖥️ Phân hệ 3: Sản phẩm, Cấu hình Nâng cấp PC & Gemini AI Chatbot
* **Phụ trách:** **Nhân Hiếu** *(Độ khó: 8.0/10)*
* **Nhiệm vụ chính:** Quản trị danh mục & sản phẩm, động cơ tùy chọn nâng cấp linh kiện (RAM, VGA, Màu sắc) và tích hợp Google Gemini AI tư vấn PC.
* **Danh sách file code phụ trách:**
  * **Controllers:**
    * `src/main/java/Controller/Cilent/DetailServlet.java` — Chi tiết PC & Tùy biến linh kiện.
    * `src/main/java/Controller/Cilent/SearchServlet.java` — Tìm kiếm & bộ lọc giá/danh mục.
    * `src/main/java/Controller/Cilent/SearchSuggestServlet.java` — Gợi ý tìm kiếm tức thì AJAX.
    * `src/main/java/Controller/Cilent/ChatbotServlet.java` — API xử lý đối thoại AI Chatbot.
    * `src/main/java/Controller/Admin/AdminProductServlet.java` — Admin CRUD máy & linh kiện nâng cấp.
    * `src/main/java/Controller/Admin/AdminCategoryServlet.java` — Admin quản lý danh mục.
  * **DAOs, Services & Models:**
    * `src/main/java/dao/ProductDao.java`, `src/main/java/dao/CategoryDao.java`, `src/main/java/dao/UpgradeDao.java`
    * `src/main/java/service/GeminiService.java`
    * `src/main/java/service/ChatbotKnowledgeService.java`
    * `src/main/java/model/Product.java`, `src/main/java/model/Category.java`, `src/main/java/model/UpgradeOption.java`
    * `src/main/java/util/ChatbotConfig.java`, `src/main/java/filter/CatagoryFilter.java`
  * **Views:**
    * `src/main/webapp/view/detail.jsp`, `src/main/webapp/view/search.jsp`
    * `src/main/webapp/view/chatbot_widget.jsp`
    * `src/main/webapp/view/admin_product.jsp`, `src/main/webapp/view/admin_categories.jsp`

---

### 4. 🛒 Phân hệ 4: Giỏ hàng, Động cơ Khuyến mãi Voucher & Vận chuyển GHN
* **Phụ trách:** **Bảo** *(Độ khó: 7.0/10)*
* **Nhiệm vụ chính:** Quản lý giỏ hàng kèm tùy chọn linh kiện nâng cấp, thuật toán chiết khấu Voucher và tích hợp API Giao Hàng Nhanh.
* **Danh sách file code phụ trách:**
  * **Controllers:**
    * `src/main/java/Controller/Cilent/CartServlet.java` — Xem giỏ hàng.
    * `src/main/java/Controller/Cilent/AddToCartServlet.java` — Thêm sản phẩm kèm linh kiện nâng cấp.
    * `src/main/java/Controller/Cilent/UpdateCartServlet.java` & `RemoveCartServlet.java` — Cập nhật/xóa giỏ.
    * `src/main/java/Controller/Cilent/CheckoutServlet.java` — Màn hình thanh toán & áp voucher.
    * `src/main/java/Controller/Cilent/ShippingApiServlet.java` — AJAX tính cước ship GHN.
    * `src/main/java/Controller/Admin/AdminVoucherServlet.java` — Admin CRUD mã giảm giá.
  * **DAOs, Services & Models:**
    * `src/main/java/dao/CartDao.java`, `src/main/java/dao/VoucherDao.java`
    * `src/main/java/service/GhnService.java`, `src/main/java/util/GhnConfig.java`
    * `src/main/java/model/Cart.java`, `src/main/java/model/CartItem.java`, `src/main/java/model/Voucher.java`
  * **Views:**
    * `src/main/webapp/view/cart.jsp`, `src/main/webapp/view/checkout.jsp`, `src/main/webapp/view/admin_vouchers.jsp`

---

### 5. 👤 Phân hệ 5: Quản trị Tài khoản, Xác thực Email OTP & Bảo mật Phân quyền
* **Phụ trách:** **Phong** *(Độ khó: 6.0/10)*
* **Nhiệm vụ chính:** Quản lý chu trình xác thực tài khoản qua Email OTP, chống Brute-force và bộ lọc phân quyền hệ thống.
* **Danh sách file code phụ trách:**
  * **Controllers:**
    * `src/main/java/Controller/Auth/LoginServlet.java` & `LogoutServlet.java` — Đăng nhập / Đăng xuất.
    * `src/main/java/Controller/Auth/RegisterServlet.java` & `RegisterSuccessServlet.java` — Đăng ký tài khoản.
    * `src/main/java/Controller/Auth/VerifyAccountServlet.java` — Xác thực OTP tài khoản mới.
    * `src/main/java/Controller/Auth/ForgotPasswordServlet.java` & `ResetPasswordServlet.java` — Quên/Đặt lại pass.
    * `src/main/java/Controller/Auth/ResendVerificationServlet.java`, `CheckAuthServlet.java`
    * `src/main/java/Controller/Cilent/ProfileServlet.java` — Hồ sơ cá nhân.
    * `src/main/java/Controller/Cilent/ChangePasswordServlet.java` & `SendPasswordOtpServlet.java`
    * `src/main/java/Controller/Admin/AdminUserServlet.java` — Admin phân quyền & khóa/mở nick.
  * **DAOs, Services & Models:**
    * `src/main/java/dao/UserDao.java`, `src/main/java/dao/UserTokenDao.java`
    * `src/main/java/service/LoginSecurityService.java`, `src/main/java/util/EmailService.java`
    * `src/main/java/model/User.java`, `src/main/java/model/UserToken.java`
    * `src/main/java/filter/AdminFilter.java`, `src/main/java/filter/UserStatusFilter.java`
  * **Views:**
    * `src/main/webapp/view/login.jsp`, `src/main/webapp/view/register.jsp`, `src/main/webapp/view/register_success.jsp`
    * `src/main/webapp/view/forgot_password.jsp`, `src/main/webapp/view/reset_password.jsp`
    * `src/main/webapp/view/profile.jsp`, `src/main/webapp/view/profile_nav.jsp`, `src/main/webapp/view/change_password.jsp`
    * `src/main/webapp/view/admin_users.jsp`

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Dự Án

### 1. Yêu cầu môi trường
* **JDK:** Java 11 hoặc mới hơn (JDK 17 / JDK 22 khuyến nghị).
* **Build Tool:** Apache Maven 3.8+.
* **Database:** Microsoft SQL Server 2019 / 2022.
* **Server:** Apache Tomcat 10.1+ (Jakarta EE compatible).

### 2. Cấu hình CSDL
Mở file `src/main/java/dao/ConnectDB.java` và chỉnh sửa thông số kết nối:
```java
private static final String DB_URL = "jdbc:sqlserver://localhost:1433;"
        + "databaseName=SD2001_DATN_DEMO3;"
        + "user=sa;"
        + "password=YOUR_PASSWORD;"
        + "encrypt=true;"
        + "trustServerCertificate=true;";
```

### 3. Build & Chạy ứng dụng
```bash
# Biên dịch và đóng gói file .war
mvn clean package -DskipTests
```
Deploy file `target/demo-1.0-SNAPSHOT.war` lên Tomcat hoặc chạy trực tiếp qua Smart Tomcat / Tomcat Plugin trong IntelliJ IDEA hoặc NetBeans.
