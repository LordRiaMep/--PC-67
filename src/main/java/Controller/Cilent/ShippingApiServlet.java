package Controller.Cilent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.GhnService;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "ShippingApiServlet", urlPatterns = {"/shipping-api"})
public class ShippingApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        PrintWriter out = response.getWriter();

        switch (action) {
            case "provinces": {
                String json = GhnService.getProvinces();
                out.print(json);
                break;
            }
            case "districts": {
                int provinceId = 0;
                try {
                    provinceId = Integer.parseInt(request.getParameter("provinceId"));
                } catch (Exception ignored) {}
                String json = GhnService.getDistricts(provinceId);
                out.print(json);
                break;
            }
            case "wards": {
                int districtId = 0;
                try {
                    districtId = Integer.parseInt(request.getParameter("districtId"));
                } catch (Exception ignored) {}
                String json = GhnService.getWards(districtId);
                out.print(json);
                break;
            }
            case "fee": {
                int districtId = 0;
                try {
                    districtId = Integer.parseInt(request.getParameter("districtId"));
                } catch (Exception ignored) {}
                String wardCode = request.getParameter("wardCode");
                int weight = 1000;
                try {
                    String weightParam = request.getParameter("weight");
                    if (weightParam != null) {
                        weight = Integer.parseInt(weightParam);
                    }
                } catch (Exception ignored) {}

                double fee = GhnService.calculateShippingFee(districtId, wardCode, weight);

                String feeJson = String.format("{\"success\":true,\"fee\":%.0f}", fee);
                out.print(feeJson);
                break;
            }
            default: {
                out.print("{\"success\":false,\"message\":\"Invalid action\"}");
                break;
            }
        }
        out.flush();
    }
}
