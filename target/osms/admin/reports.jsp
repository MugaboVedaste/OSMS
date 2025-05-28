<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Reports - OSMS</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="../css/style.css" rel="stylesheet">
</head>

</html> 
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .metric-card {
            transition: transform 0.3s;
            border-radius: 10px;
            border: none;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .metric-card:hover {
            transform: translateY(-5px);
        }
        .report-icon {
            font-size: 2.5rem;
            opacity: 0.8;
        }
        .loading-spinner {
            display: none;
            text-align: center;
            padding: 20px;
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
                    <li class="nav-item"><a class="nav-link" href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link" href="products.jsp"><i class="fas fa-box"></i> Products</a></li>
                    <li class="nav-item"><a class="nav-link" href="sellers.jsp"><i class="fas fa-store"></i> Sellers</a></li>
                    <li class="nav-item"><a class="nav-link" href="suppliers.jsp"><i class="fas fa-truck"></i> Suppliers</a></li>
                    <li class="nav-item"><a class="nav-link active" href="reports.jsp"><i class="fas fa-chart-bar"></i> Reports</a></li>
                    <li class="nav-item"><a class="nav-link" href="product_audit.jsp"><i class="fas fa-history"></i> Product Audit</a></li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="../logout"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-chart-bar"></i> Admin Reports</h2>
            <a href="product_audit.jsp" class="btn btn-info">
                <i class="fas fa-history"></i> View Product Audit Logs
            </a>
        </div>
        
        <!-- Report Type Selection Cards -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card metric-card h-100 bg-primary text-white" onclick="setReportType('Sales Report')">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="card-title">Sales Report</h5>
                            <p class="card-text">View sales data, orders, and revenue</p>
                        </div>
                        <i class="fas fa-dollar-sign report-icon"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card metric-card h-100 bg-success text-white" onclick="setReportType('Inventory Report')">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="card-title">Inventory Report</h5>
                            <p class="card-text">Check stock levels and inventory value</p>
                        </div>
                        <i class="fas fa-warehouse report-icon"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card metric-card h-100 bg-info text-white" onclick="window.location.href='product_audit.jsp'">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="card-title">Product Audit</h5>
                            <p class="card-text">Track product changes and updates</p>
                        </div>
                        <i class="fas fa-history report-icon"></i>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Report Parameters -->
        <div class="card mb-4">
            <div class="card-body">
                <h5 class="mb-3"><i class="fas fa-filter"></i> Report Parameters</h5>
                <div class="row g-3">
            <div class="col-md-3">
                <label for="reportType" class="form-label">Report Type</label>
                <select class="form-select" id="reportType">
                    <option value="Sales Report">Sales Report</option>
                    <option value="Inventory Report">Inventory Report</option>
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
            <div class="col-md-3 d-flex align-items-end">
                        <button type="button" class="btn btn-primary" onclick="fetchReportData()">Generate Report</button>
                    </div>
                </div>
            </div>
            
            <div class="col-md-auto">
                <button type="button" class="btn btn-success" onclick="downloadReport()">Download Report</button>
            </div>
        </div>
        
        <hr class="my-4">
        
        <!-- Metrics Cards -->
        <div id="metricsCards" class="row row-cols-1 row-cols-md-4 mb-4 text-center" style="display: none;">
            <div class="col-md-3">
                <div class="card metric-card bg-light">
                    <div class="card-body text-center">
                        <h3 class="card-title" id="metricTotal">$0.00</h3>
                        <p class="card-text text-muted">
                            <i class="fas fa-dollar-sign"></i> 
                            <span id="metricTitle">Total Sales</span>
                        </p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card metric-card bg-light">
                    <div class="card-body text-center">
                        <h3 class="card-title" id="metricCount">0</h3>
                        <p class="card-text text-muted">
                            <i class="fas fa-shopping-cart"></i> 
                            <span id="countTitle">Orders</span>
                        </p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card metric-card bg-light">
                    <div class="card-body text-center">
                        <h3 class="card-title" id="metricAverage">$0.00</h3>
                        <p class="card-text text-muted">
                            <i class="fas fa-calculator"></i> 
                            <span id="averageTitle">Average Order</span>
                        </p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card metric-card bg-light">
                    <div class="card-body text-center">
                        <h3 class="card-title" id="dateRange">N/A</h3>
                        <p class="card-text text-muted">
                            <i class="fas fa-calendar-alt"></i> Date Range
                        </p>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Loading Spinner -->
        <div id="loadingSpinner" class="loading-spinner">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-2">Loading report data...</p>
        </div>
        
        <!-- Chart Section -->
        <div class="card mb-4">
            <div class="card-body">
                <h5 class="mb-3"><i class="fas fa-chart-bar"></i> Report Visualization</h5>
                <canvas id="reportChart" height="100"></canvas>
            </div>
        </div>
        
        <!-- Table Section -->
        <div class="card">
            <div class="card-body">
                <h5 class="mb-3"><i class="fas fa-table"></i> Report Details</h5>
                <div class="table-responsive">
                    <table class="table table-striped table-hover" id="reportTable">
                        <thead>
                            <tr id="reportTableHeader"></tr>
                        </thead>
                        <tbody id="reportTableBody"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2025 Online Shop Management System</p>
        </div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let chart;
        
        function setReportType(type) {
            document.getElementById('reportType').value = type;
            fetchReportData();
        }
        
        function fetchReportData() {
            const reportType = document.getElementById('reportType').value;
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;
            
            // Show loading spinner
            document.getElementById('loadingSpinner').style.display = 'block';
            document.getElementById('metricsCards').style.display = 'none';
            
            // Construct URL using JavaScript to avoid JSP EL interpretation
            const url = '../admin/reportData?reportType=' + encodeURIComponent(reportType) +
                        '&startDate=' + encodeURIComponent(startDate) +
                        '&endDate=' + encodeURIComponent(endDate);

            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    return response.json();
                })
                .then(data => {
                    // Hide loading spinner
                    document.getElementById('loadingSpinner').style.display = 'none';
                    
                    if (data.redirect) {
                        window.location.href = data.redirect;
                        return;
                    }
                    
                    if (data.error) {
                        console.error("Error from server:", data.error);
                        
                        // Display error message to user in a more friendly way
                        const errorMessage = document.createElement('div');
                        errorMessage.className = 'alert alert-warning alert-dismissible fade show mt-3';
                        errorMessage.innerHTML = `
                            <strong>Note:</strong> ${data.error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        `;
                        
                        // Insert before the chart card
                        const chartCard = document.querySelector('.card.mb-4');
                        chartCard.parentNode.insertBefore(errorMessage, chartCard);
                        
                        // Still try to render what we can with the data
                    }
                    
                    updateReportUI(reportType, data);
                })
                .catch(error => {
                    document.getElementById('loadingSpinner').style.display = 'none';
                    console.error('Error fetching report data:', error);
                    
                    // Show a nicer error message to the user
                    const errorMessage = document.createElement('div');
                    errorMessage.className = 'alert alert-danger alert-dismissible fade show mt-3';
                    errorMessage.innerHTML = `
                        <strong>Error:</strong> There was a problem loading the report data.
                        <p>Please try again later or contact technical support.</p>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    `;
                    
                    // Add it to the container
                    document.querySelector('.container.mt-4').appendChild(errorMessage);
                    
                    // Initialize empty report
                    updateReportUI(reportType, {
                        orders: [],
                        products: [],
                        totalSales: 0,
                        orderCount: 0,
                        totalProducts: 0,
                        lowStockCount: 0,
                        outOfStockCount: 0,
                        inventoryValue: 0,
                        startDate: startDate || formatDate(new Date(new Date().setMonth(new Date().getMonth() - 1))),
                        endDate: endDate || formatDate(new Date())
                    });
                });
        }
        
        function updateReportUI(reportType, data) {
            const ctx = document.getElementById('reportChart').getContext('2d');
            if (chart) chart.destroy();
            
            let labels = [], values = [], tableHeader = '', tableBody = '';
            
            // Initialize data arrays if missing
            data.orders = data.orders || [];
            data.products = data.products || [];
            
            // Show metrics cards
            document.getElementById('metricsCards').style.display = 'flex';
            
            if (reportType === 'Sales Report') {
                // Update metrics
                document.getElementById('metricTotal').textContent = '$' + (data.totalSales || 0).toFixed(2);
                document.getElementById('metricCount').textContent = data.orderCount || 0;
                document.getElementById('metricTitle').textContent = 'Total Sales';
                document.getElementById('countTitle').textContent = 'Orders';
                document.getElementById('metricAverage').textContent = '$' + ((data.totalSales || 0) / (data.orderCount || 1)).toFixed(2);
                document.getElementById('averageTitle').textContent = 'Average Order';
                document.getElementById('dateRange').textContent = `${data.startDate || 'N/A'} to ${data.endDate || 'N/A'}`;
                
                // Chart data
                const ordersByDate = {};
                data.orders.forEach(order => {
                    if (!ordersByDate[order.orderDate]) {
                        ordersByDate[order.orderDate] = 0;
                    }
                    ordersByDate[order.orderDate] += order.totalAmount;
                });
                
                labels = Object.keys(ordersByDate).sort();
                values = labels.map(date => ordersByDate[date]);
                
                // Table
                tableHeader = '<th>Order ID</th><th>Date</th><th>Customer</th><th>Total</th><th>Status</th>';
                
                if (data.orders.length === 0) {
                    tableBody = '<tr><td colspan="5" class="text-center">No orders found for the selected period.</td></tr>';
                } else {
                    tableBody = data.orders.map(o => 
                        '<tr>'
                        + '<td>' + o.orderId + '</td>'
                        + '<td>' + o.orderDate + '</td>'
                        + '<td>' + (o.customerName || 'Unknown') + '</td>'
                        + '<td class="text-end">$' + o.totalAmount.toFixed(2) + '</td>'
                        + '<td><span class="badge bg-' + getStatusBadge(o.status) + '">' + o.status + '</span></td>'
                        + '</tr>'
                    ).join('');
                }
            } else if (reportType === 'Inventory Report') {
                // Update metrics
                document.getElementById('metricTotal').textContent = '$' + (data.inventoryValue || 0).toFixed(2);
                document.getElementById('metricCount').textContent = data.totalProducts || 0;
                document.getElementById('metricTitle').textContent = 'Inventory Value';
                document.getElementById('countTitle').textContent = 'Products';
                document.getElementById('metricAverage').textContent = data.lowStockCount || 0;
                document.getElementById('averageTitle').textContent = 'Low Stock Items';
                document.getElementById('dateRange').textContent = data.outOfStockCount || 0;
                
                // Chart data - show top 10 products by stock
                const sortedProducts = [...data.products].sort((a, b) => b.stockQuantity - a.stockQuantity).slice(0, 10);
                labels = sortedProducts.map(p => p.productName);
                values = sortedProducts.map(p => p.stockQuantity);
                
                // Table
                tableHeader = '<th>Product ID</th><th>Name</th><th>Category</th><th>Stock</th><th>Price</th><th>Status</th>';
                
                if (data.products.length === 0) {
                    tableBody = '<tr><td colspan="6" class="text-center">No products found in inventory.</td></tr>';
                } else {
                    tableBody = data.products.map(p => 
                        '<tr>'
                        + '<td>' + p.productId + '</td>'
                        + '<td>' + p.productName + '</td>'
                        + '<td>' + (p.category || 'Uncategorized') + '</td>'
                        + '<td class="text-end">' + p.stockQuantity + '</td>'
                        + '<td class="text-end">$' + p.price.toFixed(2) + '</td>'
                        + '<td>' + getStockStatusBadge(p.stockQuantity) + '</td>'
                        + '</tr>'
                    ).join('');
                }
            } else {
                tableHeader = '<th colspan="5" class="text-center">No data available for the selected period.</th>';
                tableBody = '';
                document.getElementById('metricsCards').style.display = 'none';
                
                // Draw empty state
                chart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: ['No Data'],
                        datasets: [{
                            label: 'Data',
                            data: [0],
                            backgroundColor: '#e9ecef'
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            title: {
                                display: true,
                                text: 'No data available'
                            }
                        }
                    }
                });
            }
            
            document.getElementById('reportTableHeader').innerHTML = tableHeader;
            document.getElementById('reportTableBody').innerHTML = tableBody;
            
            // Only create chart if we have data
            if (labels.length > 0) {
                chart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels,
                        datasets: [{
                            label: 'Data',
                            data: values,
                            backgroundColor: '#007bff',
                            borderColor: '#0056b3',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            title: {
                                display: true,
                                text: 'Report Visualization'
                            }
                        }
                    }
                });
            }
        }
        
        function getStatusBadge(status) {
            switch(status.toLowerCase()) {
                case 'pending': return 'warning';
                case 'processing': return 'info';
                case 'shipped': return 'primary';
                case 'delivered': return 'success';
                case 'cancelled': return 'danger';
                default: return 'secondary';
            }
        }
        
        function getStockStatusBadge(stockQuantity) {
            if (stockQuantity <= 0) {
                return '<span class="badge bg-danger">Out of Stock</span>';
            } else if (stockQuantity < 10) {
                return '<span class="badge bg-warning">Low Stock</span>';
            } else {
                return '<span class="badge bg-success">In Stock</span>';
            }
        }
        
        function downloadReport() {
            const reportType = document.getElementById('reportType').value;
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;

            // Construct URL for download servlet
            const downloadUrl = '../admin/downloadReport?reportType=' + encodeURIComponent(reportType) +
                                 '&startDate=' + encodeURIComponent(startDate) +
                                 '&endDate=' + encodeURIComponent(endDate);
            
            // Open URL in a new tab/window to trigger download
            window.open(downloadUrl, '_blank');
        }
        
        // Auto-load report on page load
        window.onload = function() {
            // Set default dates (last 30 days)
            const today = new Date();
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(today.getDate() - 30);
            
            document.getElementById('endDate').value = formatDate(today);
            document.getElementById('startDate').value = formatDate(thirtyDaysAgo);
            
            fetchReportData();
        };
        
        function formatDate(date) {
            const yyyy = date.getFullYear();
            const mm = String(date.getMonth() + 1).padStart(2, '0');
            const dd = String(date.getDate()).padStart(2, '0');
            return `${yyyy}-${mm}-${dd}`;
        }
    </script>
</body>
</html> 