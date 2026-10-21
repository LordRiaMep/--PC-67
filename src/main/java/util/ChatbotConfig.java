package util;

/**
 * ============================================================================
 * [PHÂN HỆ 3: SẢN PHẨM, NÂNG CẤP PC & GEMINI AI CHATBOT]
 * Phụ trách: Nhân Hiếu
 * Chức năng: Đọc và quản lý API Key, cấu hình model Google Gemini.
 * ============================================================================
 */

import java.io.InputStream;
import java.util.Properties;

/**
 * Cấu hình cho Chatbot Tư Vấn PC Độ-PC 67
 * Hỗ trợ nạp Gemini API Key từ chatbot.properties hoặc biến môi trường GEMINI_API_KEY
 */
public class ChatbotConfig {

    public static final String SHOP_NAME = "Độ-PC 67";
    public static final String SHOP_SLOGAN = "Chất Lượng Vượt Ngân Hà";
    public static final String SHOP_HOTLINE = "0904 112 618";
    public static final String SHOP_ZALO = "https://zalo.me/0904112618";
    public static final String SHOP_HOURS = "08:00 - 21:30 hàng ngày";

    private static String geminiApiKey = null;
    private static String geminiModel = "gemini-1.5-flash";

    static {
        loadConfig();
    }

    private static void loadConfig() {
        // 1. Kiểm tra file cấu hình chatbot.properties trong classpath
        try (InputStream is = ChatbotConfig.class.getClassLoader().getResourceAsStream("chatbot.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                String key = props.getProperty("gemini.api.key");
                if (key != null && !key.trim().isEmpty() && !key.contains("YOUR_API_KEY")) {
                    geminiApiKey = key.trim();
                }
                String model = props.getProperty("gemini.model");
                if (model != null && !model.trim().isEmpty()) {
                    geminiModel = model.trim();
                }
            }
        } catch (Exception ignored) {
        }

        // 2. Nếu chưa có, kiểm tra biến môi trường hoặc System Property
        if (geminiApiKey == null || geminiApiKey.isEmpty()) {
            String envKey = System.getenv("GEMINI_API_KEY");
            if (envKey != null && !envKey.trim().isEmpty()) {
                geminiApiKey = envKey.trim();
            } else {
                String sysKey = System.getProperty("gemini.api.key");
                if (sysKey != null && !sysKey.trim().isEmpty()) {
                    geminiApiKey = sysKey.trim();
                }
            }
        }
    }

    public static String getGeminiApiKey() {
        if (geminiApiKey == null) {
            loadConfig();
        }
        return geminiApiKey;
    }

    public static void setGeminiApiKey(String key) {
        geminiApiKey = key != null ? key.trim() : null;
    }

    public static String getGeminiModel() {
        return geminiModel;
    }

    public static boolean hasGeminiApiKey() {
        String key = getGeminiApiKey();
        return key != null && !key.trim().isEmpty() && !key.contains("YOUR_API_KEY");
    }
}
