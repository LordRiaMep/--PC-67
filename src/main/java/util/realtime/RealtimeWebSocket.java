package util.realtime;

import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@ServerEndpoint("/ws/realtime")
public class RealtimeWebSocket {
    private static final Logger LOGGER = Logger.getLogger(RealtimeWebSocket.class.getName());

    @OnOpen
    public void onOpen(Session session) {
        try {
            String query = session.getRequestURI().getQuery();
            RealtimeHub.registerSession(session, query);

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

        if ("ping".equalsIgnoreCase(message)) {
            try {
                session.getAsyncRemote().sendText("pong");
            } catch (Exception ignored) {}
        }
    }
}
