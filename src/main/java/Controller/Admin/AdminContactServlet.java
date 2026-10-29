package Controller.Admin;

import dao.ContactDao;
import model.Contact;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminContactServlet", urlPatterns = {"/admin/contacts"})
public class AdminContactServlet extends HttpServlet {

    private final ContactDao contactDao = new ContactDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        String keyword = request.getParameter("keyword");
        if (keyword == null) {
            keyword = "";
        }

        List<Contact> contactList = contactDao.getAll(status, keyword);
        int totalContacts = contactDao.countTotal();
        int pendingCount = contactDao.countByStatus("Chưa xử lý");
        int contactingCount = contactDao.countByStatus("Đang liên hệ");
        int completedCount = contactDao.countByStatus("Đã hoàn thành");

        request.setAttribute("contactList", contactList);
        request.setAttribute("currentStatus", status);
        request.setAttribute("keyword", keyword);
        request.setAttribute("totalContacts", totalContacts);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("contactingCount", contactingCount);
        request.setAttribute("completedCount", completedCount);

        request.getRequestDispatcher("/view/admin_contacts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("update".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                String adminNote = request.getParameter("adminNote");

                boolean ok = contactDao.updateStatusAndNote(id, status, adminNote);
                if (ok) {
                    session.setAttribute("successMessage", "Đã cập nhật trạng thái & ghi chú phản hồi cho yêu cầu #" + id + " thành công!");
                    util.realtime.RealtimeHub.broadcastContactUpdated(id, status, adminNote);
                } else {
                    session.setAttribute("errorMessage", "Cập nhật yêu cầu #" + id + " thất bại!");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Dữ liệu không hợp lệ: " + e.getMessage());
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = contactDao.delete(id);
                if (ok) {
                    session.setAttribute("successMessage", "Đã xóa yêu cầu liên hệ #" + id + "!");
                } else {
                    session.setAttribute("errorMessage", "Xóa yêu cầu #" + id + " thất bại!");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/contacts");
    }
}
