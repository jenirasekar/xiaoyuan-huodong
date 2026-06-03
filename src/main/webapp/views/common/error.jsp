<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Campus Activity System</title>
    <script src="<%= request.getContextPath() %>/assets/js/tailwind.js"></script>
</head>
<body class="bg-gray-50 min-h-screen flex items-center justify-center">
    <div class="text-center">
        <div class="text-6xl mb-4">⚠️</div>
        <h1 class="text-2xl font-bold text-gray-800 mb-2">Oops! Something went wrong</h1>
        <p class="text-gray-600 mb-6">
            <% String error = (String) request.getAttribute("error");
               if (error != null && !error.isEmpty()) { %>
                <%= error %>
            <% } else { %>
                An unexpected error occurred. Please try again later.
            <% } %>
        </p>
        <a href="<%= request.getContextPath() %>/dashboard"
           class="inline-block px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
            Back to Dashboard
        </a>
    </div>
</body>
</html>
