package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.ActivityCategoryDAO;
import com.xiaoyuan.dao.ActivityDAO;
import com.xiaoyuan.dao.RegistrationDAO;
import com.xiaoyuan.model.Activity;
import com.xiaoyuan.model.Registration;
import com.xiaoyuan.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Handles activity browsing and detail viewing for students.
 * URL patterns: /activities, /activities/detail?id=X
 */
public class ActivityServlet extends HttpServlet {

    private final ActivityDAO activityDAO = new ActivityDAO();
    private final ActivityCategoryDAO categoryDAO = new ActivityCategoryDAO();
    private final RegistrationDAO registrationDAO = new RegistrationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getParameter("action");
        if (pathInfo == null) pathInfo = "list";

        try {
            switch (pathInfo) {
                case "detail":
                    showDetail(req, resp);
                    break;
                case "list":
                default:
                    listActivities(req, resp);
                    break;
            }
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load activities: " + e.getMessage());
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
        }
    }

    private void listActivities(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String keyword = req.getParameter("keyword");
        String catIdStr = req.getParameter("categoryId");
        Integer categoryId = (catIdStr != null && !catIdStr.isEmpty()) ? Integer.parseInt(catIdStr) : null;

        int page = 1;
        try {
            page = Integer.parseInt(req.getParameter("page"));
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {}

        int pageSize = 9;
        int offset = (page - 1) * pageSize;

        List<Activity> activities = activityDAO.findPublished(keyword, categoryId, offset, pageSize);
        int total = activityDAO.countPublished(keyword, categoryId);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        req.setAttribute("activities", activities);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", total);
        req.setAttribute("keyword", keyword);
        req.setAttribute("categoryId", categoryId);
        req.setAttribute("categories", categoryDAO.findAll());

        req.getRequestDispatcher("/views/student/activities.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        Activity activity = activityDAO.findById(id);
        if (activity == null) {
            req.setAttribute("error", "Activity not found.");
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
            return;
        }

        // Check if current student has a registration — if so, allow viewing even if cancelled
        User user = (User) req.getSession().getAttribute("user");
        Registration myReg = null;
        boolean timeConflict = false;
        if (user != null && "student".equals(user.getRole())) {
            myReg = registrationDAO.findByStudentAndActivity(user.getId(), id);
            if (myReg == null) {
                timeConflict = activityDAO.hasTimeConflict(user.getId(), activity.getActivityTime());
            }
        }

        // Block non-published activities unless the student is registered for it.
        // "cancelled" and "deleted" activities are visible to registered students (soft delete).
        if (!"published".equals(activity.getStatus()) && myReg == null) {
            req.setAttribute("error", "Activity not found or not available.");
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("activity", activity);
        req.setAttribute("myRegistration", myReg);
        req.setAttribute("timeConflict", timeConflict);
        req.getRequestDispatcher("/views/student/activity-detail.jsp").forward(req, resp);
    }
}
