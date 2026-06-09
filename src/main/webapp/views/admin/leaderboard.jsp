<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List" %>
<%
    List<Object[]> leaderboard = (List<Object[]>) request.getAttribute("leaderboard");
    if (leaderboard == null) leaderboard = java.util.Collections.emptyList();
%>

<h1 class="text-2xl font-bold text-gray-800 mb-2">🏆 Points Leaderboard</h1>
<p class="text-sm text-gray-500 mb-6">Students ranked by total points earned across all activities.</p>

<% if (leaderboard.isEmpty()) { %>
    <div class="bg-white rounded-lg shadow p-12 text-center">
        <div class="text-4xl mb-3">📭</div>
        <p class="text-gray-500 text-lg">No points earned yet.</p>
        <p class="text-gray-400 text-sm mt-1">Points are awarded when students check in to activities.</p>
    </div>
<% } else { %>
<div class="bg-white rounded-lg shadow overflow-hidden">
    <table class="w-full">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rank</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Student</th>
                <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Activities</th>
                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Points</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
            <% int rank = 0;
               for (Object[] row : leaderboard) {
                   rank++;
                   String name = (String) row[1];
                   String username = (String) row[2];
                   long pts = ((Number) row[3]).longValue();
                   long actCount = ((Number) row[4]).longValue();
            %>
            <tr class="<%= rank <= 3 ? "bg-yellow-50" : "" %> hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4">
                    <span class="inline-flex items-center justify-center w-8 h-8 rounded-full text-sm font-bold
                        <%= rank == 1 ? "bg-yellow-400 text-white" :
                            rank == 2 ? "bg-gray-300 text-white" :
                            rank == 3 ? "bg-amber-600 text-white" :
                            "bg-gray-100 text-gray-500" %>">
                        <%= rank %>
                    </span>
                </td>
                <td class="px-6 py-4">
                    <div class="text-sm font-medium text-gray-800"><%= name %></div>
                    <div class="text-xs text-gray-400">@<%= username %></div>
                </td>
                <td class="px-6 py-4 text-center text-sm text-gray-500"><%= actCount %></td>
                <td class="px-6 py-4 text-right">
                    <span class="text-sm font-bold text-blue-600"><%= pts %> pts</span>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<%@ include file="../common/footer.jsp" %>
