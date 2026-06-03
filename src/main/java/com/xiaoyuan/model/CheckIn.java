package com.xiaoyuan.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * CheckIn entity representing activity check-in records.
 */
public class CheckIn implements Serializable {

    private int id;
    private int registrationId;
    private String checkinCode;
    private LocalDateTime checkinTime;

    // Joined fields
    private String studentName;
    private String activityTitle;

    public CheckIn() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getRegistrationId() { return registrationId; }
    public void setRegistrationId(int registrationId) { this.registrationId = registrationId; }

    public String getCheckinCode() { return checkinCode; }
    public void setCheckinCode(String checkinCode) { this.checkinCode = checkinCode; }

    public LocalDateTime getCheckinTime() { return checkinTime; }
    public void setCheckinTime(LocalDateTime checkinTime) { this.checkinTime = checkinTime; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getActivityTitle() { return activityTitle; }
    public void setActivityTitle(String activityTitle) { this.activityTitle = activityTitle; }

    @Override
    public String toString() {
        return "CheckIn{id=" + id + ", registrationId=" + registrationId + "}";
    }
}
