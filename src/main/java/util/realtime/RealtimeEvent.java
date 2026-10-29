package util.realtime;

import com.google.gson.Gson;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

public class RealtimeEvent implements Serializable {
    private static final long serialVersionUID = 1L;
    private static final AtomicLong ID_GENERATOR = new AtomicLong(System.currentTimeMillis());
    private static final Gson GSON = new Gson();

    private long id;
    private String type;
    private String target;
    private int targetUserId;
    private String title;
    private String message;
    private String linkUrl;
    private String soundType;
    private long timestamp;
    private Map<String, Object> data = new HashMap<>();

    public RealtimeEvent() {
        this.id = ID_GENERATOR.incrementAndGet();
        this.timestamp = System.currentTimeMillis();
        this.target = "ALL";
        this.soundType = "info";
    }

    public RealtimeEvent(String type, String target, String title, String message) {
        this();
        this.type = type;
        this.target = target;
        this.title = title;
        this.message = message;
    }

    public RealtimeEvent withData(String key, Object val) {
        this.data.put(key, val);
        return this;
    }

    public RealtimeEvent withTargetUserId(int userId) {
        this.targetUserId = userId;
        return this;
    }

    public RealtimeEvent withLink(String linkUrl) {
        this.linkUrl = linkUrl;
        return this;
    }

    public RealtimeEvent withSound(String soundType) {
        this.soundType = soundType;
        return this;
    }

    public String toJson() {
        return GSON.toJson(this);
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTarget() { return target; }
    public void setTarget(String target) { this.target = target; }

    public int getTargetUserId() { return targetUserId; }
    public void setTargetUserId(int targetUserId) { this.targetUserId = targetUserId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getLinkUrl() { return linkUrl; }
    public void setLinkUrl(String linkUrl) { this.linkUrl = linkUrl; }

    public String getSoundType() { return soundType; }
    public void setSoundType(String soundType) { this.soundType = soundType; }

    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }

    public Map<String, Object> getData() { return data; }
    public void setData(Map<String, Object> data) { this.data = data; }
}
