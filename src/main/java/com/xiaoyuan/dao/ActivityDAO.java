package com.xiaoyuan.dao;

import com.xiaoyuan.model.Activity;
import com.xiaoyuan.util.DBConnectionManager;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Activity entity.
 */
public class ActivityDAO {

    /**
     * Find all published activities with joined fields, with optional filters.
     */
    public List<Activity> findPublished(String keyword, Integer categoryId, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT a.*, u.real_name AS organizer_name, ac.name AS category_name, " +
                "(SELECT COUNT(*) FROM registration r WHERE r.activity_id = a.id AND r.status IN ('pending', 'approved')) AS registered_count " +
                "FROM activity a " +
                "JOIN user u ON a.organizer_id = u.id " +
                "JOIN activity_category ac ON a.category_id = ac.id " +
                "WHERE a.status = 'published'");

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (a.title LIKE ? OR a.location LIKE ?)");
        }
        if (categoryId != null) {
            sql.append(" AND a.category_id = ?");
        }
        sql.append(" ORDER BY a.activity_time DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            if (keyword != null && !keyword.isEmpty()) {
                String kw = "%" + keyword + "%";
                stmt.setString(idx++, kw);
                stmt.setString(idx++, kw);
            }
            if (categoryId != null) {
                stmt.setInt(idx++, categoryId);
            }
            stmt.setInt(idx++, limit);
            stmt.setInt(idx++, offset);

            List<Activity> activities = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    activities.add(mapRow(rs));
                }
            }
            return activities;
        }
    }

    /**
     * Count published activities for pagination.
     */
    public int countPublished(String keyword, Integer categoryId) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM activity a WHERE a.status = 'published'");
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (a.title LIKE ? OR a.location LIKE ?)");
        }
        if (categoryId != null) {
            sql.append(" AND a.category_id = ?");
        }

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.isEmpty()) {
                String kw = "%" + keyword + "%";
                stmt.setString(idx++, kw);
                stmt.setString(idx++, kw);
            }
            if (categoryId != null) {
                stmt.setInt(idx++, categoryId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Find activities managed by a specific organizer.
     */
    public List<Activity> findByOrganizer(int organizerId) throws SQLException {
        String sql = "SELECT a.*, u.real_name AS organizer_name, ac.name AS category_name, " +
                "(SELECT COUNT(*) FROM registration r WHERE r.activity_id = a.id AND r.status IN ('pending', 'approved')) AS registered_count " +
                "FROM activity a " +
                "JOIN user u ON a.organizer_id = u.id " +
                "JOIN activity_category ac ON a.category_id = ac.id " +
                "WHERE a.organizer_id = ? ORDER BY a.id ASC";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, organizerId);
            List<Activity> activities = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    activities.add(mapRow(rs));
                }
            }
            return activities;
        }
    }

    /**
     * Find all activities (admin use).
     */
    public List<Activity> findAll() throws SQLException {
        String sql = "SELECT a.*, u.real_name AS organizer_name, ac.name AS category_name, " +
                "(SELECT COUNT(*) FROM registration r WHERE r.activity_id = a.id AND r.status IN ('pending', 'approved')) AS registered_count " +
                "FROM activity a " +
                "JOIN user u ON a.organizer_id = u.id " +
                "JOIN activity_category ac ON a.category_id = ac.id " +
                "ORDER BY a.created_at ASC";

        try (Connection conn = DBConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            List<Activity> activities = new ArrayList<>();
            while (rs.next()) {
                activities.add(mapRow(rs));
            }
            return activities;
        }
    }

    /**
     * Find activity by ID with full joined data.
     */
    public Activity findById(int id) throws SQLException {
        String sql = "SELECT a.*, u.real_name AS organizer_name, ac.name AS category_name, " +
                "(SELECT COUNT(*) FROM registration r WHERE r.activity_id = a.id AND r.status IN ('pending', 'approved')) AS registered_count " +
                "FROM activity a " +
                "JOIN user u ON a.organizer_id = u.id " +
                "JOIN activity_category ac ON a.category_id = ac.id " +
                "WHERE a.id = ?";

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
     * Create a new activity.
     */
    public int create(Activity activity) throws SQLException {
        String sql = "INSERT INTO activity (organizer_id, category_id, title, location, activity_time, " +
                "reg_start, reg_end, max_participants, points, status, description) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setActivityParams(stmt, activity);
            stmt.executeUpdate();
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Update an existing activity.
     */
    public boolean update(Activity activity) throws SQLException {
        String sql = "UPDATE activity SET category_id = ?, title = ?, location = ?, activity_time = ?, " +
                "reg_start = ?, reg_end = ?, max_participants = ?, points = ?, status = ?, description = ? " +
                "WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, activity.getCategoryId());
            stmt.setString(2, activity.getTitle());
            stmt.setString(3, activity.getLocation());
            stmt.setTimestamp(4, Timestamp.valueOf(activity.getActivityTime()));
            stmt.setTimestamp(5, Timestamp.valueOf(activity.getRegStart()));
            stmt.setTimestamp(6, Timestamp.valueOf(activity.getRegEnd()));
            stmt.setInt(7, activity.getMaxParticipants());
            stmt.setInt(8, activity.getPoints());
            stmt.setString(9, activity.getStatus());
            stmt.setString(10, activity.getDescription());
            stmt.setInt(11, activity.getId());
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Update activity status only.
     */
    public boolean updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE activity SET status = ? WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete an activity and all related records (check-ins → registrations → activity).
     * Resets auto-increment to MAX(id)+1 afterward so the next inserted row fills the gap.
     */
    public boolean delete(int id) throws SQLException {
        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Delete check-in records linked to registrations of this activity
                String deleteCheckins = "DELETE FROM checkin WHERE registration_id IN " +
                        "(SELECT id FROM registration WHERE activity_id = ?)";
                try (PreparedStatement stmt = conn.prepareStatement(deleteCheckins)) {
                    stmt.setInt(1, id);
                    stmt.executeUpdate();
                }

                // 2. Delete registrations for this activity
                String deleteRegs = "DELETE FROM registration WHERE activity_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(deleteRegs)) {
                    stmt.setInt(1, id);
                    stmt.executeUpdate();
                }

                // 3. Delete the activity
                String deleteActivity = "DELETE FROM activity WHERE id = ?";
                boolean deleted;
                try (PreparedStatement stmt = conn.prepareStatement(deleteActivity)) {
                    stmt.setInt(1, id);
                    deleted = stmt.executeUpdate() > 0;
                }

                // 4. Reset auto-increment
                if (deleted) {
                    try (Statement st = conn.createStatement()) {
                        ResultSet rs = st.executeQuery("SELECT COALESCE(MAX(id), 0) + 1 FROM activity");
                        if (rs.next()) {
                            int nextId = rs.getInt(1);
                            st.executeUpdate("ALTER TABLE activity AUTO_INCREMENT = " + nextId);
                        }
                    }
                }

                conn.commit();
                return deleted;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * Check for time conflict: whether a student has another activity at the same time.
     */
    public boolean hasTimeConflict(int studentId, LocalDateTime activityTime) throws SQLException {
        String sql = "SELECT COUNT(*) FROM activity a " +
                "JOIN registration r ON a.id = r.activity_id " +
                "WHERE r.student_id = ? AND r.status IN ('pending', 'approved') " +
                "AND ABS(TIMESTAMPDIFF(MINUTE, a.activity_time, ?)) < 60";

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            stmt.setTimestamp(2, Timestamp.valueOf(activityTime));
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    /**
     * Get activity statistics by category.
     */
    public List<Object[]> countByCategory() throws SQLException {
        String sql = "SELECT ac.name, COUNT(a.id), " +
                "COALESCE(SUM((SELECT COUNT(*) FROM registration r WHERE r.activity_id = a.id)), 0) " +
                "FROM activity_category ac " +
                "LEFT JOIN activity a ON ac.id = a.category_id " +
                "GROUP BY ac.id, ac.name ORDER BY COUNT(a.id) DESC";

        try (Connection conn = DBConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            List<Object[]> results = new ArrayList<>();
            while (rs.next()) {
                results.add(new Object[]{rs.getString(1), rs.getInt(2), rs.getLong(3)});
            }
            return results;
        }
    }

    /**
     * Get total activity count.
     */
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM activity";
        try (Connection conn = DBConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    private void setActivityParams(PreparedStatement stmt, Activity activity) throws SQLException {
        stmt.setInt(1, activity.getOrganizerId());
        stmt.setInt(2, activity.getCategoryId());
        stmt.setString(3, activity.getTitle());
        stmt.setString(4, activity.getLocation());
        stmt.setTimestamp(5, Timestamp.valueOf(activity.getActivityTime()));
        stmt.setTimestamp(6, Timestamp.valueOf(activity.getRegStart()));
        stmt.setTimestamp(7, Timestamp.valueOf(activity.getRegEnd()));
        stmt.setInt(8, activity.getMaxParticipants());
        stmt.setInt(9, activity.getPoints());
        stmt.setString(10, activity.getStatus());
        stmt.setString(11, activity.getDescription());
    }

    private Activity mapRow(ResultSet rs) throws SQLException {
        Activity a = new Activity();
        a.setId(rs.getInt("id"));
        a.setOrganizerId(rs.getInt("organizer_id"));
        a.setCategoryId(rs.getInt("category_id"));
        a.setTitle(rs.getString("title"));
        a.setLocation(rs.getString("location"));
        a.setActivityTime(rs.getTimestamp("activity_time").toLocalDateTime());
        a.setRegStart(rs.getTimestamp("reg_start").toLocalDateTime());
        a.setRegEnd(rs.getTimestamp("reg_end").toLocalDateTime());
        a.setMaxParticipants(rs.getInt("max_participants"));
        a.setPoints(rs.getInt("points"));
        a.setStatus(rs.getString("status"));
        a.setDescription(rs.getString("description"));
        a.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        a.setOrganizerName(rs.getString("organizer_name"));
        a.setCategoryName(rs.getString("category_name"));
        a.setRegisteredCount(rs.getInt("registered_count"));
        return a;
    }
}
