package com.xiaoyuan.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Registration entity representing a student's registration for an activity.
 */
public class Registration implements Serializable {

    private int id;
    private int studentId;
    private int activityId;
    private String status;        // pending, approved, rejected
    private String reviewComment;
    private LocalDateTime registeredAt;
    private LocalDateTime reviewedAt;

    // Joined fields for display
    private String studentName;
    private String activityTitle;
    private LocalDateTime activityTime;
    private String activityLocation;
    private boolean checkedIn;

    public Registration() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getActivityId() { return activityId; }
    public void setActivityId(int activityId) { this.activityId = activityId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getReviewComment() { return reviewComment; }
    public void setReviewComment(String reviewComment) { this.reviewComment = reviewComment; }

    public LocalDateTime getRegisteredAt() { return registeredAt; }
    public void setRegisteredAt(LocalDateTime registeredAt) { this.registeredAt = registeredAt; }

    public LocalDateTime getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(LocalDateTime reviewedAt) { this.reviewedAt = reviewedAt; }

    // Joined fields
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getActivityTitle() { return activityTitle; }
    public void setActivityTitle(String activityTitle) { this.activityTitle = activityTitle; }

    public LocalDateTime getActivityTime() { return activityTime; }
    public void setActivityTime(LocalDateTime activityTime) { this.activityTime = activityTime; }

    public String getActivityLocation() { return activityLocation; }
    public void setActivityLocation(String activityLocation) { this.activityLocation = activityLocation; }

    public boolean isCheckedIn() { return checkedIn; }
    public void setCheckedIn(boolean checkedIn) { this.checkedIn = checkedIn; }

    @Override
    public String toString() {
        return "Registration{id=" + id + ", studentId=" + studentId + ", activityId=" + activityId + ", status='" + status + "'}";
    }
}
