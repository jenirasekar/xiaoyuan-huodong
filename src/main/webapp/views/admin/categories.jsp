<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.ActivityCategory" %>
<%
    List<ActivityCategory> categories = (List<ActivityCategory>) request.getAttribute("categories");
    ActivityCategory editCategory = (ActivityCategory) request.getAttribute("editCategory");
    if (categories == null) categories = java.util.Collections.emptyList();
%>

<div class="flex items-center justify-between mb-6">
    <div>
        <h1 class="text-2xl font-bold text-gray-800">Activity Categories</h1>
        <p class="text-gray-600 mt-1">Manage activity categories</p>
    </div>
    <button onclick="showCategoryModal()" class="btn btn-primary">+ Add Category</button>
</div>

<div class="bg-white rounded-lg shadow overflow-hidden">
    <table class="w-full">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
            <% if (categories.isEmpty()) { %>
                <tr><td colspan="4" class="px-4 py-8 text-center text-gray-500">No categories yet.</td></tr>
            <% } %>
            <% for (ActivityCategory cat : categories) { %>
            <tr class="hover:bg-gray-50">
                <td class="px-4 py-3 text-sm text-gray-500">#<%= cat.getId() %></td>
                <td class="px-4 py-3 text-sm font-medium text-gray-800"><%= cat.getName() %></td>
                <td class="px-4 py-3 text-sm text-gray-500"><%= cat.getDescription() != null ? cat.getDescription() : "-" %></td>
                <td class="px-4 py-3">
                    <div class="flex items-center gap-1">
                        <button onclick="editCategory(<%= cat.getId() %>, '<%= cat.getName() %>', '<%= cat.getDescription() != null ? cat.getDescription().replace("'", "\\'") : "" %>')"
                                class="text-xs px-2 py-1 bg-blue-50 text-blue-600 rounded hover:bg-blue-100">Edit</button>
                        <form method="post" action="<%= contextPath %>/admin/categories" class="inline" onsubmit="return confirm('Delete this category?')">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= cat.getId() %>">
                            <button type="submit" class="text-xs px-2 py-1 bg-red-50 text-red-600 rounded hover:bg-red-100">Del</button>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<!-- Category Modal -->
<div id="categoryModal" class="hidden fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
        <h3 id="modalTitle" class="text-lg font-semibold text-gray-800 mb-4">Add Category</h3>
        <form action="<%= contextPath %>/admin/categories" method="post">
            <input type="hidden" name="action" value="save">
            <input type="hidden" name="id" id="catId">
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Name *</label>
                    <input type="text" name="name" id="catName" required class="input-field" placeholder="Category name">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                    <textarea name="description" id="catDesc" rows="3" class="input-field" placeholder="Category description..."></textarea>
                </div>
            </div>
            <div class="flex justify-end gap-2 mt-6">
                <button type="button" onclick="document.getElementById('categoryModal').classList.add('hidden')" class="btn btn-secondary">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Category</button>
            </div>
        </form>
    </div>
</div>

<script>
function showCategoryModal() {
    document.getElementById('modalTitle').textContent = 'Add Category';
    document.getElementById('catId').value = '';
    document.getElementById('catName').value = '';
    document.getElementById('catDesc').value = '';
    document.getElementById('categoryModal').classList.remove('hidden');
}
function editCategory(id, name, desc) {
    document.getElementById('modalTitle').textContent = 'Edit Category';
    document.getElementById('catId').value = id;
    document.getElementById('catName').value = name;
    document.getElementById('catDesc').value = desc;
    document.getElementById('categoryModal').classList.remove('hidden');
}
</script>

<%@ include file="../common/footer.jsp" %>
