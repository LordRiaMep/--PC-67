package util;

import jakarta.servlet.http.HttpServletRequest;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

public class VnpayUtil {

    public static String hmacSHA512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : raw) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Lỗi tạo chữ ký VNPay", e);
        }
    }

    private static String urlEncode(String s) {
        try {
            return URLEncoder.encode(s, "US-ASCII");
        } catch (java.io.UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }

    public static String hashData(Map<String, String> params) {
        List<String> names = new ArrayList<>(params.keySet());
        Collections.sort(names);
        StringBuilder sb = new StringBuilder();
        for (String n : names) {
            String v = params.get(n);
            if (v == null || v.isEmpty()) continue;
            if (sb.length() > 0) sb.append('&');
            sb.append(n).append('=').append(urlEncode(v));
        }
        return sb.toString();
    }

    public static String buildPaymentUrl(String txnRef, long amountVnd, String orderInfo,
                                         String ipAddr, String returnUrl) {
        Map<String, String> p = new HashMap<>();
        p.put("vnp_Version", "2.1.0");
        p.put("vnp_Command", "pay");
        p.put("vnp_TmnCode", VnpayConfig.TMN_CODE);
        p.put("vnp_Amount", String.valueOf(amountVnd * 100));
        p.put("vnp_CurrCode", "VND");
        if (!VnpayConfig.BANK_CODE.isEmpty()) p.put("vnp_BankCode", VnpayConfig.BANK_CODE);
        p.put("vnp_TxnRef", txnRef);
        p.put("vnp_OrderInfo", orderInfo);
        p.put("vnp_OrderType", "other");
        p.put("vnp_Locale", "vn");
        p.put("vnp_ReturnUrl", returnUrl);
        p.put("vnp_IpAddr", ipAddr);

        TimeZone vn = TimeZone.getTimeZone("Asia/Ho_Chi_Minh");
        SimpleDateFormat f = new SimpleDateFormat("yyyyMMddHHmmss");
        f.setTimeZone(vn);
        Calendar cal = Calendar.getInstance(vn);
        p.put("vnp_CreateDate", f.format(cal.getTime()));
        cal.add(Calendar.MINUTE, 15);
        p.put("vnp_ExpireDate", f.format(cal.getTime()));

        String data = hashData(p);
        String secureHash = hmacSHA512(VnpayConfig.HASH_SECRET, data);
        return VnpayConfig.PAY_URL + "?" + data + "&vnp_SecureHash=" + secureHash;
    }

    public static boolean verifyReturn(HttpServletRequest req) {
        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> e = req.getParameterNames(); e.hasMoreElements(); ) {
            String n = e.nextElement();
            if (n.startsWith("vnp_") && !n.equals("vnp_SecureHash") && !n.equals("vnp_SecureHashType")) {
                fields.put(n, req.getParameter(n));
            }
        }
        String received = req.getParameter("vnp_SecureHash");
        if (received == null) return false;
        return hmacSHA512(VnpayConfig.HASH_SECRET, hashData(fields)).equalsIgnoreCase(received);
    }

    public static String getClientIp(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) ip = req.getRemoteAddr();
        if (ip.contains(",")) ip = ip.split(",")[0].trim();
        if (ip.contains(":")) ip = "127.0.0.1";
        return ip;
    }

    public static String baseUrl(HttpServletRequest req) {
        int port = req.getServerPort();
        String portPart = (port == 80 || port == 443) ? "" : ":" + port;
        return req.getScheme() + "://" + req.getServerName() + portPart + req.getContextPath();
    }
}
