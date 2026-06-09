package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.ActivityCategoryDAO;
import com.xiaoyuan.dao.ActivityDAO;
import com.xiaoyuan.model.Activity;
import com.xiaoyuan.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Handles activity CRUD for organizers and admins.
 */
public class ActivityManageServlet extends HttpServlet {

    private final ActivityDAO activityDAO = new ActivityDAO();
    private final ActivityCategoryDAO categoryDAO = new ActivityCategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "create":
                case "edit":
                    showForm(req, resp, action);
                    break;
                case "delete":
                    deleteActivity(req, resp);
                    break;
                default:
                    listMyActivities(req, resp);
                    break;
            }
        } catch (Exception e) {
            req.setAttribute("error", "Operation failed: " + e.getMessage());
            try {
                req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
            } catch (Exception ex) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "save";

        try {
            switch (action) {
                case "save":
                    saveActivity(req, resp);
                    req.getSession().setAttribute("successMessage", "Activity saved successfully.");
                    break;
                case "delete":
                    deleteActivity(req, resp);
                    req.getSession().setAttribute("successMessage", "Activity deleted successfully.");
                    break;
                case "updateStatus":
                    updateStatus(req, resp);
                    req.getSession().setAttribute("successMessage", "Activity status updated successfully.");
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/manage-activities");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Operation failed: " + e.getMessage());
            try {
                req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
            } catch (Exception ex) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }

    private void listMyActivities(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        User user = (User) req.getSession().getAttribute("user");

        String keyword = req.getParameter("keyword");
        int page = 1;
        try {
            page = Integer.parseInt(req.getParameter("page"));
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {}

        int pageSize = 10;
        int offset = (page - 1) * pageSize;

        if ("admin".equals(user.getRole())) {
            req.setAttribute("activities", activityDAO.findAll(keyword, offset, pageSize));
            req.setAttribute("totalCount", activityDAO.countAll(keyword));
            req.setAttribute("isAdmin", true);
        } else {
            req.setAttribute("activities", activityDAO.findByOrganizer(user.getId(), keyword, offset, pageSize));
            req.setAttribute("totalCount", activityDAO.countByOrganizer(user.getId(), keyword));
            req.setAttribute("isAdmin", false);
        }
        int total = (Integer) req.getAttribute("totalCount");
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / pageSize));
        req.setAttribute("keyword", keyword);
        req.setAttribute("categories", categoryDAO.findAll());
        req.getRequestDispatcher("/views/organizer/manage-activities.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, String action)
            throws Exception {
        req.setAttribute("categories", categoryDAO.findAll());

        if ("edit".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            Activity activity = activityDAO.findById(id);
            if (activity != null) {
                req.setAttribute("activity", activity);
            }
        }
        req.setAttribute("formAction", action);
        req.getRequestDispatcher("/views/organizer/activity-form.jsp").forward(req, resp);
    }

    private void saveActivity(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        User user = (User) req.getSession().getAttribute("user");
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

        String idStr = req.getParameter("id");
        Activity activity;
        if (idStr != null && !idStr.isEmpty()) {
            activity = activityDAO.findById(Integer.parseInt(idStr));
            if (activity == null) {
                resp.sendRedirect(req.getContextPath() + "/manage-activities?error=not_found");
                return;
            }
        } else {
            activity = new Activity();
            activity.setOrganizerId(user.getId());
            activity.setStatus("draft");
        }

        activity.setCategoryId(Integer.parseInt(req.getParameter("categoryId")));
        activity.setTitle(req.getParameter("title"));
        activity.setLocation(req.getParameter("location"));
        activity.setActivityTime(LocalDateTime.parse(req.getParameter("activityTime"), formatter));
        activity.setRegStart(LocalDateTime.parse(req.getParameter("regStart"), formatter));
        activity.setRegEnd(LocalDateTime.parse(req.getParameter("regEnd"), formatter));
        activity.setMaxParticipants(Integer.parseInt(req.getParameter("maxParticipants")));
        activity.setPoints(Integer.parseInt(req.getParameter("points")));

        String newStatus = req.getParameter("status");

        // Guard: cannot mark as completed before the activity has started
        if ("completed".equals(newStatus) && activity.getActivityTime() != null) {
            if (LocalDateTime.now().isBefore(activity.getActivityTime())) {
                req.getSession().setAttribute("errorMessage",
                        "Cannot mark as completed - the activity hasn't started yet.");
                resp.sendRedirect(req.getContextPath() + "/manage-activities");
                return;
            }
        }

        activity.setStatus(newStatus);
        activity.setDescription(req.getParameter("description"));
        activity.setCheckinCode(req.getParameter("checkinCode"));

        if (idStr != null && !idStr.isEmpty()) {
            activityDAO.update(activity);
        } else {
            activityDAO.create(activity);
        }

        resp.sendRedirect(req.getContextPath() + "/manage-activities?success=true");
    }

    private void updateStatus(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String status = req.getParameter("status");
        activityDAO.updateStatus(id, status);
        resp.sendRedirect(req.getContextPath() + "/manage-activities?success=true");
    }

    private void deleteActivity(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        // Soft-delete: mark as deleted so students still see it with a "Deleted" badge.
        // Registrations and points are preserved.
        activityDAO.updateStatus(id, "deleted");
        resp.sendRedirect(req.getContextPath() + "/manage-activities?deleted=true");
    }
}
