package service;

import dao.ProductDao;
import model.Product;
import util.ChatbotConfig;

import java.text.DecimalFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ChatbotKnowledgeService {

    private final ProductDao productDao = new ProductDao();
    private static final DecimalFormat df = new DecimalFormat("#,### đ");

    public static class ChatResult {
        private String reply;
        private List<String> suggestions;
        private List<Product> products;

        public ChatResult(String reply, List<String> suggestions, List<Product> products) {
            this.reply = reply;
            this.suggestions = suggestions != null ? suggestions : new ArrayList<String>();
            this.products = products != null ? products : new ArrayList<Product>();
        }

        public String getReply() { return reply; }
        public List<String> getSuggestions() { return suggestions; }
        public List<Product> getProducts() { return products; }
    }

    public static class ParsedIntent {
        public String brand = null;
        public String gpu = null;
        public Double targetPrice = null;
        public Double minPrice = null;
        public Double maxPrice = null;
        public String purpose = null;
        public boolean isGaming = false;
        public boolean excludeOffice = false;
        public boolean isComponent = false;
        public List<String> cleanTokens = new ArrayList<String>();
        public String originalText = "";
    }

    public static Double extractPrice(String text) {
        if (text == null) return null;
        String t = text.toLowerCase().replaceAll(",", ".").trim();

        Pattern pRange = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*(?:-|đến|toi)\\s*(\\d+(?:\\.\\d+)?)\\s*(?:tr|triệu|trieu|củ|cu|m)\\b");
        Matcher mRange = pRange.matcher(t);
        if (mRange.find()) {
            try {
                double low = Double.parseDouble(mRange.group(1));
                double high = Double.parseDouble(mRange.group(2));
                return ((low + high) / 2.0) * 1_000_000.0;
            } catch (Exception ignored) {}
        }

        Pattern p1 = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*(?:tr|triệu|trieu|m|củ|cu)\\b");
        Matcher m1 = p1.matcher(t);
        if (m1.find()) {
            try {
                double val = Double.parseDouble(m1.group(1));
                return val * 1_000_000.0;
            } catch (Exception ignored) {}
        }

        Pattern p2 = Pattern.compile("(\\d+)tr(\\d+)\\b");
        Matcher m2 = p2.matcher(t);
        if (m2.find()) {
            try {
                double whole = Double.parseDouble(m2.group(1));
                double fraction = Double.parseDouble(m2.group(2));
                return (whole * 1_000_000.0) + (fraction * 100_000.0);
            } catch (Exception ignored) {}
        }

        Pattern p3 = Pattern.compile("\\b(\\d{7,10})\\b");
        Matcher m3 = p3.matcher(t.replaceAll("\\.", ""));
        if (m3.find()) {
            try {
                return Double.parseDouble(m3.group(1));
            } catch (Exception ignored) {}
        }

        return null;
    }

    public static List<String> extractTokens(String text) {
        ParsedIntent pi = parseQuery(text);
        return pi.cleanTokens;
    }

    public static ParsedIntent parseQuery(String text) {
        ParsedIntent pi = new ParsedIntent();
        if (text == null) return pi;
        pi.originalText = text;

        String lower = text.toLowerCase()
                .replaceAll("[,.?!;:]", " ")
                .replaceAll("\\s+", " ")
                .trim();

        pi.targetPrice = extractPrice(text);

        if (lower.matches(".*\\b(amd|ryzen|radeon|am4|am5|x3d)\\b.*")) {
            pi.brand = "AMD";
        } else if (lower.matches(".*\\b(intel|core i3|core i5|core i7|core i9|ultra|xeon)\\b.*")
                || lower.matches(".*\\b(i3|i5|i7|i9)\\b.*")) {
            pi.brand = "INTEL";
        }

        Pattern pGpu = Pattern.compile("\\b(5090|5080|5070|5060|4090|4080|4070|4060|3060|3050|1660|1650|7700)\\b");
        Matcher mGpu = pGpu.matcher(lower);
        if (mGpu.find()) {
            pi.gpu = mGpu.group(1);
        }

        boolean hasGamingKeywords = containsAny(lower, "gaming", "gmaing", "geming", "game", "chơi game", "chiến game", "game thủ", "esport", "fps", "3a", "aaa", "2k", "4k", "wukong", "cyberpunk", "cs2", "valorant", "pubg", "bắn súng", "đột kích", "lol", "liên minh", "fo4");
        if (hasGamingKeywords) {
            pi.isGaming = true;
            pi.excludeOffice = true;
        }

        if (lower.contains("văn phòng") && (
                containsAny(lower, "sao lại", "không phải", "không lấy", "đừng", "bỏ", "chứ không", "không cần", "ai bảo", "đâu phải", "chán", "nhầm")
                || pi.isGaming
        )) {
            pi.excludeOffice = true;
        }

        if (containsAny(lower, "valorant", "cs2", "csgo", "lol", "liên minh", "fo4", "fifa", "cf", "đột kích", "esport", "fps", "pubg", "bắn súng")) {
            pi.purpose = "GAMING_ESPORT";
        } else if (containsAny(lower, "black myth", "wukong", "gta", "cyberpunk", "genshin", "elden ring", "aaa", "3a", "game nặng", "2k", "4k")) {
            pi.purpose = "GAMING_AAA";
        } else if (containsAny(lower, "đồ họa", "render", "premiere", "photoshop", "autocad", "blender", "edit video", "3d", "dựng phim", "kiến trúc")) {
            pi.purpose = "GRAPHICS";
        } else if (!pi.excludeOffice && containsAny(lower, "văn phòng", "học tập", "kế toán", "word", "excel", "sinh viên", "zoom", "lướt web")) {
            pi.purpose = "OFFICE";
        } else if (containsAny(lower, "workstation", "server", "máy chủ", "deep learning", "ảo hóa", "chạy nox", "giả lập")) {
            pi.purpose = "WORKSTATION";
        }

        pi.isComponent = containsAny(lower, "vga", "card màn hình", "ram", "ssd", "ổ cứng", "mainboard", "bo mạch chủ", "nguồn máy tính", "psu");

        Set<String> stopWords = new HashSet<String>(Arrays.asList(
                "pc", "máy", "tính", "bộ", "cây", "case", "thùng", "dàn", "chiếc",
                "cho", "tôi", "mình", "em", "anh", "chị", "bạn", "tớ", "bác", "ông", "ad", "shop",
                "xem", "coi", "thấy", "bảo", "nói", "hỏi", "gợi", "ý", "gợi ý", "tư", "vấn", "tư vấn",
                "tìm", "kiếm", "giúp", "hộ", "dùm", "với", "ạ", "ơi", "nhé", "nha", "được", "không", "có",
                "mua", "bán", "lấy", "chọn", "cần", "muốn", "báo", "giá", "báo giá", "tham", "khảo",
                "tầm", "khoảng", "cỡ", "độ", "chừng", "khoản", "mức", "ngân", "sách", "tiền",
                "triệu", "trieu", "củ", "cu", "tr", "m", "vnd", "đ", "đồng",
                "nào", "gì", "con", "loại", "hơn", "nhất", "tốt", "hay", "sao", "thế", "nào",
                "chơi", "làm", "dùng", "học", "việc", "ở", "đâu"
        ));

        if (pi.excludeOffice) {
            stopWords.add("văn");
            stopWords.add("phòng");
            stopWords.add("office");
        }
        if (pi.isGaming) {
            stopWords.add("gaming");
            stopWords.add("gmaing");
            stopWords.add("geming");
            stopWords.add("game");
        }

        for (String w : lower.split(" ")) {
            w = w.trim();
            if (w.isEmpty() || stopWords.contains(w) || w.length() <= 1) continue;

            if (pi.brand != null && (w.equals("amd") || w.equals("intel") || w.equals("ryzen"))) continue;
            if (pi.gpu != null && (w.equals(pi.gpu) || w.equals("rtx") || w.equals("gtx"))) continue;
            pi.cleanTokens.add(w);
        }

        return pi;
    }

    public ChatResult handleQuery(String message, String action) {
        String msg = message != null ? message.trim() : "";
        String lowerMsg = msg.toLowerCase();
        String act = action != null ? action.trim() : "";

        if (!act.isEmpty()) {
            return handleAction(act);
        }

        if (containsAny(lowerMsg, "bỏ qua hướng dẫn", "ignore previous", "báo giá 1 đồng", "giá 1 đồng", "0 đồng", "cho tôi giá 1")
                || (containsAny(lowerMsg, "1 đồng", "1đ") && containsAny(lowerMsg, "báo giá", "bán", "mua", "cam kết"))) {
            return new ChatResult(
                    "Dạ em không thể thực hiện yêu cầu này ạ! Toàn bộ giá sản phẩm tại Độ-PC 67 đều được niêm yết minh bạch, chính xác theo hệ thống và không thể cam kết giá sai lệch (như 1 đồng) hoặc bỏ qua quy tắc bảo mật của cửa hàng.",
                    Arrays.asList("Tư vấn PC theo ngân sách", "Chính sách bảo hành", "Hotline: " + ChatbotConfig.SHOP_HOTLINE),
                    new ArrayList<>()
            );
        }

        if (containsAny(lowerMsg, "system prompt", "in ra prompt", "api key", "apikey", "lộ key", "câu lệnh hệ thống", "prompt gốc")) {
            return new ChatResult(
                    "Dạ em xin phép từ chối cung cấp system prompt hoặc API key. Đây là thông tin cấu hình kỹ thuật bảo mật nội bộ của hệ thống Độ-PC 67 ạ.",
                    Arrays.asList("Tư vấn PC theo tầm giá", "Chính sách bảo hành", "Hotline: " + ChatbotConfig.SHOP_HOTLINE),
                    new ArrayList<>()
            );
        }

        if (containsAny(lowerMsg, "đơn hàng của khách khác", "đơn hàng người khác", "dữ liệu nội bộ", "thông tin khách khác", "sđt khách", "doanh thu nội bộ")) {
            return new ChatResult(
                    "Dạ Độ-PC 67 cam kết bảo mật tuyệt đối 100% dữ liệu của khách hàng. Em không thể cung cấp thông tin đơn hàng, số điện thoại hay dữ liệu cá nhân của khách hàng khác ạ.",
                    Arrays.asList("Chính sách bảo mật", "Tư vấn cấu hình PC", "Hotline: " + ChatbotConfig.SHOP_HOTLINE),
                    new ArrayList<>()
            );
        }

        if (lowerMsg.matches("^(hi|hello|chào|alo|xin chào|shop ơi|ad ơi|có ai không|hey).*")
                || containsAny(lowerMsg, "bạn là ai", "bạn tên gì", "giới thiệu bản thân", "gemini thu nhỏ", "trợ lý ai")) {
            return handleGreeting(lowerMsg);
        }

        ChatResult mathRes = handleMathAndCalculation(lowerMsg);
        if (mathRes != null) {
            return mathRes;
        }

        ChatResult itRes = handleITAndProgramming(lowerMsg);
        if (itRes != null) {
            return itRes;
        }

        ChatResult hardwareRes = handleTechnicalExplanation(lowerMsg);
        if (hardwareRes != null) {
            return hardwareRes;
        }

        ChatResult lifestyleRes = handleLifestyleAndAdvice(lowerMsg);
        if (lifestyleRes != null) {
            return lifestyleRes;
        }

        ChatResult policyRes = handleStorePolicies(lowerMsg);
        if (policyRes != null) {
            return policyRes;
        }

        ParsedIntent intent = parseQuery(msg);
        ChatResult pcRes = handlePCConsultation(intent, lowerMsg);
        if (pcRes != null) {
            return pcRes;
        }

        return handleOpenEndedMiniGemini(msg, lowerMsg);
    }

    private ChatResult handlePCConsultation(ParsedIntent intent, String lowerMsg) {

        if (intent.brand != null) {
            return handleBrandSpecificPC(intent);
        }

        if (intent.gpu != null) {
            return handleGPUSpecificPC(intent);
        }

        if (intent.targetPrice != null) {
            return handlePriceSpecificPC(intent);
        }

        if (intent.purpose != null) {
            return handlePurposeSpecificPC(intent);
        }

        if (intent.isComponent || !intent.cleanTokens.isEmpty()) {
            List<Product> list = productDao.searchAdvancedForChatbot(null, null, intent.cleanTokens, null, null, null, !intent.isComponent, 4);
            if (!list.isEmpty()) {
                String kw = String.join(" ", intent.cleanTokens).toUpperCase();
                return new ChatResult(
                        "Dạ shop tìm thấy các sản phẩm phù hợp với từ khóa **" + kw + "** hiện đang sẵn hàng tại cửa hàng:\n\n" +
                        "• Sản phẩm chính hãng 100%, bảo hành 12 - 36 tháng đầy đủ tem mác nhà phân phối.\n" +
                        "• Bạn tham khảo chi tiết cấu hình và giá bên dưới nhé:",
                        Arrays.asList("Tư vấn cấu hình theo tầm giá", "Chính sách bảo hành", "Gặp tư vấn viên"),
                        list
                );
            }
        }

        return null;
    }

    private ChatResult handleBrandSpecificPC(ParsedIntent intent) {
        String brand = intent.brand;
        Double targetPrice = intent.targetPrice;

        List<Product> products = productDao.searchAdvancedForChatbot(
                brand,
                intent.gpu,
                intent.cleanTokens.isEmpty() ? null : intent.cleanTokens,
                targetPrice,
                targetPrice != null ? targetPrice * 0.70 : null,
                targetPrice != null ? targetPrice * 1.30 : null,
                true,
                intent.isGaming,
                intent.excludeOffice,
                4
        );

        if (products.isEmpty() && targetPrice != null) {
            products = productDao.searchAdvancedForChatbot(
                    brand,
                    null,
                    null,
                    targetPrice,
                    null,
                    null,
                    true,
                    intent.isGaming,
                    intent.excludeOffice,
                    4
            );
        }

        if (products.isEmpty()) {
            products = productDao.searchAdvancedForChatbot(brand, null, null, null, null, null, true, intent.isGaming, intent.excludeOffice, 4);
        }

        if ("AMD".equals(brand)) {
            StringBuilder sb = new StringBuilder();
            String raw = intent.originalText != null ? intent.originalText.toLowerCase() : "";
            boolean isCorrection = raw.contains("sao lại") || raw.contains("văn phòng");

            if (isCorrection) {
                sb.append("Dạ shop vô cùng xin lỗi anh/chị về sự nhầm lẫn vừa rồi ạ! 🙏\n\n")
                  .append("Để phục vụ chuẩn xác nhu cầu **chiến game với cỗ máy AMD Gaming chuyên nghiệp**, shop Độ-PC 67 xin gửi tới anh/chị các bộ máy PC Gaming chạy chip AMD Ryzen gắn Card đồ họa rời (VGA) mạnh mẽ đang sẵn hàng tại showroom:\n\n");
            } else if (intent.isGaming) {
                if (targetPrice != null) {
                    sb.append("Dạ với mức ngân sách khoảng **").append(df.format(targetPrice)).append("** cho cỗ máy **PC AMD Gaming**, shop xin gợi ý các bộ máy gaming tối ưu hiệu năng và đáng mua nhất:\n\n");
                } else {
                    sb.append("Dạ với nhu cầu chọn cỗ máy **PC AMD Gaming chuyên dụng**, shop xin gợi ý các cấu hình gaming đỉnh cao hàng đầu tại Độ-PC 67:\n\n");
                }
            } else if (targetPrice != null) {
                sb.append("Dạ với mức ngân sách khoảng **").append(df.format(targetPrice)).append("** ")
                  .append("cho cấu hình chạy chip **AMD Ryzen**, shop gợi ý cho bạn các bộ máy tối ưu hiệu năng và đáng mua nhất hiện có:\n\n");
            } else {
                sb.append("Dạ với nhu cầu chọn cỗ máy chạy nền tảng **AMD Ryzen**, shop xin gợi ý các cấu hình tối ưu hàng đầu tại Độ-PC 67:\n\n");
            }

            sb.append("🔥 **Điểm mạnh vượt trội của dàn PC AMD Ryzen Gaming:**\n")
              .append("• **Hiệu năng & Tối ưu điện:** Kiến trúc Zen 4 / Zen 5 tiến trình TSMC tiên tiến, nhiệt độ vận hành cực mát mẻ và tiết kiệm điện năng.\n")
              .append("• **Khả năng nâng cấp dài lâu:** Nền tảng Socket AM5 được AMD cam kết hỗ trợ tối thiểu đến năm 2027+, bạn dễ dàng nâng cấp CPU đời sau mà không cần thay bo mạch chủ.\n")
              .append("• **Bộ nhớ đệm 3D V-Cache (Dòng X3D):** Mang lại mức FPS cực đỉnh trong các tựa game Esport và game thế giới mở AAA.\n\n")
              .append("Toàn bộ máy đều là hàng mới chính hãng 100%, bảo hành 36 tháng, 1 đổi 1 trong 30 ngày, tặng kèm gói vệ sinh và cài Win trọn đời máy!\n\n")
              .append("Bạn xem chi tiết các cấu hình AMD Gaming bên dưới nhé:");

            return new ChatResult(
                    sb.toString(),
                    Arrays.asList("So sánh AMD và Intel", "Cấu hình AMD dưới 25tr", "Cấu hình AMD trên 30tr", "Gặp tư vấn viên"),
                    products
            );
        } else {

            StringBuilder sb = new StringBuilder();
            if (targetPrice != null) {
                sb.append("Dạ với tầm giá khoảng **").append(df.format(targetPrice)).append("** ")
                  .append("cho cấu hình chạy chip **Intel Core**, shop gợi ý cho bạn các bộ máy chuẩn hiệu năng nhất:\n\n");
            } else {
                sb.append("Dạ với dòng máy tính chạy chip **Intel Core**, shop xin giới thiệu các cấu hình tiêu biểu sẵn có tại cửa hàng:\n\n");
            }

            sb.append("⚡ **Điểm mạnh của dàn PC Intel Core:**\n")
              .append("• **Tương thích hoàn hảo:** Xung nhịp đơn nhân cao, tương thích cực tốt với các phần mềm đồ họa kỹ thuật (Adobe Premiere, Photoshop, AutoCAD, 3ds Max nhờ công nghệ Intel QuickSync).\n")
              .append("• **Kiến trúc Hybrid:** Kết hợp nhân hiệu năng cao (P-core) và nhân tiết kiệm điện (E-core) giúp đa nhiệm mượt mà không bị nghẽn.\n\n")
              .append("Bạn tham khảo cấu hình và mức giá chi tiết các bộ máy Intel bên dưới nhé:");

            return new ChatResult(
                    sb.toString(),
                    Arrays.asList("Cấu hình Intel 15-20tr", "Cấu hình Intel trên 25tr", "So sánh Intel và AMD", "Hotline shop"),
                    products
            );
        }
    }

    private ChatResult handleGPUSpecificPC(ParsedIntent intent) {
        String gpu = intent.gpu;
        Double targetPrice = intent.targetPrice;

        List<Product> products = productDao.searchAdvancedForChatbot(
                intent.brand,
                gpu,
                null,
                targetPrice,
                null,
                null,
                true,
                4
        );

        if (!products.isEmpty()) {
            StringBuilder sb = new StringBuilder();
            sb.append("Dạ shop tìm thấy các cấu hình PC nguyên bộ trang bị card đồ họa **RTX ").append(gpu).append("** có sẵn tại cửa hàng:\n\n");

            if ("5060".equals(gpu) || "5070".equals(gpu) || "5080".equals(gpu) || "5090".equals(gpu)) {
                sb.append("🚀 **Thế hệ Card đồ họa NVIDIA RTX 50 Series hoàn toàn mới:**\n")
                  .append("• Kiến trúc Blackwell đỉnh cao, bộ nhớ GDDR7 tốc độ băng thông vượt bậc.\n")
                  .append("• Công nghệ DLSS 4 / Multi-Frame Generation đột phá giúp tăng gấp đôi khung hình FPS khi chơi game độ phân giải 2K, 4K.\n")
                  .append("• Tối ưu vượt trội cho các tác vụ AI tạo sinh, Render 3D và dựng video chất lượng cao.\n\n");
            }

            Product cheapest = products.get(0);
            if (targetPrice != null && targetPrice < (cheapest.getPrice() * 0.85)) {
                sb.append("💡 *Lưu ý nhỏ về mức giá:* Cấu hình trang bị RTX ").append(gpu)
                  .append(" hiện có giá khởi điểm từ **").append(df.format(cheapest.getPrice())).append("**.\n")
                  .append("Với ngân sách **").append(df.format(targetPrice)).append("** của bạn, bạn có thể tham khảo thêm các dòng RTX 4060 hoặc RTX 3050 cũng cực kỳ mượt mà nhé!\n\n");
            }

            sb.append("Bạn tham khảo cấu hình chi tiết từng bộ bên dưới:");
            return new ChatResult(
                    sb.toString(),
                    Arrays.asList("Cấu hình RTX 4060", "Chính sách bảo hành", "Hướng dẫn trả góp 0%"),
                    products
            );
        } else {

            return new ChatResult(
                    "Dạ hiện tại shop **chưa có sẵn** cấu hình PC sẵn hàng trang bị mã card **RTX " + gpu + "** trong kho sẵn.\n\n" +
                    "• Cửa hàng hiện đang sẵn các dòng PC Gaming trang bị card thế hệ mới: **RTX 3050, RTX 4060, RTX 4060 Ti, RTX 4070, RTX 5060, RTX 5070, RTX 5080, RTX 5090**.\n" +
                    "• Độ-PC 67 có nhận đặt hàng linh kiện và lắp ráp cấu hình theo yêu cầu riêng của bạn.\n\n" +
                    "Bạn có thể nhắn tin Zalo hoặc gọi Hotline **" + ChatbotConfig.SHOP_HOTLINE + "** để nhân viên báo giá cấu hình theo ý thích nhé!",
                    Arrays.asList("Xem PC Gaming sẵn có", "PC RTX 5060", "Hotline: " + ChatbotConfig.SHOP_HOTLINE),
                    productDao.searchAdvancedForChatbot(null, "5060", null, null, null, null, true, 3)
            );
        }
    }

    private ChatResult handlePriceSpecificPC(ParsedIntent intent) {
        Double targetPrice = intent.targetPrice;
        Product maxPC = productDao.getMostExpensivePC();
        Product minPC = productDao.getCheapestPC();

        if (maxPC != null && targetPrice > (maxPC.getPrice() * 1.15)) {
            List<Product> topList = new ArrayList<Product>();
            topList.add(maxPC);
            return new ChatResult(
                    "Dạ hiện tại bộ máy PC lắp sẵn cao cấp nhất trong kho của shop là bộ **" + maxPC.getName() +
                    "** với mức giá **" + df.format(maxPC.getPrice()) + "** ạ.\n\n" +
                    "🛠️ **Dịch vụ Build PC Custom Siêu Khủng theo yêu cầu:**\n" +
                    "Với mức ngân sách **" + df.format(targetPrice) + "**, **Độ-PC 67 nhận thiết kế cỗ máy Master Custom đỉnh cao**:\n" +
                    "• Tản nhiệt nước Custom toàn bộ hệ thống (ống đồng, ống thủy tinh nguyên khối, Block tản nước mạ niken).\n" +
                    "• Chạy kép card đồ họa RTX 5090 / RTX 4090 24GB - 32GB VRAM phục vụ huấn luyện mô hình AI hoặc Render kiến trúc siêu nặng.\n" +
                    "• Bo mạch chủ dòng Creator / Workstation tản nhiệt VRM cao cấp.\n\n" +
                    "Bạn liên hệ trực tiếp Hotline/Zalo **" + ChatbotConfig.SHOP_HOTLINE + "** để kỹ thuật trưởng lên sơ đồ thiết kế và báo giá chi tiết nhé!",
                    Arrays.asList("Xem bộ máy cao cấp nhất", "Build PC theo yêu cầu", "Hotline: " + ChatbotConfig.SHOP_HOTLINE),
                    topList
            );
        }

        if (minPC != null && targetPrice < (minPC.getPrice() * 0.8)) {
            List<Product> minList = new ArrayList<Product>();
            minList.add(minPC);
            return new ChatResult(
                    "Dạ hiện tại shop **không có sẵn** bộ PC nguyên bộ ở mức giá **" + df.format(targetPrice) + "** ạ.\n\n" +
                    "• Bộ máy PC có giá tốt nhất hiện tại của shop là **" + minPC.getName() + "** với mức giá chỉ **" + df.format(minPC.getPrice()) + "** (hàng mới 100%, bảo hành chính hãng 36 tháng).\n\n" +
                    "Shop khuyên bạn nên cân nhắc mức ngân sách từ **5 - 6 triệu** trở lên để sở hữu máy mới linh kiện chính hãng dùng bền bỉ, mượt mà và không lo hỏng vặt nhé!",
                    Arrays.asList("Xem bộ máy giá rẻ nhất", "Tư vấn cấu hình dưới 10tr", "Gặp tư vấn viên"),
                    minList
            );
        }

        List<Product> list = productDao.searchAdvancedForChatbot(
                null,
                null,
                intent.cleanTokens.isEmpty() ? null : intent.cleanTokens,
                targetPrice,
                targetPrice * 0.70,
                targetPrice * 1.30,
                true,
                4
        );

        if (list.isEmpty()) {
            list = productDao.searchAdvancedForChatbot(null, null, null, targetPrice, targetPrice * 0.60, targetPrice * 1.40, true, 4);
        }

        if (!list.isEmpty()) {
            StringBuilder sb = new StringBuilder();
            String rawText = intent.originalText != null ? intent.originalText.toLowerCase() : "";
            boolean isGamingHighEnd = intent.purpose != null || containsAny(rawText, "2k", "4k", "3a", "aaa", "fps", "wukong", "cyberpunk", "cs2", "valorant");

            if (isGamingHighEnd) {
                sb.append("Dạ với mức ngân sách khoảng **").append(df.format(targetPrice)).append("** phục vụ nhu cầu chiến **Game AAA ở độ phân giải 2K và Game FPS**, shop xin phân tích chi tiết cấu hình tối ưu hiệu năng nhất cho bạn:\n\n")
                  .append("🛠️ **Phân tích kỹ thuật từ chuyên viên:**\n")
                  .append("• **Card đồ họa (VGA):** Đóng vai trò then chốt khi chơi game 2K. Tầm tiền này tối ưu nhất là **NVIDIA RTX 4070 Super 12GB GDDR6X** (hỗ trợ DLSS 3.5 Frame Generation, Ray Tracing, bộ nhớ 12GB VRAM không lo tràn texture ở 1440p).\n")
                  .append("• **CPU & RAM:** Ghép cặp cùng **AMD Ryzen 5 7500F (Socket AM5)** hoặc **Intel Core i5-13400F/14400F**, đi kèm **32GB RAM DDR5** Dual Channel để vừa gánh mượt game 3A, vừa kéo FPS game bắn súng (CS2, Valorant) trên 280-350+ FPS mà không bị tụt min FPS trong combat.\n")
                  .append("• **Ổ cứng & Nguồn:** SSD NVMe PCIe 4.0 1TB tốc độ cao nạp game tức thì, kết hợp Nguồn công suất thực 750W chuẩn 80 Plus chuẩn chỉnh an tâm tuyệt đối.\n\n")
                  .append("Shop gửi bạn các bộ máy có cấu hình và tầm giá sát nhất đang sẵn hàng tại showroom để bạn tham khảo nhé:");
            } else {
                sb.append("Dạ với mức ngân sách khoảng **").append(df.format(targetPrice)).append("**, shop xin gợi ý các bộ máy PC nguyên bộ tối ưu hiệu năng và đáng mua nhất cho bạn:\n\n")
                  .append("• Toàn bộ linh kiện đều là hàng mới chính hãng 100%, bảo hành từ 12 đến 36 tháng.\n")
                  .append("• Hỗ trợ trả góp 0%, miễn phí công lắp ráp, cài Win trọn đời và giao hàng COD toàn quốc cho kiểm tra máy trước khi thanh toán.\n\n")
                  .append("Bạn bấm vào từng bộ máy bên dưới để xem chi tiết cấu hình linh kiện nhé:");
            }

            return new ChatResult(
                    sb.toString(),
                    Arrays.asList("Tư vấn cấu hình khác", "Chính sách bảo hành", "Hướng dẫn trả góp 0%", "Hotline: " + ChatbotConfig.SHOP_HOTLINE),
                    list
            );
        } else {
            return new ChatResult(
                    "Dạ hiện tại shop chưa có sẵn bộ PC ở mức giá đúng **" + df.format(targetPrice) + "** trong kho.\n\n" +
                    "Tuy nhiên shop có hỗ trợ lắp ráp và cân đối linh kiện theo đúng số tiền của bạn. Bạn vui lòng liên hệ Hotline/Zalo **" + ChatbotConfig.SHOP_HOTLINE + "** để nhân viên lên cấu hình riêng cho bạn nhé!",
                    Arrays.asList("Tư vấn cấu hình 10-15tr", "Cấu hình 15-25tr", "Hotline shop"),
                    productDao.searchAdvancedForChatbot(null, null, null, null, null, null, true, 3)
            );
        }
    }

    private ChatResult handlePurposeSpecificPC(ParsedIntent intent) {
        String p = intent.purpose;
        if ("GAMING_ESPORT".equals(p)) {
            List<Product> list = productDao.searchAdvancedForChatbot(null, null, Arrays.asList("Gaming"), 18000000.0, 14000000.0, 26000000.0, true, 3);
            return new ChatResult(
                    "🎮 **Tư vấn PC Chiến Game Esport (Valorant, LOL, CS2, FO4, Đột Kích):**\n\n" +
                    "Để đạt mức khung hình mượt mà 144Hz - 240Hz không lo drop FPS trong combat tổng:\n" +
                    "• **CPU:** Intel Core i5-12400F / 13400F hoặc AMD Ryzen 5 5600 / Ryzen 5 7500F (Xung nhịp cao, tối ưu game bắn súng).\n" +
                    "• **RAM:** Tối thiểu 16GB Dual-Channel Bus 3200MHz - 5600MHz giúp tăng 20% FPS so với cắm 1 thanh.\n" +
                    "• **VGA:** RTX 3050 6GB, RTX 4060 8GB hoặc RTX 5060 8GB.\n" +
                    "• **Ổ cứng:** SSD NVMe 512GB load bản đồ trong tích tắc.\n\n" +
                    "Shop gửi bạn một số cấu hình Esport bán chạy nhất tại shop:",
                    Arrays.asList("Cấu hình 10 - 15 triệu", "Cấu hình 15 - 25 triệu", "Bảo hành 1 đổi 1"),
                    list
            );
        } else if ("GAMING_AAA".equals(p)) {
            List<Product> list = productDao.searchAdvancedForChatbot(null, null, null, 35000000.0, 22000000.0, 60000000.0, true, 3);
            return new ChatResult(
                    "🔥 **Tư vấn PC Chiến Game Đồ Họa Nặng & Thế Giới Mở AAA (Black Myth: Wukong, Cyberpunk 2077, GTA V, Elden Ring):**\n\n" +
                    "Các tựa game AAA thế hệ mới đòi hỏi card đồ họa VRAM dồi dào và CPU khỏe:\n" +
                    "• **CPU:** Intel Core i5 14400F / i7 14700F hoặc AMD Ryzen 7 7700 / Ryzen 7 7800X3D (Vua chơi game).\n" +
                    "• **VGA:** Tối thiểu RTX 4060 8GB, tối ưu nhất là RTX 4070 12GB hoặc RTX 5070 / RTX 5080.\n" +
                    "• **RAM:** 32GB (DDR5) để tránh hiện tượng tràn bộ nhớ khi bật Ray Tracing và Textures Ultra.\n" +
                    "• **Nguồn:** 650W - 850W chuẩn 80 Plus Bronze/Gold đảm bảo cấp điện ổn định.\n\n" +
                    "Dưới đây là các cỗ máy chiến AAA đỉnh cao đang sẵn tại shop:",
                    Arrays.asList("Cấu hình trên 25 triệu", "Hỗ trợ trả góp 0%", "Lắp ráp theo yêu cầu"),
                    list
            );
        } else if ("GRAPHICS".equals(p)) {
            List<Product> list = productDao.searchAdvancedForChatbot(null, null, Arrays.asList("Workstation"), null, null, null, true, 3);
            if (list.isEmpty()) {
                list = productDao.searchAdvancedForChatbot(null, null, null, 30000000.0, 20000000.0, null, true, 3);
            }
            return new ChatResult(
                    "🎨 **Tư vấn PC Chuyên Thiết Kế Đồ Họa, Render 3D & Dựng Phim (Photoshop, Premiere, AutoCAD, Blender, 3ds Max):**\n\n" +
                    "Công việc đồ họa cần sự bền bỉ, CPU nhiều nhân luồng và RAM dung lượng lớn:\n" +
                    "• **CPU:** Intel Core i5-14600KF / i7-14700 hoặc AMD Ryzen 7 7700X / Ryzen 9.\n" +
                    "• **RAM:** Tối thiểu 32GB Dual Channel (DDR4/DDR5) giúp render nhiều timeline và layer không bị văng ứng dụng.\n" +
                    "• **VGA:** RTX 3060 12GB (VRAM nhiều rất lợi khi làm Premiere/After Effects) hoặc RTX 4060 Ti / RTX 4070 12GB.\n" +
                    "• **Ổ cứng:** SSD NVMe 1TB Gen 4 tốc độ đọc ghi > 5000MB/s để load footage 4K mượt mà.\n" +
                    "• **Tản nhiệt:** Tản khí tháp đôi hoặc Tản nhiệt nước AIO 240/360 để render liên tục mát mẻ.\n\n" +
                    "Các cấu hình đồ họa chuyên nghiệp sẵn hàng:",
                    Arrays.asList("Cấu hình Workstation", "Hỗ trợ xuất VAT", "Nâng cấp RAM 32GB/64GB"),
                    list
            );
        } else if ("OFFICE".equals(p)) {
            List<Product> list = productDao.searchAdvancedForChatbot(null, null, Arrays.asList("Văn Phòng"), null, null, 15000000.0, true, 3);
            return new ChatResult(
                    "💼 **Tư vấn PC Văn Phòng, Kế Toán & Học Tập Bền Bỉ, Tiết Kiệm Điện:**\n\n" +
                    "Với tác vụ công sở (Word, Excel, MISA, Photoshop cơ bản, lướt web mở hàng chục tab Chrome):\n" +
                    "• **CPU:** Intel Core i3-12100 / i5-12400 hoặc AMD Ryzen 5 5600G / 8600G (tích hợp nhân đồ họa mạnh mẽ).\n" +
                    "• **RAM:** 8GB - 16GB đa nhiệm thoải mái không sợ giật lag.\n" +
                    "• **SSD:** 256GB - 512GB NVMe khởi động Windows chỉ 5 giây.\n" +
                    "• Thiết kế case nhỏ gọn, hoạt động siêu êm, tiết kiệm điện năng tối đa.\n" +
                    "• Giá trọn bộ chỉ từ **5.990.000 đ**!\n\n" +
                    "Shop gửi bạn một số mẫu máy văn phòng bán chạy nhất:",
                    Arrays.asList("Dưới 10 triệu", "Chính sách bảo hành 36 tháng", "Giao hàng tận nơi"),
                    list
            );
        } else if ("WORKSTATION".equals(p)) {
            List<Product> list = productDao.searchAdvancedForChatbot(null, null, Arrays.asList("Workstation"), null, null, null, true, 3);
            return new ChatResult(
                    "🏢 **Cấu hình PC Workstation & Máy Chủ Giả Lập Đỉnh Cao:**\n\n" +
                    "• Chuyên dụng cho kiến trúc sư, kỹ sư kết cấu, đào tạo mô hình Deep Learning hoặc chạy nhiều máy ảo VMware/NoxPlayer.\n" +
                    "• Sử dụng CPU Intel Xeon / Core Ultra / AMD Ryzen 9 với bộ nhớ ECC hoặc RAM DDR5 lên đến 64GB - 128GB.\n" +
                    "• Card đồ họa chuyên nghiệp NVIDIA RTX series hoặc RTX Workstation (Ada Lovelace) mang lại độ ổn định tuyệt đối.\n\n" +
                    "Các cấu hình Workstation sẵn có tại shop:",
                    Arrays.asList("Workstation cao cấp", "Tư vấn cấu hình theo yêu cầu", "Hotline shop"),
                    list
            );
        }
        return null;
    }

    private ChatResult handleMathAndCalculation(String msg) {

        Pattern pGop = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*(?:tr|triệu|trieu|củ|m)?\\s*(?:trả góp|góp|vay)\\s*(\\d+)\\s*(?:tháng|t)\\b");
        Matcher mGop = pGop.matcher(msg);
        if (mGop.find()) {
            try {
                double amount = Double.parseDouble(mGop.group(1));
                if (amount < 1000) amount = amount * 1_000_000.0;
                int months = Integer.parseInt(mGop.group(2));
                if (months > 0 && months <= 36) {
                    double monthly = amount / months;
                    return new ChatResult(
                            "💳 **BẢNG TÍNH THAM KHẢO TRẢ GÓP 0% TẠI ĐỘ-PC 67:**\n\n" +
                            "• **Tổng số tiền:** " + df.format(amount) + "\n" +
                            "• **Kỳ hạn góp:** " + months + " tháng\n" +
                            "• **Số tiền gốc ước tính mỗi tháng:** khoảng **" + df.format(monthly) + "/tháng**\n\n" +
                            "👉 Khi làm thủ tục trả góp qua **Thẻ tín dụng (Credit Card)**, bạn được hưởng lãi suất 0% hoàn toàn!\n" +
                            "👉 Nếu trả góp qua **CCCD gắn chip**, duyệt hồ sơ online trong 15 phút, trả trước từ 10 - 20%.\n\n" +
                            "Bạn liên hệ Hotline/Zalo **" + ChatbotConfig.SHOP_HOTLINE + "** để nhân viên tính bảng chi tiết theo từng ngân hàng nhé!",
                            Arrays.asList("Hướng dẫn mua trả góp", "Tư vấn cấu hình PC", "Hotline: " + ChatbotConfig.SHOP_HOTLINE),
                            null
                    );
                }
            } catch (Exception ignored) {}
        }

        Pattern pMath = Pattern.compile("(?:tính|bằng bao nhiêu|kq)?\\s*(\\d+(?:\\.\\d+)?)\\s*([+\\-*/xX:])\\s*(\\d+(?:\\.\\d+)?)\\s*(?:=|bằng|la)?");
        Matcher mMath = pMath.matcher(msg);
        if (mMath.find()) {
            try {
                double n1 = Double.parseDouble(mMath.group(1));
                String op = mMath.group(2);
                double n2 = Double.parseDouble(mMath.group(3));
                double res = 0;
                boolean valid = true;

                if ("+".equals(op)) res = n1 + n2;
                else if ("-".equals(op)) res = n1 - n2;
                else if ("*".equals(op) || "x".equalsIgnoreCase(op)) res = n1 * n2;
                else if ("/".equals(op) || ":".equals(op)) {
                    if (n2 == 0) return new ChatResult("Dạ phép chia cho 0 không xác định được trong toán học ạ! 😊", null, null);
                    res = n1 / n2;
                } else valid = false;

                if (valid) {
                    DecimalFormat dfNum = new DecimalFormat("#,###.##");
                    return new ChatResult(
                            "🔢 **Kết quả phép tính:**\n\n" +
                            "$$" + dfNum.format(n1) + " " + op + " " + dfNum.format(n2) + " = " + dfNum.format(res) + "$$\n\n" +
                            "Em là trợ lý AI thông minh của shop Độ-PC 67, bạn cần tính toán thêm ngân sách hoặc cần tư vấn cấu hình máy tính cứ nhắn em nhé!",
                            Arrays.asList("Tư vấn cấu hình PC", "Tính trả góp", "Hotline shop"),
                            null
                    );
                }
            } catch (Exception ignored) {}
        }

        if (containsAny(msg, "1tb bằng bao nhiêu", "1tb là bao nhiêu", "1 tb bằng bao nhiêu")) {
            return new ChatResult(
                    "💡 **QUY ĐỔI DUNG LƯỢNG Ổ CỨNG & BỘ NHỚ:**\n\n" +
                    "• Trong khoa học máy tính (hệ nhị phân):\n" +
                    "  $$1 \\text{ TB} = 1.024 \\text{ GB} = 1.048.576 \\text{ MB} = 1.073.741.824 \\text{ KB}$$\n" +
                    "• Theo tiêu chuẩn thương mại của các hãng sản xuất ổ cứng (Western Digital, Samsung, Kingston):\n" +
                    "  $$1 \\text{ TB} = 1.000 \\text{ GB}$$\n" +
                    "👉 Do đó khi cắm ổ cứng 1TB vào Windows, bạn sẽ thấy dung lượng hiển thị thực tế khoảng **931 GB** (đây là điều hoàn toàn bình thường, không phải ổ bị thiếu dung lượng đâu bạn nhé)!",
                    Arrays.asList("Tư vấn SSD NVMe", "Cấu hình PC Gaming", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "1gb bằng bao nhiêu", "1 gb bằng bao nhiêu")) {
            return new ChatResult(
                    "💡 **QUY ĐỔI DUNG LƯỢNG:**\n\n" +
                    "• $$1 \\text{ GB (Gigabyte)} = 1.024 \\text{ MB (Megabyte)} = 1.048.576 \\text{ KB}$$\n" +
                    "• Ví dụ: 1 thanh RAM 16GB sẽ có khoảng **16.384 MB** bộ nhớ để lưu trữ dữ liệu tạm thời khi bạn làm việc và chơi game!",
                    Arrays.asList("Kiến thức về RAM", "Tư vấn cấu hình PC", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "1 inch bằng bao nhiêu", "inch sang cm")) {
            return new ChatResult(
                    "💡 **QUY ĐỔI KÍCH THƯỚC MÀN HÌNH (INCH SANG CM):**\n\n" +
                    "• $$1 \\text{ inch} = 2.54 \\text{ cm}$$\n" +
                    "• Kích thước màn hình máy tính phổ biến (đo theo đường chéo):\n" +
                    "  + **Màn hình 24 inch:** ~60.96 cm (khoảng cách ngồi chuẩn 50 - 60cm, rất thích hợp chơi game bắn súng CS2, Valorant).\n" +
                    "  + **Màn hình 27 inch:** ~68.58 cm (tiêu chuẩn vàng cho độ phân giải 2K, làm đồ họa và xem phim rất đã mắt).\n" +
                    "  + **Màn hình 32 inch:** ~81.28 cm (phù hợp độ phân giải 4K không gian làm việc rộng rãi).",
                    Arrays.asList("Tư vấn màn hình", "Cấu hình PC Gaming", "Hotline shop"),
                    null
            );
        }

        return null;
    }

    private ChatResult handleITAndProgramming(String msg) {

        if (containsAny(msg, "ai là gì", "trí tuệ nhân tạo là gì", "gemini hoạt động thế nào", "chatgpt hoạt động", "llm là gì")) {
            return new ChatResult(
                    "🤖 **GIẢI THÍCH: TRÍ TUỆ NHÂN TẠO (AI) & CÁCH HOẠT ĐỘNG CỦA MÔ HÌNH NGÔN NGỮ LỚN (LLM):**\n\n" +
                    "• **AI (Artificial Intelligence):** Là công nghệ mô phỏng lại quá trình học tập, suy nghĩ và giải quyết vấn đề của con người trên máy tính.\n" +
                    "• **Mô hình ngôn ngữ lớn (LLM như Gemini, ChatGPT):**\n" +
                    "  1. Được huấn luyện trên hàng tỷ tài liệu, sách báo và mã nguồn trên internet.\n" +
                    "  2. Sử dụng kiến trúc mạng nơ-ron **Transformer** để dự đoán từ tiếp theo có xác suất phù hợp nhất trong ngữ cảnh câu hỏi của bạn.\n" +
                    "  3. Nhờ đó, AI có thể trò chuyện tự nhiên, viết code, dịch thuật, tóm tắt bài giảng và tư vấn máy tính như em đang hỗ trợ bạn đây!\n\n" +
                    "👉 Để chạy các mô hình AI hoặc lập trình Machine Learning, bạn cần một dàn PC có card đồ họa RTX nhiều VRAM (từ 12GB - 24GB trở lên) để tính toán ma trận ma sát!",
                    Arrays.asList("Cấu hình PC chạy AI", "Học lập trình cần PC gì?", "Tư vấn cấu hình"),
                    null
            );
        }

        if (containsAny(msg, "học lập trình nên học gì", "mới học lập trình", "học ngôn ngữ nào", "python hay java", "nên học python")) {
            return new ChatResult(
                    "💻 **LỘ TRÌNH DÀNH CHO NGƯỜI MỚI BẮT ĐẦU HỌC LẬP TRÌNH (CODING):**\n\n" +
                    "Tùy vào mục tiêu tương lai của bạn, shop gợi ý:\n" +
                    "1. **Python (Khuyên dùng cho người mới):**\n" +
                    "   • Cú pháp cực kỳ ngắn gọn, dễ đọc như tiếng Anh.\n" +
                    "   • Phù hợp: Trí tuệ nhân tạo (AI/Data Science), viết tool tự động hóa, làm Backend.\n\n" +
                    "2. **JavaScript / TypeScript:**\n" +
                    "   • 'Vua' của thế giới Web (HTML, CSS, React, Vue, Node.js). Học xong dễ làm được sản phẩm web tương tác thực tế ngay.\n\n" +
                    "3. **Java hoặc C#:**\n" +
                    "   • Ngôn ngữ hướng đối tượng (OOP) kinh điển, chuẩn mực trong các tập đoàn lớn, ngân hàng và dự án quy mô lớn.\n\n" +
                    "4. **C / C++:**\n" +
                    "   • Rất tốt để hiểu sâu về quản lý bộ nhớ RAM, con trỏ và cấu trúc máy tính (rất cần cho sinh viên CNTT/Điện tử).\n\n" +
                    "👉 **Cấu hình máy tính học code:** Chỉ cần CPU Core i5 / Ryzen 5, RAM 16GB trở lên và ổ SSD NVMe là bạn mở mượt mà Visual Studio Code, IntelliJ, Docker hay máy ảo rồi!",
                    Arrays.asList("Tư vấn PC cho lập trình viên", "Cấu hình dưới 15 triệu", "Chính sách bảo hành"),
                    null
            );
        }

        if (containsAny(msg, "lập trình web", "frontend là gì", "backend là gì", "fullstack là gì")) {
            return new ChatResult(
                    "🌐 **TỔNG QUAN: PHÂN BIỆT FRONTEND, BACKEND & FULLSTACK TRONG LẬP TRÌNH WEB:**\n\n" +
                    "• **Frontend (Giao diện người dùng):**\n" +
                    "  + Là tất cả những gì bạn nhìn thấy và bấm vào trên trang web (màu sắc, nút bấm, thanh menu, hiệu ứng chatbox này).\n" +
                    "  + Công nghệ chính: HTML5, CSS3, JavaScript (kèm Framework như React, Next.js, Vue).\n\n" +
                    "• **Backend (Phần xử lý nghiệp vụ & Máy chủ):**\n" +
                    "  + Là 'bộ não' chạy ngầm phía server để xử lý logic, tính tiền giỏ hàng, xác thực tài khoản và lưu trữ vào cơ sở dữ liệu.\n" +
                    "  + Công nghệ chính: Java (Spring Boot / Servlet), Python (Django/FastAPI), Node.js, C# (.NET), PHP, cơ sở dữ liệu SQL Server, MySQL, MongoDB.\n\n" +
                    "• **Fullstack:**\n" +
                    "  + Lập trình viên có khả năng làm chủ cả hai mảng Frontend và Backend để tự tay xây dựng trọn vẹn một ứng dụng web từ A - Z!",
                    Arrays.asList("Học lập trình cần PC gì?", "Tư vấn cấu hình PC", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "github là gì", "git là gì", "tác dụng của github")) {
            return new ChatResult(
                    "💡 **GIT VÀ GITHUB LÀ GÌ? TẠI SAO DÂN IT BẮT BUỘC PHẢI DÙNG?**\n\n" +
                    "• **Git (Hệ thống quản lý phiên bản mã nguồn):**\n" +
                    "  + Giống như tính năng 'Save Game' của lập trình viên. Mỗi lần bạn sửa code, bạn có thể tạo một 'Commit' lưu lại lịch sử. Nếu lỡ làm code bị lỗi hỏng, bạn có thể quay ngược lại phiên bản cũ chỉ trong 1 giây mà không lo mất bài.\n\n" +
                    "• **GitHub:**\n" +
                    "  + Là một mạng xã hội / nền tảng đám mây để lưu trữ các kho mã nguồn Git.\n" +
                    "  + Giúp hàng chục kỹ sư cùng làm chung một dự án phần mềm trên khắp thế giới mà không bị đè code lên nhau.\n" +
                    "  + GitHub còn được xem là chiếc **CV sống** giá trị nhất của lập trình viên khi đi xin việc!",
                    Arrays.asList("Học lập trình nên học gì?", "Tư vấn PC học tập", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "pc cho dân it", "pc cho lập trình", "học cntt mua máy gì", "laptop hay pc học it", "cấu hình cho lập trình")) {
            return new ChatResult(
                    "💻 **TƯ VẤN CẤU HÌNH MÁY TÍNH CHUẨN DÀNH CHO DÂN IT & LẬP TRÌNH VIÊN:**\n\n" +
                    "Đặc thù của dân công nghệ thông tin là chạy nhiều môi trường cùng lúc (VS Code, IntelliJ IDEA, Docker container, máy ảo Android Emulator, mở 50 tab StackOverflow & tài liệu):\n\n" +
                    "• **RAM (Quan trọng nhất):** Tối thiểu **16GB**, khuyến nghị **32GB DDR4/DDR5**. RAM càng nhiều bạn mở máy ảo và chạy build code càng mượt mà không bị treo đơ.\n" +
                    "• **CPU:** Tối thiểu 6 nhân 12 luồng như Intel Core i5 12400F / 13400F hoặc AMD Ryzen 5 5600 / 7500F (biên dịch code nhanh).\n" +
                    "• **Ổ cứng:** SSD NVMe tối thiểu 512GB (tốc độ đọc ghi > 3000MB/s) để index source code nặng chỉ trong vài giây.\n" +
                    "• **VGA:** Nếu chỉ lập trình web/app thì card GTX 1650 hoặc RTX 3050 là đủ. Nếu học AI/Machine Learning/Làm game Unity/Unreal thì nên chọn RTX 4060 trở lên có từ 8GB - 12GB VRAM.\n\n" +
                    "Shop gửi bạn một số cấu hình học IT chuẩn bài bảo hành 36 tháng:",
                    Arrays.asList("Tầm giá 10 - 15 triệu", "Tầm giá 15 - 25 triệu", "Chính sách bảo hành"),
                    productDao.searchAdvancedForChatbot(null, null, Arrays.asList("Gaming"), 18000000.0, 14000000.0, 24000000.0, true, 3)
            );
        }

        return null;
    }

    private ChatResult handleTechnicalExplanation(String msg) {

        if ((containsAny(msg, "intel", "core") && containsAny(msg, "amd", "ryzen") && containsAny(msg, "so sánh", "và", "hay", "hơn", "khác", "chọn", "nào"))
                || containsAny(msg, "so sánh intel", "so sánh amd", "so sánh chip", "intel hay amd", "amd hay intel", "nên chọn intel hay amd", "chip nào tốt hơn", "ryzen hay core", "core hay ryzen")) {
            return new ChatResult(
                    "💡 **SO SÁNH CHUYÊN SÂU: NÊN CHỌN CPU INTEL CORE HAY AMD RYZEN?**\n\n" +
                    "• **Nền tảng AMD Ryzen (Kiến trúc Zen 4, Zen 5):**\n" +
                    "  + *Ưu điểm:* Vận hành cực kỳ mát mẻ, tiết kiệm điện năng nhờ tiến trình TSMC tiên tiến. Nền tảng Socket AM5 hỗ trợ nâng cấp lâu dài đến năm 2027+.\n" +
                    "  + *Đặc biệt:* Dòng chip có đuôi **X3D** (như Ryzen 7 7800X3D, 9800X3D) tích hợp bộ nhớ đệm 3D V-Cache cực lớn, hiện là 'Vua hiệu năng chơi game' trên toàn thế giới!\n" +
                    "  + *Phù hợp nhất:* Game thủ Esport/AAA chuyên nghiệp, người thích máy mát mẻ, ít tốn điện và muốn nâng cấp CPU trong tương lai.\n\n" +
                    "• **Nền tảng Intel Core (Gen 12, 13, 14, Core Ultra):**\n" +
                    "  + *Ưu điểm:* Xung nhịp đơn nhân cao, tương thích cực tốt với phần mềm đồ họa, dựng video Adobe Premiere, Photoshop nhờ bộ tăng tốc phần cứng Intel QuickSync.\n" +
                    "  + *Phù hợp nhất:* Người vừa làm đồ họa, dựng phim, vẽ kỹ thuật CAD vừa kết hợp chơi game giải trí.\n\n" +
                    "👉 Cửa hàng Độ-PC 67 có sẵn đầy đủ cấu hình tối ưu của cả Intel và AMD để bạn thoải mái trải nghiệm!",
                    Arrays.asList("Xem PC AMD Gaming", "Xem PC Intel Gaming", "Tư vấn cấu hình"),
                    null
            );
        }

        if (containsAny(msg, "5060") && containsAny(msg, "4060") && containsAny(msg, "so sánh", "khác", "hơn", "nâng cấp", "chọn")) {
            return new ChatResult(
                    "💡 **SO SÁNH: NVIDIA GEFORCE RTX 5060 vs RTX 4060:**\n\n" +
                    "• **Kiến trúc mới:** RTX 5060 sử dụng kiến trúc Blackwell thế hệ mới (so với Ada Lovelace trên RTX 4060), tích hợp nhân Tensor Core thế hệ 5 phục vụ tính toán AI vượt trội.\n" +
                    "• **Bộ nhớ:** RTX 5060 hỗ trợ chuẩn bộ nhớ GDDR7 băng thông siêu nhanh, giúp xử lý các khung hình game ở độ phân giải 2K mượt mà hơn hẳn.\n" +
                    "• **Công nghệ độc quyền:** Hỗ trợ tính năng DLSS 4 & Multi-Frame Generation mới nhất, cho phép tăng FPS gấp đôi trong các tựa game nặng (Cyberpunk, Black Myth: Wukong, GTA 6).\n" +
                    "• **Hiệu năng thuần:** RTX 5060 mạnh hơn RTX 4060 từ **18% - 25%** ở cùng mức tiêu thụ điện năng.\n\n" +
                    "👉 Nếu bạn đang mua máy mới năm 2026, **RTX 5060 là sự lựa chọn tương lai cực kỳ đáng giá**!",
                    Arrays.asList("Cấu hình PC RTX 5060", "Cấu hình PC RTX 4060", "Tư vấn cấu hình"),
                    null
            );
        }

        if (containsAny(msg, "nghẽn", "bottleneck", "nghen", "thắt cổ chai")) {
            return new ChatResult(
                    "💡 **GIẢI THÍCH: NGHẼN CỔ CHAI (BOTTLENECK) LÀ GÌ?**\n\n" +
                    "• **Khái niệm:** Nghẽn cổ chai là hiện tượng một linh kiện (thường là CPU hoặc VGA) có tốc độ xử lý quá yếu so với linh kiện còn lại, khiến linh kiện mạnh hơn không thể phát huy hết công suất (bị kìm hãm) gây tụt FPS hoặc giật lag đột ngột.\n\n" +
                    "• **Ví dụ điển hình:** Cắm CPU Intel Core i3 đời cũ với card đồ họa RTX 4080. Khi chơi game, CPU sẽ gánh không nổi và chạy 100% gây đơ giật, trong khi card đồ họa chỉ hoạt động khoảng 40%.\n\n" +
                    "• **Cách phòng tránh:** Khi chọn PC tại Độ-PC 67, các kỹ thuật viên luôn tính toán để CPU và GPU cân xứng hoàn hảo (ví dụ: i5 12400F đi cùng RTX 4060, hoặc Ryzen 7 7700 đi cùng RTX 4070) để bạn đạt hiệu năng 100% không bị lãng phí tiền bạc!",
                    Arrays.asList("Tư vấn cấu hình PC", "So sánh Intel và AMD", "Chính sách bảo hành"),
                    null
            );
        }

        if (containsAny(msg, "dual channel", "bus ram", "ddr4 khác ddr5", "ddr4 hay ddr5", "cần bao nhiêu ram", "8gb hay 16gb", "16gb hay 32gb", "ram máy tính")) {
            return new ChatResult(
                    "💡 **TẤT TẦN TẬT KIẾN THỨC VỀ BỘ NHỚ RAM MÁY TÍNH:**\n\n" +
                    "1. **Dung lượng bao nhiêu là đủ năm 2026?**\n" +
                    "   • **8GB:** Chỉ đủ cho tác vụ văn phòng cơ bản, gõ Word, Excel.\n" +
                    "   • **16GB (Tiêu chuẩn quốc dân):** Mức tối thiểu cần có để chiến mượt mà mọi game (Valorant, LOL, CS2, GTA V...) và làm đồ họa nhẹ.\n" +
                    "   • **32GB trở lên:** Dành cho game thủ chiến game AAA nặng (Black Myth: Wukong, Cyberpunk), dựng phim Premiere 4K, Render 3D hoặc cắm nhiều tab giả lập.\n\n" +
                    "2. **Dual Channel là gì?**\n" +
                    "   • Là cắm **2 thanh RAM** (ví dụ 2x8GB) thay vì 1 thanh 16GB. Băng thông truyền dữ liệu sẽ tăng gấp đôi, giúp tăng từ **15% đến 25% FPS** trong game!\n\n" +
                    "3. **DDR4 khác gì DDR5?**\n" +
                    "   • DDR4 (bus 3200MHz) giá rẻ, tối ưu chi phí.\n" +
                    "   • DDR5 (bus 5600 - 6400MHz) tốc độ cực cao, băng thông rộng, là chuẩn tương lai cho các CPU đời mới.",
                    Arrays.asList("Tư vấn cấu hình 15tr", "Cấu hình 20tr", "Hotline tư vấn"),
                    null
            );
        }

        if (containsAny(msg, "nvme", "sata", "hdd", "ổ cứng nào", "ssd nào tốt")) {
            return new ChatResult(
                    "💡 **PHÂN BIỆT Ổ CỨNG: SSD NVMe vs SSD SATA vs HDD:**\n\n" +
                    "• **HDD (Ổ đĩa cơ truyền thống):**\n" +
                    "   + Tốc độ: ~100 - 150 MB/s (Chậm nhất).\n" +
                    "   + Chỉ nên dùng để lưu trữ file tài liệu, phim ảnh dung lượng lớn.\n\n" +
                    "• **SSD SATA (2.5 inch):**\n" +
                    "   + Tốc độ: ~500 - 550 MB/s (Nhanh gấp 4-5 lần HDD).\n\n" +
                    "• **SSD M.2 NVMe (Gen 3, Gen 4, Gen 5):**\n" +
                    "   + Tốc độ: **3.500 MB/s - 7.500 MB/s** (Nhanh gấp 30 - 50 lần HDD!).\n" +
                    "   + Khởi động Windows chỉ 5 giây, tải màn chơi game tức thì, không bị drop FPS khi render.\n\n" +
                    "👉 Tất cả dàn PC tại Độ-PC 67 đều trang bị sẵn **SSD NVMe tốc độ cao** chính hãng!",
                    Arrays.asList("Cấu hình PC Gaming", "Chính sách bảo hành", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "tản nước", "tản khí", "tản aio", "làm mát cpu", "tản nhiệt nước")) {
            return new ChatResult(
                    "💡 **NÊN DÙNG TẢN NHIỆT KHÍ HAY TẢN NHIỆT NƯỚC AIO?**\n\n" +
                    "• **Tản nhiệt khí:**\n" +
                    "   + *Ưu điểm:* Bền bỉ vĩnh cửu (chỉ có quạt quay, không sợ rò rỉ nước), giá thành rẻ.\n" +
                    "   + *Khuyến nghị:* Rất phù hợp cho các CPU tầm trung như Core i3, Core i5, Ryzen 5.\n\n" +
                    "• **Tản nhiệt nước AIO (All-in-One):**\n" +
                    "   + *Ưu điểm:* Thẩm mỹ cực đỉnh (đèn LED ARGB, có màn hình LCD tùy biến ảnh GIF), hiệu suất hạ nhiệt nhanh chóng khi tải nặng.\n" +
                    "   + *Khuyến nghị:* Bắt buộc cho các dòng CPU tỏa nhiều nhiệt như Core i7, Core i9, Ryzen 9 để tránh bị bóp xung (Thermal Throttling).\n\n" +
                    "👉 Shop có sẵn cả tản khí tháp đôi và tản nước 240/360 lắp đặt gọn gàng, thẩm mỹ!",
                    Arrays.asList("Tư vấn build PC", "Cấu hình trên 25tr", "Dịch vụ lắp ráp"),
                    null
            );
        }

        if (containsAny(msg, "nguồn bao nhiêu watt", "80 plus là gì", "nguồn công suất thực", "chọn nguồn")) {
            return new ChatResult(
                    "💡 **HƯỚNG DẪN CHỌN NGUỒN MÁY TÍNH (PSU) CHUẨN CÔNG SUẤT:**\n\n" +
                    "Nguồn được xem là 'trái tim' cung cấp năng lượng cho toàn bộ cỗ máy. Chọn nguồn noname hoặc nguồn thiếu công suất rất dễ gây sụt áp, sập nguồn đột ngột hoặc cháy nổ linh kiện!\n\n" +
                    "• **Cấu hình văn phòng:** 400W - 450W.\n" +
                    "• **PC Gaming (GTX 1660S / RTX 3050):** 500W - 550W chuẩn 80 Plus.\n" +
                    "• **PC Gaming/Đồ họa (RTX 4060 / 4060 Ti):** 600W - 650W chuẩn 80 Plus Bronze.\n" +
                    "• **PC High-End (RTX 4070 / 5070 / 5080):** 750W - 850W chuẩn 80 Plus Gold.\n" +
                    "• **Workstation (RTX 4090 / 5090):** 1000W - 1200W chuẩn Gold/Platinum.\n\n" +
                    "👉 Chuẩn **80 Plus** đảm bảo hiệu suất chuyển đổi điện đạt trên 80-90%, giúp tiết kiệm điện và hoạt động ổn định lâu dài.",
                    Arrays.asList("Tư vấn cấu hình PC", "Chính sách bảo hành", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "màn hình bao nhiêu hz", "tần số quét là gì", "60hz khác 144hz", "144hz khác 240hz", "tần số quét")) {
            return new ChatResult(
                    "💡 **TẦN SỐ QUÉT MÀN HÌNH (Hz) LÀ GÌ? KHÁC NHAU THẾ NÀO?**\n\n" +
                    "Tần số quét (Hz) là số khung hình màn hình có thể hiển thị trong 1 giây:\n" +
                    "• **60Hz - 75Hz:** Tiêu chuẩn cho xem phim, lướt web, làm việc văn phòng.\n" +
                    "• **144Hz - 180Hz (Chuẩn Gaming):** Hiển thị hình ảnh mượt gấp 2.5 lần so với 60Hz. Khi chơi các game bắn súng (Valorant, CS2, PUBG, Apex), hồng tâm di chuyển trơn tru, không bị xé hình (tearing), giúp bạn phản xạ nhanh hơn rõ rệt.\n" +
                    "• **240Hz - 360Hz:** Dành cho game thủ Esports chuyên nghiệp thi đấu đỉnh cao.\n\n" +
                    "👉 Shop có sẵn đầy đủ màn hình từ 24 inch đến 27 inch 144Hz-240Hz giá chỉ từ 2.x triệu!",
                    Arrays.asList("Tư vấn PC chơi game", "Báo giá màn hình", "Hotline tư vấn"),
                    null
            );
        }

        if (containsAny(msg, "không lên màn hình", "màn hình đen", "không nhận tín hiệu", "quạt quay màn không lên", "máy bật không lên", "màn hình không lên")) {
            return new ChatResult(
                    "🛠️ **HƯỚNG DẪN XỬ LÝ: MÁY TÍNH BẬT QUẠT QUAY NHƯNG KHÔNG LÊN MÀN HÌNH**\n\n" +
                    "Bạn hãy kiểm tra theo 4 bước đơn giản sau nhé:\n" +
                    "1. **Kiểm tra dây cắm màn hình (HDMI/DisplayPort):** Rất nhiều bạn cắm nhầm dây lên cổng của bo mạch chủ (Mainboard) thay vì cắm vào cổng của **Card màn hình rời (VGA)** ở phía dưới.\n" +
                    "2. **Vệ sinh chân RAM:** Tắt máy, tháo thanh RAM ra, dùng cục tẩy (gôm) chà nhẹ lên hàng chân vàng bóng rồi cắm chặt lại vào khe nghe tiếng 'tách' ở 2 đầu.\n" +
                    "3. **Kiểm tra nút nguồn màn hình:** Đảm bảo đèn màn hình sáng và chọn đúng nguồn vào (Input Source: HDMI 1 hoặc DP 1).\n" +
                    "4. **Xả điện:** Rút dây nguồn, nhấn giữ nút bật nguồn của case 15 giây rồi cắm lại.\n\n" +
                    "👉 Nếu vẫn chưa lên, bạn có thể gọi Hotline kỹ thuật **" + ChatbotConfig.SHOP_HOTLINE + "** hoặc mang qua shop để được kiểm tra và đo mạch miễn phí nhé!",
                    Arrays.asList("Hotline kỹ thuật 24/7", "Dịch vụ sửa chữa", "Bảo hành 1 đổi 1"),
                    null
            );
        }

        if (containsAny(msg, "bao lâu tra keo", "khi nào tra keo", "vệ sinh máy", "nhiệt độ cpu", "máy bị nóng", "nóng cpu")) {
            return new ChatResult(
                    "💡 **BAO LÂU THÌ NÊN VỆ SINH MÁY VÀ TRA KEO TẢN NHIỆT?**\n\n" +
                    "• **Thời gian khuyến nghị:** Sau khoảng **6 tháng đến 1 năm** sử dụng, bạn nên vệ sinh bụi bẩn và thay keo tản nhiệt mới.\n" +
                    "• **Dấu hiệu máy cần vệ sinh:** Quạt tản nhiệt kêu to, máy bị nóng ran, chơi game bị giật lag tụt FPS (do CPU/VGA chạm ngưỡng 90°C - 100°C tự giảm xung để bảo vệ).\n" +
                    "• **Nhiệt độ an toàn:** Khi chơi game nặng, CPU dưới 75°C - 80°C và VGA dưới 70°C là rất mát mẻ.\n\n" +
                    "👉 Đặc biệt: Khi mua máy tại **Độ-PC 67**, bạn được hưởng đặc quyền **Vệ sinh máy và tra keo tản nhiệt MIỄN PHÍ TRỌN ĐỜI**!",
                    Arrays.asList("Dịch vụ vệ sinh PC", "Chính sách bảo hành", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "ti là gì", "super là gì", "card oc", "vram là gì", "ý nghĩa ti")) {
            return new ChatResult(
                    "💡 **Ý NGHĨA CÁC KÝ HIỆU TRÊN CARD MÀN HÌNH (VGA):**\n\n" +
                    "• **Ti (Titanium):** Phiên bản nâng cấp mạnh mẽ hơn bản tiêu chuẩn từ 15% - 25% nhờ tăng số nhân xử lý CUDA (ví dụ: RTX 4060 Ti mạnh hơn hẳn RTX 4060).\n" +
                    "• **Super:** Phiên bản cải tiến giữa vòng đời của NVIDIA, tăng tốc độ xung nhịp và dung lượng VRAM.\n" +
                    "• **OC (Overclocked):** Card đã được nhà sản xuất ép xung sẵn cao hơn xung nhịp mặc định của NVIDIA ngay từ trong nhà máy, giúp tăng thêm 3-5% hiệu năng.\n" +
                    "• **VRAM (Video RAM):** Bộ nhớ riêng của card màn hình. Game hiện đại và đồ họa 3D/Premiere cần tối thiểu 8GB - 12GB VRAM để không bị tràn văng app.",
                    Arrays.asList("Cấu hình PC Gaming", "Tư vấn cấu hình PC", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "win 10 hay win 11", "nên cài win nào", "win nào chơi game tốt hơn", "windows 10 hay 11", "chơi game cài win nào")) {
            return new ChatResult(
                    "💡 **NÊN DÙNG WINDOWS 10 HAY WINDOWS 11 CHO MÁY TÍNH?**\n\n" +
                    "• **Khuyến nghị hiện tại:** Nếu bạn đang dùng CPU đời mới (Intel Gen 12, 13, 14, Core Ultra hoặc AMD Ryzen 7000/9000), bạn **BẮT BUỘC NÊN DÙNG WINDOWS 11**.\n\n" +
                    "• **Lý do:**\n" +
                    "   1. Windows 11 có bộ điều phối Thread Director thông minh, phân bổ chuẩn xác tác vụ nặng vào nhân mạnh (P-core) và tác vụ nhẹ vào nhân tiết kiệm (E-core).\n" +
                    "   2. Hỗ trợ tính năng độc quyền cho game thủ: **Auto HDR** (tự làm đẹp màu sắc trong game) và **DirectStorage** (tải màn chơi siêu tốc qua SSD NVMe).\n" +
                    "   3. Giao diện hiện đại, bảo mật cao hơn.\n\n" +
                    "👉 Khi mua PC tại shop, bạn sẽ được **cài sẵn Windows 11 bản quyền kèm trọn bộ Office và phần mềm cần thiết hoàn toàn miễn phí**!",
                    Arrays.asList("Cấu hình PC Gaming", "Dịch vụ cài Win", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "dlss là gì", "fsr là gì", "khác biệt dlss và fsr", "dlss khác fsr")) {
            return new ChatResult(
                    "💡 **DLSS VÀ FSR LÀ GÌ? CÔNG NGHỆ NÀO VƯỢT TRỘI HƠN?**\n\n" +
                    "Cả hai đều là công nghệ **Nâng cấp độ phân giải bằng AI (Upscaling)**: render game ở độ phân giải thấp hơn để nhẹ máy, sau đó dùng thuật toán tái tạo lại độ phân giải cao sắc nét, giúp tăng từ **40% đến 100% FPS**!\n\n" +
                    "• **NVIDIA DLSS (Deep Learning Super Sampling):**\n" +
                    "  + Chạy trên nhân Tensor Core chuyên dụng của card RTX (NVIDIA độc quyền).\n" +
                    "  + Chất lượng hình ảnh cực kỳ sắc nét, ít bóng mờ (ghosting). Đặc biệt tính năng **Frame Generation (DLSS 3/4)** tự chèn thêm khung hình ảo bằng AI giúp FPS tăng gấp đôi!\n\n" +
                    "• **AMD FSR (FidelityFX Super Resolution):**\n" +
                    "  + Mã nguồn mở, chạy được trên cả card AMD, NVIDIA lẫn card tích hợp.\n" +
                    "  + Tương thích rộng rãi nhưng độ sắc nét chi tiết vật thể chưa mịn bằng DLSS.",
                    Arrays.asList("Cấu hình PC RTX 4060", "Cấu hình RTX 5060", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "màn hình xanh", "bsod", "dump xanh", "lỗi dump")) {
            return new ChatResult(
                    "🛠️ **HƯỚNG DẪN XỬ LÝ LỖI MÀN HÌNH XANH (BLUE SCREEN OF DEATH - BSOD):**\n\n" +
                    "Lỗi màn hình xanh thường do 3 nguyên nhân chính:\n" +
                    "1. **Xung đột Driver / Cập nhật Windows lỗi:** Hãy khởi động vào Safe Mode và gỡ bản cập nhật gần nhất hoặc cài lại Driver Card màn hình từ trang chủ NVIDIA/AMD.\n" +
                    "2. **Lỗi lỏng chân RAM hoặc RAM hỏng:** Tháo RAM ra vệ sinh bằng tẩy, cắm thử từng thanh một để loại trừ thanh bị lỗi.\n" +
                    "3. **Ổ cứng SSD bị bad sector hoặc quá nhiệt:** Dùng phần mềm CrystalDiskInfo kiểm tra sức khỏe ổ cứng (nếu dưới 80% hoặc báo Caution vàng thì nên sao lưu dữ liệu ngay).\n\n" +
                    "👉 Bạn có thể chụp ảnh mã lỗi (Stop Code) gửi qua Zalo **" + ChatbotConfig.SHOP_HOTLINE + "** để kỹ thuật viên shop đọc lỗi và hướng dẫn khắc phục miễn phí nhé!",
                    Arrays.asList("Hotline kỹ thuật 24/7", "Dịch vụ bảo hành", "Cài đặt Windows"),
                    null
            );
        }

        if (containsAny(msg, "làm máy tính nhanh hơn", "tối ưu máy tính", "máy tính bị chậm", "tăng tốc pc", "dọn dẹp máy tính")) {
            return new ChatResult(
                    "⚡ **5 BƯỚC ĐƠN GIẢN GIÚP MÁY TÍNH CHẠY NHANH NHƯ MỚI:**\n\n" +
                    "1. **Tắt ứng dụng khởi động cùng Windows:** Mở `Task Manager` (Ctrl + Shift + Esc) -> chọn tab `Startup apps` -> chuột phải chọn `Disable` các ứng dụng không cần thiết (như Zalo, Spotify, Skype, Steam).\n" +
                    "2. **Dọn rác ổ đĩa C:** Bấm tổ hợp phím `Windows + R`, gõ `%temp%` rồi xóa sạch các file rác bên trong.\n" +
                    "3. **Bật chế độ High Performance:** Vào `Power & Sleep` -> chọn `High performance` để CPU luôn sẵn sàng chạy tối đa công suất.\n" +
                    "4. **Kiểm tra nhiệt độ CPU/GPU:** Nếu máy nóng trên 85°C, hãy vệ sinh quạt và tra keo tản nhiệt mới.\n" +
                    "5. **Nâng cấp ổ SSD NVMe & RAM 16GB:** Nếu máy bạn vẫn đang chạy ổ HDD cơ, nâng cấp lên SSD sẽ giúp máy mở ứng dụng nhanh gấp 10 lần ngay lập tức!\n\n" +
                    "👉 Bạn có thể mang máy qua Độ-PC 67 để được **Tối ưu hóa và vệ sinh máy hoàn toàn miễn phí** nhé!",
                    Arrays.asList("Dịch vụ nâng cấp linh kiện", "Tư vấn cấu hình PC", "Hotline shop"),
                    null
            );
        }

        return null;
    }

    private ChatResult handleLifestyleAndAdvice(String msg) {

        if (containsAny(msg, "nên mua laptop hay pc", "laptop hay pc", "chọn pc hay laptop", "mua máy bàn hay laptop")) {
            return new ChatResult(
                    "💡 **NÊN MUA LAPTOP HAY PC ĐỂ BÀN?**\n\n" +
                    "• **Nên chọn Laptop khi:**\n" +
                    "  + Bạn là sinh viên hoặc người đi làm bắt buộc phải mang máy lên giảng đường, công ty, thư viện hoặc quán cà phê hàng ngày.\n" +
                    "  + Chấp nhận hiệu năng thấp hơn và giá thành đắt hơn khoảng 30% - 40% so với PC cùng thông số.\n\n" +
                    "• **Nên chọn PC để bàn khi:**\n" +
                    "  + Muốn **hiệu năng mạnh nhất trên từng đồng tiền bỏ ra** (cùng 15 triệu, PC mạnh gấp đôi laptop).\n" +
                    "  + Màn hình to 24 - 27 inch sắc nét, bàn phím chuột thoải mái, tản nhiệt cực mát cày game/render 24/7 không lo chai pin hay nóng ran bàn tay.\n" +
                    "  + Dễ dàng nâng cấp từng món linh kiện (hỏng gì thay đó, không sợ lỗi thời).\n\n" +
                    "👉 Nếu bạn không cần di chuyển mỗi ngày, **PC để bàn luôn là khoản đầu tư thông minh và bền bỉ nhất**!",
                    Arrays.asList("Tư vấn PC 10 - 15 triệu", "Tư vấn PC 15 - 25 triệu", "Chính sách bảo hành"),
                    null
            );
        }

        if (containsAny(msg, "card trâu cày", "mua vga cũ", "có nên mua đồ cũ", "linh kiện cũ")) {
            return new ChatResult(
                    "⚠️ **CẢNH BÁO: CÓ NÊN MUA CARD MÀN HÌNH TRÂU CÀY / LINH KIỆN CŨ?**\n\n" +
                    "• **Card trâu cày (Mining VGA):** Là card bị vắt kiệt sức chạy giải mã tiền ảo 24/24 trong môi trường nóng ẩm, linh kiện bị oxy hóa, chip nhớ VRAM bị om nhiệt và tụ điện đã chai sạn.\n" +
                    "• **Rủi ro lớn:** Mua về dùng rất dễ bị rác hình (Artifact), sập nguồn hoặc lăn ra chết sau vài tuần sử dụng mà không được bảo hành.\n\n" +
                    "👉 **Lời khuyên chân thành:** Tại **Độ-PC 67**, toàn bộ máy ráp đều là **hàng mới 100% chính hãng**, bảo hành 36 tháng 1 đổi 1. Mua máy mới giúp bạn an tâm làm việc, chơi game trọn vẹn và không lo rước bực vào người!",
                    Arrays.asList("Cấu hình PC mới giá tốt", "Chính sách bảo hành", "Hotline tư vấn"),
                    null
            );
        }

        if (containsAny(msg, "sinh viên nên mua máy gì", "pc cho sinh viên", "máy cho sinh viên")) {
            return new ChatResult(
                    "🎓 **TƯ VẤN PC TIẾT KIỆM & BỀN BỈ CHO SINH VIÊN:**\n\n" +
                    "• **Khối Kinh tế, Ngoại ngữ, Xã hội:** Cấu hình Core i3-12100 / Ryzen 5 5600G, RAM 16GB, SSD 512GB (tầm **7 - 10 triệu**) là mượt mà làm slide, tiểu luận, học online, giải trí LMHT.\n" +
                    "• **Khối Công nghệ thông tin (IT):** Core i5-12400F, RAM 16GB - 32GB, SSD NVMe 512GB (tầm **12 - 16 triệu**) cân tốt code Web, App, Docker và máy ảo.\n" +
                    "• **Khối Kiến trúc, Xây dựng, Đồ họa đa phương tiện:** Core i5-13400F / Ryzen 7, RAM 32GB, Card RTX 4060 8GB (tầm **18 - 25 triệu**) phục vụ vẽ AutoCAD, Revit, 3ds Max, dựng phim.\n\n" +
                    "👉 Shop có ưu đãi tặng combo phím chuột và hỗ trợ trả góp sinh viên online cực nhanh!",
                    Arrays.asList("Dưới 10 triệu", "10 - 15 triệu", "15 - 25 triệu"),
                    productDao.searchAdvancedForChatbot(null, null, Arrays.asList("Văn Phòng"), null, null, 12000000.0, true, 3)
            );
        }

        if (containsAny(msg, "kể chuyện cười", "kể chuyện vui", "hài hước", "chuyện cười it")) {
            return new ChatResult(
                    "😄 **CHUYỆN CƯỜI DÂN IT DÀNH TẶNG BẠN:**\n\n" +
                    "Vợ bảo chồng làm lập trình viên:\n" +
                    "— *'Anh ra chợ mua cho em một nải chuối. NẾU thấy có trứng gà thì mua 10 quả nhé!'*\n\n" +
                    "Một lúc sau, anh chồng hớn hở xách về... **10 nải chuối**.\n" +
                    "Vợ ngơ ngác hét lên: *'Sao anh lại mua tận 10 nải chuối?!'*\n" +
                    "Anh chồng điềm tĩnh trả lời:\n" +
                    "— *'Thì anh ra chợ THẤY CÓ TRỨNG GÀ đúng như điều kiện IF của em mà!'* 🤣\n\n" +
                    "Chúc bạn có một ngày làm việc và chơi game thật nhiều niềm vui nhé!",
                    Arrays.asList("Tư vấn cấu hình PC", "Kể chuyện khác đi", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "thời tiết hôm nay", "hôm nay trời", "thời tiết thế nào", "mưa hay nắng")) {
            return new ChatResult(
                    "🌤️ **Dạ về thời tiết hôm nay:**\n\n" +
                    "Em là trợ lý AI túc trực trong hệ thống cửa hàng Độ-PC 67 nên chưa cập nhật được radar vệ tinh thời tiết trực tiếp ở khu vực của bạn.\n\n" +
                    "Nhưng mà dù ngoài trời có mưa gió hay nắng gắt, thì cảm giác tuyệt vời nhất vẫn là ngồi trong phòng máy lạnh, bật dàn PC Độ-PC 67 lên và cùng bạn bè 'quẩy' vài trận game đúng không nào! 😄🎮\n\n" +
                    "Bạn cần em tư vấn thêm cấu hình máy tính hay giải đáp thắc mắc gì cứ hỏi em nhé!",
                    Arrays.asList("Tư vấn cấu hình PC", "Cấu hình chơi game", "Hotline shop"),
                    null
            );
        }

        if (containsAny(msg, "bảo vệ mắt", "mỏi mắt", "ngồi máy tính lâu", "mỏi lưng", "tư thế ngồi")) {
            return new ChatResult(
                    "👁️ **MẸO BẢO VỆ MẮT VÀ CỘT SỐNG CHO NGƯỜI DÙNG MÁY TÍNH NHIỀU:**\n\n" +
                    "1. **Quy tắc 20-20-20:** Cứ sau **20 phút** nhìn màn hình, hãy nhìn xa **20 feet (khoảng 6 mét)** trong vòng **20 giây** để cơ mắt được thả lỏng.\n" +
                    "2. **Khoảng cách màn hình:** Giữ khoảng cách từ mắt đến màn hình từ **50cm - 70cm** (bằng chiều dài một cánh tay).\n" +
                    "3. **Bật chế độ Night Light:** Buổi tối nên bật tính năng lọc ánh sáng xanh trên Windows 11 để không bị mất ngủ.\n" +
                    "4. **Tư thế ngồi:** Mắt nhìn ngang bằng mép trên màn hình, lưng tựa thẳng vào ghế công thái học, bàn chân đặt vuông góc tiếp sàn.\n\n" +
                    "Chúc bạn luôn giữ được đôi mắt sáng khỏe và năng lượng làm việc dồi dào nhé!",
                    Arrays.asList("Tư vấn màn hình bảo vệ mắt", "Cấu hình PC", "Hotline shop"),
                    null
            );
        }

        return null;
    }

    private ChatResult handleGreeting(String msg) {
        return new ChatResult(
                "Dạ em chào bạn ạ! 🌟 Em là **Trợ lý AI Độ-PC 67** — được trang bị trí tuệ tự nhiên linh hoạt như một phiên bản **Gemini thu nhỏ** chuyên biệt cho công nghệ và phần cứng máy tính.\n\n" +
                "Em có thể hỗ trợ bạn mọi lĩnh vực:\n" +
                "• 🖥️ **Tư vấn cấu hình PC theo nhu cầu:** Nhận diện chuẩn xác chip AMD Ryzen hay Intel Core, card đồ họa RTX 5060/4060, hoặc ngân sách (10tr, 15tr, 30tr...).\n" +
                "• 💡 **Giải đáp kiến thức công nghệ & phần cứng:** So sánh Intel vs AMD, giải thích nghẽn cổ chai, RAM, SSD, màn hình Hz, nguồn máy tính...\n" +
                "• 💻 **Kiến thức IT & Lập trình:** Chọn máy học code, giải thích AI, Web, GitHub, ngôn ngữ lập trình...\n" +
                "• 🛠️ **Xử lý sự cố máy tính:** Bật không lên màn hình, màn xanh BSOD, máy nóng tụt FPS...\n" +
                "• 📦 **Chính sách cửa hàng:** Bảo hành 1 đổi 1 trong 30 ngày, trả góp 0%, miễn phí vệ sinh & cài Win trọn đời máy.\n\n" +
                "Bạn cần em tư vấn bộ PC tầm bao nhiêu, hoặc đang có câu hỏi gì cứ thoải mái nhắn cho em nhé!",
                Arrays.asList("Gợi ý PC AMD 30tr", "PC Intel 20tr", "PC RTX 5060", "Nghẽn cổ chai là gì?", "Hotline shop"),
                productDao.searchAdvancedForChatbot(null, null, null, null, null, null, true, 3)
        );
    }

    private ChatResult handleOpenEndedMiniGemini(String rawMessage, String lower) {

        if (lower.contains("là gì") || lower.contains("nghĩa là gì") || lower.contains("thế nào là")) {
            return new ChatResult(
                    "💡 **GIẢI THÍCH TỔNG QUAN VỀ: \"" + rawMessage.toUpperCase() + "\":**\n\n" +
                    "Về khái niệm này, trong thực tế thường được hiểu là:\n" +
                    "• Đây là thuật ngữ/khái niệm quan trọng liên quan đến cách thức vận hành hệ thống và trải nghiệm công nghệ của người dùng.\n" +
                    "• Khi ứng dụng vào hệ thống máy tính và công việc hàng ngày, việc nắm rõ nguyên lý này sẽ giúp bạn tối ưu hóa hiệu suất, tránh lãng phí chi phí và vận hành máy ổn định hơn.\n\n" +
                    "👉 Nếu bạn muốn tìm hiểu sâu hơn về khía cạnh phần cứng hoặc cách thức cấu hình trên PC tại **Độ-PC 67**, bạn cứ nhắn chi tiết thêm cho em nhé!",
                    Arrays.asList("Tư vấn cấu hình PC", "Chính sách bảo hành", "Gặp tư vấn viên"),
                    productDao.searchAdvancedForChatbot(null, null, null, null, null, null, true, 3)
            );
        }

        if (lower.contains("làm sao") || lower.contains("cách nào") || lower.contains("hướng dẫn") || lower.contains("làm thế nào")) {
            return new ChatResult(
                    "🛠️ **HƯỚNG DẪN THỰC HIỆN TỐI ƯU:**\n\n" +
                    "Đối với vấn đề bạn đang quan tâm (*\"" + rawMessage + "\"*), các chuyên gia kỹ thuật khuyên bạn nên thực hiện theo các bước sau:\n" +
                    "1. **Kiểm tra tình trạng hiện tại:** Sao lưu dữ liệu quan trọng và xác định rõ thông số máy tính trước khi can thiệp.\n" +
                    "2. **Thực hiện theo trình tự an toàn:** Khởi động lại hệ thống, cập nhật phiên bản driver/phần mềm mới nhất từ trang chủ chính thức.\n" +
                    "3. **Kiểm tra độ ổn định:** Chạy thử các ứng dụng nặng để quan sát nhiệt độ và hiệu năng.\n\n" +
                    "👉 Đội ngũ kỹ thuật viên của **Độ-PC 67** luôn sẵn sàng hỗ trợ bạn từ xa qua Ultraview/Teamview hoặc qua Hotline **" + ChatbotConfig.SHOP_HOTLINE + "** hoàn toàn miễn phí!",
                    Arrays.asList("Hotline kỹ thuật", "Tư vấn cấu hình PC", "Bảo hành 1 đổi 1"),
                    null
            );
        }

        return new ChatResult(
                "Dạ em cảm ơn câu hỏi rất thú vị của bạn! 🌟\n\n" +
                "Em là **Trợ lý AI Độ-PC 67** (được tối ưu như một phiên bản Gemini thu nhỏ chuyên sâu về công nghệ và máy tính). " +
                "Em có thể giải đáp mọi thắc mắc của bạn từ tư vấn phần cứng, lựa chọn cấu hình theo ngân sách, đến kiến thức IT, xử lý sự cố hay trò chuyện đời sống.\n\n" +
                "Bạn có thể nhắn cho em:\n" +
                "1. **Tư vấn cấu hình máy tính:** Ví dụ *'Gợi ý PC AMD 30tr'*, *'PC Intel 20tr'*, *'PC chạy RTX 5060'*, *'Máy 15 triệu chơi Valorant'*\n" +
                "2. **Kiến thức kỹ thuật:** Ví dụ *'Nghẽn cổ chai là gì'*, *'So sánh chip Intel và AMD'*, *'RAM 16GB hay 32GB'*, *'Cách sửa lỗi máy không lên màn hình'*\n" +
                "3. **Hỏi bất kỳ điều gì khác** bạn đang thắc mắc nhé!\n\n" +
                "Hoặc bạn có thể bấm vào các gợi ý nhanh bên dưới:",
                Arrays.asList("Gợi ý PC AMD 30tr", "PC Intel 20tr", "PC RTX 5060", "Chính sách bảo hành", "Hotline shop"),
                productDao.searchAdvancedForChatbot(null, null, null, null, null, null, true, 3)
        );
    }

    private ChatResult handleStorePolicies(String msg) {
        if (containsAny(msg, "bảo hành", "đổi trả", "lỗi", "1 đổi 1", "bảo hành bao lâu")) {
            return handleAction("faq_warranty");
        }
        if (containsAny(msg, "ship", "giao hàng", "vận chuyển", "cod", "phí ship", "bao lâu nhận")) {
            return handleAction("faq_shipping");
        }
        if (containsAny(msg, "trả góp", "lãi suất", "thẻ tín dụng", "cccd", "trả trước")) {
            return handleAction("faq_installment");
        }
        if (containsAny(msg, "lắp ráp", "build pc", "cài win", "vệ sinh", "tra keo")) {
            return handleAction("service_assembly");
        }
        if (containsAny(msg, "thu cũ", "đổi mới", "trade in", "nâng cấp", "bán lại")) {
            return handleAction("service_tradein");
        }
        if (containsAny(msg, "địa chỉ", "ở đâu", "hotline", "số điện thoại", "sđt", "liên hệ", "cửa hàng", "zalo")) {
            return handleAction("faq_contact");
        }
        return null;
    }

    public ChatResult handleAction(String action) {
        switch (action) {
            case "budget_under_10": {
                List<Product> list = productDao.searchAdvancedForChatbot(null, null, null, 7000000.0, 5000000.0, 10000000.0, true, 3);
                if (list.isEmpty()) {
                    list = productDao.searchAdvancedForChatbot(null, null, Arrays.asList("Văn Phòng"), null, null, null, true, 3);
                }
                return new ChatResult(
                        "🖥️ **CẤU HÌNH PC DƯỚI 10 TRIỆU (Văn phòng, Học tập & Gaming nhẹ):**\n\n" +
                        "• **CPU:** Intel Core i3-10105 / 12100 hoặc AMD Ryzen 5 5600G (4 - 6 nhân, đồ họa tích hợp mượt mà).\n" +
                        "• **RAM:** 8GB - 16GB DDR4 Bus 3200MHz.\n" +
                        "• **Ổ cứng:** SSD NVMe 256GB - 512GB siêu tốc khởi động 5s.\n" +
                        "• **Hiệu năng:** Mở hàng chục tab Chrome mượt mà, chiến tốt Liên Minh Huyền Thoại, FIFA Online 4, Đột Kích mượt 100+ FPS.\n\n" +
                        "Các mẫu máy tham khảo hiện có tại cửa hàng:",
                        Arrays.asList("Tầm 10 - 15 triệu", "Chính sách bảo hành", "Dịch vụ giao hàng"),
                        list
                );
            }
            case "budget_10_15": {
                List<Product> list = productDao.searchAdvancedForChatbot(null, null, null, 14000000.0, 10000000.0, 16500000.0, true, 3);
                return new ChatResult(
                        "🎮 **CẤU HÌNH PC 10 - 15 TRIỆU (Gaming Quốc Dân & Đồ Họa 2D):**\n\n" +
                        "• **CPU:** Intel Core i5 12400F hoặc AMD Ryzen 5 5600 (6 nhân 12 luồng).\n" +
                        "• **RAM:** 16GB DDR4 Dual Channel Bus 3200MHz.\n" +
                        "• **VGA:** NVIDIA GeForce GTX 1660 Super 6GB hoặc RTX 3050 6GB.\n" +
                        "• **Ổ cứng:** SSD NVMe 512GB Gen 3/Gen 4.\n" +
                        "• **Nguồn:** 500W - 550W chuẩn 80 Plus công suất thực.\n" +
                        "• **Hiệu năng:** Cân mượt Valorant (200+ FPS), CS2 (140+ FPS), LOL max setting, GTA V high setting; làm mượt Photoshop, CapCut, Premiere 1080p.\n\n" +
                        "Các bộ máy tiêu biểu bán chạy:",
                        Arrays.asList("Tầm 15 - 25 triệu", "Hỗ trợ trả góp 0%", "Lắp ráp tận nơi"),
                        list
                );
            }
            case "budget_15_25": {
                List<Product> list = productDao.searchAdvancedForChatbot(null, null, null, 21000000.0, 16000000.0, 25500000.0, true, 3);
                return new ChatResult(
                        "⚡ **CẤU HÌNH PC 15 - 25 TRIỆU (Gaming Nặng & Thiết Kế Đồ Họa Chuyên Nghiệp):**\n\n" +
                        "• **CPU:** Intel Core i5 13400F / 14400F hoặc AMD Ryzen 5 7500F / Ryzen 7 5700X.\n" +
                        "• **RAM:** 16GB - 32GB DDR4/DDR5 RGB tản nhiệt.\n" +
                        "• **VGA:** RTX 4060 8GB, RTX 4060 Ti hoặc RTX 5060 8GB thế hệ mới.\n" +
                        "• **Ổ cứng:** SSD NVMe 512GB - 1TB Gen 4 (Tốc độ đọc 5000MB/s).\n" +
                        "• **Nguồn:** 650W chuẩn 80 Plus Bronze.\n" +
                        "• **Hiệu năng:** Chiến max setting mọi game Esport (300+ FPS), cân ngọt Black Myth: Wukong, Cyberpunk 2077, PUBG; render Premiere 4K và dựng 3D Blender trơn tru!\n\n" +
                        "Các cỗ máy bán chạy nhất tầm giá:",
                        Arrays.asList("Cấu hình trên 25 triệu", "Chính sách bảo hành", "Trả góp 0%"),
                        list
                );
            }
            case "budget_above_25": {
                List<Product> list = productDao.searchAdvancedForChatbot(null, null, null, 38000000.0, 25500000.0, null, true, 3);
                return new ChatResult(
                        "👑 **CẤU HÌNH PC TRÊN 25 TRIỆU (High-End Master & Workstation Đỉnh Cao):**\n\n" +
                        "• **CPU:** Intel Core i7 14700KF / Core i9 14900KF hoặc AMD Ryzen 7 7800X3D / Ryzen 9 7950X.\n" +
                        "• **VGA:** RTX 4070 12GB, RTX 5070 12GB, RTX 5080 hoặc RTX 5090.\n" +
                        "• **RAM:** 32GB - 64GB DDR5 Bus 6000MHz RGB.\n" +
                        "• **Tản nhiệt:** Tản nhiệt nước AIO 360 ARGB mát rượi có màn hình LCD.\n" +
                        "• **Vỏ Case:** Bể cá Panorama kính cường lực tuyệt đẹp.\n" +
                        "• Phù hợp: Gamer chuyên nghiệp, Streamer, Render 3D kiến trúc, mô hình AI Machine Learning!\n\n" +
                        "Các siêu phẩm High-end sẵn tại shop:",
                        Arrays.asList("Gợi ý PC AMD 30tr", "Chính sách bảo hành 36 tháng", "Hotline đặt hàng"),
                        list
                );
            }
            case "faq_warranty":
                return new ChatResult(
                        "🛡️ **CHÍNH SÁCH BẢO HÀNH & ĐỔI TRẢ TẠI " + ChatbotConfig.SHOP_NAME.toUpperCase() + ":**\n\n" +
                        "1. **Đổi mới 100% trong 30 ngày đầu:** Nếu linh kiện phát sinh lỗi từ nhà sản xuất, shop đổi mới ngay sản phẩm tương đương, không để khách phải đợi.\n" +
                        "2. **Bảo hành chính hãng 12 - 36 tháng:** Toàn bộ linh kiện mới được bảo hành chính hãng theo tem nhà phân phối (ASUS, MSI, Gigabyte, Kingston, Corsair...).\n" +
                        "3. **Hỗ trợ trọn đời:** Miễn phí vệ sinh máy, tra keo tản nhiệt và cài lại hệ điều hành trọn đời máy khi mua PC tại shop.\n" +
                        "4. **Hotline tiếp nhận bảo hành:** **" + ChatbotConfig.SHOP_HOTLINE + "** (xử lý nhanh chóng trong ngày).",
                        Arrays.asList("Chính sách giao hàng", "Tư vấn cấu hình PC", "Gặp tư vấn viên"),
                        null
                );
            case "faq_shipping":
                return new ChatResult(
                        "🚚 **CHÍNH SÁCH VẬN CHUYỂN & GIAO HÀNG:**\n\n" +
                        "• **Giao hàng nhanh nội thành:** Giao hỏa tốc 2 - 4 tiếng, nhân viên kỹ thuật hỗ trợ lắp đặt và cắm dây tận bàn.\n" +
                        "• **Ship COD toàn quốc:** Thùng hàng bọc xốp bọt khí chống sốc 3 lớp có nẹp góc gỗ bảo vệ tuyệt đối.\n" +
                        "• **Đồng kiểm khi nhận:** Quý khách được mở bưu kiện kiểm tra đúng sản phẩm, tem mác nguyên vẹn trước khi thanh toán tiền.\n" +
                        "• **Thời gian nhận hàng ngoại tỉnh:** 1 - 3 ngày làm việc.",
                        Arrays.asList("Chính sách đổi trả", "Phương thức thanh toán", "Tư vấn cấu hình"),
                        null
                );
            case "faq_installment":
                return new ChatResult(
                        "💳 **HƯỚNG DẪN MUA HÀNG TRẢ GÓP 0%:**\n\n" +
                        "1. **Trả góp 0% qua thẻ tín dụng (Credit Card):**\n" +
                        "   • Hỗ trợ hơn 25 ngân hàng lớn (Vietcombank, Techcombank, MB, VPBank, Sacombank...)\n" +
                        "   • Kỳ hạn linh hoạt: 3, 6, 9, 12 tháng. Quẹt thẻ trực tiếp hoặc thanh toán online 1 phút là xong.\n\n" +
                        "2. **Trả góp qua CCCD (Căn cước công dân gắn chip):**\n" +
                        "   • Duyệt hồ sơ online chỉ trong 15 phút, không cần chứng minh thu nhập phức tạp.\n" +
                        "   • Trả trước chỉ từ 10% - 30% giá trị bộ máy.\n\n" +
                        "Quý khách có thể liên hệ hotline **" + ChatbotConfig.SHOP_HOTLINE + "** để nhân viên tính trước bảng phí góp cụ thể nhé!",
                        Arrays.asList("Tư vấn cấu hình PC", "Chính sách bảo hành", "Gặp tư vấn viên"),
                        null
                );
            case "service_assembly":
                return new ChatResult(
                        "🛠️ **DỊCH VỤ LẮP RÁP PC & TỐI ƯU HỆ THỐNG:**\n\n" +
                        "• **Lắp ráp chuẩn chuyên gia:** Đi dây giấu nguồn thẩm mỹ mặt sau, tối ưu luồng gió khí động học (Airflow) mát rượi.\n" +
                        "• **Test Benchmark kỹ càng:** Chạy Furmark, Cinebench kiểm tra nhiệt độ CPU & GPU trước khi bàn giao khách.\n" +
                        "• **Miễn phí 100%:** Cài đặt Windows bản quyền dùng thử, Office, phần mềm đồ họa cơ bản và toàn bộ driver mới nhất.\n" +
                        "• Bạn có thể tự chọn từng linh kiện trên web hoặc gửi danh sách để shop báo giá tổng thể!",
                        Arrays.asList("Tư vấn cấu hình PC", "Dịch vụ thu cũ đổi mới", "Hotline shop"),
                        null
                );
            case "service_tradein":
                return new ChatResult(
                        "🔄 **CHƯƠNG TRÌNH THU CŨ ĐỔI MỚI (TRADE-IN PC):**\n\n" +
                        "• Thu mua lại máy cũ, case PC, linh kiện (CPU, VGA, RAM...) với giá tốt nhất thị trường.\n" +
                        "• **Trợ giá đặc biệt:** Tặng ngay voucher giảm giá từ **500.000 đ đến 2.000.000 đ** khi lên đời cấu hình máy mới tại shop.\n" +
                        "• Thủ tục định giá nhanh chóng trong 15 phút tại cửa hàng hoặc gửi ảnh linh kiện qua Zalo.",
                        Arrays.asList("Tư vấn cấu hình mới", "Gặp tư vấn viên Zalo", "Hotline shop"),
                        null
                );
            case "faq_contact":
            default:
                return new ChatResult(
                        "📞 **THÔNG TIN LIÊN HỆ & TỔNG ĐÀI HỖ TRỢ:**\n\n" +
                        "• **Cửa hàng:** " + ChatbotConfig.SHOP_NAME + " - " + ChatbotConfig.SHOP_SLOGAN + "\n" +
                        "• **Hotline / Zalo tư vấn 24/7:** **" + ChatbotConfig.SHOP_HOTLINE + "**\n" +
                        "• **Giờ làm việc:** " + ChatbotConfig.SHOP_HOURS + "\n" +
                        "• Hỗ trợ kỹ thuật, đặt lịch vệ sinh máy hoặc tư vấn cấu hình tùy biến riêng theo sở thích.",
                        Arrays.asList("Tư vấn cấu hình PC", "Chính sách bảo hành", "Chính sách giao hàng"),
                        null
                );
        }
    }

    private static boolean containsAny(String input, String... keywords) {
        if (input == null || keywords == null) return false;
        for (String kw : keywords) {
            if (input.contains(kw.toLowerCase())) return true;
        }
        return false;
    }
}
