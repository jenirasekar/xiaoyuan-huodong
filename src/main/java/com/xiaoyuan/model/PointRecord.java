package com.xiaoyuan.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * PointRecord entity tracking points earned by students.
 */
public class PointRecord implements Serializable {

    private int id;
    private int studentId;
    private int activityId;
    private int points;
    private String remark;
    private LocalDateTime createdAt;

    // Joined fields
    private String studentName;
    private String activityTitle;

    public PointRecord() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getActivityId() { return activityId; }
    public void setActivityId(int activityId) { this.activityId = activityId; }

    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getActivityTitle() { return activityTitle; }
    public void setActivityTitle(String activityTitle) { this.activityTitle = activityTitle; }

    @Override
    public String toString() {
        return "PointRecord{id=" + id + ", studentId=" + studentId + ", points=" + points + "}";
    }
}
