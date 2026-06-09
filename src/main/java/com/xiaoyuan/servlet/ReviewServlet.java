package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.ActivityDAO;
import com.xiaoyuan.dao.RegistrationDAO;
import com.xiaoyuan.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles registration review by organizers (approve/reject).
 */
public class ReviewServlet extends HttpServlet {

    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        try {
            String activityIdStr = req.getParameter("activityId");
            String keyword = req.getParameter("keyword");

            // Load sidebar activities with search
            if ("admin".equals(user.getRole())) {
                req.setAttribute("myActivities", activityDAO.findAll(keyword, 0, 50));
            } else {
                req.setAttribute("myActivities", activityDAO.findByOrganizer(user.getId(), keyword, 0, 50));
            }

            if (activityIdStr != null && !activityIdStr.isEmpty()) {
                int activityId = Integer.parseInt(activityIdStr);

                int page = 1;
                try {
                    page = Integer.parseInt(req.getParameter("page"));
                    if (page < 1) page = 1;
                } catch (NumberFormatException ignored) {}

                int pageSize = 15;
                int offset = (page - 1) * pageSize;

                req.setAttribute("selectedActivityId", activityId);
                req.setAttribute("registrations", registrationDAO.findByActivity(activityId, keyword, offset, pageSize));
                int total = registrationDAO.countByActivity(activityId, keyword);
                req.setAttribute("currentPage", page);
                req.setAttribute("totalPages", (int) Math.ceil((double) total / pageSize));
                req.setAttribute("totalCount", total);
                req.setAttribute("activity", activityDAO.findById(activityId));
            }

            req.setAttribute("keyword", keyword);
            req.getRequestDispatcher("/views/organizer/review.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load reviews: " + e.getMessage());
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

        String action = req.getParameter("action");

        if ("batch".equals(action)) {
            // Batch approve all pending for an activity
            int activityId = Integer.parseInt(req.getParameter("activityId"));
            try {
                var registrations = registrationDAO.findByActivity(activityId);
                for (var reg : registrations) {
                    if ("pending".equals(reg.getStatus())) {
                        registrationDAO.updateStatus(reg.getId(), "approved", "Batch approved");
                    }
                }
                req.getSession().setAttribute("successMessage", "All pending registrations approved.");
            } catch (Exception e) {
                req.getSession().setAttribute("errorMessage", "Batch approval failed: " + e.getMessage());
            }
        } else {
            // Single review
            int registrationId = Integer.parseInt(req.getParameter("registrationId"));
            String status = req.getParameter("status");
            String comment = req.getParameter("comment");
            if (comment == null) comment = "";

            try {
                registrationDAO.updateStatus(registrationId, status, comment);
                req.getSession().setAttribute("successMessage",
                        "Registration " + ("approved".equals(status) ? "approved" : "rejected") + ".");
            } catch (Exception e) {
                req.getSession().setAttribute("errorMessage", "Review failed: " + e.getMessage());
            }
        }

        String redirectActivity = req.getParameter("activityId");
        if (redirectActivity != null) {
            resp.sendRedirect(req.getContextPath() + "/reviews?activityId=" + redirectActivity);
        } else {
            resp.sendRedirect(req.getContextPath() + "/reviews");
        }
    }
}
