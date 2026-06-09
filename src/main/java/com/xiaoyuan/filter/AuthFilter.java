package com.xiaoyuan.filter;

import com.xiaoyuan.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Authentication filter that protects pages from unauthorized access.
 * Different roles have access to different URL patterns.
 */
public class AuthFilter implements Filter {

    // URLs accessible without login
    private static final Set<String> PUBLIC_URLS = new HashSet<>(Arrays.asList(
            "/", "/index.jsp", "/login", "/logout",
            "/views/auth/login.jsp", "/views/common/error.jsp",
            "/assets/css/", "/assets/js/"
    ));

    // URLs restricted by role prefix
    private static final Set<String> ADMIN_URLS = new HashSet<>(Arrays.asList(
            "/admin/"
    ));

    private static final Set<String> ORGANIZER_URLS = new HashSet<>(Arrays.asList(
            "/manage-activities", "/reviews", "/checkin"
    ));

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Allow public URLs
        if (isPublicUrl(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Check if user is logged in
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // Not logged in - redirect to login page via servlet
            res.sendRedirect(req.getContextPath() + "/login?redirect=" +
                    java.net.URLEncoder.encode(path, "UTF-8"));
            return;
        }

        // Role-based access control
        String role = user.getRole();

        if ("admin".equals(role)) {
            // Admin can access everything
            chain.doFilter(request, response);
            return;
        }

        if ("organizer".equals(role)) {
            // Organizer cannot access admin URLs
            if (isAdminUrl(path)) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin only.");
                return;
            }
            // Organizer cannot access student-only pages
            if (path.startsWith("/registrations") && req.getMethod().equals("POST")) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Organizers cannot register for activities.");
                return;
            }
            chain.doFilter(request, response);
            return;
        }

        if ("student".equals(role)) {
            // Student cannot access admin or organizer URLs
            if (isAdminUrl(path) || isOrganizerUrl(path)) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                return;
            }
            chain.doFilter(request, response);
            return;
        }

        // Unknown role
        res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
    }

    private boolean isPublicUrl(String path) {
        // Check static resource patterns
        if (path.startsWith("/assets/")) return true;

        // Check exact matches and prefix matches
        for (String url : PUBLIC_URLS) {
            if (path.equals(url) || (url.endsWith("/") && path.startsWith(url))) {
                return true;
            }
        }
        return false;
    }

    private boolean isAdminUrl(String path) {
        for (String url : ADMIN_URLS) {
            if (path.startsWith(url)) return true;
        }
        return false;
    }

    private boolean isOrganizerUrl(String path) {
        for (String url : ORGANIZER_URLS) {
            if (path.startsWith(url)) return true;
        }
        return false;
    }

    @Override
    public void destroy() {
    }
}
