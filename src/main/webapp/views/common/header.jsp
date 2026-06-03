<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.xiaoyuan.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String currentRole = (String) session.getAttribute("role");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getParameter("title") != null ? request.getParameter("title") : "Campus Activity System" %></title>
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
        /* Custom styles for consistent look */
        .card { @apply bg-white rounded-lg shadow-md p-6; }
        .btn { @apply px-4 py-2 rounded-lg font-medium transition-colors duration-200; }
        .btn-primary { @apply bg-blue-600 text-white hover:bg-blue-700; }
        .btn-success { @apply bg-green-600 text-white hover:bg-green-700; }
        .btn-danger { @apply bg-red-600 text-white hover:bg-red-700; }
        .btn-warning { @apply bg-yellow-500 text-white hover:bg-yellow-600; }
        .btn-secondary { @apply bg-gray-500 text-white hover:bg-gray-600; }
        .input-field { @apply w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent; }
        .badge { @apply inline-block px-2 py-1 text-xs font-semibold rounded-full; }
        .badge-green { @apply bg-green-100 text-green-800; }
        .badge-red { @apply bg-red-100 text-red-800; }
        .badge-yellow { @apply bg-yellow-100 text-yellow-800; }
        .badge-blue { @apply bg-blue-100 text-blue-800; }
        .badge-gray { @apply bg-gray-100 text-gray-800; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">
<%
    if (sessionUser != null) {
%>
<!-- Navigation Bar -->
<nav class="bg-white shadow-sm border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
            <div class="flex items-center">
                <a href="<%= contextPath %>/dashboard" class="flex items-center space-x-2">
                    <span class="text-2xl">🎓</span>
                    <span class="text-xl font-bold text-blue-700">XiaoYuan HuoDong</span>
                </a>
            </div>
            <div class="flex items-center space-x-4">
                <span class="text-sm text-gray-600">
                    <%= sessionUser.getRealName() %>
                    <span class="ml-1 px-2 py-0.5 rounded text-xs font-medium
                        <%= "admin".equals(currentRole) ? "bg-red-100 text-red-700" :
                            "organizer".equals(currentRole) ? "bg-blue-100 text-blue-700" :
                            "bg-green-100 text-green-700" %>">
                        <%= currentRole %>
                    </span>
                </span>
                <a href="<%= contextPath %>/logout" class="text-sm text-gray-500 hover:text-gray-700">Logout</a>
            </div>
        </div>
    </div>
</nav>

<!-- Main Layout -->
<div class="flex min-h-[calc(100vh-4rem)]">
    <!-- Sidebar -->
    <aside class="w-64 bg-white shadow-sm border-r border-gray-200 p-4">
        <nav class="space-y-1">
            <a href="<%= contextPath %>/dashboard" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().endsWith("/dashboard") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                📊 Dashboard
            </a>

            <% if ("student".equals(currentRole)) { %>
                <a href="<%= contextPath %>/activities" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/activities") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📅 Browse Activities
                </a>
                <a href="<%= contextPath %>/registrations" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/registrations") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📝 My Registrations
                </a>
                <a href="<%= contextPath %>/points" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/points") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    ⭐ My Points
                </a>
            <% } else if ("organizer".equals(currentRole)) { %>
                <a href="<%= contextPath %>/manage-activities" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("manage-activities") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📅 Manage Activities
                </a>
                <a href="<%= contextPath %>/reviews" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/reviews") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    ✅ Review Registrations
                </a>
                <a href="<%= contextPath %>/checkin" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/checkin") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    🏷️ Check-in
                </a>
            <% } else if ("admin".equals(currentRole)) { %>
                <a href="<%= contextPath %>/manage-activities" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("manage-activities") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📅 All Activities
                </a>
                <a href="<%= contextPath %>/reviews" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/reviews") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    ✅ Reviews
                </a>
                <a href="<%= contextPath %>/checkin" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/checkin") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    🏷️ Check-in
                </a>
                <div class="pt-2 mt-2 border-t border-gray-200"></div>
                <a href="<%= contextPath %>/admin/users" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/admin/users") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    👥 User Management
                </a>
                <a href="<%= contextPath %>/admin/categories" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/admin/categories") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📂 Categories
                </a>
                <a href="<%= contextPath %>/statistics" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/statistics") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    📈 Statistics
                </a>
                <a href="<%= contextPath %>/points" class="block px-3 py-2 rounded-lg text-sm font-medium <%= request.getRequestURI().contains("/points") ? "bg-blue-50 text-blue-700" : "text-gray-700 hover:bg-gray-100" %>">
                    ⭐ Leaderboard
                </a>
            <% } %>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 p-6">
        <!-- Flash Messages -->
        <%
            String successMsg = (String) session.getAttribute("successMessage");
            String errorMsg = (String) session.getAttribute("errorMessage");
            if (successMsg != null) {
        %>
            <div class="mb-4 p-4 bg-green-50 border border-green-200 text-green-700 rounded-lg flex justify-between items-center">
                <span><%= successMsg %></span>
                <button onclick="this.parentElement.remove()" class="text-green-500 hover:text-green-700">&times;</button>
            </div>
        <% session.removeAttribute("successMessage"); } if (errorMsg != null) { %>
            <div class="mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-lg flex justify-between items-center">
                <span><%= errorMsg %></span>
                <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700">&times;</button>
            </div>
        <% session.removeAttribute("errorMessage"); } %>
