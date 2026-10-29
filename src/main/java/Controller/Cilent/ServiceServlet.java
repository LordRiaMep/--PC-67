package Controller.Cilent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

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
