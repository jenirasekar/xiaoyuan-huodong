package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.ActivityCategoryDAO;
import com.xiaoyuan.model.ActivityCategory;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles activity category CRUD for admin.
 */
public class CategoryServlet extends HttpServlet {

    private final ActivityCategoryDAO categoryDAO = new ActivityCategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                ActivityCategory cat = categoryDAO.findById(id);
                if (cat != null) {
                    req.setAttribute("editCategory", cat);
                }
            }
            req.setAttribute("categories", categoryDAO.findAll());
            req.getRequestDispatcher("/views/admin/categories.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load categories: " + e.getMessage());
            req.getRequestDispatcher("/views/common/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            switch (action != null ? action : "save") {
                case "save":
                    saveCategory(req);
                    req.getSession().setAttribute("successMessage", "Category saved successfully.");
                    break;
                case "delete":
                    int id = Integer.parseInt(req.getParameter("id"));
                    categoryDAO.delete(id);
                    req.getSession().setAttribute("successMessage", "Category deleted successfully.");
                    break;
            }
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Operation failed: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }

    private void saveCategory(HttpServletRequest req) throws Exception {
        String idStr = req.getParameter("id");
        ActivityCategory category;
        boolean isNew = (idStr == null || idStr.isEmpty());

        if (isNew) {
            category = new ActivityCategory();
        } else {
            category = categoryDAO.findById(Integer.parseInt(idStr));
        }

        category.setName(req.getParameter("name"));
        category.setDescription(req.getParameter("description"));

        if (isNew) {
            categoryDAO.create(category);
        } else {
            categoryDAO.update(category);
        }
    }
}
