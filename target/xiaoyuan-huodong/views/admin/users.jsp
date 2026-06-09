<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../common/header.jsp" %>
<%@ page import="java.util.List, com.xiaoyuan.model.User" %>
<%
    List<User> users = (List<User>) request.getAttribute("users");
    User editUser = (User) request.getAttribute("editUser");
    String roleFilter = (String) request.getAttribute("roleFilter");
    if (users == null) users = java.util.Collections.emptyList();
%>

<div class="flex items-center justify-between mb-6">
    <div>
        <h1 class="text-2xl font-bold text-gray-800">User Management</h1>
        <p class="text-gray-600 mt-1">Manage system users and their roles</p>
    </div>
    <button onclick="showUserModal()" class="btn btn-primary">+ Add User</button>
</div>

<!-- Role Filter -->
<div class="bg-white rounded-lg shadow p-3 mb-4 flex items-center gap-2">
    <span class="text-sm text-gray-600">Filter:</span>
    <a href="<%= contextPath %>/admin/users" class="text-sm px-3 py-1 rounded <%= roleFilter == null ? "bg-blue-600 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">All</a>
    <a href="<%= contextPath %>/admin/users?role=student" class="text-sm px-3 py-1 rounded <%= "student".equals(roleFilter) ? "bg-blue-600 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">Students</a>
    <a href="<%= contextPath %>/admin/users?role=organizer" class="text-sm px-3 py-1 rounded <%= "organizer".equals(roleFilter) ? "bg-blue-600 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">Organizers</a>
    <a href="<%= contextPath %>/admin/users?role=admin" class="text-sm px-3 py-1 rounded <%= "admin".equals(roleFilter) ? "bg-blue-600 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">Admins</a>
</div>

