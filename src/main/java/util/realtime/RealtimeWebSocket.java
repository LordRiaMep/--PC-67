package util.realtime;

/**
 * ============================================================================
 * [PHÂN HỆ 2: REALTIME WEBSOCKET HUB, DASHBOARD DOANH THU & CSKH]
 * Phụ trách: Quang
 * Chức năng: Điểm cuối WebSocket (@ServerEndpoint) quản lý kết nối 2 chiều giữa browser và server.
 * ============================================================================
 */

import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WebSocket Server Endpoint cho kết nối 2 chiều giữa Browser và Server.
 * Khách hàng và Admin khi mở web sẽ tự động kết nối tới ws://localhost:8080/demo_war_exploded/ws/realtime
 */
@ServerEndpoint("/ws/realtime")
public class RealtimeWebSocket {
    private static final Logger LOGGER = Logger.getLogger(RealtimeWebSocket.class.getName());

    @OnOpen
    public void onOpen(Session session) {
        try {
            String query = session.getRequestURI().getQuery();
            RealtimeHub.registerSession(session, query);
            // Gửi tin chào mừng xác nhận kết nối thành công
            session.getAsyncRemote().sendText("{\"type\":\"CONNECTED\",\"message\":\"Realtime WebSocket Connected\"}");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[RealtimeWebSocket] Lỗi onOpen", e);
        }
    }

    @OnClose
    public void onClose(Session session, CloseReason reason) {
        RealtimeHub.unregisterSession(session);
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        RealtimeHub.unregisterSession(session);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        // Heartbeat ping-pong để giữ kết nối sống qua proxy/browser
        if ("ping".equalsIgnoreCase(message)) {
            try {
                session.getAsyncRemote().sendText("pong");
            } catch (Exception ignored) {}
        }
    }
}
