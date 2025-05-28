<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Check if user is logged in and is a customer
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("Customer")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - OSMS</title>
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
            <a class="navbar-brand" href="#">OSMS Customer</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="shop.jsp">Shop</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="my_orders.jsp">My Orders</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="wishlist.jsp">Wishlist</a>
                    </li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="cart.jsp">
                            <i class="fas fa-shopping-cart"></i> Cart <span class="badge bg-danger">0</span>
                        </a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            ${sessionScope.username}
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
                            <li><a class="dropdown-item" href="profile.jsp">My Profile</a></li>
                            <li><a class="dropdown-item" href="addresses.jsp">My Addresses</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="../logout">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row">
            <div class="col-md-12">
                <h2>Welcome, ${sessionScope.username}!</h2>
                <p>Manage your orders and explore products.</p>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card dashboard-card orders">
                    <div class="card-body text-center">
                        <i class="fas fa-shopping-bag fa-3x mb-3"></i>
                        <h5 class="card-title">My Orders</h5>
                        <p class="card-value">${requestScope.orderCount}</p>
                        <p class="card-text">View your orders</p>
                        <a href="my_orders.jsp" class="btn btn-primary">View Orders</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card dashboard-card">
                    <div class="card-body text-center">
                        <i class="fas fa-heart fa-3x mb-3"></i>
                        <h5 class="card-title">Wishlist</h5>
                        <p class="card-value">${requestScope.wishlistCount}</p>
                        <p class="card-text">Items in your wishlist</p>
                        <a href="wishlist.jsp" class="btn btn-primary">View Wishlist</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card dashboard-card">
                    <div class="card-body text-center">
                        <i class="fas fa-gifts fa-3x mb-3"></i>
                        <h5 class="card-title">Shop</h5>
                        <p class="card-value"><i class="fas fa-tag"></i></p>
                        <p class="card-text">Explore products</p>
                        <a href="shop.jsp" class="btn btn-primary">Start Shopping</a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h5>Recent Orders</h5>
                    </div>
                    <div class="card-body">
                        <p>No recent orders found.</p>
                        <table class="table table-striped d-none">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Date</th>
                                    <th>Total</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Data will be populated dynamically -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5>Account Details</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <strong>Username:</strong> ${sessionScope.username}
                        </div>
                        <div class="mb-3">
                            <strong>Email:</strong> <span class="text-muted">Not available</span>
                        </div>
                        <div class="mb-3">
                            <strong>Member Since:</strong> <span class="text-muted">Not available</span>
                        </div>
                        <div class="d-grid gap-2">
                            <a href="profile.jsp" class="btn btn-outline-primary">Edit Profile</a>
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
</body>
</html> 