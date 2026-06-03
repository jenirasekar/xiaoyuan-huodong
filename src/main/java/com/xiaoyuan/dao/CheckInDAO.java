package com.xiaoyuan.dao;

import com.xiaoyuan.model.CheckIn;
import com.xiaoyuan.util.DBConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for CheckIn entity.
 */
public class CheckInDAO {

    /**
     * Create a check-in record.
     */
    public int create(CheckIn checkIn) throws SQLException {
        String sql = "INSERT INTO checkin (registration_id, checkin_code, checkin_time) VALUES (?, ?, NOW())";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, checkIn.getRegistrationId());
            stmt.setString(2, checkIn.getCheckinCode());
            stmt.executeUpdate();
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Find check-in by registration ID.
     */
    public CheckIn findByRegistrationId(int registrationId) throws SQLException {
        String sql = "SELECT c.*, u.real_name AS student_name, a.title AS activity_title " +
                "FROM checkin c " +
                "JOIN registration r ON c.registration_id = r.id " +
                "JOIN user u ON r.student_id = u.id " +
                "JOIN activity a ON r.activity_id = a.id " +
                "WHERE c.registration_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, registrationId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Find all check-ins for an activity.
     */
    public List<CheckIn> findByActivity(int activityId) throws SQLException {
        String sql = "SELECT c.*, u.real_name AS student_name, a.title AS activity_title " +
                "FROM checkin c " +
                "JOIN registration r ON c.registration_id = r.id " +
                "JOIN user u ON r.student_id = u.id " +
                "JOIN activity a ON r.activity_id = a.id " +
                "WHERE r.activity_id = ? ORDER BY c.checkin_time ASC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, activityId);
            List<CheckIn> checkIns = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    checkIns.add(mapRow(rs));
                }
            }
            return checkIns;
        }
    }

    /**
     * Count total check-ins.
     */
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM checkin";
        try (Connection conn = DBConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    private CheckIn mapRow(ResultSet rs) throws SQLException {
        CheckIn c = new CheckIn();
        c.setId(rs.getInt("id"));
        c.setRegistrationId(rs.getInt("registration_id"));
        c.setCheckinCode(rs.getString("checkin_code"));
        c.setCheckinTime(rs.getTimestamp("checkin_time").toLocalDateTime());
        c.setStudentName(rs.getString("student_name"));
        c.setActivityTitle(rs.getString("activity_title"));
        return c;
    }
}
