package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.*;
import com.xiaoyuan.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Routes users to their role-specific dashboard.
 */
public class DashboardServlet extends HttpServlet {

    private final ActivityDAO activityDAO = new ActivityDAO();
    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final CheckInDAO checkInDAO = new CheckInDAO();
    private final PointRecordDAO pointRecordDAO = new PointRecordDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String role = user.getRole();

        try {
            switch (role) {
                case "admin":
                    loadAdminDashboard(req);
                    req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
                    break;
                case "organizer":
                    loadOrganizerDashboard(req, user.getId());
                    req.getRequestDispatcher("/views/organizer/dashboard.jsp").forward(req, resp);
                    break;
                case "student":
                    loadStudentDashboard(req, user.getId());
                    req.getRequestDispatcher("/views/student/dashboard.jsp").forward(req, resp);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load dashboard: " + e.getMessage());
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
        }
    }

    private void loadAdminDashboard(HttpServletRequest req) throws Exception {
        req.setAttribute("totalActivities", activityDAO.countAll());
        req.setAttribute("totalRegistrations", registrationDAO.countAll());
        req.setAttribute("totalCheckins", checkInDAO.countAll());
        req.setAttribute("totalStudents", userDAO.countByRole("student"));
        req.setAttribute("totalOrganizers", userDAO.countByRole("organizer"));
        req.setAttribute("recentActivities", activityDAO.findAll().stream().limit(5).toList());
        req.setAttribute("leaderboard", pointRecordDAO.getLeaderboard(10));
    }

    private void loadOrganizerDashboard(HttpServletRequest req, int organizerId) throws Exception {
        var activities = activityDAO.findByOrganizer(organizerId);
        req.setAttribute("myActivities", activities);
        req.setAttribute("totalActivities", activities.size());

        int totalRegistrations = 0;
        for (var act : activities) {
            totalRegistrations += act.getRegisteredCount();
        }
        req.setAttribute("totalRegistrations", totalRegistrations);
    }

    private void loadStudentDashboard(HttpServletRequest req, int studentId) throws Exception {
        req.setAttribute("myRegistrations", registrationDAO.findByStudent(studentId));
        req.setAttribute("totalPoints", pointRecordDAO.getTotalPoints(studentId));
        req.setAttribute("availableActivities", activityDAO.findPublished(null, null, 0, 5));
    }
}
