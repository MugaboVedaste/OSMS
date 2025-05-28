<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.osms.dao.OrderDAO" %>
<%@ page import="com.osms.model.Order" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in and is a customer
    String userType = (String) session.getAttribute("userType");
    Integer customerId = (Integer) session.getAttribute("userId");
    if (userType == null || !userType.equals("Customer") || customerId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get order ID from request parameter
    String orderIdStr = request.getParameter("orderId");
    Order order = null;
    
    if (orderIdStr != null && !orderIdStr.isEmpty()) {
        try {
            int orderId = Integer.parseInt(orderIdStr);
            OrderDAO orderDAO = new OrderDAO();
            order = orderDAO.getById(orderId);
            
            // Make sure the order belongs to the current customer
            if (order != null && order.getCustomerId() != customerId) {
                order = null;
            }
        } catch (NumberFormatException e) {
            // Invalid order ID
        }
    }
    
    // If order not found, redirect to orders page
    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/customer/my_orders.jsp");
        return;
    }
    
    // Format for prices and dates
    DecimalFormat df = new DecimalFormat("0.00");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy");
    
    // Generate estimated delivery date (5 days from order date)
    java.util.Calendar cal = java.util.Calendar.getInstance();
    cal.setTime(order.getOrderDate());
    cal.add(java.util.Calendar.DAY_OF_MONTH, 5);
    java.util.Date estimatedDeliveryDate = cal.getTime();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Confirmation - Customer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .order-confirmation {
            max-width: 800px;
            margin: 0 auto;
        }
        .success-icon {
            font-size: 5rem;
            color: #28a745;
        }
        .thank-you {
            font-size: 2rem;
            color: #28a745;
        }
        @media print {
            .no-print {
                display: none !important;
            }
            .card {
                border: 1px solid #ddd !important;
                box-shadow: none !important;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark no-print">
        <div class="container">
            <a class="navbar-brand" href="dashboard.jsp">Customer Dashboard</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item"><a class="nav-link" href="shop.jsp">Shop</a></li>
                    <li class="nav-item"><a class="nav-link" href="my_orders.jsp">My Orders</a></li>
                    <li class="nav-item"><a class="nav-link" href="wishlist.jsp">Wishlist</a></li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="../logout">Logout</a></li>
                </ul>
            </div>
        </div>
    </nav>
    
    <div class="container mt-5 mb-5">
        <div class="order-confirmation">
            <div class="text-center mb-4">
                <i class="fas fa-check-circle success-icon mb-3"></i>
                <h1 class="thank-you mb-3">Thank You for Your Order!</h1>
                <p class="lead">Your order has been placed successfully.</p>
                <p>An email confirmation has been sent to your registered email address.</p>
            </div>
            
            <div class="card mb-4 shadow-sm">
                <div class="card-header bg-light">
                    <div class="d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Order #<%= order.getOrderId() %></h5>
                        <span class="badge bg-warning text-dark"><%= order.getStatus() %></span>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <h6>Order Information</h6>
                            <p class="mb-1"><strong>Order ID:</strong> #<%= order.getOrderId() %></p>
                            <p class="mb-1"><strong>Order Date:</strong> <%= dateFormat.format(order.getOrderDate()) %></p>
                            <p class="mb-1"><strong>Payment Method:</strong> Cash on Delivery</p>
                            <p class="mb-1"><strong>Total Amount:</strong> $<%= df.format(order.getTotalAmount()) %></p>
                        </div>
                        <div class="col-md-6">
                            <h6>Shipping Information</h6>
                            <p class="mb-1"><strong>Estimated Delivery:</strong> <%= dateFormat.format(estimatedDeliveryDate) %></p>
                            <p class="mb-1"><strong>Status:</strong> <%= order.getStatus() %></p>
                            <p class="mb-1"><strong>Shipping Address:</strong></p>
                            <p class="mb-0">123 Main Street, Apt 4B<br>New York, NY 10001</p>
                        </div>
                    </div>
                    
                    <h6>Order Summary</h6>
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Item</th>
                                    <th>Quantity</th>
                                    <th>Price</th>
                                    <th class="text-end">Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Sample items since we don't have OrderItem implementation yet -->
                                <tr>
                                    <td>Sample Product 1</td>
                                    <td>1</td>
                                    <td>$50.00</td>
                                    <td class="text-end">$50.00</td>
                                </tr>
                                <tr>
                                    <td>Sample Product 2</td>
                                    <td>2</td>
                                    <td>$25.50</td>
                                    <td class="text-end">$51.00</td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="text-end border-0"><strong>Shipping:</strong></td>
                                    <td class="text-end border-0">$5.00</td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="text-end border-0"><strong>Order Total:</strong></td>
                                    <td class="text-end border-0"><strong>$<%= df.format(order.getTotalAmount()) %></strong></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <div class="d-flex justify-content-between align-items-center mb-4 no-print">
                <a href="my_orders.jsp?orderId=<%= order.getOrderId() %>" class="btn btn-primary">
                    <i class="fas fa-box"></i> View Order Status
                </a>
                <div>
                    <button class="btn btn-outline-secondary me-2" onclick="window.print();">
                        <i class="fas fa-print"></i> Print Receipt
                    </button>
                    <a href="shop.jsp" class="btn btn-success">
                        <i class="fas fa-shopping-bag"></i> Continue Shopping
                    </a>
                </div>
            </div>
        </div>
    </div>
    
    <footer class="mt-5 py-3 bg-light no-print">
        <div class="container text-center">
            <p>&copy; 2023 Online Shop Management System</p>
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 