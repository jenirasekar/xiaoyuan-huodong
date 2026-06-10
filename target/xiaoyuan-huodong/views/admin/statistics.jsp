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
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead>
                    <tr class="text-xs font-medium text-gray-500 uppercase border-b">
                        <th class="py-2 text-left">Category</th>
                        <th class="py-2 text-center w-20">Activities</th>
                        <th class="py-2 text-center w-20">Participants</th>
                        <th class="py-2 text-center w-20">Check-ins</th>
                        <th class="py-2 text-center w-20">Absences</th>
                        <th class="py-2 text-left w-40">Check-in Rate</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Object[] row : categoryStats) {
                        String name = (String) row[0];
                        long actCount = ((Number) row[1]).longValue();
                        long participantCount = ((Number) row[2]).longValue();
                        long checkinCount = ((Number) row[3]).longValue();
                        long absenceCount = participantCount - checkinCount;
                        int ratePct = participantCount > 0 ? (int) (checkinCount * 100 / participantCount) : 0;
                        String rateColor = ratePct >= 80 ? "bg-green-500" : ratePct >= 50 ? "bg-yellow-500" : "bg-red-500";
                    %>
                    <tr class="border-b border-gray-100 hover:bg-gray-50 transition-colors">
                        <td class="py-3 text-sm font-medium text-gray-700"><%= name %></td>
                        <td class="py-3 text-center">
                            <span class="text-sm font-semibold text-blue-600"><%= actCount %></span>
                        </td>
                        <td class="py-3 text-center">
                            <span class="text-sm text-gray-700"><%= participantCount %></span>
                        </td>
                        <td class="py-3 text-center">
                            <span class="text-sm font-medium text-green-600"><%= checkinCount %></span>
                        </td>
                        <td class="py-3 text-center">
                            <span class="text-sm <%= absenceCount > 0 ? "text-red-500 font-medium" : "text-gray-400" %>"><%= absenceCount %></span>
                        </td>
                        <td class="py-3">
                            <div class="flex items-center gap-2">
                                <div class="flex-1 bg-gray-200 rounded-full h-2">
                                    <div class="<%= rateColor %> h-2 rounded-full" style="width: <%= ratePct %>%"></div>
                                </div>
                                <span class="text-xs text-gray-500 w-8 text-right"><%= ratePct %>%</span>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
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
