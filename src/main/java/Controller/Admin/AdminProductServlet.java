package Controller.Admin;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import dao.CategoryDao;
import dao.ProductDao;
import dao.ProductImageDao;
import dao.UpgradeDao;
import model.Product;
import model.UpgradeOption;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/products")
public class AdminProductServlet extends HttpServlet {
    private final ProductDao productDao = new ProductDao();
    private final CategoryDao categoryDao = new CategoryDao();
    private final UpgradeDao upgradeDao = new UpgradeDao();
    private final ProductImageDao productImageDao = new ProductImageDao();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String pageParam = req.getParameter("page");
        int page = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }

        if ("get_options_ajax".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int productId = Integer.parseInt(req.getParameter("productId"));
                List<UpgradeOption> opts = upgradeDao.getOptionsByProductId(productId);
                resp.getWriter().write(gson.toJson(opts));
            } catch (Exception e) {
                resp.getWriter().write("[]");
            }
            return;
        }

        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Product oldProd = productDao.getProductById(id);
                String oldName = (oldProd != null) ? oldProd.getName() : "Sản phẩm #" + id;
                boolean ok = productDao.delete(id);
                if (ok) {
                    util.realtime.RealtimeHub.broadcastProductChanged("delete", id, oldName, 0, 0, "");
                    resp.sendRedirect(req.getContextPath() + "/admin/products?msg=delete_success&page=" + page);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?error=delete_fail&page=" + page);
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/products?error=invalid_id&page=" + page);
            }
            return;
        }

        if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Product p = productDao.getProductById(id);
                if (p != null) {
                    req.setAttribute("product", p);
                    List<UpgradeOption> options = upgradeDao.getOptionsByProductId(id);
                    req.setAttribute("productOptions", options);
                    req.setAttribute("productOptionsJson", gson.toJson(options));

                    List<String> images = p.getImages();
                    req.setAttribute("productImages", images);
                    req.setAttribute("productImagesJson", gson.toJson(images));
                }
            } catch (Exception ignored) {}
        }

        int pageSize = 10;
        int totalProducts = productDao.getTotalProducts();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }

        List<Product> listProducts = productDao.getProductsByPage(page, pageSize);

        List<Integer> pids = new ArrayList<>();
        for (Product pr : listProducts) {
            pids.add(pr.getId());
        }
        Map<Integer, Integer> optionCountMap = upgradeDao.getOptionCountByProductIds(pids);
        Map<Integer, Integer> imageCountMap = productImageDao.getImageCountByProductIds(pids);

        req.setAttribute("listProducts", listProducts);
        req.setAttribute("optionCountMap", optionCountMap);
        req.setAttribute("imageCountMap", imageCountMap);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("listCategories", categoryDao.findAll());

        String msg = req.getParameter("msg");
        String err = req.getParameter("error");
        if ("delete_success".equals(msg)) req.setAttribute("successMessage", "Xóa / Ẩn sản phẩm thành công!");
        else if ("insert_success".equals(msg)) req.setAttribute("successMessage", "Thêm sản phẩm mới và thiết lập tùy chọn thành công!");
        else if ("update_success".equals(msg)) req.setAttribute("successMessage", "Cập nhật sản phẩm và tùy chọn thành công!");
        else if ("options_updated".equals(msg)) req.setAttribute("successMessage", "Cập nhật tùy chọn cấu hình sản phẩm thành công!");

        if ("delete_fail".equals(err)) req.setAttribute("errorMessage", "Không thể xóa sản phẩm do lỗi hệ thống.");
        else if ("invalid_data".equals(err)) req.setAttribute("errorMessage", "Dữ liệu nhập không hợp lệ. Vui lòng kiểm tra lại tên, giá và danh mục.");

        req.getRequestDispatcher("/view/admin_product.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String pageParam = req.getParameter("page");
        String redirectPage = (pageParam != null && !pageParam.isEmpty()) ? "&page=" + pageParam : "";
        String action = req.getParameter("action");

        if ("quick_save_options".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int productId = Integer.parseInt(req.getParameter("productId"));
                String optionsJson = req.getParameter("optionsJson");
                List<UpgradeOption> opts = parseOptionsJson(optionsJson);
                boolean ok = upgradeDao.saveProductOptions(productId, opts);
                resp.getWriter().write("{\"success\":" + ok + ",\"count\":" + opts.size() + "}");
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
            }
            return;
        }

        try {
            int id = 0;
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                id = Integer.parseInt(idStr);
            }

            int categoryId = Integer.parseInt(req.getParameter("categoryId"));
            String name = req.getParameter("name");
            String description = req.getParameter("description");
            double price = Double.parseDouble(req.getParameter("price"));
            int stock = Integer.parseInt(req.getParameter("stock"));
            String imageUrl = req.getParameter("imageUrl");
            String imagesJson = req.getParameter("imagesJson");
            String subImagesText = req.getParameter("subImagesText");
            String specDetail = normalizeSpec(req.getParameter("specDetail"));

            if (name == null || name.trim().isEmpty() || price < 0 || stock < 0 || categoryId <= 0) {
                resp.sendRedirect(req.getContextPath() + "/admin/products?error=invalid_data" + redirectPage);
                return;
            }

            // Xử lý danh sách nhiều ảnh từ Admin
            List<String> allImages = new ArrayList<>();
            if (imagesJson != null && !imagesJson.trim().isEmpty()) {
                try {
                    Type type = new TypeToken<List<String>>(){}.getType();
                    List<String> parsed = gson.fromJson(imagesJson, type);
                    if (parsed != null) {
                        for (String img : parsed) {
                            if (img != null && !img.trim().isEmpty()) {
                                String clean = img.trim();
                                if (!allImages.contains(clean)) allImages.add(clean);
                            }
                        }
                    }
                } catch (Exception ignored) {}
            }
            if (subImagesText != null && !subImagesText.trim().isEmpty()) {
                for (String line : subImagesText.split("\\r?\\n")) {
                    String clean = line.trim();
                    if (!clean.isEmpty() && !allImages.contains(clean)) {
                        allImages.add(clean);
                    }
                }
            }
            if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                String cleanMain = imageUrl.trim();
                if (!allImages.contains(cleanMain)) {
                    allImages.add(0, cleanMain);
                }
            } else if (!allImages.isEmpty()) {
                imageUrl = allImages.get(0);
            }

            Product p = new Product(id, categoryId, name.trim(), description, price, imageUrl, stock, "ACTIVE", null);
            p.setSpecDetail(specDetail);
            p.setImages(allImages);

            String upgradeOptionsJson = req.getParameter("upgradeOptionsJson");
            List<UpgradeOption> optionsToSave = parseOptionsJson(upgradeOptionsJson);

            if ("update".equals(action) && id > 0) {
                productDao.update(p);
                upgradeDao.saveProductOptions(id, optionsToSave);
                productImageDao.saveProductImages(id, allImages);
                util.realtime.RealtimeHub.broadcastProductChanged("update", id, p.getName(), p.getPrice(), p.getQuantity(), p.getImage());
                resp.sendRedirect(req.getContextPath() + "/admin/products?msg=update_success" + redirectPage);
            } else {
                int newId = productDao.insert(p);
                if (newId > 0) {
                    if (!optionsToSave.isEmpty()) {
                        upgradeDao.saveProductOptions(newId, optionsToSave);
                    }
                    if (!allImages.isEmpty()) {
                        productImageDao.saveProductImages(newId, allImages);
                    }
                    util.realtime.RealtimeHub.broadcastProductChanged("create", newId, p.getName(), p.getPrice(), p.getQuantity(), p.getImage());
                    resp.sendRedirect(req.getContextPath() + "/admin/products?msg=insert_success&page=1");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?error=invalid_data" + redirectPage);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/products?error=invalid_data" + redirectPage);
        }
    }

    private List<UpgradeOption> parseOptionsJson(String json) {
        List<UpgradeOption> result = new ArrayList<>();
        if (json == null || json.trim().isEmpty()) return result;
        try {
            Type type = new TypeToken<List<UpgradeOption>>(){}.getType();
            List<UpgradeOption> list = gson.fromJson(json, type);
            if (list != null) {
                for (UpgradeOption opt : list) {
                    if (opt != null && opt.getGroupName() != null && !opt.getGroupName().trim().isEmpty()
                            && opt.getName() != null && !opt.getName().trim().isEmpty()) {
                        opt.setGroupName(opt.getGroupName().trim());
                        opt.setName(opt.getName().trim());
                        if (opt.getStatus() == null || opt.getStatus().trim().isEmpty()) {
                            opt.setStatus("ACTIVE");
                        }
                        result.add(opt);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi parseOptionsJson: " + e.getMessage());
        }
        return result;
    }

    private String normalizeSpec(String raw) {
        if (raw == null) return null;
        StringBuilder sb = new StringBuilder();
        for (String line : raw.split("\\r?\\n")) {
            String s = line.replace("|", " ").trim();
            if (s.isEmpty()) continue;
            if (sb.length() > 0) sb.append("|");
            sb.append(s);
        }
        return sb.length() == 0 ? null : sb.toString();
    }
}
