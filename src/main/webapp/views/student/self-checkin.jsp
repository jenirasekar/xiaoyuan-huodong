<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>

<div class="max-w-lg mx-auto">
    <div class="mb-6">
        <h1 class="text-2xl font-bold text-gray-800">Self Check-in</h1>
        <p class="text-gray-600 mt-1">Enter the check-in code provided by your activity organizer</p>
    </div>

    <div class="bg-white rounded-lg shadow p-8">
        <div class="text-center mb-6">
            <div class="text-5xl mb-4">🏷️</div>
            <p class="text-gray-600">Enter the code given by the organizer to check in for your activity.</p>
            <p class="text-sm text-gray-400 mt-1">Check-in is only available during or after the activity start time.</p>
        </div>

        <form action="<%= contextPath %>/self-checkin" method="post" class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Check-in Code</label>
                <input type="text" name="checkinCode" required class="input-field text-center text-lg tracking-widest"
                       placeholder="Enter code..." autocomplete="off" autofocus>
            </div>
            <button type="submit" class="w-full py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors">
                Check In
            </button>
        </form>

        <div class="mt-6 pt-4 border-t border-gray-200 text-sm text-gray-500">
            <p>💡 <strong>Tip:</strong> The organizer will provide the check-in code during or after the activity. Make sure your registration has been approved before attempting check-in.</p>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
