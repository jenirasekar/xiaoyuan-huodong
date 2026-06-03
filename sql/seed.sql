-- ============================================
-- Seed Data for Testing
-- ============================================
USE xiaoyuan_huodong;

-- Default users (passwords are hashed with SHA-256 + salt)
-- Plain text passwords for testing:
--   admin123    -> admin
--   organizer123 -> organizer
--   student123  -> student
INSERT INTO user (username, password, real_name, email, role) VALUES
('admin',        'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'System Admin',     'admin@xiaoyuan.edu',    'admin'),
('organizer1',   'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'Zhang Organizer',  'organizer1@xiaoyuan.edu', 'organizer'),
('organizer2',   'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'Li Organizer',     'organizer2@xiaoyuan.edu', 'organizer'),
('student1',     'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'Wang Student',     'student1@xiaoyuan.edu',  'student'),
('student2',     'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'Liu Student',      'student2@xiaoyuan.edu',  'student'),
('student3',     'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'Chen Student',     'student3@xiaoyuan.edu',  'student');

-- Activity categories
INSERT INTO activity_category (name, description) VALUES
('Lecture',        'Academic lectures and guest speaker events'),
('Volunteer',      'Volunteer service and community activities'),
('Club',           'Student club and organization activities'),
('Sports',         'Sports competitions and physical activities'),
('Competition',    'Academic and skill competitions'),
('Workshop',       'Hands-on workshops and training sessions');

-- Sample activities (organizer_id = 2 is organizer1)
INSERT INTO activity (organizer_id, category_id, title, location, activity_time, reg_start, reg_end, max_participants, points, status, description) VALUES
(2, 1, 'AI and the Future of Education', 'Lecture Hall A', '2026-06-15 14:00:00', '2026-06-01 08:00:00', '2026-06-14 18:00:00', 200, 2, 'published',
 'This lecture explores how artificial intelligence is transforming education, including personalized learning, automated assessment, and intelligent tutoring systems.'),
(2, 2, 'Community Clean-up Day', 'City Park', '2026-06-20 09:00:00', '2026-06-05 08:00:00', '2026-06-19 12:00:00', 50, 3, 'published',
 'Join us for a community clean-up day at the City Park. Volunteers will help collect litter, plant trees, and beautify public spaces.'),
(2, 3, 'Photography Club Exhibition', 'Student Center Gallery', '2026-06-25 10:00:00', '2026-06-10 08:00:00', '2026-06-24 20:00:00', 80, 1, 'published',
 'Annual photography exhibition showcasing the best works from our photography club members this semester.'),
(2, 4, 'Inter-department Basketball Tournament', 'University Gymnasium', '2026-07-01 13:00:00', '2026-06-15 08:00:00', '2026-06-30 18:00:00', 100, 4, 'published',
 'Annual inter-department basketball tournament. Teams from all departments are welcome to participate.'),
(3, 5, 'Programming Contest 2026', 'Computer Lab Building 3F', '2026-07-10 09:00:00', '2026-06-20 08:00:00', '2026-07-09 12:00:00', 60, 5, 'published',
 'Annual campus programming contest. Solve algorithmic problems within the time limit. Open to all students.'),
(3, 6, 'Resume Writing Workshop', 'Teaching Building Room 201', '2026-07-15 15:00:00', '2026-07-01 08:00:00', '2026-07-14 17:00:00', 40, 1, 'published',
 'Practical workshop on writing effective resumes and cover letters. Bring your draft for personalized feedback.');

-- Some sample registrations
INSERT INTO registration (student_id, activity_id, status, registered_at) VALUES
(4, 1, 'approved', '2026-06-02 10:30:00'),
(4, 2, 'approved', '2026-06-06 14:20:00'),
(5, 1, 'pending', '2026-06-03 09:15:00'),
(5, 3, 'approved', '2026-06-12 11:00:00'),
(6, 2, 'pending', '2026-06-07 16:45:00'),
(6, 4, 'approved', '2026-06-18 08:30:00');

-- Sample check-ins (for approved registrations)
INSERT INTO checkin (registration_id, checkin_code, checkin_time) VALUES
(1, 'CK001', '2026-06-15 13:50:00'),
(2, 'CK002', '2026-06-20 08:55:00'),
(4, 'CK003', '2026-06-25 09:50:00');

-- Sample point records
INSERT INTO point_record (student_id, activity_id, points, remark) VALUES
(4, 1, 2, 'Activity check-in: AI and the Future of Education'),
(4, 2, 3, 'Activity check-in: Community Clean-up Day'),
(5, 3, 1, 'Activity check-in: Photography Club Exhibition');
