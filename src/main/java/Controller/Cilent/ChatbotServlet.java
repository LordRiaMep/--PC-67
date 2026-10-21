package Controller.Cilent;

/**
 * ============================================================================
 * [PHÂN HỆ 3: SẢN PHẨM, NÂNG CẤP PC & GEMINI AI CHATBOT]
 * Phụ trách: Nhân Hiếu
 * Chức năng: API xử lý hội thoại tư vấn cấu hình PC thông minh cho widget Chatbot.
 * ============================================================================
 */

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.ProductDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import service.ChatbotKnowledgeService;
import service.GeminiService;
import util.ChatbotConfig;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@WebServlet(name = "ChatbotServlet", urlPatterns = {"/api/chat", "/chatbot"})
public class ChatbotServlet extends HttpServlet {

    private final GeminiService geminiService = new GeminiService();
    private final ChatbotKnowledgeService knowledgeService = new ChatbotKnowledgeService();
    private final ProductDao productDao = new ProductDao();
    private final Gson gson = new Gson();
    private final DecimalFormat df = new DecimalFormat("#,### đ");

    // Quản lý tần suất gọi API (Rate Limiting - 13.11): Lưu mốc thời gian gọi của từng IP
    private static final Map<String, List<Long>> requestHistory = new ConcurrentHashMap<>();

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip != null ? ip : "unknown";
    }

    private boolean isRateLimited(String clientIp) {
        long now = System.currentTimeMillis();
        long window = 60_000L; // Cửa sổ 1 phút
        int maxRequests = 30;  // Tối đa 30 request/phút (chặn spam 100 lần/phút)

        synchronized (requestHistory) {
            List<Long> timestamps = requestHistory.computeIfAbsent(clientIp, k -> new ArrayList<>());
            timestamps.removeIf(t -> now - t > window);
            if (timestamps.size() >= maxRequests) {
                return true;
            }
            timestamps.add(now);
            return false;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        JsonObject res = new JsonObject();
        res.addProperty("status", "ready");
        res.addProperty("shop", ChatbotConfig.SHOP_NAME);
        res.addProperty("hotline", ChatbotConfig.SHOP_HOTLINE);
        res.addProperty("hasGeminiKey", ChatbotConfig.hasGeminiApiKey());
        res.addProperty("model", ChatbotConfig.getGeminiModel());

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(res));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        // 13.11: Kiểm tra giới hạn tần suất gọi API
        String clientIp = getClientIp(request);
        if (isRateLimited(clientIp)) {
            response.setStatus(429);
            JsonObject rateLimitRes = new JsonObject();
            rateLimitRes.addProperty("status", "rate_limited");
            rateLimitRes.addProperty("reply", "Bạn đang gửi tin nhắn quá nhanh (giới hạn 30 tin/phút). Vui lòng đợi trong giây lát để hệ thống hỗ trợ bạn chu đáo hơn nhé!");
            rateLimitRes.add("suggestions", new JsonArray());
            rateLimitRes.add("products", new JsonArray());
            try (PrintWriter out = response.getWriter()) {
                out.print(gson.toJson(rateLimitRes));
            }
            return;
        }

        String userMessage = null;
        String action = null;

        // Đọc dữ liệu từ body JSON hoặc form data
        String contentType = request.getContentType();
        if (contentType != null && contentType.toLowerCase().contains("application/json")) {
            try (BufferedReader reader = request.getReader()) {
                JsonObject body = gson.fromJson(reader, JsonObject.class);
                if (body != null) {
                    if (body.has("message") && !body.get("message").isJsonNull()) {
                        userMessage = body.get("message").getAsString();
                    }
                    if (body.has("action") && !body.get("action").isJsonNull()) {
                        action = body.get("action").getAsString();
                    }
                }
            } catch (Exception ignored) {}
        }

        // Fallback đọc param từ form thông thường nếu JSON rỗng
        if (userMessage == null) {
            userMessage = request.getParameter("message");
        }
        if (action == null) {
            action = request.getParameter("action");
        }

        // 13.12: Giới hạn độ dài tin nhắn (tối đa 1.000 ký tự để chống tràn bộ nhớ / đốt token)
        if (userMessage != null && userMessage.length() > 1000) {
            userMessage = userMessage.substring(0, 1000);
        }

        String replyText = null;
        List<String> suggestions = new ArrayList<>();
        List<Product> products = new ArrayList<>();
        String mode = "rule-based";

        // 1. Nếu người dùng kích hoạt Action (bấm nút nhanh) -> Phản hồi siêu tốc từ Knowledge Engine
        if (action != null && !action.trim().isEmpty()) {
            ChatbotKnowledgeService.ChatResult cr = knowledgeService.handleQuery(null, action);
            replyText = cr.getReply();
            suggestions = cr.getSuggestions();
            products = cr.getProducts();
        } else if (userMessage != null && !userMessage.trim().isEmpty()) {
            // 2. Nếu có tin nhắn gõ tự do
            boolean usedGemini = false;

            if (ChatbotConfig.hasGeminiApiKey()) {
                ChatbotKnowledgeService.ParsedIntent pi = ChatbotKnowledgeService.parseQuery(userMessage);

                // Lấy ngữ cảnh các sản phẩm THỰC TẾ phù hợp nhất với nhu cầu người dùng để cung cấp cho AI
                List<Product> relevantSample = productDao.searchAdvancedForChatbot(
                        pi.brand,
                        pi.gpu,
                        pi.cleanTokens.isEmpty() ? null : pi.cleanTokens,
                        pi.targetPrice,
                        pi.targetPrice != null ? pi.targetPrice * 0.70 : null,
                        pi.targetPrice != null ? pi.targetPrice * 1.30 : null,
                        !pi.isComponent,
                        pi.isGaming,
                        pi.excludeOffice,
                        8
                );
                if (relevantSample.isEmpty()) {
                    relevantSample = productDao.searchAdvancedForChatbot(pi.brand, null, null, pi.targetPrice, null, null, true, pi.isGaming, pi.excludeOffice, 8);
                }
                if (relevantSample.isEmpty()) {
                    relevantSample = productDao.searchForChatbot(null, null, null, 8);
                }

                StringBuilder shopContext = new StringBuilder();
                for (Product p : relevantSample) {
                    shopContext.append("- ").append(p.getName())
                            .append(" | Giá: ").append(df.format(p.getPrice()))
                            .append(" | Loại: ").append(p.getCategoryName() != null ? p.getCategoryName() : "PC")
                            .append("\n");
                }

                String aiResponse = geminiService.askGemini(userMessage, shopContext.toString());
                if (aiResponse != null && !aiResponse.trim().isEmpty()) {
                    replyText = aiResponse;
                    mode = "gemini";
                    usedGemini = true;

                    // Tìm sản phẩm liên quan từ câu hỏi hoặc từ khóa chính để đính kèm Card
                    products = findRelevantProducts(userMessage);

                    suggestions = Arrays.asList(
                            "Tư vấn cấu hình theo tầm giá",
                            "Chính sách bảo hành & Đổi trả",
                            "Gặp nhân viên hỗ trợ",
                            "Hotline: " + ChatbotConfig.SHOP_HOTLINE
                    );
                }
            }

            // Nếu không dùng Gemini hoặc Gemini bị lỗi/hết quota -> Dùng Local Knowledge Base
            if (!usedGemini) {
                ChatbotKnowledgeService.ChatResult cr = knowledgeService.handleQuery(userMessage, null);
                replyText = cr.getReply();
                suggestions = cr.getSuggestions();
                products = cr.getProducts();
            }
        } else {
            replyText = "Dạ bạn có thể gõ câu hỏi hoặc chọn các nút tư vấn nhanh bên dưới nhé!";
            suggestions = Arrays.asList("Dưới 10 triệu", "10 - 15 triệu", "15 - 25 triệu", "Trên 25 triệu", "Bảo hành");
        }

        // Tạo JSON response
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("status", "success");
        jsonResponse.addProperty("mode", mode);
        jsonResponse.addProperty("reply", replyText);

        JsonArray suggestArray = new JsonArray();
        for (String s : suggestions) {
            suggestArray.add(s);
        }
        jsonResponse.add("suggestions", suggestArray);

        JsonArray prodArray = new JsonArray();
        if (products != null) {
            for (Product p : products) {
                JsonObject pObj = new JsonObject();
                pObj.addProperty("id", p.getId());
                pObj.addProperty("name", p.getName());
                pObj.addProperty("price", p.getPrice());
                pObj.addProperty("formattedPrice", df.format(p.getPrice()));
                pObj.addProperty("image", p.getImage() != null ? p.getImage() : "");
                pObj.addProperty("categoryName", p.getCategoryName() != null ? p.getCategoryName() : "");
                prodArray.add(pObj);
            }
        }
        jsonResponse.add("products", prodArray);

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(jsonResponse));
        }
    }

    private List<Product> findRelevantProducts(String userMessage) {
        ChatbotKnowledgeService.ParsedIntent pi = ChatbotKnowledgeService.parseQuery(userMessage);

        List<Product> list = productDao.searchAdvancedForChatbot(
                pi.brand,
                pi.gpu,
                pi.cleanTokens.isEmpty() ? null : pi.cleanTokens,
                pi.targetPrice,
                pi.targetPrice != null ? pi.targetPrice * 0.70 : null,
                pi.targetPrice != null ? pi.targetPrice * 1.30 : null,
                !pi.isComponent,
                pi.isGaming,
                pi.excludeOffice,
                4
        );

        if (!list.isEmpty()) return list;

        // Fallback: Nếu có brand thì luôn giữ đúng brand đó và tôn trọng gaming/excludeOffice
        if (pi.brand != null) {
            return productDao.searchAdvancedForChatbot(pi.brand, null, null, pi.targetPrice, null, null, true, pi.isGaming, pi.excludeOffice, 4);
        }

        // Fallback: Nếu có GPU
        if (pi.gpu != null) {
            return productDao.searchAdvancedForChatbot(null, pi.gpu, null, null, null, null, true, pi.isGaming, pi.excludeOffice, 4);
        }

        // Fallback: Nếu có targetPrice
        if (pi.targetPrice != null) {
            return productDao.searchAdvancedForChatbot(null, null, null, pi.targetPrice, pi.targetPrice * 0.60, pi.targetPrice * 1.40, true, pi.isGaming, pi.excludeOffice, 4);
        }

        return productDao.searchAdvancedForChatbot(null, null, null, null, null, null, true, pi.isGaming, pi.excludeOffice, 4);
    }
}
