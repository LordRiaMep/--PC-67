package util;

import dao.WarehouseDao;
import model.WarehouseConfig;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GhnService {

    private static volatile String cachedProvincesJson = null;

    private static volatile WarehouseConfig cachedWarehouse = null;
    private static final WarehouseDao warehouseDao = new WarehouseDao();

    public static WarehouseConfig getWarehouseConfig() {
        if (cachedWarehouse == null) {
            cachedWarehouse = warehouseDao.getWarehouseConfig();
        }
        return cachedWarehouse;
    }

    public static void reloadWarehouseConfig() {
        cachedWarehouse = warehouseDao.getWarehouseConfig();
    }

    private static String sendHttpRequest(String urlStr, String method, String jsonBody, boolean includeShopId) {
        HttpURLConnection conn = null;
        try {
            URL url = java.net.URI.create(urlStr).toURL();
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod(method);
            conn.setRequestProperty("token", GhnConfig.API_TOKEN);
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            if (includeShopId) {
                conn.setRequestProperty("ShopId", String.valueOf(GhnConfig.SHOP_ID));
            }
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);

            if (jsonBody != null && !jsonBody.isEmpty()) {
                conn.setDoOutput(true);
                byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
                try (OutputStream os = conn.getOutputStream()) {
                    os.write(input, 0, input.length);
                }
            }

            int responseCode = conn.getResponseCode();
            InputStream is = (responseCode >= 200 && responseCode < 300)
                    ? conn.getInputStream()
                    : conn.getErrorStream();

            if (is == null) {
                return null;
            }

            StringBuilder response = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
            }
            return response.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    public static String getProvinces() {
        if (cachedProvincesJson != null) {
            return cachedProvincesJson;
        }

        String res = sendHttpRequest(GhnConfig.API_PROVINCE, "GET", null, false);
        if (res != null && !res.isEmpty()) {
            cachedProvincesJson = res;
            return cachedProvincesJson;
        }
        return "{\"code\":500,\"message\":\"Không thể tải danh sách tỉnh thành\",\"data\":[]}";
    }

    public static String getDistricts(int provinceId) {
        String jsonBody = "{\"province_id\":" + provinceId + "}";
        String res = sendHttpRequest(GhnConfig.API_DISTRICT, "POST", jsonBody, false);
        if (res != null && !res.isEmpty()) {
            return res;
        }
        return "{\"code\":500,\"message\":\"Không thể tải danh sách quận huyện\",\"data\":[]}";
    }

    public static String getWards(int districtId) {
        String jsonBody = "{\"district_id\":" + districtId + "}";
        String res = sendHttpRequest(GhnConfig.API_WARD, "POST", jsonBody, false);
        if (res != null && !res.isEmpty()) {
            return res;
        }
        return "{\"code\":500,\"message\":\"Không thể tải danh sách phường xã\",\"data\":[]}";
    }

    public static double calculateShippingFee(int toDistrictId, String toWardCode, int weightGram) {
        if (toDistrictId <= 0 || toWardCode == null || toWardCode.trim().isEmpty()) {
            return 30000.0;
        }

        int weight = weightGram > 0 ? weightGram : 1000;

        WarehouseConfig warehouse = getWarehouseConfig();
        int fromDistrictId = (warehouse != null && warehouse.getDistrictId() > 0)
                ? warehouse.getDistrictId()
                : GhnConfig.FROM_DISTRICT_ID;
        String fromWardCode = (warehouse != null && warehouse.getWardCode() != null && !warehouse.getWardCode().isEmpty())
                ? warehouse.getWardCode()
                : GhnConfig.FROM_WARD_CODE;

        String jsonBody = "{"
                + "\"from_district_id\":" + fromDistrictId + ","
                + "\"from_ward_code\":\"" + fromWardCode + "\","
                + "\"service_type_id\":2,"
                + "\"to_district_id\":" + toDistrictId + ","
                + "\"to_ward_code\":\"" + toWardCode.trim() + "\","
                + "\"height\":15,"
                + "\"length\":20,"
                + "\"width\":15,"
                + "\"weight\":" + weight
                + "}";

        String res = sendHttpRequest(GhnConfig.API_FEE, "POST", jsonBody, true);
        if (res != null) {
            Matcher m = Pattern.compile("\"total\":\\s*(\\d+)").matcher(res);
            if (m.find()) {
                try {
                    return Double.parseDouble(m.group(1));
                } catch (NumberFormatException ignored) {}
            }
        }

        return 30000.0;
    }
}
