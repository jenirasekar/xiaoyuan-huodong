package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.ActivityDAO;
import com.xiaoyuan.dao.RegistrationDAO;
import com.xiaoyuan.model.Activity;
import com.xiaoyuan.model.Registration;
import com.xiaoyuan.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles student registration for activities.
 */
public class RegistrationServlet extends HttpServlet {

    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        try {
            req.setAttribute("registrations", registrationDAO.findByStudent(user.getId()));
            req.getRequestDispatcher("/views/student/my-registrations.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load registrations: " + e.getMessage());
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        // Only students can register
        if (!"student".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only students can register for activities.");
            return;
        }

        String action = req.getParameter("action");
        if ("cancel".equals(action)) {
            // For simplicity, we'll just show an error that cancellations aren't supported for now
            // or redirect to the registration list
            resp.sendRedirect(req.getContextPath() + "/registrations");
            return;
        }

        int activityId;
        try {
            activityId = Integer.parseInt(req.getParameter("activityId"));
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid activity ID.");
            forwardToList(req, resp);
            return;
        }

        try {
            // Check if activity exists and is published
            Activity activity = activityDAO.findById(activityId);
            if (activity == null || !"published".equals(activity.getStatus())) {
                req.setAttribute("error", "Activity not found or not open for registration.");
                forwardToList(req, resp);
                return;
            }

            // Check if registration is open
            if (!activity.isRegistrationOpen()) {
                req.setAttribute("error", "Registration is not currently open for this activity.");
                forwardToList(req, resp);
                return;
            }

            // Check for duplicate registration
            Registration existing = registrationDAO.findByStudentAndActivity(user.getId(), activityId);
            if (existing != null) {
                req.setAttribute("error", "You have already registered for this activity.");
                forwardToList(req, resp);
                return;
            }

            // Check max capacity
            if (activity.isFull()) {
                req.setAttribute("error", "This activity has reached its maximum capacity.");
                forwardToList(req, resp);
                return;
            }

            // Check time conflict
            if (activityDAO.hasTimeConflict(user.getId(), activity.getActivityTime())) {
                req.setAttribute("error", "This activity conflicts with another activity you have registered for.");
                forwardToList(req, resp);
                return;
            }

            // Create registration
            Registration reg = new Registration();
            reg.setStudentId(user.getId());
            reg.setActivityId(activityId);
            registrationDAO.create(reg);

            req.getSession().setAttribute("successMessage", "Successfully registered for the activity! Pending organizer review.");
            resp.sendRedirect(req.getContextPath() + "/registrations");

        } catch (Exception e) {
            req.setAttribute("error", "Registration failed: " + e.getMessage());
            forwardToList(req, resp);
        }
    }

    private void forwardToList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        try {
            req.setAttribute("registrations", registrationDAO.findByStudent(user.getId()));
        } catch (Exception e) {
            req.setAttribute("registrations", java.util.Collections.emptyList());
        }
        req.getRequestDispatcher("/views/student/my-registrations.jsp").forward(req, resp);
    }
}