<div class="bg-white rounded-lg shadow overflow-hidden">
    <table class="w-full">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Username</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Real Name</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
            <% for (User u : users) { %>
            <tr class="hover:bg-gray-50">
                <td class="px-4 py-3 text-sm text-gray-500">#<%= u.getId() %></td>
                <td class="px-4 py-3 text-sm font-medium text-gray-800"><%= u.getUsername() %></td>
                <td class="px-4 py-3 text-sm text-gray-600"><%= u.getRealName() %></td>
                <td class="px-4 py-3 text-sm text-gray-500"><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
                <td class="px-4 py-3">
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full
                        <%= "admin".equals(u.getRole()) ? "bg-red-100 text-red-700" :
                            "organizer".equals(u.getRole()) ? "bg-blue-100 text-blue-700" :
                            "bg-green-100 text-green-700" %>">
                        <%= u.getRole() %>
                    </span>
                </td>
                <td class="px-4 py-3">
                    <div class="flex items-center gap-1">
                        <button onclick="editUser(<%= u.getId() %>, '<%= u.getUsername().replace("'", "\\'") %>', '<%= u.getRealName().replace("'", "\\'") %>', '<%= (u.getEmail() != null ? u.getEmail() : "").replace("'", "\\'") %>', '<%= u.getRole() %>')"
                                class="text-xs px-2 py-1 bg-blue-50 text-blue-600 rounded hover:bg-blue-100">Edit</button>
                        <form method="post" action="<%= contextPath %>/admin/users" class="inline" onsubmit="return confirm('Reset password to 123456?')">
                            <input type="hidden" name="action" value="resetPassword">
                            <input type="hidden" name="id" value="<%= u.getId() %>">
                            <button type="submit" class="text-xs px-2 py-1 bg-yellow-50 text-yellow-600 rounded hover:bg-yellow-100">Reset PW</button>
                        </form>
                        <form method="post" action="<%= contextPath %>/admin/users" class="inline" onsubmit="return confirm('Delete this user?')">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= u.getId() %>">
                            <button type="submit" class="text-xs px-2 py-1 bg-red-50 text-red-600 rounded hover:bg-red-100">Del</button>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<!-- User Modal -->
<div id="userModal" class="hidden fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
        <h3 id="modalTitle" class="text-lg font-semibold text-gray-800 mb-4">Add User</h3>
        <form id="userForm" action="<%= contextPath %>/admin/users" method="post" onsubmit="return validateUserForm()">
            <input type="hidden" name="action" value="save">
            <input type="hidden" name="id" id="userId">
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Username *</label>
                    <input type="text" name="username" id="formUsername" required class="input-field" placeholder="Username"
                           maxlength="50" oninput="clearFieldError('username')">
                    <p id="errUsername" class="hidden text-xs text-red-600 mt-1"></p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Password <span id="pwReq" class="text-red-500">*</span></label>
                    <input type="password" name="password" id="formPassword" class="input-field" placeholder="Leave empty to keep current"
                           maxlength="100" oninput="clearFieldError('password')">
                    <p id="errPassword" class="hidden text-xs text-red-600 mt-1"></p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Real Name *</label>
                    <input type="text" name="realName" id="formRealName" required class="input-field" placeholder="Full name"
                           maxlength="100" oninput="clearFieldError('realName')">
                    <p id="errRealName" class="hidden text-xs text-red-600 mt-1"></p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <input type="email" name="email" id="formEmail" class="input-field" placeholder="Email address"
                           maxlength="100" oninput="clearFieldError('email')">
                    <p id="errEmail" class="hidden text-xs text-red-600 mt-1"></p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Role *</label>
                    <select name="role" id="formRole" required class="input-field">
                        <option value="student">Student</option>
                        <option value="organizer">Organizer</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
            </div>
            <div class="flex justify-end gap-2 mt-6">
                <button type="button" onclick="document.getElementById('userModal').classList.add('hidden')" class="btn btn-secondary">Cancel</button>
                <button type="submit" class="btn btn-primary">Save User</button>
            </div>
        </form>
    </div>
</div>

<script>
function showUserModal() {
    document.getElementById('modalTitle').textContent = 'Add User';
    document.getElementById('userForm').reset();
    document.getElementById('userId').value = '';
    document.getElementById('pwReq').classList.remove('hidden');
    document.getElementById('formPassword').required = true;
    clearAllErrors();
    document.getElementById('userModal').classList.remove('hidden');
}
function editUser(id, username, realName, email, role) {
    document.getElementById('modalTitle').textContent = 'Edit User';
    document.getElementById('userId').value = id;
    document.getElementById('formUsername').value = username;
    document.getElementById('formRealName').value = realName;
    document.getElementById('formEmail').value = email;
    document.getElementById('formRole').value = role;
    document.getElementById('pwReq').classList.add('hidden');
    document.getElementById('formPassword').required = false;
    document.getElementById('formPassword').value = '';
    clearAllErrors();
    document.getElementById('userModal').classList.remove('hidden');
}

// ── Validation ──────────────────────────────────────────────

function showError(field, msg) {
    var el = document.getElementById('err' + field.charAt(0).toUpperCase() + field.slice(1));
    if (el) { el.textContent = msg; el.classList.remove('hidden'); }
}
function clearFieldError(field) {
    var el = document.getElementById('err' + field.charAt(0).toUpperCase() + field.slice(1));
    if (el) { el.textContent = ''; el.classList.add('hidden'); }
}
function clearAllErrors() {
    ['Username','Password','RealName','Email'].forEach(function(f) { clearFieldError(f); });
}

function validateUserForm() {
    clearAllErrors();
    var valid = true;

    // Username
    var username = document.getElementById('formUsername').value.trim();
    var usernameRegex = /^[a-zA-Z0-9_]+$/;
    if (!username) {
        showError('username', 'Username is required.');
        valid = false;
    } else if (username.length < 3) {
        showError('username', 'Username must be at least 3 characters.');
        valid = false;
    } else if (username.length > 50) {
        showError('username', 'Username must not exceed 50 characters.');
        valid = false;
    } else if (!usernameRegex.test(username)) {
        showError('username', 'Username can only contain letters, numbers, and underscores.');
        valid = false;
    }

    // Password
    var isNew = !document.getElementById('userId').value;
    var password = document.getElementById('formPassword').value;
    if (isNew) {
        if (!password) {
            showError('password', 'Password is required for new users.');
            valid = false;
        } else if (password.length < 6) {
            showError('password', 'Password must be at least 6 characters.');
            valid = false;
        }
    } else {
        if (password && password.length < 6) {
            showError('password', 'Password must be at least 6 characters.');
            valid = false;
        }
    }

    // Real Name
    var realName = document.getElementById('formRealName').value.trim();
    if (!realName) {
        showError('realName', 'Real name is required.');
        valid = false;
    } else if (realName.length < 2) {
        showError('realName', 'Real name must be at least 2 characters.');
        valid = false;
    } else if (realName.length > 100) {
        showError('realName', 'Real name must not exceed 100 characters.');
        valid = false;
    }

    // Email (optional)
    var email = document.getElementById('formEmail').value.trim();
    if (email) {
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            showError('email', 'Please enter a valid email address.');
            valid = false;
        }
    }

    return valid;
}
</script>

<%@ include file="../common/footer.jsp" %>
