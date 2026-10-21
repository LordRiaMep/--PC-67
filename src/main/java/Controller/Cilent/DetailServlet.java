package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 3: SẢN PHẨM, NÂNG CẤP PC & GEMINI AI CHATBOT]
 * Phụ trách: Nhân Hiếu
 * Chức năng: Hiển thị trang chi tiết sản phẩm, tải nhóm tùy chọn nâng cấp và tính tiền linh hoạt.
 * ============================================================================
 */

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

@WebServlet(name = "DetailServlet", urlPatterns = {"/product/detail", "/detail"})
public class DetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idS = request.getParameter("id");
        int id = Integer.parseInt(idS);

        ProductDao dao = new ProductDao();
        Product p = dao.getProductById(id);

        // Sản phẩm không tồn tại -> về trang chủ
        if (p == null) {
            response.sendRedirect(request.getContextPath() + "/Home");
            return;
        }

        Map<String, List<UpgradeOption>> upgradeGroups = new UpgradeDao().getGroupsByProduct(id);

        // Sản phẩm tương tự: cùng danh mục, giá gần nhất, tối đa 8 sản phẩm
        List<Product> relatedProducts = dao.getRelatedProducts(p.getId(), p.getCategoryId(), p.getPrice(), 8);

        // Danh sách Voucher ưu đãi khả dụng
        List<model.Voucher> voucherList = new dao.VoucherDao().getAvailableVouchersForDisplay();

        request.setAttribute("p", p);
        request.setAttribute("upgradeGroups", upgradeGroups);
        request.setAttribute("relatedProducts", relatedProducts);
        request.setAttribute("voucherList", voucherList);
        request.getRequestDispatcher("/view/detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}