<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Registration" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    List<Registration> registrations = (List<Registration>) request.getAttribute("registrations");
    if (registrations == null) registrations = java.util.Collections.emptyList();
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>

<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-800">My Registrations</h1>
    <p class="text-gray-600 mt-1">Track your activity registrations and check-in status</p>
</div>

<% if (registrations.isEmpty()) { %>
    <div class="bg-white rounded-lg shadow p-12 text-center">
        <div class="text-5xl mb-4">📝</div>
        <p class="text-gray-600 mb-4">You haven't registered for any activities yet.</p>
        <a href="<%= contextPath %>/activities" class="btn btn-primary">Browse Activities</a>
    </div>
<% } else { %>
<div class="bg-white rounded-lg shadow overflow-hidden">
    <table class="w-full">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Activity</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Check-in</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Comment</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
            <% for (Registration reg : registrations) { %>
            <tr class="hover:bg-gray-50">
                <td class="px-4 py-3">
                    <div class="text-sm font-medium text-gray-800">
                        <%= reg.getActivityTitle() %>
                        <% if (reg.getActivityStatus() != null && "cancelled".equals(reg.getActivityStatus())) { %>
                            <span class="ml-1 px-1.5 py-0.5 text-xs font-medium rounded bg-red-100 text-red-600">Cancelled</span>
                        <% } else if (reg.getActivityStatus() != null && "deleted".equals(reg.getActivityStatus())) { %>
                            <span class="ml-1 px-1.5 py-0.5 text-xs font-medium rounded bg-gray-200 text-gray-500">Deleted</span>
                        <% } %>
                    </div>
                    <div class="text-xs text-gray-500">📍 <%= reg.getActivityLocation() %></div>
                </td>
                <td class="px-4 py-3 text-sm text-gray-500"><%= reg.getActivityTime().format(dtf) %></td>
                <td class="px-4 py-3">
                    <% if ("approved".equals(reg.getStatus())) { %>
                        <span class="px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700">✅ Approved</span>
                    <% } else if ("rejected".equals(reg.getStatus())) { %>
                        <span class="px-2 py-1 text-xs font-medium rounded-full bg-red-100 text-red-700">❌ Rejected</span>
                    <% } else { %>
                        <span class="px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">⏳ Pending</span>
                    <% } %>
                </td>
                <td class="px-4 py-3">
                    <% if (reg.isCheckedIn()) { %>
                        <span class="text-green-600 text-sm">✅ Checked In</span>
                    <% } else if ("approved".equals(reg.getStatus())) { %>
                        <span class="text-gray-400 text-sm">Not yet</span>
                    <% } else { %>
                        <span class="text-gray-300 text-sm">-</span>
                    <% } %>
                </td>
                <td class="px-4 py-3 text-sm text-gray-500 max-w-[200px] truncate">
                    <%= reg.getReviewComment() != null ? reg.getReviewComment() : "-" %>
                </td>
                <td class="px-4 py-3">
                    <% if ("pending".equals(reg.getStatus())) { %>
                        <form action="<%= contextPath %>/registrations" method="post"
                              onsubmit="return confirm('Are you sure you want to cancel this registration?');"
                              style="display:inline;">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="registrationId" value="<%= reg.getId() %>">
                            <button type="submit" class="px-3 py-1 text-xs font-medium rounded bg-red-50 text-red-600 hover:bg-red-100 border border-red-200 transition-colors">
                                Cancel
                            </button>
                        </form>
                    <% } else { %>
                        <span class="text-gray-300 text-sm">-</span>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<%@ include file="../common/footer.jsp" %>
