package util;

import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class EmailService {

    private static final ExecutorService executor = Executors.newFixedThreadPool(3);

    private static final Map<String, String> latestDevLinks = new ConcurrentHashMap<>();
    private static final Map<String, String> latestDevOtps = new ConcurrentHashMap<>();

    public static String getLatestDevLink(String email) {
        if (email == null) return null;
        return latestDevLinks.get(email.trim().toLowerCase());
    }

    public static String getLatestDevOtp(String email) {
        if (email == null) return null;
        return latestDevOtps.get(email.trim().toLowerCase());
    }

    public static void sendVerificationEmail(String recipientEmail, String recipientName, String verifyLink, String otpCode) {
        if (recipientEmail == null || recipientEmail.trim().isEmpty()) return;
        String cleanEmail = recipientEmail.trim().toLowerCase();

        latestDevLinks.put(cleanEmail, verifyLink);
        if (otpCode != null) latestDevOtps.put(cleanEmail, otpCode);

        printConsoleNotification("XÁC NHẬN TẠO TÀI KHOẢN", cleanEmail, recipientName, verifyLink, otpCode);

        executor.submit(() -> {
            String subject = "Xác nhận tạo tài khoản thành công - Độ-PC 67";
            String content = buildVerificationEmailHtml(recipientName, verifyLink, otpCode);
            sendSmtpEmail(cleanEmail, recipientName, subject, content);
        });
    }

    public static void sendResetPasswordEmail(String recipientEmail, String recipientName, String resetLink, String otpCode) {
        if (recipientEmail == null || recipientEmail.trim().isEmpty()) return;
        String cleanEmail = recipientEmail.trim().toLowerCase();

        latestDevLinks.put(cleanEmail, resetLink);
        if (otpCode != null) latestDevOtps.put(cleanEmail, otpCode);

        printConsoleNotification("YÊU CẦU ĐẶT LẠI MẬT KHẨU", cleanEmail, recipientName, resetLink, otpCode);

        executor.submit(() -> {
            String subject = "Yêu cầu đặt lại mật khẩu tài khoản - Độ-PC 67";
            String content = buildResetPasswordEmailHtml(recipientName, resetLink, otpCode);
            sendSmtpEmail(cleanEmail, recipientName, subject, content);
        });
    }

    public static void sendOtpChangePasswordEmail(String recipientEmail, String recipientName, String otpCode) {
        if (recipientEmail == null || recipientEmail.trim().isEmpty()) return;
        String cleanEmail = recipientEmail.trim().toLowerCase();

        if (otpCode != null) latestDevOtps.put(cleanEmail, otpCode);

        printConsoleNotification("MÃ OTP XÁC THỰC ĐỔI MẬT KHẨU", cleanEmail, recipientName, null, otpCode);

        executor.submit(() -> {
            String subject = "Mã OTP xác thực đổi mật khẩu - Độ-PC 67";
            String content = buildOtpChangePasswordEmailHtml(recipientName, otpCode);
            sendSmtpEmail(cleanEmail, recipientName, subject, content);
        });
    }

    public static boolean sendSmtpEmail(String toEmail, String toName, String subject, String htmlContent) {
        if (EmailConfig.SMTP_PASSWORD == null || EmailConfig.SMTP_PASSWORD.trim().isEmpty()) {
            System.err.println("[EmailService] Chưa cấu hình SMTP_PASSWORD!");
            return false;
        }

        try (SSLSocket socket = (SSLSocket) SSLSocketFactory.getDefault().createSocket(EmailConfig.SMTP_HOST, EmailConfig.SMTP_PORT)) {
            socket.setSoTimeout(15000);

            BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream(), StandardCharsets.UTF_8));

            int code = readSmtpResponse(reader);
            if (code != 220) {
                System.err.println("[Brevo SMTP Error] Greeting thất bại, code: " + code);
                return false;
            }

            sendSmtpLine(writer, "EHLO localhost");
            code = readSmtpResponse(reader);
            if (code != 250) {
                System.err.println("[Brevo SMTP Error] EHLO thất bại, code: " + code);
                return false;
            }

            sendSmtpLine(writer, "AUTH LOGIN");
            code = readSmtpResponse(reader);
            if (code != 334) {
                System.err.println("[Brevo SMTP Error] AUTH LOGIN thất bại, code: " + code);
                return false;
            }

            String authUser = (EmailConfig.SMTP_USERNAME != null && !EmailConfig.SMTP_USERNAME.trim().isEmpty())
                    ? EmailConfig.SMTP_USERNAME.trim()
                    : EmailConfig.SENDER_EMAIL.trim();

            sendSmtpLine(writer, Base64.getEncoder().encodeToString(authUser.getBytes(StandardCharsets.UTF_8)));
            code = readSmtpResponse(reader);
            if (code != 334) {
                System.err.println("[Brevo SMTP Error] Xác thực Username thất bại, code: " + code);
                return false;
            }

            String cleanPw = EmailConfig.SMTP_PASSWORD.replaceAll("\\s+", "");
            sendSmtpLine(writer, Base64.getEncoder().encodeToString(cleanPw.getBytes(StandardCharsets.UTF_8)));
            code = readSmtpResponse(reader);
            if (code != 235) {
                if (code == 525) {
                    System.err.println("[Brevo SMTP Error] IP chưa được cấp quyền (Unauthorized IP), code: 525. Cần thêm IP vào Brevo -> Authorized IPs!");
                } else {
                    System.err.println("[Brevo SMTP Error] Xác thực Password thất bại, code: " + code);
                }
                return false;
            }

            sendSmtpLine(writer, "MAIL FROM:<" + EmailConfig.SENDER_EMAIL.trim() + ">");
            code = readSmtpResponse(reader);
            if (code != 250) {
                System.err.println("[Brevo SMTP Error] MAIL FROM thất bại, code: " + code);
                return false;
            }

            sendSmtpLine(writer, "RCPT TO:<" + toEmail.trim() + ">");
            code = readSmtpResponse(reader);
            if (code != 250) {
                System.err.println("[Brevo SMTP Error] RCPT TO thất bại, code: " + code);
                return false;
            }

            sendSmtpLine(writer, "DATA");
            code = readSmtpResponse(reader);
            if (code != 354) {
                System.err.println("[Brevo SMTP Error] DATA command thất bại, code: " + code);
                return false;
            }

            String b64SenderName = Base64.getEncoder().encodeToString(EmailConfig.SENDER_NAME.getBytes(StandardCharsets.UTF_8));
            String b64Subject = Base64.getEncoder().encodeToString(subject.getBytes(StandardCharsets.UTF_8));

            writer.write("From: =?UTF-8?B?" + b64SenderName + "?= <" + EmailConfig.SENDER_EMAIL.trim() + ">\r\n");
            writer.write("To: <" + toEmail.trim() + ">\r\n");
            writer.write("Subject: =?UTF-8?B?" + b64Subject + "?=\r\n");
            writer.write("MIME-Version: 1.0\r\n");
            writer.write("Content-Type: text/html; charset=UTF-8\r\n");
            writer.write("Content-Transfer-Encoding: base64\r\n");
            writer.write("\r\n");

            String b64Body = Base64.getEncoder().encodeToString(htmlContent.getBytes(StandardCharsets.UTF_8));
            for (int i = 0; i < b64Body.length(); i += 76) {
                int end = Math.min(i + 76, b64Body.length());
                writer.write(b64Body.substring(i, end) + "\r\n");
            }

            writer.write(".\r\n");
            writer.flush();

            code = readSmtpResponse(reader);
            if (code != 250) {
                System.err.println("[Brevo SMTP Error] Gửi nội dung DATA thất bại, code: " + code);
                return false;
            }

            sendSmtpLine(writer, "QUIT");
            System.out.println("================================================================================");
            System.out.println("  [BREVO SMTP] GỬI EMAIL THẬT THÀNH CÔNG ĐẾN HỘP THƯ KHÁCH HÀNG!");
            System.out.println("  Người nhận : " + toEmail);
            System.out.println("  Tiêu đề    : " + subject);
            System.out.println("================================================================================");
            return true;
        } catch (Exception e) {
            System.err.println("[EmailService] Lỗi kết nối Brevo SMTP: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private static void sendSmtpLine(BufferedWriter writer, String line) throws IOException {
        writer.write(line + "\r\n");
        writer.flush();
    }

    private static int readSmtpResponse(BufferedReader reader) throws IOException {
        String line;
        int code = 0;
        while ((line = reader.readLine()) != null) {
            if (line.length() >= 3) {
                try {
                    code = Integer.parseInt(line.substring(0, 3));
                } catch (Exception ignored) {}
                if (line.length() == 3 || line.charAt(3) != '-') {
                    break;
                }
            }
        }
        return code;
    }

    private static void printConsoleNotification(String type, String email, String name, String link, String otp) {
        System.out.println("================================================================================");
        System.out.println("  [ĐỘ-PC 67] BẮT ĐẦU GỬI EMAIL THẬT");
        System.out.println("  Loại yêu cầu : " + type);
        System.out.println("  Người nhận   : " + (name != null ? name : "Khách hàng") + " <" + email + ">");
        if (otp != null) {
            System.out.println("  Mã OTP       : " + otp);
        }
        if (link != null) {
            System.out.println("  Liên kết URL : " + link);
        }
        System.out.println("================================================================================");
    }

    private static String buildVerificationEmailHtml(String name, String verifyLink, String otpCode) {
        String displayName = (name != null && !name.trim().isEmpty()) ? name : "Quý khách";
        return "<!DOCTYPE html>"
                + "<html lang='vi'>"
                + "<head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,sans-serif;color:#333;'>"
                + "  <table width='100%' cellpadding='0' cellspacing='0' style='background-color:#f4f6f8;padding:30px 0;'>"
                + "    <tr><td align='center'>"
                + "      <table width='600' cellpadding='0' cellspacing='0' style='background-color:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 4px 15px rgba(0,0,0,0.08);'>"
                + "        <!-- HEADER -->"
                + "        <tr><td style='background-color:#E30019;padding:24px 30px;text-align:center;color:#ffffff;'>"
                + "          <h1 style='margin:0;font-size:24px;font-weight:bold;letter-spacing:1px;'>ĐỘ-PC 67</h1>"
                + "          <p style='margin:6px 0 0;font-size:13px;opacity:0.9;'>HỆ THỐNG MÁY TÍNH & LINH KIỆN CAO CẤP</p>"
                + "        </td></tr>"
                + "        <!-- BODY -->"
                + "        <tr><td style='padding:35px 35px 25px;'>"
                + "          <h2 style='color:#1f2937;font-size:20px;margin-top:0;'>Xin chào " + displayName + ",</h2>"
                + "          <p style='font-size:15px;line-height:1.6;color:#4b5563;'>"
                + "            Cảm ơn bạn đã đăng ký tài khoản thành viên tại <strong>Độ-PC 67</strong>. "
                + "            Để hoàn tất quá trình tạo tài khoản và bắt đầu mua sắm, bạn vui lòng nhấn vào nút xác nhận bên dưới:"
                + "          </p>"
                + "          <!-- BUTTON -->"
                + "          <div style='text-align:center;margin:30px 0;'>"
                + "            <a href='" + verifyLink + "' target='_blank' style='background-color:#E30019;color:#ffffff;padding:14px 32px;font-size:16px;font-weight:bold;text-decoration:none;border-radius:8px;display:inline-block;box-shadow:0 4px 10px rgba(227,0,25,0.3);'>"
                + "              XÁC NHẬN TẠO TÀI KHOẢN"
                + "            </a>"
                + "          </div>"
                + "          <div style='background-color:#fff1f2;border-left:4px solid #E30019;padding:12px 16px;border-radius:6px;margin:25px 0;font-size:13px;color:#9f1239;'>"
                + "            <strong>Lưu ý:</strong> Liên kết xác nhận này có hiệu lực trong vòng <strong>24 giờ</strong>. Sau khi xác nhận thành công, hệ thống sẽ tự động chuyển bạn về trang đăng nhập để tiếp tục mua sắm."
                + "          </div>"
                + "          <p style='font-size:12px;color:#9ca3af;word-break:break-all;'>"
                + "            Nếu nút bấm trên không hoạt động, vui lòng copy liên kết sau vào trình duyệt:<br>"
                + "            <a href='" + verifyLink + "' style='color:#E30019;'>" + verifyLink + "</a>"
                + "          </p>"
                + "        </td></tr>"
                + "        <!-- FOOTER -->"
                + "        <tr><td style='background-color:#f9fafb;padding:20px 30px;border-top:1px solid #e5e7eb;text-align:center;font-size:13px;color:#6b7280;'>"
                + "          <p style='margin:0 0 6px;'>Hotline hỗ trợ: <strong style='color:#E30019;'>090.411.2618</strong> | Email: <strong>cskh@dopc67.vn</strong></p>"
                + "          <p style='margin:0;font-size:12px;color:#9ca3af;'>© 2026 Độ-PC 67. Tất cả các quyền được bảo lưu.</p>"
                + "        </td></tr>"
                + "      </table>"
                + "    </td></tr>"
                + "  </table>"
                + "</body></html>";
    }

    private static String buildResetPasswordEmailHtml(String name, String resetLink, String otpCode) {
        String displayName = (name != null && !name.trim().isEmpty()) ? name : "Quý khách";
        return "<!DOCTYPE html>"
                + "<html lang='vi'>"
                + "<head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,sans-serif;color:#333;'>"
                + "  <table width='100%' cellpadding='0' cellspacing='0' style='background-color:#f4f6f8;padding:30px 0;'>"
                + "    <tr><td align='center'>"
                + "      <table width='600' cellpadding='0' cellspacing='0' style='background-color:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 4px 15px rgba(0,0,0,0.08);'>"
                + "        <!-- HEADER -->"
                + "        <tr><td style='background-color:#E30019;padding:24px 30px;text-align:center;color:#ffffff;'>"
                + "          <h1 style='margin:0;font-size:24px;font-weight:bold;letter-spacing:1px;'>ĐỘ-PC 67</h1>"
                + "          <p style='margin:6px 0 0;font-size:13px;opacity:0.9;'>YÊU CẦU ĐẶT LẠI MẬT KHẨU</p>"
                + "        </td></tr>"
                + "        <!-- BODY -->"
                + "        <tr><td style='padding:35px 35px 25px;'>"
                + "          <h2 style='color:#1f2937;font-size:20px;margin-top:0;'>Xin chào " + displayName + ",</h2>"
                + "          <p style='font-size:15px;line-height:1.6;color:#4b5563;'>"
                + "            Hệ thống nhận được yêu cầu đặt lại mật khẩu cho tài khoản Độ-PC 67 của bạn. "
                + "            Vui lòng nhấn vào nút bên dưới để thiết lập mật khẩu mới:"
                + "          </p>"
                + "          <!-- BUTTON -->"
                + "          <div style='text-align:center;margin:30px 0;'>"
                + "            <a href='" + resetLink + "' target='_blank' style='background-color:#E30019;color:#ffffff;padding:14px 32px;font-size:16px;font-weight:bold;text-decoration:none;border-radius:8px;display:inline-block;box-shadow:0 4px 10px rgba(227,0,25,0.3);'>"
                + "              ĐẶT LẠI MẬT KHẨU"
                + "            </a>"
                + "          </div>"
                + "          <div style='background-color:#fef3c7;border-left:4px solid #f59e0b;padding:12px 16px;border-radius:6px;margin:25px 0;font-size:13px;color:#92400e;'>"
                + "            <strong>Lưu ý:</strong> Liên kết này sẽ hết hạn sau <strong>30 phút</strong>. Nếu bạn không gửi yêu cầu này, vui lòng bỏ qua email hoặc đổi mật khẩu để bảo vệ tài khoản."
                + "          </div>"
                + "          <p style='font-size:12px;color:#9ca3af;word-break:break-all;'>"
                + "            Nếu nút bấm trên không hoạt động, bạn hãy truy cập liên kết:<br>"
                + "            <a href='" + resetLink + "' style='color:#E30019;'>" + resetLink + "</a>"
                + "          </p>"
                + "        </td></tr>"
                + "        <!-- FOOTER -->"
                + "        <tr><td style='background-color:#f9fafb;padding:20px 30px;border-top:1px solid #e5e7eb;text-align:center;font-size:13px;color:#6b7280;'>"
                + "          <p style='margin:0 0 6px;'>Hotline hỗ trợ: <strong style='color:#E30019;'>090.411.2618</strong> | Email: <strong>cskh@dopc67.vn</strong></p>"
                + "          <p style='margin:0;font-size:12px;color:#9ca3af;'>© 2026 Độ-PC 67. Tất cả các quyền được bảo lưu.</p>"
                + "        </td></tr>"
                + "      </table>"
                + "    </td></tr>"
                + "  </table>"
                + "</body></html>";
    }

    private static String buildOtpChangePasswordEmailHtml(String name, String otpCode) {
        String displayName = (name != null && !name.trim().isEmpty()) ? name : "Quý khách";
        return "<!DOCTYPE html>"
                + "<html lang='vi'>"
                + "<head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;background-color:#f4f6f8;font-family:Arial,sans-serif;color:#333;'>"
                + "  <table width='100%' cellpadding='0' cellspacing='0' style='background-color:#f4f6f8;padding:30px 0;'>"
                + "    <tr><td align='center'>"
                + "      <table width='600' cellpadding='0' cellspacing='0' style='background-color:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 4px 15px rgba(0,0,0,0.08);'>"
                + "        <!-- HEADER -->"
                + "        <tr><td style='background-color:#E30019;padding:24px 30px;text-align:center;color:#ffffff;'>"
                + "          <h1 style='margin:0;font-size:24px;font-weight:bold;letter-spacing:1px;'>ĐỘ-PC 67</h1>"
                + "          <p style='margin:6px 0 0;font-size:13px;opacity:0.9;'>XÁC THỰC THAY ĐỔI MẬT KHẨU</p>"
                + "        </td></tr>"
                + "        <!-- BODY -->"
                + "        <tr><td style='padding:35px 35px 25px;'>"
                + "          <h2 style='color:#1f2937;font-size:20px;margin-top:0;'>Xin chào " + displayName + ",</h2>"
                + "          <p style='font-size:15px;line-height:1.6;color:#4b5563;'>"
                + "            Bạn vừa yêu cầu thay đổi mật khẩu tài khoản tại Độ-PC 67. "
                + "            Đây là mã xác nhận (OTP) để hoàn tất thao tác:"
                + "          </p>"
                + "          <!-- OTP BOX -->"
                + "          <div style='text-align:center;margin:30px 0;background-color:#fef2f2;border:2px dashed #E30019;padding:20px;border-radius:10px;'>"
                + "            <span style='font-size:32px;font-weight:bold;letter-spacing:6px;color:#E30019;'>" + otpCode + "</span>"
                + "            <p style='margin:8px 0 0;font-size:13px;color:#6b7280;'>Mã OTP có hiệu lực trong 10 phút</p>"
                + "          </div>"
                + "          <div style='background-color:#fee2e2;border-left:4px solid #ef4444;padding:12px 16px;border-radius:6px;margin:25px 0;font-size:13px;color:#991b1b;'>"
                + "            <strong>Cảnh báo bảo mật:</strong> Tuyệt đối không chia sẻ mã này cho bất kỳ ai, kể cả nhân viên Độ-PC 67."
                + "          </div>"
                + "        </td></tr>"
                + "        <!-- FOOTER -->"
                + "        <tr><td style='background-color:#f9fafb;padding:20px 30px;border-top:1px solid #e5e7eb;text-align:center;font-size:13px;color:#6b7280;'>"
                + "          <p style='margin:0 0 6px;'>Hotline hỗ trợ: <strong style='color:#E30019;'>090.411.2618</strong> | Email: <strong>cskh@dopc67.vn</strong></p>"
                + "          <p style='margin:0;font-size:12px;color:#9ca3af;'>© 2026 Độ-PC 67. Tất cả các quyền được bảo lưu.</p>"
                + "        </td></tr>"
                + "      </table>"
                + "    </td></tr>"
                + "  </table>"
                + "</body></html>";
    }
}
