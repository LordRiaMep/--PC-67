package util;

import java.io.InputStream;
import java.util.Properties;

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
