package Controller.Admin;

import dao.UserDao;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        UserDao userDao = new UserDao();
        List<User> allUsers = userDao.getAllUsers();

        int pageSize = 5;
        int currentPage = 1;

        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try { currentPage = Integer.parseInt(pageParam); }
            catch (Exception e) { currentPage = 1; }
        }

        int totalUsers = allUsers.size();
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalUsers);

        List<User> pageUsers = new ArrayList<>();
        if (fromIndex < totalUsers) {
            pageUsers = allUsers.subList(fromIndex, toIndex);
        }

        req.setAttribute("users", pageUsers);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);

        req.getRequestDispatcher("/view/admin_users.jsp").forward(req, resp);
    }
}