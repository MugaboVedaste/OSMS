<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.osms.dao.OrderDAO" %>
<%@ page import="com.osms.dao.ProductDAO" %>
<%@ page import="com.osms.dao.OrderItemDAO" %>
<%@ page import="com.osms.model.Order" %>
<%@ page import="com.osms.model.Product" %>
<%@ page import="com.osms.model.OrderItem" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.osms.model.Customer" %>
<%@ page import="com.osms.dao.CustomerDAO" %>
<%@ page import="java.sql.SQLException" %>
<%
    // Check if user is logged in and is a customer
    String userType = (String) session.getAttribute("userType");
    Integer customerId = (Integer) session.getAttribute("customerId");
    if (userType == null || !userType.equals("Customer") || customerId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get customer orders
    OrderDAO orderDAO = new OrderDAO();
    List<Order> orders = orderDAO.getByCustomerId(customerId);
    
    // Format for prices and dates
    DecimalFormat df = new DecimalFormat("0.00");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    
    // Get selected order details
    String selectedOrderId = request.getParameter("orderId");
    Order selectedOrder = null;
    List<OrderItem> orderItems = new ArrayList<>();
    
    if (selectedOrderId != null && !selectedOrderId.isEmpty()) {
        try {
            int orderIdInt = Integer.parseInt(selectedOrderId);
            selectedOrder = orderDAO.getById(orderIdInt);
            
            // Verify the order belongs to this customer
            if (selectedOrder != null && selectedOrder.getCustomerId() != customerId) {
                selectedOrder = null;
            } else if (selectedOrder != null) {
                // Load order items
                OrderItemDAO orderItemDAO = new OrderItemDAO();
                orderItems = orderItemDAO.getByOrderId(orderIdInt);
            }
        } catch (NumberFormatException e) {
            // Invalid order ID, ignore
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Orders - Customer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .order-card {
            transition: transform 0.2s;
            cursor: pointer;
        }
        .order-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .order-card.selected {
            border-color: #0d6efd;
            border-width: 2px;
        }
        .tracking-step {
            position: relative;
            padding-bottom: 3rem;
        }
        .tracking-step:before {
            content: '';
            position: absolute;
            left: 1.1rem;
            top: 2.5rem;
            bottom: 0;
            width: 3px;
            background-color: #e9ecef;
        }
        .tracking-step.completed:before {
            background-color: #198754;
        }
        .tracking-step:last-child:before {
            display: none;
        }
        .step-icon {
            width: 2.3rem;
            height: 2.3rem;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background-color: #e9ecef;
            color: #6c757d;
            margin-right: 1rem;
        }
        .tracking-step.completed .step-icon {
            background-color: #198754;
            color: white;
        }
        .tracking-step.active .step-icon {
            background-color: #0d6efd;
            color: white;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="dashboard.jsp">Customer Dashboard</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item"><a class="nav-link" href="shop.jsp">Shop</a></li>
                    <li class="nav-item"><a class="nav-link active" href="my_orders.jsp">My Orders</a></li>
                    <li class="nav-item"><a class="nav-link" href="wishlist.jsp">Wishlist</a></li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="cart.jsp">
                            <i class="fas fa-shopping-cart"></i> Cart
                            <% 
                                // Get cart items count
                                List<Integer> cartItems = (List<Integer>) session.getAttribute("cart");
                                int cartCount = (cartItems != null) ? cartItems.size() : 0;
                                if (cartCount > 0) {
                            %>
                            <span class="badge rounded-pill bg-danger"><%= cartCount %></span>
                            <% } %>
                        </a>
                    </li>
                    <li class="nav-item"><a class="nav-link" href="../logout">Logout</a></li>
                </ul>
            </div>
        </div>
    </nav>
    
    <div class="container mt-4">
        <h2><i class="fas fa-box"></i> My Orders</h2>
        
        <% if (orders.isEmpty()) { %>
            <div class="alert alert-info mt-3">
                <i class="fas fa-info-circle"></i> You haven't placed any orders yet. 
                <a href="shop.jsp" class="alert-link">Start shopping</a> to place your first order.
            </div>
        <% } else { %>
            <div class="row mt-4">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header bg-light">
                            <h5 class="mb-0">Order History</h5>
                        </div>
                        <div class="list-group list-group-flush">
                            <% for (Order order : orders) { 
                                boolean isSelected = selectedOrder != null && selectedOrder.getOrderId() == order.getOrderId();
                                String statusBadge = "secondary";
                                if ("Delivered".equalsIgnoreCase(order.getStatus())) statusBadge = "success";
                                else if ("Shipped".equalsIgnoreCase(order.getStatus())) statusBadge = "info";
                                else if ("Processing".equalsIgnoreCase(order.getStatus())) statusBadge = "primary";
                                else if ("Cancelled".equalsIgnoreCase(order.getStatus())) statusBadge = "danger";
                                else if ("Pending".equalsIgnoreCase(order.getStatus())) statusBadge = "warning";
                            %>
                                <a href="my_orders.jsp?orderId=<%= order.getOrderId() %>" class="list-group-item list-group-item-action <%= isSelected ? "active" : "" %>">
                                    <div class="d-flex w-100 justify-content-between">
                                        <h6 class="mb-1">Order #<%= order.getOrderId() %></h6>
                                        <span class="badge bg-<%= statusBadge %>"><%= order.getStatus() %></span>
                                    </div>
                                    <p class="mb-1"><%= dateFormat.format(order.getOrderDate()) %></p>
                                    <small>$<%= df.format(order.getTotalAmount()) %></small>
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-8">
                    <% if (selectedOrder != null) { %>
                        <div class="card">
                            <div class="card-header bg-light">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Order #<%= selectedOrder.getOrderId() %> Details</h5>
                                    <span class="badge bg-<%= 
                                        "Delivered".equalsIgnoreCase(selectedOrder.getStatus()) ? "success" : 
                                        "Shipped".equalsIgnoreCase(selectedOrder.getStatus()) ? "info" : 
                                        "Processing".equalsIgnoreCase(selectedOrder.getStatus()) ? "primary" : 
                                        "Cancelled".equalsIgnoreCase(selectedOrder.getStatus()) ? "danger" : 
                                        "Pending".equalsIgnoreCase(selectedOrder.getStatus()) ? "warning" : "secondary" 
                                    %>"><%= selectedOrder.getStatus() %></span>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="row mb-4">
                                    <div class="col-md-6">
                                        <h6>Order Information</h6>
                                        <p class="mb-0"><strong>Date:</strong> <%= dateFormat.format(selectedOrder.getOrderDate()) %></p>
                                        <p class="mb-0"><strong>Total:</strong> $<%= df.format(selectedOrder.getTotalAmount()) %></p>
                                        <p><strong>Status:</strong> <%= selectedOrder.getStatus() %></p>
                                    </div>
                                    <div class="col-md-6">
                                        <h6>Shipping Address</h6>
                                        <p class="mb-0"><strong>Address:</strong> <%= selectedOrder.getShippingAddress() != null ? selectedOrder.getShippingAddress() : "N/A" %></p>
                                        <p class="mb-0"><strong>City:</strong> <%= selectedOrder.getShippingCity() != null ? selectedOrder.getShippingCity() : "N/A" %></p>
                                        <p class="mb-0"><strong>State:</strong> <%= selectedOrder.getShippingState() != null ? selectedOrder.getShippingState() : "N/A" %></p>
                                        <p class="mb-0"><strong>Zip Code:</strong> <%= selectedOrder.getShippingZipCode() != null ? selectedOrder.getShippingZipCode() : "N/A" %></p>
                                        <p><strong>Country:</strong> <%= selectedOrder.getShippingCountry() != null ? selectedOrder.getShippingCountry() : "N/A" %></p>
                                    </div>
                                </div>
                                
                                <h6>Order Tracking</h6>
                                <div class="tracking-container mb-4">
                                    <div class="tracking-step completed">
                                        <div class="d-flex">
                                            <div class="step-icon">
                                                <i class="fas fa-check"></i>
                                            </div>
                                            <div>
                                                <h6 class="mb-1">Order Placed</h6>
                                                <p class="text-muted mb-0">Your order has been placed</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="tracking-step <%= 
                                        "Processing".equalsIgnoreCase(selectedOrder.getStatus()) || 
                                        "Shipped".equalsIgnoreCase(selectedOrder.getStatus()) || 
                                        "Delivered".equalsIgnoreCase(selectedOrder.getStatus()) ? "completed" : 
                                        "Pending".equalsIgnoreCase(selectedOrder.getStatus()) ? "active" : "" 
                                    %>">
                                        <div class="d-flex">
                                            <div class="step-icon">
                                                <i class="fas fa-cog"></i>
                                            </div>
                                            <div>
                                                <h6 class="mb-1">Processing</h6>
                                                <p class="text-muted mb-0">Your order is being processed</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="tracking-step <%= 
                                        "Shipped".equalsIgnoreCase(selectedOrder.getStatus()) || 
                                        "Delivered".equalsIgnoreCase(selectedOrder.getStatus()) ? "completed" : 
                                        "Processing".equalsIgnoreCase(selectedOrder.getStatus()) ? "active" : "" 
                                    %>">
                                        <div class="d-flex">
                                            <div class="step-icon">
                                                <i class="fas fa-truck"></i>
                                            </div>
                                            <div>
                                                <h6 class="mb-1">Shipped</h6>
                                                <p class="text-muted mb-0">Your order has been shipped</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="tracking-step <%= 
                                        "Delivered".equalsIgnoreCase(selectedOrder.getStatus()) ? "completed" : 
                                        "Shipped".equalsIgnoreCase(selectedOrder.getStatus()) ? "active" : "" 
                                    %>">
                                        <div class="d-flex">
                                            <div class="step-icon">
                                                <i class="fas fa-home"></i>
                                            </div>
                                            <div>
                                                <h6 class="mb-1">Delivered</h6>
                                                <p class="text-muted mb-0">Your order has been delivered</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <h6>Order Items</h6>
                                <div class="table-responsive">
                                    <table class="table">
                                        <thead>
                                            <tr>
                                                <th>Product</th>
                                                <th>Price</th>
                                                <th>Quantity</th>
                                                <th>Total</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% 
                                                if (orderItems.isEmpty()) {
                                                    %>
                                                    <tr>
                                                        <td colspan="4" class="text-center">No items found for this order</td>
                                                    </tr>
                                                    <%
                                                } else {
                                                    ProductDAO productDAO = new ProductDAO();
                                                    double orderTotal = 0.0;
                                                    
                                                    for (OrderItem item : orderItems) {
                                                        Product product = productDAO.getById(item.getProductId());
                                                        String productName = product != null ? product.getProductName() : "Unknown Product";
                                                        double unitPrice = item.getPrice();
                                                        int quantity = item.getQuantity();
                                                        double subtotal = unitPrice * quantity;
                                                        orderTotal += subtotal;
                                                    %>
                                                    <tr>
                                                        <td><%= productName %></td>
                                                        <td>$<%= df.format(unitPrice) %></td>
                                                        <td><%= quantity %></td>
                                                        <td>$<%= df.format(subtotal) %></td>
                                                    </tr>
                                                    <%
                                                    }
                                                }
                                            %>
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <td colspan="3" class="text-end fw-bold">Total:</td>
                                                <td class="fw-bold">$<%= df.format(selectedOrder.getTotalAmount()) %></td>
                                            </tr>
                                        </tfoot>
                                    </table>
                                </div>
                                
                                <% if (!"Delivered".equalsIgnoreCase(selectedOrder.getStatus()) && 
                                       !"Cancelled".equalsIgnoreCase(selectedOrder.getStatus())) { %>
                                    <div class="d-flex justify-content-end mt-3">
                                        <a href="../order/cancel?orderId=<%= selectedOrder.getOrderId() %>" class="btn btn-outline-danger"
                                           onclick="return confirm('Are you sure you want to cancel this order?');">
                                            <i class="fas fa-times"></i> Cancel Order
                                        </a>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="card">
                            <div class="card-body text-center py-5">
                                <i class="fas fa-box-open fa-4x text-muted mb-3"></i>
                                <h5>Select an order to view details</h5>
                                <p class="text-muted">Click on any order from the list on the left to view its details</p>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>
    </div>
    
    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2025 Online Shop Management System</p>
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 