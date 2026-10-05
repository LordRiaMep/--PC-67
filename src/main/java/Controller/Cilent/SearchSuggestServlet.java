package Controller.Cilent;


import dao.ProductDao;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "SearchSuggestServlet", urlPatterns = {"/search-suggest"})
public class SearchSuggestServlet extends HttpServlet {

    private static final int MAX_SUGGESTIONS = 5; // số sản phẩm gợi ý

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");
        keyword = (keyword == null) ? "" : keyword.trim();

        StringBuilder json = new StringBuilder("[");

        if (!keyword.isEmpty()) {
            ProductDao dao = new ProductDao();
            List<Product> list = dao.searchSuggestions(keyword, MAX_SUGGESTIONS);

            for (int i = 0; i < list.size(); i++) {
                Product p = list.get(i);
                if (i > 0) json.append(",");
                json.append("{")
                        .append("\"id\":").append(p.getId()).append(",")
                        .append("\"name\":\"").append(escape(p.getName())).append("\",")
                        .append("\"image\":\"").append(escape(p.getImage())).append("\",")
                        .append("\"price\":").append((long) p.getPrice())
                        .append("}");
            }
        }

        json.append("]");

        try (PrintWriter out = response.getWriter()) {
            out.print(json);
        }
    }

    // Escape ký tự đặc biệt để JSON không bị lỗi
    private String escape(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }
}








