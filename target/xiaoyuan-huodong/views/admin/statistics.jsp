<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Activity" %>
<%
    Integer totalActivities = (Integer) request.getAttribute("totalActivities");
    Integer totalRegistrations = (Integer) request.getAttribute("totalRegistrations");
    Integer totalCheckins = (Integer) request.getAttribute("totalCheckins");
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    Integer totalOrganizers = (Integer) request.getAttribute("totalOrganizers");
    List<Object[]> categoryStats = (List<Object[]>) request.getAttribute("categoryStats");
    List<Object[]> leaderboard = (List<Object[]>) request.getAttribute("leaderboard");
    if (categoryStats == null) categoryStats = java.util.Collections.emptyList();
    if (leaderboard == null) leaderboard = java.util.Collections.emptyList();
%>

<h1 class="text-2xl font-bold text-gray-800 mb-6">System Statistics</h1>

<!-- Summary Cards -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 mb-8">
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Total Activities</div>
        <div class="text-2xl font-bold text-blue-600"><%= totalActivities != null ? totalActivities : 0 %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Registrations</div>
        <div class="text-2xl font-bold text-green-600"><%= totalRegistrations != null ? totalRegistrations : 0 %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Check-ins</div>
        <div class="text-2xl font-bold text-purple-600"><%= totalCheckins != null ? totalCheckins : 0 %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Students</div>
        <div class="text-2xl font-bold text-indigo-600"><%= totalStudents != null ? totalStudents : 0 %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Organizers</div>
        <div class="text-2xl font-bold text-orange-600"><%= totalOrganizers != null ? totalOrganizers : 0 %></div>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <!-- Category Statistics -->
    <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold text-gray-800 mb-4">📊 Activities by Category</h2>
        <% if (categoryStats.isEmpty()) { %>
            <p class="text-gray-500 text-sm">No data yet.</p>
        <% } else { %>
        <div class="space-y-3">
            <% long maxCount = 0;
               for (Object[] row : categoryStats) maxCount = Math.max(maxCount, ((Number) row[1]).longValue());
               for (Object[] row : categoryStats) {
                   String name = (String) row[0];
                   long count = ((Number) row[1]).longValue();
                   long regCount = ((Number) row[2]).longValue();
                   int pct = maxCount > 0 ? (int) (count * 100 / maxCount) : 0;
            %>
            <div>
                <div class="flex justify-between text-sm mb-1">
                    <span class="font-medium text-gray-700"><%= name %></span>
                    <span class="text-gray-500"><%= count %> activities, <%= regCount %> registrations</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                    <div class="bg-blue-600 h-2 rounded-full" style="width: <%= pct %>%"></div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <!-- Points Leaderboard -->
    <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold text-gray-800 mb-4">🏆 Student Points Ranking</h2>
        <% if (leaderboard.isEmpty()) { %>
            <p class="text-gray-500 text-sm">No points earned yet.</p>
        <% } else { %>
        <table class="w-full">
            <thead>
                <tr class="text-xs font-medium text-gray-500 uppercase border-b">
                    <th class="py-2 text-left">Rank</th>
                    <th class="py-2 text-left">Student</th>
                    <th class="py-2 text-right">Activities</th>
                    <th class="py-2 text-right">Points</th>
                </tr>
            </thead>
            <tbody>
                <% int rank = 0;
                   for (Object[] row : leaderboard) {
                       rank++;
                       String name = (String) row[1];
                       long pts = ((Number) row[3]).longValue();
                       long actCount = ((Number) row[4]).longValue();
                %>
                <tr class="border-b border-gray-100 <%= rank <= 3 ? "bg-yellow-50" : "" %>">
                    <td class="py-2 text-sm font-bold <%= rank <= 3 ? "text-yellow-500" : "text-gray-400" %>">#<%= rank %></td>
                    <td class="py-2 text-sm text-gray-700"><%= name %></td>
                    <td class="py-2 text-sm text-gray-500 text-right"><%= actCount %></td>
                    <td class="py-2 text-sm font-medium text-blue-600 text-right"><%= pts %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
