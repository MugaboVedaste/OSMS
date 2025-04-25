<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Check if user is logged in and is an admin
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("Admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - OSMS</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                        <a class="nav-link active" href="reports.jsp">Reports</a>
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
                <h2>Reports</h2>
            </div>
            <div class="col-md-4 text-end">
                <div class="btn-group">
                    <button type="button" class="btn btn-outline-primary">
                        <i class="fas fa-download"></i> Export
                    </button>
                    <button type="button" class="btn btn-outline-success">
                        <i class="fas fa-print"></i> Print
                    </button>
                </div>
            </div>
        </div>

        <!-- Report Filter Section -->
        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-body">
                        <form class="row g-3">
                            <div class="col-md-3">
                                <label for="reportType" class="form-label">Report Type</label>
                                <select class="form-select" id="reportType">
                                    <option selected>Sales Report</option>
                                    <option>Inventory Report</option>
                                    <option>Product Performance</option>
                                    <option>Seller Performance</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="dateRange" class="form-label">Date Range</label>
                                <select class="form-select" id="dateRange">
                                    <option selected>Last 7 Days</option>
                                    <option>Last 30 Days</option>
                                    <option>This Month</option>
                                    <option>Last Month</option>
                                    <option>Custom Range</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="startDate" class="form-label">Start Date</label>
                                <input type="date" class="form-control" id="startDate">
                            </div>
                            <div class="col-md-3">
                                <label for="endDate" class="form-label">End Date</label>
                                <input type="date" class="form-control" id="endDate">
                            </div>
                            <div class="col-md-12">
                                <button type="submit" class="btn btn-primary float-end">Generate Report</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Charts Row -->
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Sales Overview</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="salesChart" height="250"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Product Categories Distribution</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="categoriesChart" height="250"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Report Table -->
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header">
                        <h5>Sales Detail Report</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Order ID</th>
                                        <th>Product</th>
                                        <th>Seller</th>
                                        <th>Quantity</th>
                                        <th>Price</th>
                                        <th>Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td colspan="7" class="text-center">No data available for the selected period.</td>
                                    </tr>
                                    <!-- Report data will be populated here dynamically -->
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th colspan="6" class="text-end">Total:</th>
                                        <th>$0.00</th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2023 Online Shop Management System</p>
        </div>
    </footer>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Chart Initialization Script -->
    <script>
        // Sample data for demonstration
        document.addEventListener('DOMContentLoaded', function() {
            // Sales Chart
            const salesCtx = document.getElementById('salesChart').getContext('2d');
            new Chart(salesCtx, {
                type: 'line',
                data: {
                    labels: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
                    datasets: [{
                        label: 'Sales ($)',
                        data: [0, 0, 0, 0, 0, 0, 0],
                        backgroundColor: 'rgba(54, 162, 235, 0.2)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 2,
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
            
            // Categories Chart
            const categoriesCtx = document.getElementById('categoriesChart').getContext('2d');
            new Chart(categoriesCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Electronics', 'Clothing', 'Home & Kitchen', 'Books'],
                    datasets: [{
                        label: 'Categories',
                        data: [0, 0, 0, 0],
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.6)',
                            'rgba(54, 162, 235, 0.6)',
                            'rgba(255, 206, 86, 0.6)',
                            'rgba(75, 192, 192, 0.6)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)',
                            'rgba(75, 192, 192, 1)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'right',
                        }
                    }
                }
            });
        });
    </script>
</body>
</html> 