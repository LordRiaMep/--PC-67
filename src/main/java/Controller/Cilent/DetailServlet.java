package Controller.Cilent;

import dao.ProductDao;
import dao.UpgradeDao;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.Product;
import model.UpgradeOption;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/product/detail")
public class DetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idS = request.getParameter("id");
        int id = Integer.parseInt(idS);

        ProductDao dao = new ProductDao();
        Product p = dao.getProductById(id);

        Map<String, List<UpgradeOption>> upgradeGroups = new UpgradeDao().getGroupsByProduct(id);

        request.setAttribute("p", p);
        request.setAttribute("upgradeGroups", upgradeGroups);
        request.getRequestDispatcher("/view/detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}
