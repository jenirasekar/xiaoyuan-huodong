<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="com.xiaoyuan.model.Activity, com.xiaoyuan.model.Registration, java.time.format.DateTimeFormatter" %>
<%
    Activity activity = (Activity) request.getAttribute("activity");
    Registration myRegistration = (Registration) request.getAttribute("myRegistration");
    if (activity == null) {
        response.sendRedirect(contextPath + "/activities");
        return;
    }
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>

<div class="max-w-4xl mx-auto">
    <div class="mb-4">
        <a href="<%= contextPath %>/activities" class="text-blue-600 hover:underline text-sm">← Back to Activities</a>
    </div>

    <% if ("cancelled".equals(activity.getStatus())) { %>
    <div class="mb-4 p-4 bg-red-50 border border-red-300 text-red-700 rounded-lg font-medium text-center">
        🚫 This activity has been cancelled by the organizer.
    </div>
    <% } else if ("deleted".equals(activity.getStatus())) { %>
    <div class="mb-4 p-4 bg-gray-100 border border-gray-400 text-gray-600 rounded-lg font-medium text-center">
        🗑️ This activity has been removed by the organizer. Your registration and points are preserved.
    </div>
    <% } %>

    <div class="bg-white rounded-lg shadow">
        <div class="p-6 border-b border-gray-200">
            <div class="flex items-center gap-2 mb-3">
                <span class="text-xs font-medium px-2 py-1 rounded bg-blue-100 text-blue-700"><%= activity.getCategoryName() %></span>
                <span class="text-xs font-medium px-2 py-1 rounded bg-green-100 text-green-700">+<%= activity.getPoints() %> Points</span>
                <% if (activity.isFull()) { %>
                    <span class="text-xs font-medium px-2 py-1 rounded bg-red-100 text-red-700">Full</span>
                <% } %>
            </div>
            <h1 class="text-2xl font-bold text-gray-800"><%= activity.getTitle() %></h1>
            <p class="text-gray-500 text-sm mt-1">Organized by: <%= activity.getOrganizerName() %></p>
        </div>

        <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <h2 class="text-lg font-semibold text-gray-800 mb-4">Activity Details</h2>
                <div class="space-y-3">
                    <div class="flex items-start">
                        <span class="text-gray-500 w-6">📍</span>
                        <div><span class="text-sm font-medium text-gray-700">Location</span>
                            <p class="text-sm text-gray-600"><%= activity.getLocation() %></p></div>
                    </div>
                    <div class="flex items-start">
                        <span class="text-gray-500 w-6">🕐</span>
                        <div><span class="text-sm font-medium text-gray-700">Activity Time</span>
                            <p class="text-sm text-gray-600"><%= activity.getActivityTime().format(dtf) %></p></div>
                    </div>
                    <div class="flex items-start">
                        <span class="text-gray-500 w-6">📝</span>
                        <div><span class="text-sm font-medium text-gray-700">Registration Period</span>
                            <p class="text-sm text-gray-600"><%= activity.getRegStart().format(dtf) %> ~ <%= activity.getRegEnd().format(dtf) %></p></div>
                    </div>
                    <div class="flex items-start">
                        <span class="text-gray-500 w-6">👥</span>
                        <div><span class="text-sm font-medium text-gray-700">Capacity</span>
                            <p class="text-sm <%= activity.isFull() ? "text-red-600" : "text-gray-600" %>">
                                <%= activity.getRegisteredCount() %> / <%= activity.getMaxParticipants() %>
                                <% if (activity.isFull()) { %><span class="text-xs ml-1">(Full)</span><% } %>
                            </p></div>
                    </div>
                </div>
            </div>

            <div>
                <h2 class="text-lg font-semibold text-gray-800 mb-4">Description</h2>
                <div class="bg-gray-50 rounded-lg p-4 text-sm text-gray-700 leading-relaxed">
                    <%= activity.getDescription() != null ? activity.getDescription() : "No description provided." %>
                </div>

                <div class="mt-6">
                    <% if ("student".equals(session.getAttribute("role"))) { %>
                        <%-- Already registered — show status --%>
                        <% if (myRegistration != null) { %>
                            <div class="w-full py-3 bg-blue-50 border border-blue-200 text-blue-700 font-medium rounded-lg text-center">
                                <% if ("pending".equals(myRegistration.getStatus())) { %>
                                    ⏳ Registration pending review
                                <% } else if ("approved".equals(myRegistration.getStatus())) { %>
                                    ✅ Registration approved
                                <% } else { %>
                                    ❌ Registration rejected
                                <% } %>
                            </div>
                            <% if ("pending".equals(myRegistration.getStatus())) { %>
                                <form action="<%= contextPath %>/registrations" method="post"
                                      onsubmit="return confirm('Are you sure you want to cancel this registration?');"
                                      class="mt-3">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="registrationId" value="<%= myRegistration.getId() %>">
                                    <button type="submit" class="w-full py-2 bg-red-50 border border-red-200 text-red-600 font-medium rounded-lg hover:bg-red-100 transition-colors text-sm">
                                        Cancel Registration
                                    </button>
                                </form>
                            <% } %>
                        <% } else { %>
                            <%-- Time conflict warning --%>
                            <% Boolean timeConflict = (Boolean) request.getAttribute("timeConflict"); %>
                            <% if (timeConflict != null && timeConflict) { %>
                                <div class="w-full py-2 mb-3 bg-yellow-50 border border-yellow-200 text-yellow-700 text-sm rounded-lg text-center">
                                    ⚠️ This activity conflicts with another activity you are registered for (within 1 hour).
                                </div>
                            <% } %>
                            <%-- Not registered yet --%>
                            <% if (activity.isRegistrationOpen() && !activity.isFull()) { %>
                                <form action="<%= contextPath %>/registrations" method="post">
                                    <input type="hidden" name="activityId" value="<%= activity.getId() %>">
                                    <button type="submit" class="w-full py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors">
                                        Register Now
                                    </button>
                                </form>
                            <% } else if (activity.isFull()) { %>
                                <button disabled class="w-full py-3 bg-gray-300 text-gray-500 font-medium rounded-lg cursor-not-allowed">
                                    Registration Full
                                </button>
                            <% } else if (!activity.isRegistrationOpen()) { %>
                                <button disabled class="w-full py-3 bg-gray-300 text-gray-500 font-medium rounded-lg cursor-not-allowed">
                                    Registration Closed
                                </button>
                            <% } %>
                        <% } %>
                    <% } else { %>
                        <p class="text-sm text-gray-500 text-center">Only students can register for activities.</p>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
