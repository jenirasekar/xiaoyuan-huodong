<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.Activity, com.xiaoyuan.model.ActivityCategory" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    List<Activity> activities = (List<Activity>) request.getAttribute("activities");
    List<ActivityCategory> categories = (List<ActivityCategory>) request.getAttribute("categories");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String keyword = (String) request.getAttribute("keyword");
    Integer categoryId = (Integer) request.getAttribute("categoryId");

    if (activities == null) activities = java.util.Collections.emptyList();
    if (categories == null) categories = java.util.Collections.emptyList();
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 0;
    if (totalCount == null) totalCount = 0;

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>

<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-800">Browse Activities</h1>
    <p class="text-gray-600 mt-1">Discover and register for campus activities</p>
</div>

<!-- Search & Filter -->
<div class="bg-white rounded-lg shadow p-4 mb-6">
    <form action="<%= contextPath %>/activities" method="get" class="flex flex-wrap gap-3 items-end">
        <div class="flex-1 min-w-[200px]">
            <label class="block text-sm font-medium text-gray-700 mb-1">Search</label>
            <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>"
                   class="input-field" placeholder="Search by title or location...">
        </div>
        <div class="w-48">
            <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
            <select name="categoryId" class="input-field">
                <option value="">All Categories</option>
                <% for (ActivityCategory cat : categories) { %>
                    <option value="<%= cat.getId() %>" <%= (categoryId != null && categoryId == cat.getId()) ? "selected" : "" %>>
                        <%= cat.getName() %>
                    </option>
                <% } %>
            </select>
        </div>
        <div>
            <button type="submit" class="btn btn-primary">🔍 Search</button>
        </div>
    </form>
</div>

<!-- Results -->
<div class="mb-4 text-sm text-gray-500">
    Found <strong><%= totalCount %></strong> activities
    <% if (totalPages > 1) { %> | Page <%= currentPage %> of <%= totalPages %><% } %>
</div>

<% if (activities.isEmpty()) { %>
    <div class="bg-white rounded-lg shadow p-12 text-center text-gray-500">
        <div class="text-4xl mb-3">📭</div>
        <p>No activities found matching your criteria.</p>
    </div>
<% } else { %>
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
    <% for (Activity act : activities) { %>
    <div class="bg-white rounded-lg shadow hover:shadow-md transition">
        <div class="p-5">
            <div class="flex items-center gap-2 mb-2">
                <span class="text-xs font-medium px-2 py-0.5 rounded bg-blue-100 text-blue-700"><%= act.getCategoryName() %></span>
                <span class="text-xs font-medium px-2 py-0.5 rounded bg-green-100 text-green-700">+<%= act.getPoints() %> pts</span>
            </div>
            <h3 class="text-lg font-semibold text-gray-800 mb-2"><%= act.getTitle() %></h3>
            <div class="space-y-1 text-sm text-gray-500">
                <p>📍 <%= act.getLocation() %></p>
                <p>🕐 <%= act.getActivityTime().format(dtf) %></p>
                <p>👤 <%= act.getOrganizerName() %></p>
            </div>
        </div>
        <div class="border-t border-gray-100 px-5 py-3 flex items-center justify-between bg-gray-50 rounded-b-lg">
            <div class="text-sm">
                <span class="text-gray-500">Registered: </span>
                <span class="font-medium <%= act.isFull() ? "text-red-600" : "text-green-600" %>">
                    <%= act.getRegisteredCount() %>/<%= act.getMaxParticipants() %>
                </span>
            </div>
            <a href="<%= contextPath %>/activities?action=detail&id=<%= act.getId() %>"
               class="btn btn-primary text-sm py-1.5 px-3">
                View →
            </a>
        </div>
    </div>
    <% } %>
</div>

<!-- Pagination -->
<% if (totalPages > 1) { %>
<div class="mt-6 flex justify-center">
    <nav class="flex items-center space-x-1">
        <% if (currentPage > 1) { %>
            <a href="<%= contextPath %>/activities?page=<%= currentPage - 1 %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %><%= categoryId != null ? "&categoryId=" + categoryId : "" %>"
               class="px-3 py-2 rounded-lg border border-gray-300 text-sm text-gray-700 hover:bg-gray-100">← Prev</a>
        <% } %>
        <% for (int i = 1; i <= totalPages; i++) { %>
            <a href="<%= contextPath %>/activities?page=<%= i %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %><%= categoryId != null ? "&categoryId=" + categoryId : "" %>"
               class="px-3 py-2 rounded-lg text-sm <%= i == currentPage ? "bg-blue-600 text-white" : "border border-gray-300 text-gray-700 hover:bg-gray-100" %>">
                <%= i %>
            </a>
        <% } %>
        <% if (currentPage < totalPages) { %>
            <a href="<%= contextPath %>/activities?page=<%= currentPage + 1 %><%= keyword != null ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "" %><%= categoryId != null ? "&categoryId=" + categoryId : "" %>"
               class="px-3 py-2 rounded-lg border border-gray-300 text-sm text-gray-700 hover:bg-gray-100">Next →</a>
        <% } %>
    </nav>
</div>
<% } %>
<% } %>

<%@ include file="../common/footer.jsp" %>
