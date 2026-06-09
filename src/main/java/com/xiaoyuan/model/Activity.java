package com.xiaoyuan.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Activity entity representing a campus activity/event.
 */
public class Activity implements Serializable {

    private int id;
    private int organizerId;
    private int categoryId;
    private String title;
    private String location;
    private LocalDateTime activityTime;
    private LocalDateTime regStart;
    private LocalDateTime regEnd;
    private int maxParticipants;
    private int points;
    private String status;      // draft, published, cancelled, completed, deleted
    private String description;
    private LocalDateTime createdAt;

    // Joined fields for display
    private String organizerName;
    private String categoryName;
    private int registeredCount;

    public Activity() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrganizerId() { return organizerId; }
    public void setOrganizerId(int organizerId) { this.organizerId = organizerId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public LocalDateTime getActivityTime() { return activityTime; }
    public void setActivityTime(LocalDateTime activityTime) { this.activityTime = activityTime; }

    public LocalDateTime getRegStart() { return regStart; }
    public void setRegStart(LocalDateTime regStart) { this.regStart = regStart; }

    public LocalDateTime getRegEnd() { return regEnd; }
    public void setRegEnd(LocalDateTime regEnd) { this.regEnd = regEnd; }

    public int getMaxParticipants() { return maxParticipants; }
    public void setMaxParticipants(int maxParticipants) { this.maxParticipants = maxParticipants; }

    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // Joined fields
    public String getOrganizerName() { return organizerName; }
    public void setOrganizerName(String organizerName) { this.organizerName = organizerName; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public int getRegisteredCount() { return registeredCount; }
    public void setRegisteredCount(int registeredCount) { this.registeredCount = registeredCount; }

    // Helper methods
    public boolean isRegistrationOpen() {
        if (!"published".equals(status)) return false;
        LocalDateTime now = LocalDateTime.now();
        return !now.isBefore(regStart) && !now.isAfter(regEnd);
    }

    public boolean isFull() {
        return registeredCount >= maxParticipants;
    }

    @Override
    public String toString() {
        return "Activity{id=" + id + ", title='" + title + "', status='" + status + "'}";
    }
}
