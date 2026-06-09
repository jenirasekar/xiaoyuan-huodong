package com.xiaoyuan.dao;

import com.xiaoyuan.model.Registration;
import com.xiaoyuan.util.DBConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Registration entity.
 */
public class RegistrationDAO {

    /**
     * Find registration by student and activity (latest first).
     */
    public Registration findByStudentAndActivity(int studentId, int activityId) throws SQLException {
        String sql = "SELECT r.*, u.real_name AS student_name, a.title AS activity_title, " +
                "a.activity_time, a.location AS activity_location, a.status AS activity_status, " +
                "(SELECT COUNT(*) FROM checkin c WHERE c.registration_id = r.id) > 0 AS checked_in " +
                "FROM registration r " +
                "JOIN user u ON r.student_id = u.id " +
                "JOIN activity a ON r.activity_id = a.id " +
                "WHERE r.student_id = ? AND r.activity_id = ? " +
                "ORDER BY r.registered_at DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            stmt.setInt(2, activityId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Find registration by ID.
     */
    public Registration findById(int id) throws SQLException {
        String sql = "SELECT r.*, u.real_name AS student_name, a.title AS activity_title, " +
                "a.activity_time, a.location AS activity_location, a.status AS activity_status, " +
                "(SELECT COUNT(*) FROM checkin c WHERE c.registration_id = r.id) > 0 AS checked_in " +
                "FROM registration r " +
                "JOIN user u ON r.student_id = u.id " +
                "JOIN activity a ON r.activity_id = a.id " +
                "WHERE r.id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Find registrations by student.
     */
    public List<Registration> findByStudent(int studentId) throws SQLException {
        String sql = "SELECT r.*, u.real_name AS student_name, a.title AS activity_title, " +
                "a.activity_time, a.location AS activity_location, a.status AS activity_status, " +
                "(SELECT COUNT(*) FROM checkin c WHERE c.registration_id = r.id) > 0 AS checked_in " +
                "FROM registration r " +
                "JOIN user u ON r.student_id = u.id " +
                "JOIN activity a ON r.activity_id = a.id " +
                "WHERE r.student_id = ? ORDER BY r.registered_at DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            List<Registration> registrations = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    registrations.add(mapRow(rs));
                }
            }
            return registrations;
        }
    }

    /**
     * Find registrations by activity (for organizer review).
     */
    public List<Registration> findByActivity(int activityId) throws SQLException {
        String sql = "SELECT r.*, u.real_name AS student_name, a.title AS activity_title, " +
                "a.activity_time, a.location AS activity_location, a.status AS activity_status, " +
                "(SELECT COUNT(*) FROM checkin c WHERE c.registration_id = r.id) > 0 AS checked_in " +
                "FROM registration r " +
                "JOIN user u ON r.student_id = u.id " +
                "JOIN activity a ON r.activity_id = a.id " +
                "WHERE r.activity_id = ? ORDER BY r.registered_at ASC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, activityId);
            List<Registration> registrations = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    registrations.add(mapRow(rs));
                }
            }
            return registrations;
        }
    }

    /**
     * Find all registrations (admin use) with pagination.
     */
    public List<Registration> findAll(int offset, int limit) throws SQLException {
        String sql = "SELECT r.*, u.real_name AS student_name, a.title AS activity_title, " +
                "a.activity_time, a.location AS activity_location, a.status AS activity_status, " +
                "(SELECT COUNT(*) FROM checkin c WHERE c.registration_id = r.id) > 0 AS checked_in " +
                "FROM registration r " +
                "JOIN user u ON r.student_id = u.id " +
                "JOIN activity a ON r.activity_id = a.id " +
                "ORDER BY r.registered_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            stmt.setInt(2, offset);
            List<Registration> registrations = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    registrations.add(mapRow(rs));
                }
            }
            return registrations;
        }
    }

    /**
     * Register a student for an activity.
     */
    public int create(Registration registration) throws SQLException {
        String sql = "INSERT INTO registration (student_id, activity_id, status) VALUES (?, ?, 'pending')";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, registration.getStudentId());
            stmt.setInt(2, registration.getActivityId());
            stmt.executeUpdate();
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Update registration status (approve/reject).
     */
    public boolean updateStatus(int id, String status, String reviewComment) throws SQLException {
        String sql = "UPDATE registration SET status = ?, review_comment = ?, reviewed_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, reviewComment);
            stmt.setInt(3, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Count registrations by status for an activity.
     */
    public int countByActivityAndStatus(int activityId, String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration WHERE activity_id = ? AND status = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, activityId);
            stmt.setString(2, status);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Count total registrations.
     */
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration";
        try (Connection conn = DBConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    /**
     * Count approved registrations that are NOT checked in (for absence calculation).
     */
    public int countAbsentByActivity(int activityId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r " +
                "WHERE r.activity_id = ? AND r.status = 'approved' " +
                "AND NOT EXISTS (SELECT 1 FROM checkin c WHERE c.registration_id = r.id)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, activityId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Delete a pending registration by ID and student ID (for self-cancellation).
     * Only deletes if the registration is still pending.
     */
    public boolean deletePending(int id, int studentId) throws SQLException {
        String sql = "DELETE FROM registration WHERE id = ? AND student_id = ? AND status = 'pending'";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.setInt(2, studentId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Get approved registrations for an activity (for check-in purposes).
     */
    public List<Registration> findApprovedByActivity(int activityId) throws SQLException {
        String sql = "SELECT r.*, u.real_name AS student_name, a.title AS activity_title, " +
                "a.activity_time, a.location AS activity_location, a.status AS activity_status, " +
                "(SELECT COUNT(*) FROM checkin c WHERE c.registration_id = r.id) > 0 AS checked_in " +
                "FROM registration r " +
                "JOIN user u ON r.student_id = u.id " +
                "JOIN activity a ON r.activity_id = a.id " +
                "WHERE r.activity_id = ? AND r.status = 'approved' " +
                "ORDER BY r.registered_at ASC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, activityId);
            List<Registration> registrations = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    registrations.add(mapRow(rs));
                }
            }
            return registrations;
        }
    }

    private Registration mapRow(ResultSet rs) throws SQLException {
        Registration r = new Registration();
        r.setId(rs.getInt("id"));
        r.setStudentId(rs.getInt("student_id"));
        r.setActivityId(rs.getInt("activity_id"));
        r.setStatus(rs.getString("status"));
        r.setReviewComment(rs.getString("review_comment"));
        r.setRegisteredAt(rs.getTimestamp("registered_at").toLocalDateTime());
        Timestamp reviewedAt = rs.getTimestamp("reviewed_at");
        if (reviewedAt != null) {
            r.setReviewedAt(reviewedAt.toLocalDateTime());
        }
        r.setStudentName(rs.getString("student_name"));
        r.setActivityTitle(rs.getString("activity_title"));
        r.setActivityTime(rs.getTimestamp("activity_time").toLocalDateTime());
        r.setActivityLocation(rs.getString("activity_location"));
        r.setActivityStatus(rs.getString("activity_status"));
        r.setCheckedIn(rs.getBoolean("checked_in"));
        return r;
    }
}
