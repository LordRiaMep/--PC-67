package model;

import java.util.Date;

public class News {
    private int id;
    private String title;
    private String summary;
    private String content;
    private String image;
    private String author;
    private int viewCount;
    private boolean featured;
    private String status;
    private Date createdAt;

    private String homeRole = "NONE";

    private int homeOrder = 0;

    private int sortOrder = 0;

    public News() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }

    public boolean isFeatured() { return featured; }
    public void setFeatured(boolean featured) { this.featured = featured; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getHomeRole() { return homeRole != null ? homeRole : "NONE"; }
    public void setHomeRole(String homeRole) { this.homeRole = homeRole; }

    public int getHomeOrder() { return homeOrder; }
    public void setHomeOrder(int homeOrder) { this.homeOrder = homeOrder; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public boolean isHomeMain() {
        return "MAIN".equalsIgnoreCase(this.homeRole);
    }

    public boolean isHomeSub() {
        return "SUB".equalsIgnoreCase(this.homeRole);
    }
}
