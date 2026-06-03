package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.PointRecordDAO;
import com.xiaoyuan.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles points viewing and leaderboard display.
 */
public class PointsServlet extends HttpServlet {

    private final PointRecordDAO pointRecordDAO = new PointRecordDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        try {
            // Always load leaderboard (visible to all)
            req.setAttribute("leaderboard", pointRecordDAO.getLeaderboard(20));

            // Load user-specific data
            if ("student".equals(user.getRole())) {
                req.setAttribute("myPoints", pointRecordDAO.getTotalPoints(user.getId()));
                req.setAttribute("myRecords", pointRecordDAO.findByStudent(user.getId()));
                req.getRequestDispatcher("/views/student/my-points.jsp").forward(req, resp);
            } else {
                // Organizer and admin view
                req.getRequestDispatcher("/views/admin/statistics.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load points data: " + e.getMessage());
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
        }
    }
}
