<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="com.xiaoyuan.model.Activity, com.xiaoyuan.model.ActivityCategory, java.util.List" %>
<%
    Activity activity = (Activity) request.getAttribute("activity");
    List<ActivityCategory> categories = (List<ActivityCategory>) request.getAttribute("categories");
    String formAction = (String) request.getAttribute("formAction");
    boolean isEdit = "edit".equals(formAction) && activity != null;
    if (categories == null) categories = java.util.Collections.emptyList();
%>

<div class="max-w-3xl mx-auto">
    <div class="mb-4">
        <a href="<%= contextPath %>/manage-activities" class="text-blue-600 hover:underline text-sm">← Back</a>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <h1 class="text-xl font-bold text-gray-800 mb-6"><%= isEdit ? "Edit Activity" : "Create New Activity" %></h1>

        <form action="<%= contextPath %>/manage-activities" method="post" class="space-y-5">
            <input type="hidden" name="action" value="save">
            <% if (isEdit) { %>
                <input type="hidden" name="id" value="<%= activity.getId() %>">
            <% } %>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="md:col-span-2">
                    <label class="block text-sm font-medium text-gray-700 mb-1">Title *</label>
                    <input type="text" name="title" required class="input-field"
                           value="<%= isEdit ? activity.getTitle() : "" %>" placeholder="Activity title">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Category *</label>
                    <select name="categoryId" required class="input-field">
                        <option value="">Select category</option>
                        <% for (ActivityCategory cat : categories) { %>
                            <option value="<%= cat.getId() %>" <%= (isEdit && activity.getCategoryId() == cat.getId()) ? "selected" : "" %>>
                                <%= cat.getName() %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Location *</label>
                    <input type="text" name="location" required class="input-field"
                           value="<%= isEdit ? activity.getLocation() : "" %>" placeholder="Event location">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Activity Time *</label>
                    <input type="datetime-local" name="activityTime" required class="input-field"
                           value="<%= isEdit ? activity.getActivityTime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : "" %>">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Max Participants *</label>
                    <input type="number" name="maxParticipants" required min="1" class="input-field"
                           value="<%= isEdit ? activity.getMaxParticipants() : "50" %>">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Registration Start *</label>
                    <input type="datetime-local" name="regStart" required class="input-field"
                           value="<%= isEdit ? activity.getRegStart().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : "" %>">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Registration End *</label>
                    <input type="datetime-local" name="regEnd" required class="input-field"
                           value="<%= isEdit ? activity.getRegEnd().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : "" %>">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Points *</label>
                    <input type="number" name="points" required min="0" class="input-field"
                           value="<%= isEdit ? activity.getPoints() : "1" %>">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Status *</label>
                    <select name="status" required class="input-field">
                        <option value="draft" <%= (isEdit && "draft".equals(activity.getStatus())) ? "selected" : "" %>>Draft</option>
                        <option value="published" <%= (isEdit && "published".equals(activity.getStatus())) ? "selected" : "" %>>Published</option>
                        <option value="cancelled" <%= (isEdit && "cancelled".equals(activity.getStatus())) ? "selected" : "" %>>Cancelled</option>
                        <%
                            boolean canComplete = isEdit
                                && activity.getActivityTime() != null
                                && !java.time.LocalDateTime.now().isBefore(activity.getActivityTime());
                        %>
                        <option value="completed"
                            <%= (isEdit && "completed".equals(activity.getStatus())) ? "selected" : "" %>
                            <%= canComplete ? "" : "disabled" %>>
                            Completed<%= !canComplete ? " (after activity starts)" : "" %>
                        </option>
                    </select>
                    <% if (!canComplete && isEdit) { %>
                        <p class="text-xs text-amber-600 mt-1">Cannot mark as completed until the activity time has passed.</p>
                    <% } %>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Check-in Code</label>
                    <input type="text" name="checkinCode" class="input-field"
                           value="<%= (isEdit && activity.getCheckinCode() != null) ? activity.getCheckinCode() : "" %>"
                           placeholder="Code for student self-check-in (optional)">
                    <p class="text-xs text-gray-500 mt-1">Students can use this code for self-check-in during the event.</p>
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea name="description" rows="4" class="input-field"
                          placeholder="Activity description..."><%= (isEdit && activity.getDescription() != null) ? activity.getDescription() : "" %></textarea>
            </div>

            <div class="flex items-center gap-3 pt-4 border-t border-gray-200">
                <button type="submit" class="btn btn-primary"><%= isEdit ? "Update Activity" : "Create Activity" %></button>
                <a href="<%= contextPath %>/manage-activities" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
