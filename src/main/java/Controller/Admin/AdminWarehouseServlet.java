package Controller.Admin;

import dao.WarehouseDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.WarehouseConfig;
import util.GhnService;

import java.io.IOException;

@WebServlet("/admin/warehouse")
public class AdminWarehouseServlet extends HttpServlet {

    private final WarehouseDao warehouseDao = new WarehouseDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        WarehouseConfig warehouse = warehouseDao.getWarehouseConfig();
        req.setAttribute("warehouse", warehouse);
        req.getRequestDispatcher("/view/admin_warehouse.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        try {
            int provinceId = Integer.parseInt(req.getParameter("provinceId"));
            String provinceName = req.getParameter("provinceName");
            int districtId = Integer.parseInt(req.getParameter("districtId"));
            String districtName = req.getParameter("districtName");
            String wardCode = req.getParameter("wardCode");
            String wardName = req.getParameter("wardName");
            String detailAddress = req.getParameter("detailAddress");

            if (provinceId <= 0 || districtId <= 0 || districtName == null || districtName.trim().isEmpty()
                    || wardCode == null || wardCode.trim().isEmpty() || wardName == null || wardName.trim().isEmpty()) {
                session.setAttribute("errorMsg", "Vui lòng chọn đầy đủ Tỉnh/Thành, Quận/Huyện và Phường/Xã cho kho!");
                resp.sendRedirect(req.getContextPath() + "/admin/warehouse");
                return;
            }

            WarehouseConfig cfg = new WarehouseConfig();
            cfg.setId(1);
            cfg.setProvinceId(provinceId);
            cfg.setProvinceName(provinceName != null ? provinceName.trim() : "");
            cfg.setDistrictId(districtId);
            cfg.setDistrictName(districtName != null ? districtName.trim() : "");
            cfg.setWardCode(wardCode.trim());
            cfg.setWardName(wardName != null ? wardName.trim() : "");
            cfg.setDetailAddress(detailAddress != null ? detailAddress.trim() : "");

            boolean success = warehouseDao.updateWarehouseConfig(cfg);
            if (success) {

                GhnService.reloadWarehouseConfig();
                session.setAttribute("successMsg", "Đã cập nhật địa chỉ kho hàng thành công! Tất cả đơn hàng mới sẽ tính phí ship từ kho này.");
            } else {
                session.setAttribute("errorMsg", "Lỗi khi lưu cấu hình kho hàng vào cơ sở dữ liệu!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Đã xảy ra lỗi: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/warehouse");
    }
}
