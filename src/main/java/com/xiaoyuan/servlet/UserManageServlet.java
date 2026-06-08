package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.UserDAO;
import com.xiaoyuan.model.User;
import com.xiaoyuan.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles user CRUD for admin.
 */
public class UserManageServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                User user = userDAO.findById(id);
                if (user != null) {
                    req.setAttribute("editUser", user);
                }
            }
            String roleFilter = req.getParameter("role");
            req.setAttribute("users", userDAO.findAll(roleFilter));
            req.setAttribute("roleFilter", roleFilter);
            req.getRequestDispatcher("/views/admin/users.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load users: " + e.getMessage());
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
                    saveUser(req);
                    req.getSession().setAttribute("successMessage", "User saved successfully.");
                    break;
                case "delete":
                    int id = Integer.parseInt(req.getParameter("id"));
                    userDAO.delete(id);
                    req.getSession().setAttribute("successMessage", "User deleted successfully.");
                    break;
                case "resetPassword":
                    resetPassword(req);
                    req.getSession().setAttribute("successMessage", "Password reset successfully.");
                    break;
            }
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Operation failed: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private void saveUser(HttpServletRequest req) throws Exception {
        String idStr = req.getParameter("id");
        User user;
        boolean isNew = (idStr == null || idStr.isEmpty());

        if (isNew) {
            user = new User();
            user.setUsername(req.getParameter("username"));
            String plainPassword = req.getParameter("password");
            if (plainPassword != null && !plainPassword.isEmpty()) {
                user.setPassword(PasswordUtil.hash(plainPassword));
            }
        } else {
            user = userDAO.findById(Integer.parseInt(idStr));
            user.setUsername(req.getParameter("username"));
            if (req.getParameter("password") != null && !req.getParameter("password").isEmpty()) {
                user.setPassword(PasswordUtil.hash(req.getParameter("password")));
            }
        }

        user.setRealName(req.getParameter("realName"));
        user.setEmail(req.getParameter("email"));
        user.setRole(req.getParameter("role"));

        if (isNew) {
            userDAO.create(user);
        } else {
            userDAO.update(user);
        }
    }

    private void resetPassword(HttpServletRequest req) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        User user = userDAO.findById(id);
        if (user != null) {
            user.setPassword(PasswordUtil.hash("123456"));
            userDAO.update(user);
        }
    }
}
