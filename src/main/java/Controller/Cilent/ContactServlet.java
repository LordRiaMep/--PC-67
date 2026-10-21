package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 2: REALTIME WEBSOCKET HUB, DASHBOARD DOANH THU & CSKH]
 * Phụ trách: Quang
 * Chức năng: Khách hàng gửi form liên hệ, góp ý, phản ánh dịch vụ.
 * ============================================================================
 */

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Controller điều hướng và tiếp nhận thông tin liên hệ của khách hàng tại /contact
 */
@WebServlet(name = "ContactServlet", urlPatterns = {"/contact", "/contact/"})
public class ContactServlet extends HttpServlet {

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

        if (fullName == null || fullName.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ Họ và tên và Số điện thoại liên hệ!");
            request.setAttribute("formFullName", fullName);
            request.setAttribute("formPhone", phone);
            request.setAttribute("formEmail", email);
            request.setAttribute("formTopic", topic);
            request.setAttribute("formMessage", message);
        } else {
            model.Contact contact = new model.Contact();
            contact.setFullName(fullName.trim());
            contact.setPhone(phone.trim());
            contact.setEmail(email != null ? email.trim() : "");
            contact.setTopic(topic != null ? topic.trim() : "Tư vấn cấu hình PC");
            contact.setMessage(message != null ? message.trim() : "");
            contact.setStatus("Chưa xử lý");
            boolean ok = new dao.ContactDao().insert(contact);
            if (ok) {
                util.realtime.RealtimeHub.broadcastContactCreated(contact.getId(), contact.getFullName(), contact.getPhone(), contact.getEmail(), contact.getTopic(), contact.getMessage());
            }

            String successMsg = "Cảm ơn " + fullName.trim() + "! Độ-PC 67 đã tiếp nhận yêu cầu liên hệ của bạn. "
                    + "Chuyên viên tư vấn sẽ liên hệ lại qua số " + phone.trim() + " trong vòng 15 phút.";
            request.setAttribute("successMessage", successMsg);
            request.setAttribute("submitted", true);
        }

        request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
    }
}
