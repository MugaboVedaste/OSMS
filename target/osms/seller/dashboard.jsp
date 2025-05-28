<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.osms.dao.ProductDAO" %>
<%@ page import="com.osms.dao.OrderDAO" %>
<%@ page import="com.osms.dao.OrderItemDAO" %>
<%@ page import="com.osms.model.Product" %>
<%@ page import="com.osms.model.Order" %>
<%@ page import="com.osms.model.OrderItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    // Check if user is logged in and is a seller
    String userType = (String) session.getAttribute("userType");
    Integer sellerId = (Integer) session.getAttribute("sellerId");
    if (userType == null || !userType.equals("Seller") || sellerId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Initialize DAOs
    ProductDAO productDAO = new ProductDAO();
    OrderDAO orderDAO = new OrderDAO();
    OrderItemDAO orderItemDAO = new OrderItemDAO();
    
    // Get all products for this seller
    List<Product> sellerProducts = productDAO.getBySellerId(sellerId);
    
    // Count products
    int totalProducts = sellerProducts.size();
    
    // Find low stock products (less than 10 items)
    List<Product> lowStockProducts = new ArrayList<>();
    for (Product product : sellerProducts) {
        if (product.getStockQuantity() < 10) {
            lowStockProducts.add(product);
        }
    }
    
    // --- Refactored Order and Metrics Fetching ---
    
    // Get all orders containing seller's products
    List<Order> sellerOrders = orderDAO.getBySellerId(sellerId);
    
    // Maps to store orders with their items and metrics
    Map<Order, List<OrderItem>> ordersWithItems = new HashMap<>();
    int newOrdersCount = 0;
    double totalSales = 0.0; // Total sales across all time for this seller's items
    double todaySales = 0.0;
    double monthlyRevenue = 0.0;
    double totalSalesAllTime = 0.0;

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat monthFormat = new SimpleDateFormat("yyyy-MM");
    String today = dateFormat.format(new Date());
    String thisMonth = monthFormat.format(new Date());
    
    for (Order order : sellerOrders) {
        List<OrderItem> allOrderItems = orderItemDAO.getByOrderId(order.getOrderId());
        List<OrderItem> sellerItemsForOrder = new ArrayList<>();
        double orderSellerTotal = 0.0; // Total for this seller's items in this order

        if (allOrderItems != null) {
            for (OrderItem item : allOrderItems) {
                 // Ensure the item belongs to this seller's product
                 // (redundant if getBySellerId is accurate, but good for safety)
                Product product = productDAO.getById(item.getProductId());
                if (product != null && product.getSellerId() == sellerId) {
                    sellerItemsForOrder.add(item);
                    orderSellerTotal += item.getQuantity() * item.getUnitPrice(); // Use unitPrice for calculation
                }
            }
        }

        // Only consider orders that actually have items from this seller
        if (!sellerItemsForOrder.isEmpty()) {
            ordersWithItems.put(order, sellerItemsForOrder);

            // Count new orders (Pending)
            if ("Pending".equals(order.getStatus())) {
                newOrdersCount++;
            }

            // Calculate sales metrics
            totalSalesAllTime += orderSellerTotal; // Add to total sales (all time)

            if (dateFormat.format(order.getOrderDate()).equals(today)) {
                todaySales += orderSellerTotal; // Add to today's sales
            }

            if (monthFormat.format(order.getOrderDate()).equals(thisMonth)) {
                monthlyRevenue += orderSellerTotal; // Add to monthly revenue
            }
        }
    }

    // Sort recent orders by date (newest first) and limit to 5
    List<Order> recentOrders = new ArrayList<>(ordersWithItems.keySet());
    recentOrders.sort((o1, o2) -> o2.getOrderDate().compareTo(o1.getOrderDate()));
    if (recentOrders.size() > 5) {
        recentOrders = recentOrders.subList(0, 5);
    }

    // --- End Refactored Order and Metrics Fetching ---

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Dashboard - OSMS</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="../css/style.css" rel="stylesheet">
    <style>
        .dashboard-card {
            transition: transform 0.3s;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
        }
        .dashboard-card .card-value {
            font-size: 2rem;
            font-weight: bold;
        }
        .dashboard-card.products {
            border-left: 5px solid #007bff;
        }
        .dashboard-card.orders {
            border-left: 5px solid #28a745;
        }
        .dashboard-card.sales {
            border-left: 5px solid #ffc107;
        }
        .dashboard-card.revenue {
            border-left: 5px solid #dc3545;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="#">OSMS Seller</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="my_products.jsp">My Products</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="orders.jsp">Orders</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="my_store.jsp">My Store</a>
                    </li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            ${sessionScope.username}
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
                            <li><a class="dropdown-item" href="profile.jsp">My Profile</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="../logout">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2>Seller Dashboard</h2>
                <p class="text-muted">Welcome, ${sessionScope.username}!</p>
            </div>
            <a href="javascript:void(0)" class="btn btn-success" onclick="generateSalesReport()">
                <i class="fas fa-download"></i> Download Sales Report
            </a>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-3">
                <div class="card dashboard-card products">
                    <div class="card-body text-center">
                        <i class="fas fa-box-open fa-3x mb-3 text-primary"></i>
                        <h5 class="card-title">Products</h5>
                        <p class="card-value"><%= totalProducts %></p>
                        <p class="card-text">Total products listed</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card orders">
                    <div class="card-body text-center">
                        <i class="fas fa-shopping-cart fa-3x mb-3 text-success"></i>
                        <h5 class="card-title">Orders</h5>
                        <p class="card-value"><%= newOrdersCount %></p>
                        <p class="card-text">New orders (Pending)</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card sales">
                    <div class="card-body text-center">
                        <i class="fas fa-chart-line fa-3x mb-3 text-warning"></i>
                        <h5 class="card-title">Sales (Today)</h5>
                        <p class="card-value">$<%= String.format("%.2f", todaySales) %></p>
                        <p class="card-text">Total sales today for your products</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card revenue">
                    <div class="card-body text-center">
                        <i class="fas fa-dollar-sign fa-3x mb-3 text-danger"></i>
                        <h5 class="card-title">Revenue (Monthly)</h5>
                        <p class="card-value">$<%= String.format("%.2f", monthlyRevenue) %></p>
                        <p class="card-text">Total revenue this month for your products</p>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Recent Orders (Last 5)</h5>
                        <a href="orders.jsp" class="btn btn-sm btn-primary">View All</a>
                    </div>
                    <ul class="list-group list-group-flush">
                        <% if (recentOrders.isEmpty()) { %>
                            <li class="list-group-item text-center text-muted">No recent orders found.</li>
                        <% } else { %>
                            <% for (Order order : recentOrders) { %>
                                <% List<OrderItem> items = ordersWithItems.get(order); %>
                                <% double sellerTotal = 0.0; %>
                                <% if (items != null) { %>
                                     <% for (OrderItem item : items) { %>
                                         <% sellerTotal += item.getQuantity() * item.getUnitPrice(); %>
                                     <% } %>
                                <% } %>
                                <li class="list-group-item">
                                    Order #<%= order.getOrderId() %> - <%= new SimpleDateFormat("MMM dd, yyyy").format(order.getOrderDate()) %> - $<%= String.format("%.2f", sellerTotal) %>
                                    <span class="badge bg-<%= getStatusClass(order.getStatus()) %> float-end">
                                        <%= order.getStatus() %>
                                    </span>
                                </li>
                            <% } %>
                        <% } %>
                    </ul>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Low Stock Products</h5>
                    </div>
                    <ul class="list-group list-group-flush">
                        <% if (lowStockProducts.isEmpty()) { %>
                            <li class="list-group-item text-center text-muted">No products are low in stock.</li>
                        <% } else { %>
                            <% for (Product product : lowStockProducts) { %>
                                <li class="list-group-item">
                                    <%= product.getProductName() %> - Stock: <%= product.getStockQuantity() %>
                                </li>
                            <% } %>
                        <% } %>
                    </ul>
                </div>
            </div>
        </div>
        
        <%-- Placeholder for sales report generation script --%>
        <script>
            function generateSalesReport() {
                alert("Sales report generation not yet implemented.");
                // TODO: Implement sales report generation logic
                // This might involve another servlet call similar to the order report, 
                // or generating the report data directly in the JSP and using a library 
                // to create the PDF/CSV on the client side.
            }
        </script>
    </div>

    <footer class="bg-light text-center text-lg-start mt-5">
        <div class="text-center p-3" style="background-color: rgba(0, 0, 0, 0.05);">
            © 2025 Online Shop Management System
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

    <%! // Helper method for Bootstrap badge classes
        private String getStatusClass(String status) {
            if (status == null) return "secondary";
            
            switch (status.toLowerCase()) {
                case "pending":
                    return "warning";
                case "processing":
                    return "info";
                case "shipped":
                    return "primary";
                case "delivered":
                    return "success";
                case "cancelled":
                    return "danger";
                default:
                    return "secondary";
            }
        }
    %>
</body>
</html> 