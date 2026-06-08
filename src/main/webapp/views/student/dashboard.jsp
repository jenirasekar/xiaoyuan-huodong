<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%
    java.util.List<com.xiaoyuan.model.Registration> myRegs =
        (java.util.List<com.xiaoyuan.model.Registration>) request.getAttribute("myRegistrations");
    Integer totalPoints = (Integer) request.getAttribute("totalPoints");
    java.util.List<com.xiaoyuan.model.Activity> available =
        (java.util.List<com.xiaoyuan.model.Activity>) request.getAttribute("availableActivities");
    if (myRegs == null) myRegs = java.util.Collections.emptyList();
    if (totalPoints == null) totalPoints = 0;
    if (available == null) available = java.util.Collections.emptyList();
%>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm text-gray-500">My Points</div>
        <div class="text-3xl font-bold text-blue-600 mt-1"><%= totalPoints %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm text-gray-500">Total Registrations</div>
        <div class="text-3xl font-bold text-green-600 mt-1"><%= myRegs.size() %></div>
    </div>
    <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm text-gray-500">Approved</div>
        <div class="text-3xl font-bold text-indigo-600 mt-1">
            <%= myRegs.stream().filter(r -> "approved".equals(r.getStatus())).count() %>
        </div>
    </div>
    <div class="bg-white rounded-lg shadow p-6">
        <div class="text-sm text-gray-500">Checked In</div>
        <div class="text-3xl font-bold text-purple-600 mt-1">
            <%= myRegs.stream().filter(r -> r.isCheckedIn()).count() %>
        </div>
    </div>
</div>

<h2 class="text-lg font-semibold text-gray-800 mb-4">📅 Available Activities</h2>
<% if (available.isEmpty()) { %>
    <p class="text-gray-500 mb-8">No activities available at the moment.</p>
<% } else { %>
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
    <% for (com.xiaoyuan.model.Activity act : available) { %>
    <div class="bg-white rounded-lg shadow p-5 hover:shadow-md transition">
        <div class="flex items-start justify-between">
            <div class="flex-1">
                <span class="text-xs font-medium px-2 py-0.5 rounded bg-blue-100 text-blue-700"><%= act.getCategoryName() %></span>
                <h3 class="text-base font-semibold text-gray-800 mt-2"><%= act.getTitle() %></h3>
                <p class="text-sm text-gray-500 mt-1">📍 <%= act.getLocation() %></p>
                <p class="text-sm text-gray-500">🕐 <%= act.getActivityTime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %></p>
            </div>
        </div>
        <div class="mt-3 flex items-center justify-between">
            <span class="text-sm text-gray-500"><%= act.getRegisteredCount() %>/<%= act.getMaxParticipants() %></span>
            <span class="text-sm font-medium text-blue-600">+<%= act.getPoints() %> pts</span>
        </div>
        <a href="<%= contextPath %>/activities?action=detail&id=<%= act.getId() %>"
           class="mt-3 block text-center py-2 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700">
            View Details
        </a>
    </div>
    <% } %>
</div>
<% } %>

<h2 class="text-lg font-semibold text-gray-800 mb-4">📝 My Recent Registrations</h2>
<% if (myRegs.isEmpty()) { %>
    <div class="bg-white rounded-lg shadow p-8 text-center text-gray-500">
        You haven't registered for any activities yet.
        <br>
        <a href="<%= contextPath %>/activities" class="text-blue-600 hover:underline mt-2 inline-block">Browse Activities →</a>
    </div>
<% } else { %>
<div class="bg-white rounded-lg shadow overflow-hidden">
    <table class="w-full">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Activity</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Check-in</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Registered</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
            <% for (com.xiaoyuan.model.Registration reg : myRegs) { %>
            <tr>
                <td class="px-4 py-3 text-sm">
                    <%= reg.getActivityTitle() %>
                    <% if (reg.getActivityStatus() != null && "cancelled".equals(reg.getActivityStatus())) { %>
                        <span class="ml-1 px-1.5 py-0.5 text-xs font-medium rounded bg-red-100 text-red-600">Cancelled</span>
                    <% } %>
                </td>
                <td class="px-4 py-3">
                    <% if ("approved".equals(reg.getStatus())) { %>
                        <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-green-100 text-green-700">Approved</span>
                    <% } else if ("rejected".equals(reg.getStatus())) { %>
                        <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-red-100 text-red-700">Rejected</span>
                    <% } else { %>
                        <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">Pending</span>
                    <% } %>
                </td>
                <td class="px-4 py-3">
                    <% if (reg.isCheckedIn()) { %>
                        <span class="text-green-600">✅</span>
                    <% } else { %>
                        <span class="text-gray-400">-</span>
                    <% } %>
                </td>
                <td class="px-4 py-3 text-sm text-gray-500"><%= reg.getRegisteredAt().format(java.time.format.DateTimeFormatter.ofPattern("MM-dd HH:mm")) %></td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<%@ include file="../common/footer.jsp" %>
