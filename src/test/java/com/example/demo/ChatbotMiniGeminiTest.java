package com.example.demo;

import model.Product;
import service.ChatbotKnowledgeService;

public class ChatbotMiniGeminiTest {

    public static void main(String[] args) {
        ChatbotKnowledgeService service = new ChatbotKnowledgeService();
        int passed = 0;
        int total = 0;

        System.out.println("=================================================");
        System.out.println("TESTING MINI-GEMINI CHATBOT & SMART PC ENGINE");
        System.out.println("=================================================\n");

        total++;
        System.out.println(">>> TEST 1: 'cho tôi xem pc amd 30tr'");
        ChatbotKnowledgeService.ChatResult cr1 = service.handleQuery("cho tôi xem pc amd 30tr", null);
        System.out.println("Reply:\n" + cr1.getReply());
        System.out.println("Sản phẩm gợi ý:");
        boolean allAMD = true;
        for (Product p : cr1.getProducts()) {
            System.out.println("   * " + p.getName() + " - " + p.getPrice());
            if (!p.getName().toUpperCase().contains("AMD") && !p.getName().toUpperCase().contains("RYZEN")) {
                allAMD = false;
            }
        }
        if (allAMD && !cr1.getProducts().isEmpty() && !cr1.getReply().contains("tiêu chí:")) {
            System.out.println("===> TEST 1: PASSED! (Strictly AMD products, natural response)\n");
            passed++;
        } else {
            System.out.println("===> TEST 1: FAILED! (Contains non-AMD or debug tokens)\n");
        }

        total++;
        System.out.println(">>> TEST 2: 'gợi ý pc amd 30tr'");
        ChatbotKnowledgeService.ChatResult cr2 = service.handleQuery("gợi ý pc amd 30tr", null);
        System.out.println("Reply:\n" + cr2.getReply());
        allAMD = true;
        for (Product p : cr2.getProducts()) {
            System.out.println("   * " + p.getName() + " - " + p.getPrice());
            if (!p.getName().toUpperCase().contains("AMD") && !p.getName().toUpperCase().contains("RYZEN")) {
                allAMD = false;
            }
        }
        if (allAMD && !cr2.getProducts().isEmpty() && !cr2.getReply().contains("tiêu chí:")) {
            System.out.println("===> TEST 2: PASSED!\n");
            passed++;
        } else {
            System.out.println("===> TEST 2: FAILED!\n");
        }

        total++;
        System.out.println(">>> TEST 3: 'pc intel 20tr'");
        ChatbotKnowledgeService.ChatResult cr3 = service.handleQuery("pc intel 20tr", null);
        System.out.println("Reply:\n" + cr3.getReply());
        boolean allIntel = true;
        for (Product p : cr3.getProducts()) {
            System.out.println("   * " + p.getName() + " - " + p.getPrice());
            if (!p.getName().toUpperCase().contains("INTEL") && !p.getName().toUpperCase().contains("CORE")) {
                allIntel = false;
            }
        }
        if (allIntel && !cr3.getProducts().isEmpty()) {
            System.out.println("===> TEST 3: PASSED! (Strictly Intel products)\n");
            passed++;
        } else {
            System.out.println("===> TEST 3: FAILED!\n");
        }

        total++;
        System.out.println(">>> TEST 4: 'pc rtx 5060'");
        ChatbotKnowledgeService.ChatResult cr4 = service.handleQuery("pc rtx 5060", null);
        System.out.println("Reply:\n" + cr4.getReply());
        boolean has5060 = false;
        for (Product p : cr4.getProducts()) {
            System.out.println("   * " + p.getName() + " - " + p.getPrice());
            if (p.getName().contains("5060")) has5060 = true;
        }
        if (has5060) {
            System.out.println("===> TEST 4: PASSED! (Found RTX 5060 build)\n");
            passed++;
        } else {
            System.out.println("===> TEST 4: FAILED!\n");
        }

        total++;
        System.out.println(">>> TEST 5: 'so sánh chip amd và intel'");
        ChatbotKnowledgeService.ChatResult cr5 = service.handleQuery("so sánh chip amd và intel", null);
        System.out.println("Reply:\n" + cr5.getReply());
        if (cr5.getReply().contains("AMD Ryzen") && cr5.getReply().contains("Intel Core")) {
            System.out.println("===> TEST 5: PASSED!\n");
            passed++;
        } else {
            System.out.println("===> TEST 5: FAILED!\n");
        }

        total++;
        System.out.println(">>> TEST 6: 'lập trình web nên học gì'");
        ChatbotKnowledgeService.ChatResult cr6 = service.handleQuery("lập trình web nên học gì", null);
        System.out.println("Reply:\n" + cr6.getReply());
        if (cr6.getReply().contains("Frontend") && cr6.getReply().contains("Backend")) {
            System.out.println("===> TEST 6: PASSED!\n");
            passed++;
        } else {
            System.out.println("===> TEST 6: FAILED!\n");
        }

        total++;
        System.out.println(">>> TEST 7: '15 triệu trả góp 6 tháng mỗi tháng bao nhiêu'");
        ChatbotKnowledgeService.ChatResult cr7 = service.handleQuery("15 triệu trả góp 6 tháng mỗi tháng bao nhiêu", null);
        System.out.println("Reply:\n" + cr7.getReply());
        if (cr7.getReply().contains("2.500.000")) {
            System.out.println("===> TEST 7: PASSED!\n");
            passed++;
        } else {
            System.out.println("===> TEST 7: FAILED!\n");
        }

        total++;
        System.out.println(">>> TEST 8: 'bạn là ai'");
        ChatbotKnowledgeService.ChatResult cr8 = service.handleQuery("bạn là ai", null);
        System.out.println("Reply:\n" + cr8.getReply());
        if (cr8.getReply().contains("Gemini thu nhỏ") || cr8.getReply().contains("Trợ lý AI")) {
            System.out.println("===> TEST 8: PASSED!\n");
            passed++;
        } else {
            System.out.println("===> TEST 8: FAILED!\n");
        }

        total++;
        System.out.println(">>> TEST 9: 'kể chuyện cười đi'");
        ChatbotKnowledgeService.ChatResult cr9 = service.handleQuery("kể chuyện cười đi", null);
        System.out.println("Reply:\n" + cr9.getReply());
        if (cr9.getReply().contains("CHUYỆN CƯỜI")) {
            System.out.println("===> TEST 9: PASSED!\n");
            passed++;
        } else {
            System.out.println("===> TEST 9: FAILED!\n");
        }

        total++;
        System.out.println(">>> TEST 10: 'Kiểm tra thông số sản phẩm #51 (ASUS ROG Astral RTX 5090)'");
        dao.ProductDao pDao = new dao.ProductDao();
        Product p51 = pDao.getProductById(51);
        if (p51 != null) {
            System.out.println("Name: " + p51.getName());
            System.out.println("Description (Mô tả ngắn): " + p51.getDescription());
            System.out.println("Thông số chi tiết (p.specList):");
            for (String spec : p51.getSpecList()) {
                System.out.println("   [✓] " + spec);
            }
            boolean matched = p51.getSpecList().size() == 5
                    && p51.getSpecList().get(0).contains("PCI Express 5.0")
                    && p51.getSpecList().get(1).contains("21760")
                    && p51.getSpecList().get(4).contains("32 GB GDDR7");
            if (matched) {
                System.out.println("===> TEST 10: PASSED! (Thông số khớp 100% với Admin đã nhập)\n");
                passed++;
            } else {
                System.out.println("===> TEST 10: FAILED!\n");
            }
        } else {
            System.out.println("===> TEST 10: FAILED! (Product 51 not found)\n");
        }

        System.out.println("=================================================");
        System.out.println("FINAL RESULT: " + passed + " / " + total + " TESTS PASSED!");
        System.out.println("=================================================");
    }
}
