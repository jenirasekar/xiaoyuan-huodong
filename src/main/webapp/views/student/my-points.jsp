<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.PointRecord" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Integer myPoints = (Integer) request.getAttribute("myPoints");
    List<PointRecord> myRecords = (List<PointRecord>) request.getAttribute("myRecords");
    List<Object[]> leaderboard = (List<Object[]>) request.getAttribute("leaderboard");
    if (myPoints == null) myPoints = 0;
    if (myRecords == null) myRecords = java.util.Collections.emptyList();
    if (leaderboard == null) leaderboard = java.util.Collections.emptyList();
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div class="lg:col-span-2">
        <div class="bg-white rounded-lg shadow p-6 mb-6">
            <h1 class="text-xl font-bold text-gray-800">My Points Summary</h1>
            <div class="mt-4 text-center">
                <div class="text-6xl font-bold text-blue-600"><%= myPoints %></div>
                <div class="text-gray-500 mt-2">Total Points Earned</div>
            </div>
        </div>

        <h2 class="text-lg font-semibold text-gray-800 mb-4">My Points History</h2>
        <% if (myRecords.isEmpty()) { %>
            <div class="bg-white rounded-lg shadow p-8 text-center text-gray-500">
                No points earned yet. Participate in activities and check in to earn points!
            </div>
        <% } else { %>
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <table class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Activity</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Points</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Remark</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    <% for (PointRecord pr : myRecords) { %>
                    <tr>
                        <td class="px-4 py-3 text-sm"><%= pr.getActivityTitle() != null ? pr.getActivityTitle() : "(Activity deleted)" %></td>
                        <td class="px-4 py-3">
                            <span class="text-sm font-medium text-green-600">+<%= pr.getPoints() %></span>
                        </td>
                        <td class="px-4 py-3 text-sm text-gray-500"><%= pr.getRemark() != null ? pr.getRemark() : "" %></td>
                        <td class="px-4 py-3 text-sm text-gray-500"><%= pr.getCreatedAt().format(dtf) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>

    <div>
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-semibold text-gray-800 mb-4">🏆 Points Leaderboard</h2>
            <% if (leaderboard.isEmpty()) { %>
                <p class="text-gray-500 text-sm">No data yet.</p>
            <% } else { %>
            <div class="space-y-3">
                <% int rank = 0;
                   for (Object[] row : leaderboard) {
                       rank++;
                       int sid = (Integer) row[0];
                       String name = (String) row[1];
                       String uname = (String) row[2];
                       long pts = ((Number) row[3]).longValue();
                       long actCount = ((Number) row[4]).longValue();
                %>
                <div class="flex items-center justify-between p-3 rounded-lg <%= sid == sessionUser.getId() ? "bg-blue-50 border border-blue-200" : "bg-gray-50" %>">
                    <div class="flex items-center gap-3">
                        <span class="text-lg font-bold <%= rank <= 3 ? "text-yellow-500" : "text-gray-400" %>">
                            #<%= rank %>
                        </span>
                        <div>
                            <div class="text-sm font-medium text-gray-800"><%= name %></div>
                            <div class="text-xs text-gray-500"><%= actCount %> activities</div>
                        </div>
                    </div>
                    <span class="text-sm font-bold text-blue-600"><%= pts %> pts</span>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
