<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Activity" %>
<%
    Integer totalActivities = (Integer) request.getAttribute("totalActivities");
    Integer totalRegistrations = (Integer) request.getAttribute("totalRegistrations");
    Integer totalCheckins = (Integer) request.getAttribute("totalCheckins");
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    Integer totalOrganizers = (Integer) request.getAttribute("totalOrganizers");
    List<Activity> recentActivities = (List<Activity>) request.getAttribute("recentActivities");
    List<Object[]> leaderboard = (List<Object[]>) request.getAttribute("leaderboard");
    if (leaderboard == null) leaderboard = java.util.Collections.emptyList();
    if (recentActivities == null) recentActivities = java.util.Collections.emptyList();
%>

<h1 class="text-2xl font-bold text-gray-800 mb-6">Admin Dashboard</h1>

<div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4 mb-8">
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Activities</div>
        <div class="text-2xl font-bold text-blue-600 mt-1"><%= totalActivities != null ? totalActivities : 0 %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Registrations</div>
        <div class="text-2xl font-bold text-green-600 mt-1"><%= totalRegistrations != null ? totalRegistrations : 0 %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Check-ins</div>
        <div class="text-2xl font-bold text-purple-600 mt-1"><%= totalCheckins != null ? totalCheckins : 0 %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Students</div>
        <div class="text-2xl font-bold text-indigo-600 mt-1"><%= totalStudents != null ? totalStudents : 0 %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-4">
        <div class="text-xs text-gray-500 uppercase">Organizers</div>
        <div class="text-2xl font-bold text-orange-600 mt-1"><%= totalOrganizers != null ? totalOrganizers : 0 %></div>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold text-gray-800 mb-4">📅 Recent Activities</h2>
        <% if (recentActivities.isEmpty()) { %>
            <p class="text-gray-500 text-sm">No activities yet.</p>
        <% } else { %>
        <div class="space-y-3">
            <% for (Activity act : recentActivities) { %>
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div>
                    <div class="text-sm font-medium text-gray-800"><%= act.getTitle() %></div>
                    <div class="text-xs text-gray-500"><%= act.getCategoryName() %> · <%= act.getOrganizerName() %></div>
                </div>
                <span class="text-xs px-2 py-0.5 rounded-full <%= "published".equals(act.getStatus()) ? "bg-green-100 text-green-700" : "cancelled".equals(act.getStatus()) ? "bg-red-100 text-red-700" : "deleted".equals(act.getStatus()) ? "bg-gray-200 text-gray-500" : "bg-gray-100 text-gray-700" %>"><%= act.getStatus() %></span>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold text-gray-800 mb-4">🏆 Points Leaderboard</h2>
        <% if (leaderboard.isEmpty()) { %>
            <p class="text-gray-500 text-sm">No data yet.</p>
        <% } else { %>
        <div class="space-y-2">
            <% int rank = 0;
               for (Object[] row : leaderboard) {
                   rank++;
                   String name = (String) row[1];
                   long pts = ((Number) row[3]).longValue();
                   if (rank > 10) break;
            %>
            <div class="flex items-center justify-between p-2 rounded-lg <%= rank <= 3 ? "bg-yellow-50" : "bg-gray-50" %>">
                <div class="flex items-center gap-2">
                    <span class="text-sm font-bold <%= rank <= 3 ? "text-yellow-500" : "text-gray-400" %>">#<%= rank %></span>
                    <span class="text-sm text-gray-700"><%= name %></span>
                </div>
                <span class="text-sm font-medium text-blue-600"><%= pts %> pts</span>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
