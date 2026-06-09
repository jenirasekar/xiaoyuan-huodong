package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.*;
import com.xiaoyuan.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDateTime;

/**
 * Handles student self-check-in using a code provided by the organizer.
 */
public class SelfCheckInServlet extends HttpServlet {

    private final ActivityDAO activityDAO = new ActivityDAO();
    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final CheckInDAO checkInDAO = new CheckInDAO();
    private final PointRecordDAO pointRecordDAO = new PointRecordDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        if (!"student".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only students can use self-check-in.");
            return;
        }

        req.getRequestDispatcher("/views/student/self-checkin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        if (!"student".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String code = req.getParameter("checkinCode");
        if (code == null || code.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Please enter a check-in code.");
            resp.sendRedirect(req.getContextPath() + "/self-checkin");
            return;
        }
        code = code.trim();

        try {
            // Find the activity by check-in code
            Activity activity = activityDAO.findByCheckinCode(code);
            if (activity == null) {
                req.getSession().setAttribute("errorMessage", "Invalid check-in code. Please check and try again.");
                resp.sendRedirect(req.getContextPath() + "/self-checkin");
                return;
            }

            // Verify activity time: check-in only within 2 hours of activity start
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime activityStart = activity.getActivityTime();
            java.time.format.DateTimeFormatter dtf =
                    java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

            if (now.isBefore(activityStart)) {
                req.getSession().setAttribute("errorMessage",
                        "Check-in is only available during or after the activity. The activity begins at "
                        + activityStart.format(dtf) + ".");
                resp.sendRedirect(req.getContextPath() + "/self-checkin");
                return;
            }

            LocalDateTime checkinDeadline = activityStart.plusHours(2);
            if (now.isAfter(checkinDeadline)) {
                req.getSession().setAttribute("errorMessage",
                        "The check-in window has closed. Check-in is only available within 2 hours of the activity start time (deadline was "
                        + checkinDeadline.format(dtf) + ").");
                resp.sendRedirect(req.getContextPath() + "/self-checkin");
                return;
            }

            // Find the student's approved registration for this activity
            Registration reg = registrationDAO.findByStudentAndActivity(user.getId(), activity.getId());
            if (reg == null) {
                req.getSession().setAttribute("errorMessage", "You are not registered for this activity.");
                resp.sendRedirect(req.getContextPath() + "/self-checkin");
                return;
            }

            if (!"approved".equals(reg.getStatus())) {
                req.getSession().setAttribute("errorMessage",
                        "Your registration has not been approved yet. Only approved registrations can check in.");
                resp.sendRedirect(req.getContextPath() + "/self-checkin");
                return;
            }

            // Check if already checked in
            CheckIn existing = checkInDAO.findByRegistrationId(reg.getId());
            if (existing != null) {
                req.getSession().setAttribute("successMessage",
                        "You have already checked in for " + activity.getTitle() + "!");
                resp.sendRedirect(req.getContextPath() + "/self-checkin");
                return;
            }

            // Create check-in
            CheckIn checkIn = new CheckIn();
            checkIn.setRegistrationId(reg.getId());
            checkIn.setCheckinCode(code);
            checkInDAO.create(checkIn);

            // Award points (guard against duplicates)
            if (activity.getPoints() > 0) {
                if (!pointRecordDAO.existsByStudentAndActivity(user.getId(), activity.getId())) {
                    PointRecord record = new PointRecord();
                    record.setStudentId(user.getId());
                    record.setActivityId(activity.getId());
                    record.setPoints(activity.getPoints());
                    record.setRemark("Self check-in: " + activity.getTitle());
                    pointRecordDAO.create(record);
                }
            }

            req.getSession().setAttribute("successMessage",
                    "Check-in successful! You earned " + activity.getPoints() + " points for " + activity.getTitle() + ".");

        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Check-in failed: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/self-checkin");
    }
}
