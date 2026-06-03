package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles statistics and analytics display for admin.
 */
public class StatisticsServlet extends HttpServlet {

    private final ActivityDAO activityDAO = new ActivityDAO();
    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final CheckInDAO checkInDAO = new CheckInDAO();
    private final PointRecordDAO pointRecordDAO = new PointRecordDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            // Overall stats
            req.setAttribute("totalActivities", activityDAO.countAll());
            req.setAttribute("totalRegistrations", registrationDAO.countAll());
            req.setAttribute("totalCheckins", checkInDAO.countAll());
            req.setAttribute("totalStudents", userDAO.countByRole("student"));
            req.setAttribute("totalOrganizers", userDAO.countByRole("organizer"));

            // Activity statistics by category
            req.setAttribute("categoryStats", activityDAO.countByCategory());

            // Points leaderboard
            req.setAttribute("leaderboard", pointRecordDAO.getLeaderboard(20));

            // Recent activities
            req.setAttribute("recentActivities", activityDAO.findAll().stream().limit(10).toList());

            req.getRequestDispatcher("/views/admin/statistics.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load statistics: " + e.getMessage());
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
        }
    }
}
