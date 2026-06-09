<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Activity" %>
<%
    List<Activity> myActivities = (List<Activity>) request.getAttribute("myActivities");
    Integer totalRegistrations = (Integer) request.getAttribute("totalRegistrations");
    Integer totalActivities = (Integer) request.getAttribute("totalActivities");
    if (myActivities == null) myActivities = java.util.Collections.emptyList();
    if (totalRegistrations == null) totalRegistrations = 0;
    if (totalActivities == null) totalActivities = 0;
%>

<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
    <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm text-gray-500">My Activities</div>
        <div class="text-3xl font-bold text-blue-600 mt-1"><%= totalActivities %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm text-gray-500">Total Registrations</div>
        <div class="text-3xl font-bold text-green-600 mt-1"><%= totalRegistrations %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm text-gray-500">Published</div>
        <div class="text-3xl font-bold text-indigo-600 mt-1">
            <%= myActivities.stream().filter(a -> "published".equals(a.getStatus())).count() %>
        </div>
    </div>
</div>

<div class="flex items-center justify-between mb-4">
    <h2 class="text-lg font-semibold text-gray-800">📅 My Activities</h2>
    <a href="<%= contextPath %>/manage-activities?action=create" class="btn btn-primary">+ New Activity</a>
</div>

<% if (myActivities.isEmpty()) { %>
    <div class="bg-white rounded-lg shadow p-12 text-center">
        <div class="text-5xl mb-4">📅</div>
        <p class="text-gray-600 mb-4">You haven't created any activities yet.</p>
        <a href="<%= contextPath %>/manage-activities?action=create" class="btn btn-primary">Create Your First Activity</a>
    </div>
<% } else { %>
<div class="bg-white rounded-lg shadow overflow-hidden">
    <table class="w-full">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Title</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Registered</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Points</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
            <% for (Activity act : myActivities) { %>
            <tr class="hover:bg-gray-50">
                <td class="px-4 py-3">
                    <div class="text-sm font-medium text-gray-800"><%= act.getTitle() %></div>
                    <div class="text-xs text-gray-500"><%= act.getActivityTime().format(java.time.format.DateTimeFormatter.ofPattern("MM-dd HH:mm")) %></div>
                </td>
                <td class="px-4 py-3 text-sm text-gray-500"><%= act.getCategoryName() %></td>
                <td class="px-4 py-3">
                    <% if ("published".equals(act.getStatus())) { %>
                        <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-green-100 text-green-700">Published</span>
                    <% } else if ("draft".equals(act.getStatus())) { %>
                        <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-gray-100 text-gray-700">Draft</span>
                    <% } else if ("cancelled".equals(act.getStatus())) { %>
                        <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-red-100 text-red-700">Cancelled</span>
                    <% } else if ("deleted".equals(act.getStatus())) { %>
                        <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-gray-200 text-gray-500 line-through">Deleted</span>
                    <% } else { %>
                        <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-blue-100 text-blue-700"><%= act.getStatus() %></span>
                    <% } %>
                </td>
                <td class="px-4 py-3 text-sm"><%= act.getRegisteredCount() %>/<%= act.getMaxParticipants() %></td>
                <td class="px-4 py-3 text-sm font-medium text-blue-600">+<%= act.getPoints() %></td>
                <td class="px-4 py-3">
                    <div class="flex items-center gap-1">
                        <a href="<%= contextPath %>/manage-activities?action=edit&id=<%= act.getId() %>"
                           class="text-xs px-2 py-1 bg-blue-50 text-blue-600 rounded hover:bg-blue-100">Edit</a>
                        <a href="<%= contextPath %>/reviews?activityId=<%= act.getId() %>"
                           class="text-xs px-2 py-1 bg-green-50 text-green-600 rounded hover:bg-green-100">Review</a>
                        <a href="<%= contextPath %>/checkin?activityId=<%= act.getId() %>"
                           class="text-xs px-2 py-1 bg-purple-50 text-purple-600 rounded hover:bg-purple-100">Check-in</a>
                    </div>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<%@ include file="../common/footer.jsp" %>
