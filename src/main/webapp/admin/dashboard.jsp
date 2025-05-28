<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.Connection, java.sql.Statement, java.sql.ResultSet, java.sql.SQLException" %>
<%@ page import="com.osms.util.DatabaseUtil" %>
<%
    // Check if user is logged in and is an admin
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("Admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Initialize counters
    int productCount = 0;
    int orderCount = 0;
    int customerCount = 0;
    double totalRevenue = 0.0;
    
    // Get counts from database
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = DatabaseUtil.getConnection();
        stmt = conn.createStatement();
        
        // Get product count
        rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM Product");
        if (rs.next()) {
            productCount = rs.getInt("count");
        }
        
        // Get order count
        rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM Orders");
        if (rs.next()) {
            orderCount = rs.getInt("count");
        }
        
        // Get customer count
        rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM Customer");
        if (rs.next()) {
            customerCount = rs.getInt("count");
        }
        
        // Get total revenue
        rs = stmt.executeQuery("SELECT SUM(TotalAmount) AS total FROM Orders");
        if (rs.next()) {
            totalRevenue = rs.getDouble("total");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - OSMS</title>
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
                        <a class="nav-link active" href="dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="products.jsp">Products</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="sellers.jsp">Sellers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="customers.jsp">Customers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="suppliers.jsp">Suppliers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="reports.jsp">Reports</a>
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
        <div class="row">
            <div class="col-md-12">
                <h2>Admin Dashboard</h2>
                <p>Welcome, ${sessionScope.username}!</p>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-3">
                <div class="card dashboard-card products">
                    <div class="card-body">
                        <h5 class="card-title">Products</h5>
                        <p class="card-value"><%= productCount %></p>
                        <p class="card-text">Total products in database</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card orders">
                    <div class="card-body">
                        <h5 class="card-title">Orders</h5>
                        <p class="card-value"><%= orderCount %></p>
                        <p class="card-text">Total orders processed</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card users">
                    <div class="card-body">
                        <h5 class="card-title">Customers</h5>
                        <p class="card-value"><%= customerCount %></p>
                        <p class="card-text">Registered customers</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card">
                    <div class="card-body">
                        <h5 class="card-title">Revenue</h5>
                        <p class="card-value">$<%= String.format("%.2f", totalRevenue) %></p>
                        <p class="card-text">Total revenue generated</p>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Low Stock Products</h5>
                    </div>
                    <div class="card-body">
                        <% 
                        try {
                            conn = DatabaseUtil.getConnection();
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT p.ProductId, p.ProductName, s.CompanyName, p.StockQuantity FROM Product p LEFT JOIN Supplier s ON p.SupplierId = s.SupplierId WHERE p.StockQuantity < 10 ORDER BY p.StockQuantity ASC LIMIT 5");
                            
                            boolean hasLowStock = false;
                            
                            // Check if we have low stock products
                            if (rs.isBeforeFirst()) {
                                hasLowStock = true;
                            }
                        %>
                            <% if (hasLowStock) { %>
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Product Name</th>
                                            <th>Supplier</th>
                                            <th>Stock</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% while (rs.next()) { %>
                                            <tr>
                                                <td><%= rs.getInt("ProductId") %></td>
                                                <td><%= rs.getString("ProductName") %></td>
                                                <td><%= rs.getString("CompanyName") != null ? rs.getString("CompanyName") : "N/A" %></td>
                                                <td><%= rs.getInt("StockQuantity") %></td>
                                                <td>
                                                    <a href="products.jsp?id=<%= rs.getInt("ProductId") %>" class="btn btn-sm btn-primary">View</a>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <p>No products with low stock levels.</p>
                            <% } %>
                        <%
                        } catch (SQLException e) {
                            e.printStackTrace();
                            out.println("<p>Error loading low stock products: " + e.getMessage() + "</p>");
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (stmt != null) stmt.close();
                                if (conn != null) conn.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                        %>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Recent Orders</h5>
                    </div>
                    <div class="card-body">
                        <% 
                        try {
                            conn = DatabaseUtil.getConnection();
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT o.OrderId, CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, o.OrderDate, o.TotalAmount, o.Status FROM Orders o INNER JOIN Customer c ON o.CustomerId = c.CustomerId ORDER BY o.OrderDate DESC LIMIT 5");
                            
                            boolean hasOrders = false;
                            
                            // Check if we have orders
                            if (rs.isBeforeFirst()) {
                                hasOrders = true;
                            }
                        %>
                            <% if (hasOrders) { %>
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Customer</th>
                                            <th>Date</th>
                                            <th>Amount</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% while (rs.next()) { %>
                                            <tr>
                                                <td><%= rs.getInt("OrderId") %></td>
                                                <td><%= rs.getString("CustomerName") %></td>
                                                <td><%= rs.getDate("OrderDate") %></td>
                                                <td>$<%= String.format("%.2f", rs.getDouble("TotalAmount")) %></td>
                                                <td><%= rs.getString("Status") %></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <p>No recent orders.</p>
                            <% } %>
                        <%
                        } catch (SQLException e) {
                            e.printStackTrace();
                            out.println("<p>Error loading recent orders: " + e.getMessage() + "</p>");
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (stmt != null) stmt.close();
                                if (conn != null) conn.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                        %>
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
</body>
</html> 