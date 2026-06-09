<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Campus Activity System</title>
    <script src="<%= request.getContextPath() %>/assets/js/tailwind.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: { 500: '#3b82f6', 600: '#2563eb', 700: '#1d4ed8' }
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-md">
        <div class="text-center mb-8">
            <div class="text-5xl mb-3">🎓</div>
            <h1 class="text-3xl font-bold text-gray-800">XiaoYuan HuoDong</h1>
            <p class="text-gray-600 mt-2">Campus Activity Registration & Points System</p>
        </div>

        <div class="bg-white rounded-xl shadow-lg p-8">
            <h2 class="text-xl font-semibold text-gray-800 mb-6 text-center">Sign In</h2>

            <%
                String error = (String) request.getAttribute("error");
                String message = request.getParameter("message");
                if (error != null && !error.isEmpty()) {
            %>
                <div class="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm"><%= error %></div>
            <% } if ("logged_out".equals(message)) { %>
                <div class="mb-4 p-3 bg-green-50 border border-green-200 text-green-700 rounded-lg text-sm">You have been logged out successfully.</div>
            <% } %>

            <form action="<%= request.getContextPath() %>/login" method="post" class="space-y-5">
                <% String redirect = request.getParameter("redirect");
                   if (redirect != null && !redirect.isEmpty()) { %>
                    <input type="hidden" name="redirect" value="<%= redirect %>">
                <% } %>

                <div>
                    <label for="username" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                    <input type="text" id="username" name="username" required
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="Enter your username">
                </div>

                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                    <input type="password" id="password" name="password" required
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                           placeholder="Enter your password">
                </div>

                <button type="submit"
                        class="w-full py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors duration-200">
                    Sign In
                </button>
            </form>

            <div class="mt-6 p-4 bg-gray-50 rounded-lg">
                <p class="text-xs font-medium text-gray-500 mb-2">Demo Accounts (click to copy):</p>
                <div class="space-y-1 text-xs text-gray-600">
                    <div class="flex justify-between cursor-pointer hover:bg-gray-100 p-1 rounded" onclick="fillLogin('admin','admin123')">
                        <span class="font-medium">Admin:</span> <span>admin / admin123</span>
                    </div>
                    <div class="flex justify-between cursor-pointer hover:bg-gray-100 p-1 rounded" onclick="fillLogin('organizer1','organizer123')">
                        <span class="font-medium">Organizer:</span> <span>organizer1 / organizer123</span>
                    </div>
                    <div class="flex justify-between cursor-pointer hover:bg-gray-100 p-1 rounded" onclick="fillLogin('student1','student123')">
                        <span class="font-medium">Student:</span> <span>student1 / student123</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function fillLogin(username, password) {
            document.getElementById('username').value = username;
            document.getElementById('password').value = password;
        }
    </script>
</body>
</html>
