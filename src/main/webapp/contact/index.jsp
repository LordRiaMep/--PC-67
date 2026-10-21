<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String topic = request.getParameter("topic");
        String message = request.getParameter("message");

        if (fullName != null && !fullName.trim().isEmpty() && phone != null && !phone.trim().isEmpty()) {
            model.Contact c = new model.Contact();
            c.setFullName(fullName.trim());
            c.setPhone(phone.trim());
            c.setEmail(email != null ? email.trim() : "");
            c.setTopic(topic != null ? topic.trim() : "Tư vấn cấu hình PC Gaming");
            c.setMessage(message != null ? message.trim() : "");
            c.setStatus("Chưa xử lý");
            new dao.ContactDao().insert(c);

            request.setAttribute("successMessage", "Cảm ơn quý khách " + fullName.trim() + "! Độ-PC 67 đã tiếp nhận yêu cầu liên hệ của bạn. Chuyên viên tư vấn sẽ liên hệ lại qua số " + phone.trim() + " trong vòng 15 phút.");
            request.setAttribute("submitted", true);
        } else {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ Họ và tên và Số điện thoại liên hệ!");
        }
    }
    request.getRequestDispatcher("/view/contact.jsp").forward(request, response);
%>
