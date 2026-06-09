-- ============================================
-- Campus Activity Registration, Review & Points Management System
-- Database Schema for MySQL
-- ============================================

CREATE DATABASE IF NOT EXISTS xiaoyuan_huodong
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE xiaoyuan_huodong;

-- ============================================
-- 1. User Table
-- ============================================
DROP TABLE IF EXISTS point_record;
DROP TABLE IF EXISTS checkin;
DROP TABLE IF EXISTS registration;
DROP TABLE IF EXISTS activity;
DROP TABLE IF EXISTS activity_category;
DROP TABLE IF EXISTS user;

CREATE TABLE user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    real_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    role ENUM('student', 'organizer', 'admin') NOT NULL DEFAULT 'student',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================
-- 2. Activity Category Table
-- ============================================
CREATE TABLE activity_category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500)
) ENGINE=InnoDB;

-- ============================================
-- 3. Activity Table
-- ============================================
CREATE TABLE activity (
    id INT AUTO_INCREMENT PRIMARY KEY,
    organizer_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    location VARCHAR(200) NOT NULL,
    activity_time DATETIME NOT NULL,
    reg_start DATETIME NOT NULL,
    reg_end DATETIME NOT NULL,
    max_participants INT NOT NULL DEFAULT 50,
    points INT NOT NULL DEFAULT 0,
    status ENUM('draft', 'published', 'cancelled', 'completed', 'deleted') NOT NULL DEFAULT 'draft',
    description TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (organizer_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES activity_category(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================
-- 4. Registration Table
-- ============================================
CREATE TABLE registration (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    activity_id INT NOT NULL,
    status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    review_comment VARCHAR(500),
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME,
    FOREIGN KEY (student_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
    UNIQUE KEY uk_student_activity (student_id, activity_id)
) ENGINE=InnoDB;

-- ============================================
-- 5. Check-in Table
-- ============================================
CREATE TABLE checkin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    registration_id INT NOT NULL UNIQUE,
    checkin_code VARCHAR(20),
    checkin_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registration_id) REFERENCES registration(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- 6. Point Record Table
-- ============================================
CREATE TABLE point_record (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    activity_id INT NOT NULL,
    points INT NOT NULL DEFAULT 0,
    remark VARCHAR(200),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- Indexes for performance
-- ============================================
CREATE INDEX idx_activity_status ON activity(status);
CREATE INDEX idx_activity_time ON activity(activity_time);
CREATE INDEX idx_registration_status ON registration(status);
CREATE INDEX idx_registration_student ON registration(student_id);
CREATE INDEX idx_registration_activity ON registration(activity_id);
CREATE INDEX idx_checkin_registration ON checkin(registration_id);
CREATE INDEX idx_point_record_student ON point_record(student_id);
