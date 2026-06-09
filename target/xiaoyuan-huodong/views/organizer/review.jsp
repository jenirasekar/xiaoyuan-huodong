<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Activity, com.xiaoyuan.model.Registration" %>
<%
    List<Activity> myActivities = (List<Activity>) request.getAttribute("myActivities");
    List<Registration> registrations = (List<Registration>) request.getAttribute("registrations");
    Activity selectedActivity = (Activity) request.getAttribute("activity");
    Integer selectedActivityId = (Integer) request.getAttribute("selectedActivityId");
    if (myActivities == null) myActivities = java.util.Collections.emptyList();
    if (registrations == null) registrations = java.util.Collections.emptyList();
%>

<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-800">Review Registrations</h1>
    <p class="text-gray-600 mt-1">Approve or reject student registrations</p>
</div>

<div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
    <!-- Activity List Sidebar -->
    <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-sm font-semibold text-gray-700 mb-3">My Activities</h2>
        <div class="space-y-1">
            <% for (Activity act : myActivities) { %>
                <a href="<%= contextPath %>/reviews?activityId=<%= act.getId() %>"
                   class="block px-3 py-2 rounded-lg text-sm <%= (selectedActivityId != null && selectedActivityId == act.getId()) ? "bg-blue-50 text-blue-700 font-medium" : "text-gray-700 hover:bg-gray-100" %>">
                    <%= act.getTitle() %>
                    <span class="text-xs text-gray-500 block"><%= act.getRegisteredCount() %> registered</span>
                </a>
            <% } %>
        </div>
    </div>

    <!-- Registration List -->
    <div class="lg:col-span-3">
        <% if (selectedActivity == null) { %>
            <div class="bg-white rounded-lg shadow p-12 text-center text-gray-500">
                <div class="text-5xl mb-4">👈</div>
                <p>Select an activity from the list to review its registrations.</p>
            </div>
        <% } else { %>
            <div class="bg-white rounded-lg shadow p-6 mb-6">
                <h2 class="text-lg font-semibold text-gray-800"><%= selectedActivity.getTitle() %></h2>
                <div class="flex items-center gap-4 mt-2 text-sm text-gray-500">
                    <span>Total: <%= registrations.size() %></span>
                    <span class="text-yellow-600">Pending: <%= registrations.stream().filter(r -> "pending".equals(r.getStatus())).count() %></span>
                    <span class="text-green-600">Approved: <%= registrations.stream().filter(r -> "approved".equals(r.getStatus())).count() %></span>
                    <span class="text-red-600">Rejected: <%= registrations.stream().filter(r -> "rejected".equals(r.getStatus())).count() %></span>
                </div>
                <% long pendingCount = registrations.stream().filter(r -> "pending".equals(r.getStatus())).count();
                   if (pendingCount > 0) { %>
                <form action="<%= contextPath %>/reviews" method="post" class="mt-3">
                    <input type="hidden" name="action" value="batch">
                    <input type="hidden" name="activityId" value="<%= selectedActivity.getId() %>">
                    <button type="submit" class="btn btn-success text-sm">Batch Approve All Pending</button>
                </form>
                <% } %>
            </div>

            <% if (registrations.isEmpty()) { %>
                <div class="bg-white rounded-lg shadow p-8 text-center text-gray-500">
                    No registrations for this activity yet.
                </div>
            <% } else { %>
            <div class="bg-white rounded-lg shadow overflow-hidden">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Student</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Registered</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Comment</th>
                            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        <% for (Registration reg : registrations) { %>
                        <tr>
                            <td class="px-4 py-3 text-sm font-medium text-gray-800"><%= reg.getStudentName() %></td>
                            <td class="px-4 py-3">
                                <% if ("approved".equals(reg.getStatus())) { %>
                                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-green-100 text-green-700">Approved</span>
                                <% } else if ("rejected".equals(reg.getStatus())) { %>
                                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-red-100 text-red-700">Rejected</span>
                                <% } else { %>
                                    <span class="px-2 py-0.5 text-xs font-medium rounded-full bg-yellow-100 text-yellow-700">Pending</span>
                                <% } %>
                            </td>
                            <td class="px-4 py-3 text-sm text-gray-500"><%= reg.getRegisteredAt().format(java.time.format.DateTimeFormatter.ofPattern("MM-dd HH:mm")) %></td>
                            <td class="px-4 py-3 text-sm text-gray-500 max-w-[150px] truncate"><%= reg.getReviewComment() != null ? reg.getReviewComment() : "-" %></td>
                            <td class="px-4 py-3">
                                <% if ("pending".equals(reg.getStatus())) { %>
                                <div class="flex items-center gap-1">
                                    <form action="<%= contextPath %>/reviews" method="post">
                                        <input type="hidden" name="registrationId" value="<%= reg.getId() %>">
                                        <input type="hidden" name="activityId" value="<%= selectedActivity.getId() %>">
                                        <input type="hidden" name="status" value="approved">
                                        <input type="hidden" name="comment" value="Approved by organizer">
                                        <button type="submit" class="text-xs px-2 py-1 bg-green-50 text-green-600 rounded hover:bg-green-100">Approve</button>
                                    </form>
                                    <button onclick="rejectReg(<%= reg.getId() %>)" class="text-xs px-2 py-1 bg-red-50 text-red-600 rounded hover:bg-red-100">Reject</button>
                                </div>
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

<% if (selectedActivity != null) { %>
<!-- Reject Modal -->
<div id="rejectModal" class="hidden fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
        <h3 class="text-lg font-semibold text-gray-800 mb-4">Reject Registration</h3>
        <form action="<%= contextPath %>/reviews" method="post">
            <input type="hidden" name="activityId" value="<%= selectedActivity.getId() %>">
            <input type="hidden" name="status" value="rejected">
            <input type="hidden" name="registrationId" id="rejectRegId">
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-1">Rejection Reason</label>
                <textarea name="comment" rows="3" class="input-field" placeholder="Provide a reason for rejection..." required></textarea>
            </div>
            <div class="flex justify-end gap-2">
                <button type="button" onclick="document.getElementById('rejectModal').classList.add('hidden')" class="btn btn-secondary">Cancel</button>
                <button type="submit" class="btn btn-danger">Reject</button>
            </div>
        </form>
    </div>
</div>
<script>
function rejectReg(id) {
    document.getElementById('rejectRegId').value = id;
    document.getElementById('rejectModal').classList.remove('hidden');
}
</script>
<% } %>

<%@ include file="../common/footer.jsp" %>
