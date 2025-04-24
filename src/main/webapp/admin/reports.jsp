<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="com.osms.model.SalesReport, com.osms.model.InventoryReport, java.util.List, java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, java.util.Calendar" %>
<%
    // Check if user is logged in and is an admin
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("Admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Generate default dates if not set
    String startDateDisplay = (String) request.getAttribute("startDateDisplay");
    String endDateDisplay = (String) request.getAttribute("endDateDisplay");
    String reportType = (String) request.getAttribute("reportType");
    String dateRange = (String) request.getAttribute("dateRange");
    
    if (startDateDisplay == null) {
        SimpleDateFormat displayFormat = new SimpleDateFormat("MMM dd, yyyy");
        Calendar cal = Calendar.getInstance();
        endDateDisplay = displayFormat.format(cal.getTime());
        cal.add(Calendar.DAY_OF_MONTH, -6);
        startDateDisplay = displayFormat.format(cal.getTime());
    }
    
    if (reportType == null) reportType = "SalesReport";
    if (dateRange == null) dateRange = "Last7Days";
    
    // Get report data
    List<SalesReport> salesReport = (List<SalesReport>) request.getAttribute("salesReport");
    List<InventoryReport> inventoryReport = (List<InventoryReport>) request.getAttribute("inventoryReport");
    Map<String, Double> dailySales = (Map<String, Double>) request.getAttribute("dailySales");
    Map<String, Integer> categoryDistribution = (Map<String, Integer>) request.getAttribute("categoryDistribution");
    Double totalSales = (Double) request.getAttribute("totalSales");
    
    if (totalSales == null) totalSales = 0.0;
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
    <style>
        .custom-date-inputs {
            display: none;
        }
        .report-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .date-range-display {
            font-size: 1.2rem;
            color: #6c757d;
        }
        .chart-container {
            position: relative;
            height: 300px;
            width: 100%;
        }
    </style>
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
                <% if (startDateDisplay != null && endDateDisplay != null) { %>
                    <div class="date-range-display">
                        <i class="far fa-calendar-alt me-2"></i> <%= startDateDisplay %> - <%= endDateDisplay %>
                    </div>
                <% } %>
            </div>
            <div class="col-md-4 text-end">
                <div class="btn-group">
                    <button type="button" class="btn btn-outline-primary" onclick="exportReportToPDF()">
                        <i class="fas fa-download"></i> Export
                    </button>
                    <button type="button" class="btn btn-outline-success" onclick="printReport()">
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
                        <form class="row g-3" action="generateReport" method="get">
                            <div class="col-md-3">
                                <label for="reportType" class="form-label">Report Type</label>
                                <select class="form-select" id="reportType" name="reportType">
                                    <option value="SalesReport" <%= "SalesReport".equals(reportType) ? "selected" : "" %>>Sales Report</option>
                                    <option value="InventoryReport" <%= "InventoryReport".equals(reportType) ? "selected" : "" %>>Inventory Report</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="dateRange" class="form-label">Date Range</label>
                                <select class="form-select" id="dateRange" name="dateRange" onchange="toggleCustomDateInputs()">
                                    <option value="Today" <%= "Today".equals(dateRange) ? "selected" : "" %>>Today</option>
                                    <option value="Yesterday" <%= "Yesterday".equals(dateRange) ? "selected" : "" %>>Yesterday</option>
                                    <option value="Last7Days" <%= "Last7Days".equals(dateRange) ? "selected" : "" %>>Last 7 Days</option>
                                    <option value="Last30Days" <%= "Last30Days".equals(dateRange) ? "selected" : "" %>>Last 30 Days</option>
                                    <option value="ThisMonth" <%= "ThisMonth".equals(dateRange) ? "selected" : "" %>>This Month</option>
                                    <option value="LastMonth" <%= "LastMonth".equals(dateRange) ? "selected" : "" %>>Last Month</option>
                                    <option value="CustomRange" <%= "CustomRange".equals(dateRange) ? "selected" : "" %>>Custom Range</option>
                                </select>
                            </div>
                            <div class="col-md-3 custom-date-inputs" id="startDateContainer">
                                <label for="startDate" class="form-label">Start Date</label>
                                <input type="date" class="form-control" id="startDate" name="startDate">
                            </div>
                            <div class="col-md-3 custom-date-inputs" id="endDateContainer">
                                <label for="endDate" class="form-label">End Date</label>
                                <input type="date" class="form-control" id="endDate" name="endDate">
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
                        <div class="chart-container">
                            <canvas id="salesChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Product Categories Distribution</h5>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="categoriesChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Report Table -->
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header report-header">
                        <h5>
                            <% if ("InventoryReport".equals(reportType)) { %>
                                Inventory Report
                            <% } else { %>
                                Sales Detail Report
                            <% } %>
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <% if ("InventoryReport".equals(reportType)) { %>
                                <!-- Inventory Report Table -->
                                <table class="table table-striped" id="reportTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Product</th>
                                            <th>Category</th>
                                            <th>Stock</th>
                                            <th>Price</th>
                                            <th>Supplier</th>
                                            <th>Expiration Date</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (inventoryReport != null && !inventoryReport.isEmpty()) { %>
                                            <% for (InventoryReport item : inventoryReport) { %>
                                                <tr>
                                                    <td><%= item.getProductId() %></td>
                                                    <td><%= item.getProductName() %></td>
                                                    <td><%= item.getCategory() != null ? item.getCategory() : "Uncategorized" %></td>
                                                    <td><%= item.getStockQuantity() %></td>
                                                    <td><fmt:formatNumber value="<%= item.getPrice() %>" type="currency" currencySymbol="$" /></td>
                                                    <td><%= item.getSupplierName() != null ? item.getSupplierName() : "Not Assigned" %></td>
                                                    <td>
                                                        <% if (item.getExpirationDate() != null) { %>
                                                            <fmt:formatDate value="<%= item.getExpirationDate() %>" pattern="MMM dd, yyyy" />
                                                        <% } else { %>
                                                            N/A
                                                        <% } %>
                                                    </td>
                                                    <td>
                                                        <% String status = item.getStockStatus(); %>
                                                        <% if ("Out of Stock".equals(status)) { %>
                                                            <span class="badge bg-danger">Out of Stock</span>
                                                        <% } else if ("Low Stock".equals(status)) { %>
                                                            <span class="badge bg-warning">Low Stock</span>
                                                        <% } else { %>
                                                            <span class="badge bg-success">In Stock</span>
                                                        <% } %>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        <% } else { %>
                                            <tr>
                                                <td colspan="8" class="text-center">No inventory data available.</td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <!-- Sales Report Table -->
                                <table class="table table-striped" id="reportTable">
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
                                        <% if (salesReport != null && !salesReport.isEmpty()) { %>
                                            <% for (SalesReport sale : salesReport) { %>
                                                <tr>
                                                    <td><fmt:formatDate value="<%= sale.getOrderDate() %>" pattern="MMM dd, yyyy" /></td>
                                                    <td><%= sale.getOrderId() %></td>
                                                    <td><%= sale.getProductName() %></td>
                                                    <td><%= sale.getSellerName() != null ? sale.getSellerName() : "Direct" %></td>
                                                    <td><%= sale.getQuantity() %></td>
                                                    <td><fmt:formatNumber value="<%= sale.getUnitPrice() %>" type="currency" currencySymbol="$" /></td>
                                                    <td><fmt:formatNumber value="<%= sale.getTotal() %>" type="currency" currencySymbol="$" /></td>
                                                </tr>
                                            <% } %>
                                        <% } else { %>
                                            <tr>
                                                <td colspan="7" class="text-center">No sales data available for the selected period.</td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                    <% if (!"InventoryReport".equals(reportType)) { %>
                                        <tfoot>
                                            <tr>
                                                <th colspan="6" class="text-end">Total:</th>
                                                <th><fmt:formatNumber value="<%= totalSales %>" type="currency" currencySymbol="$" /></th>
                                            </tr>
                                        </tfoot>
                                    <% } %>
                                </table>
                            <% } %>
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
        // Show or hide custom date inputs based on selection
        function toggleCustomDateInputs() {
            const dateRange = document.getElementById('dateRange').value;
            const customDateInputs = document.querySelectorAll('.custom-date-inputs');
            
            if (dateRange === 'CustomRange') {
                customDateInputs.forEach(input => {
                    input.style.display = 'block';
                });
            } else {
                customDateInputs.forEach(input => {
                    input.style.display = 'none';
                });
            }
        }
        
        // Print report function
        function printReport() {
            window.print();
        }
        
        // Export to PDF function (this is a placeholder - would need a library like jsPDF in production)
        function exportReportToPDF() {
            alert('This feature would export the report to PDF. Implementation requires a PDF generation library.');
        }
        
        // Initialize custom date inputs
        document.addEventListener('DOMContentLoaded', function() {
            toggleCustomDateInputs();
            
            // Setup Sales Chart
            const salesCtx = document.getElementById('salesChart').getContext('2d');
            const salesChart = new Chart(salesCtx, {
                type: 'line',
                data: {
                    labels: [
                        <% if (dailySales != null) { %>
                            <% for (String date : dailySales.keySet()) { %>
                                '<%= date %>',
                            <% } %>
                        <% } else { %>
                            'No Data'
                        <% } %>
                    ],
                    datasets: [{
                        label: 'Sales ($)',
                        data: [
                            <% if (dailySales != null) { %>
                                <% for (Double amount : dailySales.values()) { %>
                                    <%= amount %>,
                                <% } %>
                            <% } else { %>
                                0
                            <% } %>
                        ],
                        backgroundColor: 'rgba(54, 162, 235, 0.2)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 2,
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
            
            // Setup Categories Chart
            const categoriesCtx = document.getElementById('categoriesChart').getContext('2d');
            const categoriesChart = new Chart(categoriesCtx, {
                type: 'doughnut',
                data: {
                    labels: [
                        <% if (categoryDistribution != null) { %>
                            <% for (String category : categoryDistribution.keySet()) { %>
                                '<%= category %>',
                            <% } %>
                        <% } else { %>
                            'No Data'
                        <% } %>
                    ],
                    datasets: [{
                        label: 'Categories',
                        data: [
                            <% if (categoryDistribution != null) { %>
                                <% for (Integer count : categoryDistribution.values()) { %>
                                    <%= count %>,
                                <% } %>
                            <% } else { %>
                                0
                            <% } %>
                        ],
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.6)',
                            'rgba(54, 162, 235, 0.6)',
                            'rgba(255, 206, 86, 0.6)',
                            'rgba(75, 192, 192, 0.6)',
                            'rgba(153, 102, 255, 0.6)',
                            'rgba(255, 159, 64, 0.6)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)',
                            'rgba(75, 192, 192, 1)',
                            'rgba(153, 102, 255, 1)',
                            'rgba(255, 159, 64, 1)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'right'
                        }
                    }
                }
            });
        });
    </script>
</body>
</html> 