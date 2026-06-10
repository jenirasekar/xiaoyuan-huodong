<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Registration" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    List<Registration> registrations = (List<Registration>) request.getAttribute("registrations");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    if (registrations == null) registrations = java.util.Collections.emptyList();
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 0;
    if (totalCount == null) totalCount = 0;
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>

<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-800">My Registrations</h1>
    <p class="text-gray-600 mt-1">Track your activity registrations and check-in status</p>
</div>

<!-- Results info -->
<div class="mb-4 text-sm text-gray-500">
    Found <strong><%= totalCount %></strong> registrations
    <% if (totalPages > 1) { %> | Page <%= currentPage %> of <%= totalPages %><% } %>
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
                    <% if ("rejected".equals(reg.getStatus()) && reg.getReviewComment() != null && !reg.getReviewComment().isEmpty()) { %>
                        <button onclick="viewComment('<%= reg.getActivityTitle().replace("\\", "\\\\").replace("'", "\\'") %>', '<%= reg.getReviewComment().replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "") %>')"
                                class="text-red-600 hover:text-red-800 underline cursor-pointer text-left" title="View rejection reason">
                            <%= reg.getReviewComment() %>
                        </button>
                    <% } else { %>
                        <%= reg.getReviewComment() != null ? reg.getReviewComment() : "-" %>
                    <% } %>
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

<!-- Pagination -->
<% if (totalPages > 1) { %>
<div class="mt-6 flex justify-center">
    <nav class="flex items-center space-x-1">
        <% if (currentPage > 1) { %>
            <a href="<%= contextPath %>/registrations?page=<%= currentPage - 1 %>"
               class="px-3 py-2 rounded-lg border border-gray-300 text-sm text-gray-700 hover:bg-gray-100">← Prev</a>
        <% } %>
        <% for (int i = 1; i <= totalPages; i++) { %>
            <a href="<%= contextPath %>/registrations?page=<%= i %>"
               class="px-3 py-2 rounded-lg text-sm <%= i == currentPage ? "bg-blue-600 text-white" : "border border-gray-300 text-gray-700 hover:bg-gray-100" %>">
                <%= i %>
            </a>
        <% } %>
        <% if (currentPage < totalPages) { %>
            <a href="<%= contextPath %>/registrations?page=<%= currentPage + 1 %>"
               class="px-3 py-2 rounded-lg border border-gray-300 text-sm text-gray-700 hover:bg-gray-100">Next →</a>
        <% } %>
    </nav>
</div>
<% } %>
<% } %>

<!-- View Comment Modal -->
<div id="viewCommentModal" class="hidden fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-800">Rejection Comment</h3>
            <button onclick="document.getElementById('viewCommentModal').classList.add('hidden')"
                    class="text-gray-400 hover:text-gray-600 text-xl leading-none">&times;</button>
        </div>
        <div class="mb-2">
            <span class="text-xs text-gray-500">Activity: </span>
            <span id="commentActivityTitle" class="text-sm font-medium text-gray-800"></span>
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

<script>
function viewComment(title, comment) {
    document.getElementById('commentActivityTitle').textContent = title;
    document.getElementById('commentText').textContent = comment;
    document.getElementById('viewCommentModal').classList.remove('hidden');
}
</script>

<%@ include file="../common/footer.jsp" %>
