package com.xiaoyuan.dao;

import com.xiaoyuan.model.PointRecord;
import com.xiaoyuan.util.DBConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for PointRecord entity.
 */
public class PointRecordDAO {

    /**
     * Create a point record.
     */
    public int create(PointRecord record) throws SQLException {
        String sql = "INSERT INTO point_record (student_id, activity_id, points, remark) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, record.getStudentId());
            stmt.setInt(2, record.getActivityId());
            stmt.setInt(3, record.getPoints());
            stmt.setString(4, record.getRemark());
            stmt.executeUpdate();
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Find point records by student.
     */
    public List<PointRecord> findByStudent(int studentId) throws SQLException {
        String sql = "SELECT pr.*, u.real_name AS student_name, a.title AS activity_title " +
                "FROM point_record pr " +
                "JOIN user u ON pr.student_id = u.id " +
                "JOIN activity a ON pr.activity_id = a.id " +
                "WHERE pr.student_id = ? ORDER BY pr.created_at DESC";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            List<PointRecord> records = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    records.add(mapRow(rs));
                }
            }
            return records;
        }
    }

    /**
     * Get total points for a student.
     */
    public int getTotalPoints(int studentId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(points), 0) FROM point_record WHERE student_id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Get points leaderboard (top N students).
     */
    public List<Object[]> getLeaderboard(int limit) throws SQLException {
        String sql = "SELECT u.id, u.real_name, u.username, COALESCE(SUM(pr.points), 0) AS total_points, " +
                "COUNT(DISTINCT pr.activity_id) AS activity_count " +
                "FROM user u " +
                "LEFT JOIN point_record pr ON u.id = pr.student_id " +
                "WHERE u.role = 'student' " +
                "GROUP BY u.id, u.real_name, u.username " +
                "ORDER BY total_points DESC LIMIT ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                List<Object[]> leaderboard = new ArrayList<>();
                while (rs.next()) {
                    leaderboard.add(new Object[]{
                            rs.getInt("id"),
                            rs.getString("real_name"),
                            rs.getString("username"),
                            rs.getInt("total_points"),
                            rs.getInt("activity_count")
                    });
                }
                return leaderboard;
            }
        }
    }

    /**
     * Count total point records.
     */
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM point_record";
        try (Connection conn = DBConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    private PointRecord mapRow(ResultSet rs) throws SQLException {
        PointRecord pr = new PointRecord();
        pr.setId(rs.getInt("id"));
        pr.setStudentId(rs.getInt("student_id"));
        pr.setActivityId(rs.getInt("activity_id"));
        pr.setPoints(rs.getInt("points"));
        pr.setRemark(rs.getString("remark"));
        pr.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        pr.setStudentName(rs.getString("student_name"));
        pr.setActivityTitle(rs.getString("activity_title"));
        return pr;
    }
}
