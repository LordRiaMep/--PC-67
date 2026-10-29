<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    request.setCharacterEncoding("UTF-8");
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

    request.setAttribute("formFullName", fullName);
    request.setAttribute("formPhone", phone);
    request.setAttribute("formEmail", email);
    request.setAttribute("formTopic", topic);
    request.setAttribute("formMessage", message);

    String vnPhoneRegex = "^(0|\\+84)[35789][0-9]{8}$";
    String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";

    if (cleanFullName.isEmpty()) {
        request.setAttribute("errorMessage", "Vui lòng nhập Họ và tên của bạn!");
    } else if (cleanPhone.isEmpty()) {
        request.setAttribute("errorMessage", "Vui lòng nhập Số điện thoại liên hệ!");
    } else if (!cleanPhone.matches(vnPhoneRegex)) {
        request.setAttribute("errorMessage", "Số điện thoại không hợp lệ. Vui lòng nhập đúng số điện thoại theo định dạng Việt Nam (VD: 0904112618 hoặc +84904112618)!");
    } else if (!cleanEmail.isEmpty() && !cleanEmail.matches(emailRegex)) {
        request.setAttribute("errorMessage", "Địa chỉ email không đúng định dạng. Vui lòng nhập email hợp lệ (VD: name@example.com)!");
    } else {
        model.Contact c = new model.Contact();
        c.setFullName(cleanFullName);
        c.setPhone(cleanPhone);
        c.setEmail(cleanEmail);
        c.setTopic(cleanTopic);
        c.setMessage(cleanMessage);
        c.setStatus("Chưa xử lý");
        boolean ok = new dao.ContactDao().insert(c);
        if (ok) {
            util.realtime.RealtimeHub.broadcastContactCreated(c.getId(), c.getFullName(), c.getPhone(), c.getEmail(), c.getTopic(), c.getMessage());
        }

        request.setAttribute("successMessage", "Cảm ơn " + cleanFullName + "! Độ-PC 67 đã tiếp nhận yêu cầu liên hệ của bạn. Chuyên viên tư vấn sẽ liên hệ lại qua số " + cleanPhone + " trong vòng 15 phút.");
        request.setAttribute("submitted", true);
        request.removeAttribute("formFullName");
        request.removeAttribute("formPhone");
        request.removeAttribute("formEmail");
        request.removeAttribute("formMessage");
    }
}
request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
%>
