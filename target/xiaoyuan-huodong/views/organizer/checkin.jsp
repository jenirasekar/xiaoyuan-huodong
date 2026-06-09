<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Activity, com.xiaoyuan.model.Registration, com.xiaoyuan.model.CheckIn" %>
<%
    List<Activity> allActivities = (List<Activity>) request.getAttribute("allActivities");
    List<Activity> myActivities = (List<Activity>) request.getAttribute("myActivities");
    List<Activity> activityList = allActivities != null ? allActivities : myActivities;
    List<Registration> registrations = (List<Registration>) request.getAttribute("registrations");
    List<CheckIn> checkIns = (List<CheckIn>) request.getAttribute("checkIns");
    Activity selectedActivity = (Activity) request.getAttribute("activity");
    Integer selectedActivityId = (Integer) request.getAttribute("selectedActivityId");
    if (activityList == null) activityList = java.util.Collections.emptyList();
    if (registrations == null) registrations = java.util.Collections.emptyList();
    if (checkIns == null) checkIns = java.util.Collections.emptyList();
%>

<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-800">Activity Check-in</h1>
    <p class="text-gray-600 mt-1">Manage on-site check-in for approved participants</p>
</div>

<div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
    <!-- Activity List Sidebar -->
    <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-sm font-semibold text-gray-700 mb-3">Activities</h2>
        <div class="space-y-1">
            <% for (Activity act : activityList) { %>
                <a href="<%= contextPath %>/checkin?activityId=<%= act.getId() %>"
                   class="block px-3 py-2 rounded-lg text-sm <%= (selectedActivityId != null && selectedActivityId == act.getId()) ? "bg-blue-50 text-blue-700 font-medium" : "text-gray-700 hover:bg-gray-100" %>">
                    <%= act.getTitle() %>
                </a>
            <% } %>
        </div>
    </div>

    <div class="lg:col-span-3">
        <% if (selectedActivity == null) { %>
            <div class="bg-white rounded-lg shadow p-12 text-center text-gray-500">
                <div class="text-5xl mb-4">👈</div>
                <p>Select an activity to manage check-ins.</p>
            </div>
        <% } else { %>
            <div class="bg-white rounded-lg shadow p-6 mb-4">
                <h2 class="text-lg font-semibold text-gray-800"><%= selectedActivity.getTitle() %></h2>
                <div class="flex items-center gap-4 mt-2 text-sm text-gray-500">
                    <span>Approved: <%= registrations.size() %></span>
                    <span class="text-green-600">Checked in: <%= checkIns.size() %></span>
                    <span class="text-red-600">Not checked in: <%= registrations.size() - checkIns.size() %></span>
                </div>
            </div>

            <h3 class="text-md font-semibold text-gray-700 mb-3">Approved Participants</h3>
            <% if (registrations.isEmpty()) { %>
                <div class="bg-white rounded-lg shadow p-8 text-center text-gray-500">No approved participants.</div>
            <% } else { %>
            <div class="bg-white rounded-lg shadow overflow-hidden">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Student</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Check-in Time</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% for (Registration reg : registrations) { %>
                        <tr>
                            <td class="px-4 py-3 text-sm font-medium text-gray-800"><%= reg.getStudentName() %></td>
                            <td class="px-4 py-3">
                                <% if (reg.isCheckedIn()) { %>
                                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-green-100 text-green-700">Checked In</span>
                                <% } else { %>
                                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-red-100 text-red-700">Not Checked In</span>
                                <% } %>
                            </td>
                            <td class="px-4 py-3 text-sm text-gray-500">
                                <% if (reg.isCheckedIn()) {
                                    for (CheckIn ci : checkIns) {
                                        if (ci.getRegistrationId() == reg.getId()) { %>
                                            <%= ci.getCheckinTime().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss")) %>
                                        <% break; }
                                    }
                                } else { %>-<% } %>
                            </td>
                            <td class="px-4 py-3 text-sm text-gray-500">
                                <% if (reg.isCheckedIn()) {
                                    for (CheckIn ci : checkIns) {
                                        if (ci.getRegistrationId() == reg.getId()) { %>
                                            <%= ci.getCheckinCode() %>
                                        <% break; }
                                    }
                                } else { %>-<% } %>
                            </td>
                            <td class="px-4 py-3">
                                <% if (!reg.isCheckedIn()) { %>
                                <form action="<%= contextPath %>/checkin" method="post">
                                    <input type="hidden" name="registrationId" value="<%= reg.getId() %>">
                                    <input type="hidden" name="activityId" value="<%= selectedActivity.getId() %>">
                                    <input type="hidden" name="checkinCode" value="MANUAL-<%= System.currentTimeMillis() %>">
                                    <button type="submit" class="text-xs px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700">✅ Check In</button>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        <% } %>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
