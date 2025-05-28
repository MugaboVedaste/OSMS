<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.osms.dao.ProductAuditDAO, java.util.List, java.util.Map, java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in and is an admin
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("Admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get all audit records
    ProductAuditDAO auditDAO = new ProductAuditDAO();
    List<Map<String, Object>> auditRecords = auditDAO.getAllAuditRecords();
    
    // Date formatter
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    
    // Get messages from session if any
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    
    // Clear messages after retrieving them
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Audit Log - OSMS</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="../css/style.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="#">OSMS Admin</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="products.jsp">Products</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="sellers.jsp">Sellers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="suppliers.jsp">Suppliers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="reports.jsp">Reports</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="product_audit.jsp">Product Audit</a>
                    </li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="../logout">Logout</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col-md-8">
                <h2>Product Audit Log</h2>
                <p class="text-muted">View history of all product modifications by administrators</p>
            </div>
            <div class="col-md-4 text-end">
                <button type="button" class="btn btn-primary" onclick="window.print()">
                    <i class="fas fa-print"></i> Print Report
                </button>
            </div>
        </div>

        <!-- Search and Filter Section -->
        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-body">
                        <form class="row g-3">
                            <div class="col-md-4">
                                <input type="text" class="form-control" id="searchInput" placeholder="Search audit records...">
                            </div>
                            <div class="col-md-3">
                                <select class="form-select" id="actionFilter">
                                    <option value="">All Actions</option>
                                    <option value="UPDATE">Updates Only</option>
                                    <option value="DELETE">Deletions Only</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <input type="date" class="form-control" id="dateFilter" placeholder="Filter by date">
                            </div>
                            <div class="col-md-2">
                                <button type="button" class="btn btn-primary w-100" onclick="filterTable()">Filter</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Audit Records Table -->
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-body">
                        <% if (successMessage != null && !successMessage.isEmpty()) { %>
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <%= successMessage %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>
                        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <%= errorMessage %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>
                        <div class="table-responsive">
                            <table class="table table-hover" id="auditTable">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Product</th>
                                        <th>Admin</th>
                                        <th>Action</th>
                                        <th>Date/Time</th>
                                        <th>Reason</th>
                                        <th>Changes</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (auditRecords.size() > 0) { %>
                                        <% for (Map<String, Object> record : auditRecords) { %>
                                            <tr>
                                                <td><%= record.get("id") %></td>
                                                <td>
                                                    <%= record.get("productName") %> 
                                                    <small class="text-muted">(ID: <%= record.get("productId") %>)</small>
                                                </td>
                                                <td><%= record.get("adminName") %></td>
                                                <td>
                                                    <% if ("UPDATE".equals(record.get("actionType"))) { %>
                                                        <span class="badge bg-info">Update</span>
                                                    <% } else if ("DELETE".equals(record.get("actionType"))) { %>
                                                        <span class="badge bg-danger">Delete</span>
                                                    <% } %>
                                                </td>
                                                <td><%= dateFormat.format(record.get("changeDate")) %></td>
                                                <td><%= record.get("reason") %></td>
                                                <td><%= record.get("changes") %></td>
                                            </tr>
                                        <% } %>
                                    <% } else { %>
                                        <tr>
                                            <td colspan="7" class="text-center">No audit records found.</td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2025 Online Shop Management System</p>
        </div>
    </footer>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Function to filter the table
        function filterTable() {
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const actionFilter = document.getElementById('actionFilter').value;
            const dateFilter = document.getElementById('dateFilter').value;
            
            const table = document.getElementById('auditTable');
            const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            
            for (let i = 0; i < rows.length; i++) {
                const row = rows[i];
                const cells = row.getElementsByTagName('td');
                
                if (cells.length === 0) continue; // Skip if no cells (like a "no records" row)
                
                // Get text content from all cells
                const rowText = Array.from(cells).map(cell => cell.textContent.toLowerCase()).join(' ');
                
                // Get the action type (UPDATE or DELETE)
                const actionCell = cells[3].textContent.trim();
                const actionType = actionCell.includes('Update') ? 'UPDATE' : 'DELETE';
                
                // Get the date from the date cell
                const dateCell = cells[4].textContent.trim();
                const dateMatch = dateFilter ? dateCell.startsWith(dateFilter) : true;
                
                // Filter by search text, action type, and date
                const matchesSearch = searchInput === '' || rowText.includes(searchInput);
                const matchesAction = actionFilter === '' || actionType === actionFilter;
                
                // Show or hide the row based on filters
                row.style.display = (matchesSearch && matchesAction && dateMatch) ? '' : 'none';
            }
        }
        
        // Add event listener for search input
        document.getElementById('searchInput').addEventListener('keyup', filterTable);
    </script>
</body>
</html> 