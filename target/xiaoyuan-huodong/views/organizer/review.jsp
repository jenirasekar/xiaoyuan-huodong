<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Activity, com.xiaoyuan.model.Registration" %>
<%
    List<Activity> myActivities = (List<Activity>) request.getAttribute("myActivities");
    List<Registration> registrations = (List<Registration>) request.getAttribute("registrations");
    Activity selectedActivity = (Activity) request.getAttribute("activity");
    Integer selectedActivityId = (Integer) request.getAttribute("selectedActivityId");
    String keyword = (String) request.getAttribute("keyword");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    if (myActivities == null) myActivities = java.util.Collections.emptyList();
    if (registrations == null) registrations = java.util.Collections.emptyList();
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 0;
    if (totalCount == null) totalCount = 0;
%>

<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-800">Review Registrations</h1>
    <p class="text-gray-600 mt-1">Approve or reject student registrations</p>
</div>

<div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
    <!-- Activity List Sidebar -->
    <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-sm font-semibold text-gray-700 mb-3">My Activities</h2>
        <!-- Sidebar search -->
        <form action="<%= contextPath %>/reviews" method="get" class="mb-3">
            <% if (selectedActivityId != null) { %>
            <input type="hidden" name="activityId" value="<%= selectedActivityId %>">
            <% } %>
            <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>"
                   class="input-field text-sm py-1.5" placeholder="Search activities...">
        </form>
        <div class="space-y-1 max-h-96 overflow-y-auto">
            <% for (Activity act : myActivities) { %>
                <a href="<%= contextPath %>/reviews?activityId=<%= act.getId() %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %>"
                   class="block px-3 py-2 rounded-lg text-sm <%= (selectedActivityId != null && selectedActivityId == act.getId()) ? "bg-blue-50 text-blue-700 font-medium" : "text-gray-700 hover:bg-gray-100" %>">
                    <%= act.getTitle() %>
                    <span class="text-xs text-gray-500 block"><%= act.getRegisteredCount() %> registered</span>
                </a>
            <% } %>
            <% if (myActivities.isEmpty()) { %>
                <p class="text-xs text-gray-400 px-3 py-2">No activities found.</p>
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
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-gray-800"><%= selectedActivity.getTitle() %></h2>
                    <a href="<%= contextPath %>/export?activityId=<%= selectedActivity.getId() %>"
                       class="btn bg-green-600 hover:bg-green-700 text-white text-sm px-4 py-2 rounded-lg inline-flex items-center gap-1">
                        📥 Export Excel
                    </a>
                </div>
                <div class="flex items-center gap-4 mt-2 text-sm text-gray-500">
                    <span>Total: <%= totalCount %></span>
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
                            <td class="px-4 py-3 text-sm text-gray-500 max-w-[150px] truncate">
                                <% if ("rejected".equals(reg.getStatus()) && reg.getReviewComment() != null && !reg.getReviewComment().isEmpty()) { %>
                                    <button onclick="viewComment('<%= reg.getStudentName().replace("\\", "\\\\").replace("'", "\\'") %>', '<%= reg.getReviewComment().replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "") %>')"
                                            class="text-red-600 hover:text-red-800 underline cursor-pointer" title="View rejection reason">
                                        <%= reg.getReviewComment() %>
                                    </button>
                                <% } else { %>
                                    <%= reg.getReviewComment() != null ? reg.getReviewComment() : "-" %>
                                <% } %>
                            </td>
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

            <!-- Pagination -->
            <% if (totalPages > 1) { %>
            <div class="mt-6 flex justify-center">
                <nav class="flex items-center space-x-1">
                    <% if (currentPage > 1) { %>
                        <a href="<%= contextPath %>/reviews?activityId=<%= selectedActivityId %>&page=<%= currentPage - 1 %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %>"
                           class="px-3 py-2 rounded-lg border border-gray-300 text-sm text-gray-700 hover:bg-gray-100">← Prev</a>
                    <% } %>
                    <% for (int i = 1; i <= totalPages; i++) { %>
                        <a href="<%= contextPath %>/reviews?activityId=<%= selectedActivityId %>&page=<%= i %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %>"
                           class="px-3 py-2 rounded-lg text-sm <%= i == currentPage ? "bg-blue-600 text-white" : "border border-gray-300 text-gray-700 hover:bg-gray-100" %>">
                            <%= i %>
                        </a>
                    <% } %>
                    <% if (currentPage < totalPages) { %>
                        <a href="<%= contextPath %>/reviews?activityId=<%= selectedActivityId %>&page=<%= currentPage + 1 %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %>"
                           class="px-3 py-2 rounded-lg border border-gray-300 text-sm text-gray-700 hover:bg-gray-100">Next →</a>
                    <% } %>
                </nav>
            </div>
            <% } %>
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
function viewComment(name, comment) {
    document.getElementById('commentStudentName').textContent = name;
    document.getElementById('commentText').textContent = comment;
    document.getElementById('viewCommentModal').classList.remove('hidden');
}
</script>

<!-- View Comment Modal -->
<div id="viewCommentModal" class="hidden fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-800">Rejection Comment</h3>
            <button onclick="document.getElementById('viewCommentModal').classList.add('hidden')"
                    class="text-gray-400 hover:text-gray-600 text-xl leading-none">&times;</button>
        </div>
        <div class="mb-2">
            <span class="text-xs text-gray-500">Student: </span>
            <span id="commentStudentName" class="text-sm font-medium text-gray-800"></span>
        </div>
        <div class="bg-red-50 border border-red-200 rounded-lg p-4 mt-2">
            <p id="commentText" class="text-sm text-gray-700 whitespace-pre-wrap"></p>
        </div>
        <div class="flex justify-end mt-4">
            <button type="button" onclick="document.getElementById('viewCommentModal').classList.add('hidden')"
                    class="btn btn-secondary text-sm">Close</button>
        </div>
    </div>
</div>
<% } %>

<%@ include file="../common/footer.jsp" %>
