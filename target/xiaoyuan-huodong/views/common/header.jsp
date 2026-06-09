<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.xiaoyuan.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String currentRole = (String) session.getAttribute("role");
    String contextPath = request.getContextPath();

    // Guard: if not logged in, redirect to login with current page as redirect target
    if (sessionUser == null) {
        String currentPath = request.getRequestURI().substring(contextPath.length());
        response.sendRedirect(contextPath + "/login?redirect=" + java.net.URLEncoder.encode(currentPath, "UTF-8"));
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campus Activity System</title>
    <script src="<%= contextPath %>/assets/js/tailwind.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: { 50: '#eff6ff', 100: '#dbeafe', 200: '#bfdbfe', 300: '#93c5fd', 400: '#60a5fa', 500: '#3b82f6', 600: '#2563eb', 700: '#1d4ed8', 800: '#1e40af', 900: '#1e3a8a' },
                        accent: { 50: '#f0fdf4', 100: '#dcfce7', 500: '#22c55e', 600: '#16a34a', 700: '#15803d' }
                    }
                }
            }
        }
    </script>
    <style>
        .card { background-color: white; border-radius: 0.5rem; box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1); padding: 1.5rem; }
        .btn { padding: 0.5rem 1rem; border-radius: 0.5rem; font-weight: 500; cursor: pointer; }
        .btn-primary { background-color: #2563eb; color: white; border: none; }
        .btn-primary:hover { background-color: #1d4ed8; }
        .btn-success { background-color: #16a34a; color: white; border: none; }
        .btn-success:hover { background-color: #15803d; }
        .btn-danger { background-color: #dc2626; color: white; border: none; }
        .btn-danger:hover { background-color: #b91c1c; }
        .btn-warning { background-color: #eab308; color: white; border: none; }
        .btn-warning:hover { background-color: #ca8a04; }
        .btn-secondary { background-color: #6b7280; color: white; border: none; }
        .btn-secondary:hover { background-color: #4b5563; }
        .input-field { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid #d1d5db; border-radius: 0.5rem; outline: none; box-sizing: border-box; }
        .input-field:focus { box-shadow: 0 0 0 2px #3b82f6; border-color: transparent; }
        .badge { display: inline-block; padding: 0.125rem 0.5rem; font-size: 0.75rem; font-weight: 600; border-radius: 9999px; }
        .badge-green { background-color: #dcfce7; color: #166534; }
        .badge-red { background-color: #fee2e2; color: #991b1b; }
        .badge-yellow { background-color: #fef9c3; color: #854d0e; }
        .badge-blue { background-color: #dbeafe; color: #1e40af; }
        .badge-gray { background-color: #f3f4f6; color: #1f2937; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">

<!-- Navigation Bar -->
<nav class="bg-white shadow-sm border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
            <div class="flex items-center">
                <a href="<%= contextPath %>/dashboard" class="flex items-center space-x-2 no-underline">
                    <span class="text-2xl">🎓</span>
                    <span class="text-xl font-bold text-blue-700">XiaoYuan HuoDong</span>
                </a>
            </div>
            <div class="flex items-center space-x-4">
                <span class="text-sm text-gray-600">
                    <%= sessionUser.getRealName() %>
                    <span class="ml-1 px-2 py-0.5 rounded text-xs font-medium
                        <% if ("admin".equals(currentRole)) { %>bg-red-100 text-red-700
                        <% } else if ("organizer".equals(currentRole)) { %>bg-blue-100 text-blue-700
                        <% } else { %>bg-green-100 text-green-700<% } %>">
                        <%= currentRole %>
                    </span>
                </span>
                <a href="<%= contextPath %>/logout" class="text-sm text-gray-500 hover:text-gray-700 no-underline">Logout</a>
            </div>
        </div>
    </div>
</nav>

<!-- Main Layout -->
<div style="display:flex; min-height:calc(100vh - 4rem)">
    <!-- Sidebar -->
    <aside style="width:16rem; flex-shrink:0" class="bg-white shadow-sm border-r border-gray-200 p-4">
        <nav class="space-y-1">
            <a href="<%= contextPath %>/dashboard" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().endsWith("/dashboard") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                📊 Dashboard
            </a>

            <% if ("student".equals(currentRole)) { %>
                <a href="<%= contextPath %>/activities" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/activities") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📅 Browse Activities
                </a>
                <a href="<%= contextPath %>/registrations" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/registrations") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📝 My Registrations
                </a>
                <a href="<%= contextPath %>/points" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/points") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    ⭐ My Points
                </a>
            <% } else if ("organizer".equals(currentRole)) { %>
                <a href="<%= contextPath %>/manage-activities" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("manage-activities") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📅 Manage Activities
                </a>
                <a href="<%= contextPath %>/reviews" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/reviews") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    ✅ Review Registrations
                </a>
                <a href="<%= contextPath %>/checkin" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/checkin") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    🏷️ Check-in
                </a>
            <% } else if ("admin".equals(currentRole)) { %>
                <a href="<%= contextPath %>/manage-activities" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("manage-activities") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📅 All Activities
                </a>
                <a href="<%= contextPath %>/reviews" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/reviews") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    ✅ Reviews
                </a>
                <a href="<%= contextPath %>/checkin" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/checkin") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    🏷️ Check-in
                </a>
                <div class="pt-2 mt-2 border-t border-gray-200"></div>
                <a href="<%= contextPath %>/admin/users" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/admin/users") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    👥 User Management
                </a>
                <a href="<%= contextPath %>/admin/categories" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/admin/categories") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📂 Categories
                </a>
                <a href="<%= contextPath %>/statistics" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/statistics") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📈 Statistics
                </a>
                <a href="<%= contextPath %>/points" class="block px-3 py-2 rounded-lg text-sm font-medium no-underline <%= request.getRequestURI().contains("/points") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    ⭐ Leaderboard
                </a>
            <% } %>
        </nav>
    </aside>

    <!-- Main Content -->
    <main style="flex:1" class="p-6">
        <!-- Flash Messages -->
        <%
            String successMsg = (String) session.getAttribute("successMessage");
            String errorMsg = (String) session.getAttribute("errorMessage");
        %>
        <% if (successMsg != null) { %>
            <div class="mb-4 p-4 bg-green-50 border border-green-200 text-green-700 rounded-lg flex justify-between items-center">
                <span><%= successMsg %></span>
                <button onclick="this.parentElement.remove()" class="text-green-500 hover:text-green-700">&times;</button>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-lg flex justify-between items-center">
                <span><%= errorMsg %></span>
                <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700">&times;</button>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>
