package util;

public class EmailConfig {

    public static final String SMTP_HOST = "smtp-relay.brevo.com";
    public static final int SMTP_PORT = 465;

    public static String SMTP_USERNAME = System.getenv("SMTP_USERNAME") != null ? System.getenv("SMTP_USERNAME") : "bdbd76001@smtp-brevo.com";
    public static String SMTP_PASSWORD = System.getenv("SMTP_PASSWORD") != null ? System.getenv("SMTP_PASSWORD") : "YOUR_BREVO_SMTP_KEY";

    public static String SENDER_EMAIL = "dopc6767@gmail.com";
    public static String SENDER_NAME = "Độ-PC 67 Store";

    public static boolean DEV_MODE = false;
}
