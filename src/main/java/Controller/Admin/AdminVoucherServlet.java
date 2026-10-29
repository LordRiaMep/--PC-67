package Controller.Admin;

import dao.VoucherDao;
import model.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet("/admin/vouchers")
public class AdminVoucherServlet extends HttpServlet {
    private final VoucherDao dao = new VoucherDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String pageParam = req.getParameter("page");
        String keyword = req.getParameter("keyword");
        if (keyword != null) keyword = keyword.trim();

        int page = 1;
        int pageSize = 6;
        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException ignored) {}

        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Voucher oldV = dao.getById(id);
                String oldCode = (oldV != null) ? oldV.getCode() : "Voucher #" + id;
                boolean ok = dao.delete(id);
                if (ok) {
                    util.realtime.RealtimeHub.broadcastVoucherChanged("delete", oldCode);
                    resp.sendRedirect(req.getContextPath() + "/admin/vouchers?msg=delete_success&page=" + page);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=cannot_delete&page=" + page);
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_id&page=" + page);
            }
            return;
        } else if ("toggle".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Voucher oldV = dao.getById(id);
                dao.toggleStatus(id);
                if (oldV != null) {
                    util.realtime.RealtimeHub.broadcastVoucherChanged("toggle", oldV.getCode());
                }
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?msg=toggle_success&page=" + page);
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_id&page=" + page);
            }
            return;
        } else if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Voucher v = dao.getById(id);
                if (v != null) {
                    req.setAttribute("voucher", v);
                }
            } catch (Exception ignored) {}
        }

        int totalItems = dao.getTotalCount(keyword);
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }
        if (page < 1) page = 1;

        List<Voucher> listVouchers = dao.getByPage(page, pageSize, keyword);

        List<Voucher> allVouchers = dao.getAll();
        int countActive = 0;
        int countExpiredOrFull = 0;
        for (Voucher v : allVouchers) {
            if (v.isUsableNow()) countActive++;
            else if (v.isExpired() || v.isUsageExceeded()) countExpiredOrFull++;
        }

        req.setAttribute("listVouchers", listVouchers);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("keyword", keyword);
        req.setAttribute("countTotal", allVouchers.size());
        req.setAttribute("countActive", countActive);
        req.setAttribute("countExpiredOrFull", countExpiredOrFull);

        String msg = req.getParameter("msg");
        String err = req.getParameter("error");
        if ("insert_success".equals(msg)) req.setAttribute("successMessage", "Thêm voucher thành công!");
        else if ("update_success".equals(msg)) req.setAttribute("successMessage", "Cập nhật voucher thành công!");
        else if ("delete_success".equals(msg)) req.setAttribute("successMessage", "Xóa/Vô hiệu hóa voucher thành công!");
        else if ("toggle_success".equals(msg)) req.setAttribute("successMessage", "Thay đổi trạng thái voucher thành công!");

        if ("cannot_delete".equals(err)) req.setAttribute("errorMessage", "Không thể xóa voucher đã phát sinh đơn hàng!");
        else if ("code_exists".equals(err)) req.setAttribute("errorMessage", "Mã voucher này đã tồn tại trên hệ thống!");
        else if ("invalid_dates".equals(err)) req.setAttribute("errorMessage", "Ngày kết thúc phải lớn hơn ngày bắt đầu!");
        else if ("invalid_discount".equals(err)) req.setAttribute("errorMessage", "Mức giảm giá không hợp lệ (Phần trăm từ 1 - 100%, hoặc số tiền > 0)!");
        else if ("invalid_usage_limit".equals(err)) req.setAttribute("errorMessage", "Số lượt sử dụng tối đa phải lớn hơn 0!");
        else if ("limit_below_used".equals(err)) req.setAttribute("errorMessage", "Số lượt dùng tối đa không được nhỏ hơn số lượt đã sử dụng!");
        else if ("cannot_change_type".equals(err)) req.setAttribute("errorMessage", "Không thể thay đổi loại giảm giá khi voucher đã có đơn hàng sử dụng!");
        else if ("invalid_data".equals(err)) req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các trường thông tin bắt buộc!");

        req.getRequestDispatcher("/view/admin_vouchers.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String pageParam = req.getParameter("page");
        String redirectPage = (pageParam != null && !pageParam.isEmpty()) ? "&page=" + pageParam : "";

        try {
            String idParam = req.getParameter("id");
            int id = (idParam != null && !idParam.isEmpty()) ? Integer.parseInt(idParam) : 0;
            String code = req.getParameter("code");
            String name = req.getParameter("name");
            String discountType = req.getParameter("discountType");
            String discountValueStr = req.getParameter("discountValue");
            String maxDiscountStr = req.getParameter("maxDiscountAmount");
            String minOrderStr = req.getParameter("minOrderAmount");
            String usageLimitStr = req.getParameter("usageLimit");
            String startDateStr = req.getParameter("startDate");
            String endDateStr = req.getParameter("endDate");
            String status = req.getParameter("status");

            if (code == null || code.trim().isEmpty() || name == null || name.trim().isEmpty()
                    || discountValueStr == null || discountValueStr.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_data" + redirectPage);
                return;
            }

            code = code.trim().toUpperCase().replaceAll("\\s+", "");

            if (dao.isCodeExists(code, id)) {
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=code_exists" + redirectPage);
                return;
            }

            if (!"PERCENT".equalsIgnoreCase(discountType) && !"FIXED".equalsIgnoreCase(discountType)) {
                discountType = "PERCENT";
            }

            double discountValue = Double.parseDouble(discountValueStr.trim());
            if ("PERCENT".equalsIgnoreCase(discountType)) {
                if (discountValue < 1.0 || discountValue > 100.0) {
                    resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_discount" + redirectPage);
                    return;
                }
            } else {
                if (discountValue <= 0) {
                    resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_discount" + redirectPage);
                    return;
                }
            }

            Double maxDiscountAmount = null;
            if ("PERCENT".equalsIgnoreCase(discountType)) {
                if (maxDiscountStr != null && !maxDiscountStr.trim().isEmpty()) {
                    try {
                        double md = Double.parseDouble(maxDiscountStr.trim());
                        if (md > 0) maxDiscountAmount = md;
                    } catch (NumberFormatException ignored) {}
                }
            } else {

                maxDiscountAmount = null;
            }

            double minOrderAmount = 0.0;
            if (minOrderStr != null && !minOrderStr.trim().isEmpty()) {
                try {
                    minOrderAmount = Double.parseDouble(minOrderStr.trim());
                    if (minOrderAmount < 0) minOrderAmount = 0.0;
                } catch (NumberFormatException ignored) {}
            }

            if ("FIXED".equalsIgnoreCase(discountType) && minOrderAmount > 0 && minOrderAmount < discountValue) {
                minOrderAmount = discountValue;
            }

            int usageLimit = 100;
            if (usageLimitStr != null && !usageLimitStr.trim().isEmpty()) {
                try {
                    usageLimit = Integer.parseInt(usageLimitStr.trim());
                } catch (NumberFormatException e) {
                    usageLimit = -1;
                }
            }
            if (usageLimit <= 0) {
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_usage_limit" + redirectPage);
                return;
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Timestamp startTs = null;
            Timestamp endTs = null;

            if (startDateStr != null && !startDateStr.trim().isEmpty()) {
                Date d = sdf.parse(startDateStr.trim());
                startTs = new Timestamp(d.getTime());
            } else {
                startTs = new Timestamp(System.currentTimeMillis());
            }

            if (endDateStr != null && !endDateStr.trim().isEmpty()) {
                Date d = sdf.parse(endDateStr.trim());
                endTs = new Timestamp(d.getTime() + (24 * 60 * 60 * 1000L - 1000L));
            } else {

                endTs = new Timestamp(System.currentTimeMillis() + (30L * 24 * 60 * 60 * 1000L));
            }

            if (startDateStr != null && !startDateStr.trim().isEmpty() && endDateStr != null && !endDateStr.trim().isEmpty()) {
                Date dStart = sdf.parse(startDateStr.trim());
                Date dEnd = sdf.parse(endDateStr.trim());
                if (!dEnd.after(dStart)) {
                    resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_dates" + redirectPage);
                    return;
                }
            } else if (!endTs.after(startTs)) {
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_dates" + redirectPage);
                return;
            }

            if (status == null || (!"ACTIVE".equalsIgnoreCase(status) && !"INACTIVE".equalsIgnoreCase(status))) {
                status = "ACTIVE";
            }

            Voucher v = new Voucher();
            v.setId(id);
            v.setCode(code);
            v.setName(name.trim());
            v.setDiscountType(discountType);
            v.setDiscountValue(discountValue);
            v.setMaxDiscountAmount(maxDiscountAmount);
            v.setMinOrderAmount(minOrderAmount);
            v.setUsageLimit(usageLimit);
            v.setStartDate(startTs);
            v.setEndDate(endTs);
            v.setStatus(status);

            if ("update".equals(req.getParameter("action")) && id > 0) {
                Voucher existing = dao.getById(id);
                if (existing != null) {
                    if (usageLimit < existing.getUsedCount()) {
                        resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=limit_below_used" + redirectPage);
                        return;
                    }
                    if (existing.getUsedCount() > 0 && !existing.getDiscountType().equalsIgnoreCase(discountType)) {
                        resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=cannot_change_type" + redirectPage);
                        return;
                    }
                }
                dao.update(v);
                util.realtime.RealtimeHub.broadcastVoucherChanged("update", v.getCode());
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?msg=update_success" + redirectPage);
            } else {
                dao.insert(v);
                util.realtime.RealtimeHub.broadcastVoucherChanged("create", v.getCode());
                resp.sendRedirect(req.getContextPath() + "/admin/vouchers?msg=insert_success" + redirectPage);
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/vouchers?error=invalid_data" + redirectPage);
        }
    }
}
