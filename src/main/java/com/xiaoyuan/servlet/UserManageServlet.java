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
        boolean isNew = (idStr == null || idStr.isEmpty());

        // ── Extract and trim fields ──
        String username = req.getParameter("username");
        if (username != null) username = username.trim();
        String plainPassword = req.getParameter("password");
        String realName = req.getParameter("realName");
        if (realName != null) realName = realName.trim();
        String email = req.getParameter("email");
        if (email != null) email = email.trim();
        String role = req.getParameter("role");

        // ── Validate Username ──
        if (username == null || username.isEmpty()) {
            throw new IllegalArgumentException("Username is required.");
        }
        if (username.length() < 3) {
            throw new IllegalArgumentException("Username must be at least 3 characters.");
        }
        if (username.length() > 50) {
            throw new IllegalArgumentException("Username must not exceed 50 characters.");
        }
        if (!username.matches("^[a-zA-Z0-9_]+$")) {
            throw new IllegalArgumentException("Username can only contain letters, numbers, and underscores.");
        }
        // Check uniqueness
        User existingByUsername = userDAO.findByUsername(username);
        if (existingByUsername != null && (isNew || existingByUsername.getId() != Integer.parseInt(idStr))) {
            throw new IllegalArgumentException("Username '" + username + "' is already taken.");
        }

        // ── Validate Password ──
        if (isNew) {
            if (plainPassword == null || plainPassword.isEmpty()) {
                throw new IllegalArgumentException("Password is required for new users.");
            }
            if (plainPassword.length() < 6) {
                throw new IllegalArgumentException("Password must be at least 6 characters.");
            }
        } else {
            if (plainPassword != null && !plainPassword.isEmpty() && plainPassword.length() < 6) {
                throw new IllegalArgumentException("Password must be at least 6 characters.");
            }
        }

        // ── Validate Real Name ──
        if (realName == null || realName.isEmpty()) {
            throw new IllegalArgumentException("Real name is required.");
        }
        if (realName.length() < 2) {
            throw new IllegalArgumentException("Real name must be at least 2 characters.");
        }
        if (realName.length() > 100) {
            throw new IllegalArgumentException("Real name must not exceed 100 characters.");
        }

        // ── Validate Email ──
        if (email != null && !email.isEmpty()) {
            if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                throw new IllegalArgumentException("Please enter a valid email address.");
            }
        }

        // ── Build user object ──
        User user;
        if (isNew) {
            user = new User();
            user.setUsername(username);
            if (plainPassword != null && !plainPassword.isEmpty()) {
                user.setPassword(PasswordUtil.hash(plainPassword));
            }
        } else {
            user = userDAO.findById(Integer.parseInt(idStr));
            user.setUsername(username);
            if (plainPassword != null && !plainPassword.isEmpty()) {
                user.setPassword(PasswordUtil.hash(plainPassword));
            }
        }

        user.setRealName(realName);
        user.setEmail(email);
        user.setRole(role);

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
