<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Activity, com.xiaoyuan.model.ActivityCategory" %>
<%
    List<Activity> activities = (List<Activity>) request.getAttribute("activities");
    List<ActivityCategory> categories = (List<ActivityCategory>) request.getAttribute("categories");
    Boolean isAdmin = (Boolean) request.getAttribute("isAdmin");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String keyword = (String) request.getAttribute("keyword");

    if (activities == null) activities = java.util.Collections.emptyList();
    if (categories == null) categories = java.util.Collections.emptyList();
    if (isAdmin == null) isAdmin = false;
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 0;
    if (totalCount == null) totalCount = 0;
%>

<div class="flex items-center justify-between mb-6">
    <div>
        <h1 class="text-2xl font-bold text-gray-800"><%= isAdmin ? "All Activities" : "My Activities" %></h1>
        <p class="text-gray-600 mt-1">Manage and track activities</p>
    </div>
    <a href="<%= contextPath %>/manage-activities?action=create" class="btn btn-primary">+ New Activity</a>
</div>

<!-- Search -->
<div class="bg-white rounded-lg shadow p-4 mb-6">
    <form action="<%= contextPath %>/manage-activities" method="get" class="flex gap-3 items-end">
        <div class="flex-1">
            <label class="block text-sm font-medium text-gray-700 mb-1">Search</label>
            <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>"
                   class="input-field" placeholder="Search by title or location...">
        </div>
        <div>
            <button type="submit" class="btn btn-primary">🔍 Search</button>
        </div>
        <% if (keyword != null && !keyword.isEmpty()) { %>
        <div>
            <a href="<%= contextPath %>/manage-activities" class="btn btn-secondary">Clear</a>
        </div>
        <% } %>
    </form>
</div>

<!-- Results info -->
<div class="mb-4 text-sm text-gray-500">
    Found <strong><%= totalCount %></strong> activities
    <% if (totalPages > 1) { %> | Page <%= currentPage %> of <%= totalPages %><% } %>
</div>

<% if (activities.isEmpty()) { %>
    <div class="bg-white rounded-lg shadow p-12 text-center text-gray-500">
        <div class="text-5xl mb-4">📅</div>
        <p>No activities to display.</p>
    </div>
<% } else { %>
<div class="bg-white rounded-lg shadow overflow-hidden">
    <table class="w-full">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Title</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Reg</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
            <% for (Activity act : activities) { %>
            <tr class="hover:bg-gray-50">
                <td class="px-4 py-3 text-sm text-gray-500">#<%= act.getId() %></td>
                <td class="px-4 py-3 text-sm font-medium text-gray-800"><%= act.getTitle() %></td>
                <td class="px-4 py-3 text-sm text-gray-500"><%= act.getCategoryName() %></td>
                <td class="px-4 py-3 text-sm text-gray-500"><%= act.getActivityTime().format(java.time.format.DateTimeFormatter.ofPattern("MM-dd HH:mm")) %></td>
                <td class="px-4 py-3">
                    <% String statusClass = "draft".equals(act.getStatus()) ? "bg-gray-100 text-gray-700" :
                       "published".equals(act.getStatus()) ? "bg-green-100 text-green-700" :
                       "cancelled".equals(act.getStatus()) ? "bg-red-100 text-red-700" :
                       "deleted".equals(act.getStatus()) ? "bg-gray-200 text-gray-500 line-through" :
                       "bg-blue-100 text-blue-700"; %>
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full <%= statusClass %>"><%= act.getStatus() %></span>
                </td>
                <td class="px-4 py-3 text-sm"><%= act.getRegisteredCount() %>/<%= act.getMaxParticipants() %></td>
                <td class="px-4 py-3">
                    <div class="flex items-center gap-1">
                        <a href="<%= contextPath %>/manage-activities?action=edit&id=<%= act.getId() %>"
                           class="text-xs px-2 py-1 bg-blue-50 text-blue-600 rounded hover:bg-blue-100">Edit</a>
                        <form method="post" action="<%= contextPath %>/manage-activities" class="inline" onsubmit="return confirm('Delete this activity?\n\nThis will soft-delete the activity. Registrations, check-in records, and points will be preserved. Students will see this activity as deleted.')">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= act.getId() %>">
                            <button type="submit" class="text-xs px-2 py-1 bg-red-50 text-red-600 rounded hover:bg-red-100">Delete</button>
                        </form>
                    </div>
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
            <a href="<%= contextPath %>/manage-activities?page=<%= currentPage - 1 %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %>"
               class="px-3 py-2 rounded-lg border border-gray-300 text-sm text-gray-700 hover:bg-gray-100">← Prev</a>
        <% } %>
        <% for (int i = 1; i <= totalPages; i++) { %>
            <a href="<%= contextPath %>/manage-activities?page=<%= i %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %>"
               class="px-3 py-2 rounded-lg text-sm <%= i == currentPage ? "bg-blue-600 text-white" : "border border-gray-300 text-gray-700 hover:bg-gray-100" %>">
                <%= i %>
            </a>
        <% } %>
        <% if (currentPage < totalPages) { %>
            <a href="<%= contextPath %>/manage-activities?page=<%= currentPage + 1 %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %>"
               class="px-3 py-2 rounded-lg border border-gray-300 text-sm text-gray-700 hover:bg-gray-100">Next →</a>
        <% } %>
    </nav>
</div>
<% } %>
<% } %>

<%@ include file="../common/footer.jsp" %>
