package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.UserDAO;
import com.xiaoyuan.model.User;
import com.xiaoyuan.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;

/**
 * Handles user login authentication.
 */
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String redirect = req.getParameter("redirect");

        // Check if already logged in
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            // Respect the redirect parameter if present and safe
            if (redirect != null && !redirect.isEmpty() && !redirect.contains("login")) {
                resp.sendRedirect(req.getContextPath() + redirect);
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
            return;
        }
        req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String redirect = req.getParameter("redirect");

        // Validate input
        if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Username and password are required.");
            req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
            return;
        }

        try {
            String passwordHash = PasswordUtil.hash(password.trim());
            User user = userDAO.findByCredentials(username.trim(), passwordHash);

            if (user != null) {
                // Login successful
                HttpSession session = req.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getId());
                session.setAttribute("role", user.getRole());

                if (redirect != null && !redirect.isEmpty() && !redirect.contains("login")) {
                    resp.sendRedirect(req.getContextPath() + redirect);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/dashboard");
                }
            } else {
                req.setAttribute("error", "Invalid username or password.");
                req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Login failed: " + e.getMessage());
            req.getRequestDispatcher("/views/auth/login.jsp").forward(req, resp);
        }
    }
}
