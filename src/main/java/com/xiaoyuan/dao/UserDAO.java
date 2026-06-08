package com.xiaoyuan.dao;

import com.xiaoyuan.model.User;
import com.xiaoyuan.util.DBConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for User entity.
 */
public class UserDAO {

    /**
     * Find a user by username and password hash (for login).
     */
    public User findByCredentials(String username, String passwordHash) throws SQLException {
        String sql = "SELECT id, username, password, real_name, email, role, created_at FROM user WHERE username = ? AND password = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, passwordHash);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find a user by ID.
     */
    public User findById(int id) throws SQLException {
        String sql = "SELECT id, username, password, real_name, email, role, created_at FROM user WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find a user by username.
     */
    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT id, username, password, real_name, email, role, created_at FROM user WHERE username = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get all users, optionally filtered by role.
     */
    public List<User> findAll(String roleFilter) throws SQLException {
        List<User> users = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, username, password, real_name, email, role, created_at FROM user WHERE 1=1");

        if (roleFilter != null && !roleFilter.isEmpty()) {
            sql.append(" AND role = ?");
        }
        sql.append(" ORDER BY id ASC");

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            if (roleFilter != null && !roleFilter.isEmpty()) {
                stmt.setString(1, roleFilter);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        }
        return users;
    }

    /**
     * Create a new user.
     */
    public int create(User user) throws SQLException {
        String sql = "INSERT INTO user (username, password, real_name, email, role) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getRealName());
            stmt.setString(4, user.getEmail());
            stmt.setString(5, user.getRole());
            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Update an existing user.
     */
    public boolean update(User user) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE user SET username = ?, real_name = ?, email = ?, role = ?");
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            sql.append(", password = ?");
        }
        sql.append(" WHERE id = ?");

        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            stmt.setString(idx++, user.getUsername());
            stmt.setString(idx++, user.getRealName());
            stmt.setString(idx++, user.getEmail());
            stmt.setString(idx++, user.getRole());
            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                stmt.setString(idx++, user.getPassword());
            }
            stmt.setInt(idx, user.getId());
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete a user by ID. Resets auto-increment to MAX(id)+1 afterward
     * so the next inserted row fills the gap.
     */
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM user WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            boolean deleted = stmt.executeUpdate() > 0;
            if (deleted) {
                // Reset auto-increment to the next available ID
                try (Statement st = conn.createStatement()) {
                    ResultSet rs = st.executeQuery("SELECT COALESCE(MAX(id), 0) + 1 FROM user");
                    if (rs.next()) {
                        int nextId = rs.getInt(1);
                        st.executeUpdate("ALTER TABLE user AUTO_INCREMENT = " + nextId);
                    }
                }
            }
            return deleted;
        }
    }

    /**
     * Count users by role.
     */
    public int countByRole(String role) throws SQLException {
        String sql = "SELECT COUNT(*) FROM user WHERE role = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setRealName(rs.getString("real_name"));
        user.setEmail(rs.getString("email"));
        user.setRole(rs.getString("role"));
        user.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        return user;
    }
}
