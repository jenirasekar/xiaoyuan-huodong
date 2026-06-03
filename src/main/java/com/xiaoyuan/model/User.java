package com.xiaoyuan.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * User entity representing system users (student, organizer, admin).
 */
public class User implements Serializable {

    private int id;
    private String username;
    private String password;  // hashed
    private String realName;
    private String email;
    private String role;      // student, organizer, admin
    private LocalDateTime createdAt;

    public User() {}

    public User(int id, String username, String realName, String email, String role) {
        this.id = id;
        this.username = username;
        this.realName = realName;
        this.email = email;
        this.role = role;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public boolean isAdmin() { return "admin".equals(role); }
    public boolean isOrganizer() { return "organizer".equals(role); }
    public boolean isStudent() { return "student".equals(role); }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', role='" + role + "'}";
    }
}
