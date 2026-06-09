package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.*;
import com.xiaoyuan.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles activity check-in management.
 */
public class CheckInServlet extends HttpServlet {

    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final CheckInDAO checkInDAO = new CheckInDAO();
    private final PointRecordDAO pointRecordDAO = new PointRecordDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        try {
            String keyword = req.getParameter("keyword");

            if ("admin".equals(user.getRole())) {
                req.setAttribute("allActivities", activityDAO.findAll(keyword, 0, 50));
            } else {
                req.setAttribute("myActivities", activityDAO.findByOrganizer(user.getId(), keyword, 0, 50));
            }

            String activityIdStr = req.getParameter("activityId");
            if (activityIdStr != null && !activityIdStr.isEmpty()) {
                int activityId = Integer.parseInt(activityIdStr);
                req.setAttribute("selectedActivityId", activityId);
                req.setAttribute("activity", activityDAO.findById(activityId));
                req.setAttribute("registrations", registrationDAO.findApprovedByActivity(activityId));
                req.setAttribute("checkIns", checkInDAO.findByActivity(activityId));
            }

            req.setAttribute("keyword", keyword);
            req.getRequestDispatcher("/views/organizer/checkin.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load check-in data: " + e.getMessage());
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        if (!"organizer".equals(user.getRole()) && !"admin".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int registrationId = Integer.parseInt(req.getParameter("registrationId"));
        String activityIdStr = req.getParameter("activityId");

        try {
            // Check if already checked in
            CheckIn existing = checkInDAO.findByRegistrationId(registrationId);
            if (existing != null) {
                req.getSession().setAttribute("errorMessage", "This student has already checked in.");
                resp.sendRedirect(req.getContextPath() + "/checkin?activityId=" + activityIdStr);
                return;
            }

            // Verify registration is approved
            Registration reg = registrationDAO.findById(registrationId);
            if (reg == null || !"approved".equals(reg.getStatus())) {
                req.getSession().setAttribute("errorMessage", "Only approved registrations can be checked in.");
                resp.sendRedirect(req.getContextPath() + "/checkin?activityId=" + activityIdStr);
                return;
            }

            // Create check-in
            String checkinCode = req.getParameter("checkinCode");
            if (checkinCode == null || checkinCode.trim().isEmpty()) {
                checkinCode = "MANUAL-" + System.currentTimeMillis() % 100000;
            }

            CheckIn checkIn = new CheckIn();
            checkIn.setRegistrationId(registrationId);
            checkIn.setCheckinCode(checkinCode.trim());
            checkInDAO.create(checkIn);

            // Award points (guard against duplicates)
            Activity activity = activityDAO.findById(reg.getActivityId());
            if (activity != null && activity.getPoints() > 0) {
                if (!pointRecordDAO.existsByStudentAndActivity(reg.getStudentId(), reg.getActivityId())) {
                    PointRecord record = new PointRecord();
                    record.setStudentId(reg.getStudentId());
                    record.setActivityId(reg.getActivityId());
                    record.setPoints(activity.getPoints());
                    record.setRemark("Activity check-in: " + activity.getTitle());
                    pointRecordDAO.create(record);
                }
            }

            req.getSession().setAttribute("successMessage", "Check-in successful! Points awarded.");

        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Check-in failed: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/checkin?activityId=" + activityIdStr);
    }
}
