package Controller.Cilent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "ContactServlet", urlPatterns = {"/contact", "/contact/"})
public class ContactServlet extends HttpServlet {

    // Regex định dạng số điện thoại di động Việt Nam:
    // Bắt đầu bằng 0 hoặc +84, theo sau bởi các đầu số 3, 5, 7, 8, 9 và 8 chữ số tiếp theo (tổng 10 số nếu đầu 0).
    private static final String VN_PHONE_REGEX = "^(0|\\+84)[35789][0-9]{8}$";

    // Regex định dạng email tiêu chuẩn
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String topic = request.getParameter("topic");
        String message = request.getParameter("message");

        String cleanFullName = fullName != null ? fullName.trim() : "";
        String cleanPhone = phone != null ? phone.trim().replaceAll("[\\s.-]", "") : "";
        String cleanEmail = email != null ? email.trim() : "";
        String cleanTopic = topic != null ? topic.trim() : "Tư vấn cấu hình PC Gaming";
        String cleanMessage = message != null ? message.trim() : "";

        // Giữ lại dữ liệu đã nhập trên form nếu có lỗi
        request.setAttribute("formFullName", fullName);
        request.setAttribute("formPhone", phone);
        request.setAttribute("formEmail", email);
        request.setAttribute("formTopic", topic);
        request.setAttribute("formMessage", message);

        // 1. Kiểm tra Họ và tên
        if (cleanFullName.isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập Họ và tên của bạn!");
            request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
            return;
        }

        // 2. Kiểm tra Số điện thoại theo vùng Việt Nam
        if (cleanPhone.isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập Số điện thoại liên hệ!");
            request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
            return;
        }

        if (!cleanPhone.matches(VN_PHONE_REGEX)) {
            request.setAttribute("errorMessage", "Số điện thoại không hợp lệ. Vui lòng nhập đúng số điện thoại theo định dạng Việt Nam (VD: 0904112618 hoặc +84904112618)!");
            request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
            return;
        }

        // 3. Kiểm tra định dạng Email (nếu có nhập)
        if (!cleanEmail.isEmpty() && !cleanEmail.matches(EMAIL_REGEX)) {
            request.setAttribute("errorMessage", "Địa chỉ email không đúng định dạng. Vui lòng nhập email hợp lệ (VD: name@example.com)!");
            request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
            return;
        }

        // Hợp lệ: Thêm vào database
        model.Contact contact = new model.Contact();
        contact.setFullName(cleanFullName);
        contact.setPhone(cleanPhone);
        contact.setEmail(cleanEmail);
        contact.setTopic(cleanTopic);
        contact.setMessage(cleanMessage);
        contact.setStatus("Chưa xử lý");

        boolean ok = new dao.ContactDao().insert(contact);
        if (ok) {
            util.realtime.RealtimeHub.broadcastContactCreated(contact.getId(), contact.getFullName(), contact.getPhone(), contact.getEmail(), contact.getTopic(), contact.getMessage());
        }

        String successMsg = "Cảm ơn " + cleanFullName + "! Độ-PC 67 đã tiếp nhận yêu cầu liên hệ của bạn. "
                + "Chuyên viên tư vấn sẽ liên hệ lại qua số " + cleanPhone + " trong vòng 15 phút.";
        request.setAttribute("successMessage", successMsg);
        request.setAttribute("submitted", true);

        // Xóa form khi thành công
        request.removeAttribute("formFullName");
        request.removeAttribute("formPhone");
        request.removeAttribute("formEmail");
        request.removeAttribute("formMessage");

        request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
    }
}
