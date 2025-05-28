<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.osms.dao.OrderDAO" %>
<%@ page import="com.osms.dao.OrderItemDAO" %>
<%@ page import="com.osms.dao.ProductDAO" %>
<%@ page import="com.osms.dao.CustomerDAO" %>
<%@ page import="com.osms.model.Order" %>
<%@ page import="com.osms.model.OrderItem" %>
<%@ page import="com.osms.model.Product" %>
<%@ page import="com.osms.model.Customer" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.osms.util.DatabaseUtil" %>
<%
    // Check if user is logged in and is a seller
    String userType = (String) session.getAttribute("userType");
    Integer sellerId = (Integer) session.getAttribute("sellerId");
    if (userType == null || !userType.equals("Seller") || sellerId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Initialize DAOs
    OrderDAO orderDAO = new OrderDAO();
    OrderItemDAO orderItemDAO = new OrderItemDAO();
    ProductDAO productDAO = new ProductDAO();
    CustomerDAO customerDAO = new CustomerDAO();
    
    // Debug line
    System.out.println("Looking for orders for seller ID: " + sellerId);
    
    // Get all orders for debugging
    List<Order> allOrders = orderDAO.getAll();
    System.out.println("Total orders in system: " + allOrders.size());
    for (Order order : allOrders) {
        System.out.println("Order #" + order.getOrderId() + ", Customer: " + order.getCustomerId() + ", Status: " + order.getStatus());
    }
    
    // Get all products for this seller for debugging
    List<Product> sellerProducts = productDAO.getBySellerId(sellerId);
    System.out.println("Products for seller " + sellerId + ": " + sellerProducts.size());
    for (Product product : sellerProducts) {
        System.out.println("Product #" + product.getProductId() + " - " + product.getProductName());
    }
    
    // Check if there are any order items for the seller's products
    boolean foundOrderItems = false;
    for (Order order : allOrders) {
        List<OrderItem> orderItems = orderItemDAO.getByOrderId(order.getOrderId());
        System.out.println("Order #" + order.getOrderId() + " has " + orderItems.size() + " items");
        
        for (OrderItem item : orderItems) {
            Product product = productDAO.getById(item.getProductId());
            if (product != null && product.getSellerId() == sellerId) {
                System.out.println("Found matching product: " + product.getProductName() + " in order #" + order.getOrderId());
                foundOrderItems = true;
            }
        }
    }
    
    // Get orders for this seller using the proper method
    List<Order> sellerOrders = orderDAO.getBySellerId(sellerId);
    System.out.println("Orders for seller " + sellerId + " (via getBySellerId): " + sellerOrders.size());
    
    // Map to store orders with their items
    Map<Order, List<OrderItem>> ordersWithItems = new HashMap<>();
    
    // For each order, get the order items
    for (Order order : sellerOrders) {
        List<OrderItem> allOrderItems = orderItemDAO.getByOrderId(order.getOrderId());
        List<OrderItem> sellerItems = new ArrayList<>();
        
        for (OrderItem item : allOrderItems) {
            Product product = productDAO.getById(item.getProductId());
            // Only include items for products that belong to this seller
            if (product != null && product.getSellerId() == sellerId) {
                sellerItems.add(item);
            }
        }
        
        // Only add orders that have items for this seller
        if (!sellerItems.isEmpty()) {
            ordersWithItems.put(order, sellerItems);
            System.out.println("Found order " + order.getOrderId() + " for seller " + sellerId + " with " + sellerItems.size() + " items");
        }
    }
    
    if (ordersWithItems.isEmpty() && !foundOrderItems) {
        System.out.println("No orders with items for this seller were found. This suggests a data issue.");
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Orders - Seller</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="dashboard.jsp">OSMS Seller</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item"><a class="nav-link" href="dashboard.jsp">Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link" href="my_products.jsp">My Products</a></li>
                    <li class="nav-item"><a class="nav-link active" href="orders.jsp">Orders</a></li>
                    <li class="nav-item"><a class="nav-link" href="my_store.jsp">My Store</a></li>
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
            <h2>Customer Orders</h2>
            <a href="javascript:void(0)" class="btn btn-success" onclick="generateOrderReport()">
                <i class="fas fa-download"></i> Download Report
            </a>
        </div>
        
        <% if (request.getSession().getAttribute("successMessage") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <%= request.getSession().getAttribute("successMessage") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% request.getSession().removeAttribute("successMessage"); %>
        <% } %>
        
        <% if (request.getSession().getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= request.getSession().getAttribute("errorMessage") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% request.getSession().removeAttribute("errorMessage"); %>
        <% } %>
        
        <!-- Debug information -->
        <% if (ordersWithItems.isEmpty()) { %>
            <div class="alert alert-info">
                <h5>Debug Information:</h5>
                <p>Total orders in system: <%= allOrders.size() %></p>
                <p>Products for seller <%= sellerId %>: <%= sellerProducts.size() %></p>
                <% if (sellerProducts.isEmpty()) { %>
                    <p class="text-danger"><strong>No products found for this seller.</strong> You need to add products before you can see orders.</p>
                <% } else if (!foundOrderItems) { %>
                    <p class="text-warning"><strong>No orders contain products from this seller.</strong> Customers may not have ordered your products yet.</p>
                <% } else { %>
                    <p class="text-danger"><strong>Data inconsistency detected.</strong> Order items exist but couldn't be displayed.</p>
                <% } %>
            </div>
        <% } %>
        
        <ul class="nav nav-tabs mb-4" id="orderTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="all-orders-tab" data-bs-toggle="tab" data-bs-target="#all-orders" type="button">All Orders</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="pending-tab" data-bs-toggle="tab" data-bs-target="#pending" type="button">Pending</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="processing-tab" data-bs-toggle="tab" data-bs-target="#processing" type="button">Processing</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="shipped-tab" data-bs-toggle="tab" data-bs-target="#shipped" type="button">Shipped</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="delivered-tab" data-bs-toggle="tab" data-bs-target="#delivered" type="button">Delivered</button>
            </li>
        </ul>
        
        <div class="tab-content" id="orderTabsContent">
            <div class="tab-pane fade show active" id="all-orders" role="tabpanel">
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>Order ID</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Products</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (ordersWithItems.isEmpty()) { %>
                                <tr>
                                    <td colspan="7" class="text-center">No orders found.</td>
                                </tr>
                            <% } else { %>
                                <% for (Map.Entry<Order, List<OrderItem>> entry : ordersWithItems.entrySet()) { %>
                                    <% Order order = entry.getKey(); %>
                                    <% List<OrderItem> items = entry.getValue(); %>
                                    <% Customer customer = customerDAO.getById(order.getCustomerId()); %>
                                    <tr>
                                        <td><%= order.getOrderId() %></td>
                                        <td><%= dateFormat.format(order.getOrderDate()) %></td>
                                        <td><%= customer != null ? customer.getFirstName() + " " + customer.getLastName() : "Unknown" %></td>
                                        <td>
                                            <% if (items != null && !items.isEmpty()) { %>
                                                <ul class="list-unstyled mb-0">
                                                <% double sellerTotal = 0.0; %>
                                                <% for (OrderItem item : items) { %>
                                                    <% Product product = productDAO.getById(item.getProductId()); %>
                                                    <% if (product != null && product.getSellerId() == sellerId) { %>
                                                        <li><strong><%= product.getProductName() %></strong> - <%= item.getQuantity() %> x $<%= String.format("%.2f", item.getPrice()) %></li>
                                                        <% sellerTotal += (item.getQuantity() * item.getPrice()); %>
                                                    <% } %>
                                                <% } %>
                                                </ul>
                                            <% } else { %>
                                                <span class="text-muted">No products found</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% 
                                                // Calculate total for just this seller's items
                                                double sellerTotal = 0.0;
                                                for (OrderItem item : items) {
                                                    if (productDAO.getById(item.getProductId()).getSellerId() == sellerId) {
                                                        sellerTotal += (item.getQuantity() * item.getPrice());
                                                    }
                                                }
                                            %>
                                            $<%= String.format("%.2f", sellerTotal) %>
                                        </td>
                                        <td>
                                            <span class="badge bg-<%= getStatusClass(order.getStatus()) %>">
                                                <%= order.getStatus() %>
                                            </span>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-primary" onclick="viewOrderDetails(<%= order.getOrderId() %>)">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button class="btn btn-sm btn-success" onclick="updateOrderStatus(<%= order.getOrderId() %>)">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Other tabs with filtered content will be implemented via JavaScript -->
            <div class="tab-pane fade" id="pending" role="tabpanel">
                <!-- Pending orders will be loaded here -->
            </div>
            <div class="tab-pane fade" id="processing" role="tabpanel">
                <!-- Processing orders will be loaded here -->
            </div>
            <div class="tab-pane fade" id="shipped" role="tabpanel">
                <!-- Shipped orders will be loaded here -->
            </div>
            <div class="tab-pane fade" id="delivered" role="tabpanel">
                <!-- Delivered orders will be loaded here -->
            </div>
        </div>
    </div>
    
    <!-- Order Status Update Modal -->
    <div class="modal fade" id="updateStatusModal" tabindex="-1" aria-labelledby="updateStatusModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="updateStatusModalLabel">Update Order Status</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="../updateOrderStatus" method="post">
                    <div class="modal-body">
                        <input type="hidden" id="updateOrderId" name="orderId">
                        <div class="mb-3">
                            <label for="orderStatus" class="form-label">Status</label>
                            <select class="form-select" id="orderStatus" name="status" required>
                                <option value="Pending">Pending</option>
                                <option value="Processing">Processing</option>
                                <option value="Shipped">Shipped</option>
                                <option value="Delivered">Delivered</option>
                                <option value="Cancelled">Cancelled</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update Status</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Order Details Modal -->
    <div class="modal fade" id="orderDetailsModal" tabindex="-1" aria-labelledby="orderDetailsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="orderDetailsModalLabel">Order Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="orderDetailsContent">
                    <!-- Order details will be loaded here via JavaScript -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    
    <footer class="bg-light text-center text-lg-start mt-5">
        <div class="text-center p-3" style="background-color: rgba(0, 0, 0, 0.05);">
            © 2025 Online Shop Management System
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function updateOrderStatus(orderId) {
            document.getElementById('updateOrderId').value = orderId;
            var modal = new bootstrap.Modal(document.getElementById('updateStatusModal'));
            modal.show();
        }
        
        function viewOrderDetails(orderId) {
            // Implementation will be added to show order details
            const modal = new bootstrap.Modal(document.getElementById('orderDetailsModal'));
            
            // Get the order details content container
            const contentDiv = document.getElementById('orderDetailsContent');
            contentDiv.innerHTML = '<div class="text-center"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>';
            
            // Show the modal
            modal.show();
            
            // In a real implementation, you would fetch the details from the server
            // Here we're simulating loading the details for the order
            setTimeout(() => {
                // Find the order in our existing data
                <% for (Map.Entry<Order, List<OrderItem>> entry : ordersWithItems.entrySet()) { %>
                    <% Order order = entry.getKey(); %>
                    if (<%= order.getOrderId() %> === orderId) {
                        let html = `
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <h6>Order #<%= order.getOrderId() %></h6>
                                    <p>Date: <%= dateFormat.format(order.getOrderDate()) %></p>
                                    <p>Status: <span class="badge bg-<%= getStatusClass(order.getStatus()) %>"><%= order.getStatus() %></span></p>
                                </div>
                                <div class="col-md-6">
                                    <% Customer customer = customerDAO.getById(order.getCustomerId()); %>
                                    <h6>Customer Information</h6>
                                    <p><%= customer != null ? customer.getFirstName() + " " + customer.getLastName() : "Unknown" %></p>
                                    <p><%= customer != null ? customer.getEmail() : "" %></p>
                                    <p><%= customer != null ? customer.getPhone() : "" %></p>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-bordered">
                                    <thead>
                                        <tr>
                                            <th>Product</th>
                                            <th>Price</th>
                                            <th>Quantity</th>
                                            <th>Total</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% List<OrderItem> items = entry.getValue(); %>
                                        <% double sellerTotal = 0.0; %>
                                        <% for (OrderItem item : items) { %>
                                            <% Product product = productDAO.getById(item.getProductId()); %>
                                            <% if (product != null && product.getSellerId() == sellerId) { %>
                                                <% double itemTotal = item.getQuantity() * item.getPrice(); %>
                                                <% sellerTotal += itemTotal; %>
                                                <tr>
                                                    <td><%= product.getProductName() %></td>
                                                    <td>$<%= String.format("%.2f", item.getPrice()) %></td>
                                                    <td><%= item.getQuantity() %></td>
                                                    <td>$<%= String.format("%.2f", itemTotal) %></td>
                                                </tr>
                                            <% } %>
                                        <% } %>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <th colspan="3" class="text-end">Total:</th>
                                            <th>$<%= String.format("%.2f", sellerTotal) %></th>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        `;
                        contentDiv.innerHTML = html;
                    }
                <% } %>
            }, 500);
        }
        
        function generateOrderReport() {
            // Get the sellerId from the session attribute
            var sellerId = <%= sellerId %>; // Accessing the sellerId from the JSP scriptlet
            if (sellerId) {
                // Construct the URL for the report servlet
                var reportUrl = '<%= request.getContextPath() %>/SellerOrderReport?sellerId=' + sellerId;
                
                // Redirect to the servlet URL to trigger the download
                window.location.href = reportUrl;
            } else {
                alert("Seller ID not found."); // Should not happen if seller is logged in
            }
        }
        
        // Filter orders by status in tabs
        document.addEventListener('DOMContentLoaded', function() {
            // Get all tab buttons
            const tabs = document.querySelectorAll('[data-bs-toggle="tab"]');
            
            // Add click event to each tab button
            tabs.forEach(tab => {
                tab.addEventListener('click', function() {
                    const status = this.textContent.trim();
                    const isAll = status === 'All Orders';
                    
                    // Get all table rows
                    const rows = document.querySelectorAll('#all-orders tbody tr');
                    
                    // Clone the rows to the appropriate tab pane
                    const targetPane = document.querySelector(this.getAttribute('data-bs-target'));
                    if (targetPane && targetPane.id !== 'all-orders') {
                        // Clear the target pane
                        targetPane.innerHTML = `
                            <div class="table-responsive">
                                <table class="table table-striped table-hover">
                                    <thead class="table-dark">
                                        <tr>
                                            <th>Order ID</th>
                                            <th>Date</th>
                                            <th>Customer</th>
                                            <th>Products</th>
                                            <th>Total</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="${targetPane.id}-body">
                                    </tbody>
                                </table>
                            </div>
                        `;
                        
                        // Copy matching rows
                        let found = false;
                        rows.forEach(row => {
                            const statusCell = row.querySelector('td:nth-child(6)');
                            if (statusCell && (statusCell.textContent.trim() === status || isAll)) {
                                document.getElementById(`${targetPane.id}-body`).appendChild(row.cloneNode(true));
                                found = true;
                            }
                        });
                        
                        // If no rows found, show a message
                        if (!found) {
                            document.getElementById(`${targetPane.id}-body`).innerHTML = `
                                <tr>
                                    <td colspan="7" class="text-center">No ${status} orders found.</td>
                                </tr>
                            `;
                        }
                    }
                });
            });
        });
    </script>
    
    <%!
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