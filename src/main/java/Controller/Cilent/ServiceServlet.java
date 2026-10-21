package Controller.Cilent;

/**
 * ============================================================================
 * [HỆ THỐNG DÙNG CHUNG (DỊCH VỤ CÔNG NGHỆ)]
 * Phụ trách: Cả nhóm
 * Chức năng: Hiển thị trang dịch vụ lắp ráp máy tính và thu cũ đổi mới.
 * ============================================================================
 */

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Mở 2 trang dịch vụ gắn với 2 banner ở trang chủ:
 *   /service/assembly -> view/service_assembly.jsp (Ráp máy tại nhà)
 *   /service/trade-in -> view/service_trade_in.jsp (Thu cũ đổi mới)
 */
@WebServlet(urlPatterns = {"/service/assembly", "/service/trade-in"})
public class ServiceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String view;
        if ("/service/trade-in".equals(req.getServletPath())) {
            view = "/view/service_trade_in.jsp";
        } else {
            view = "/view/service_assembly.jsp";
        }
        req.getRequestDispatcher(view).forward(req, resp);
    }
}
