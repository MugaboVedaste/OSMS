<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.osms.dao.ProductDAO" %>
<%@ page import="com.osms.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    // Check if user is logged in and is a customer
    String userType = (String) session.getAttribute("userType");
    Integer customerId = (Integer) session.getAttribute("userId");
    if (userType == null || !userType.equals("Customer") || customerId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get all products from the database
    ProductDAO productDAO = new ProductDAO();
    List<Product> products = productDAO.getAll();
    
    // Sort by category for better display
    products.sort((p1, p2) -> {
        if (p1.getCategory() == null && p2.getCategory() == null) return 0;
        if (p1.getCategory() == null) return 1;
        if (p2.getCategory() == null) return -1;
        return p1.getCategory().compareTo(p2.getCategory());
    });
    
    // Format for prices
    DecimalFormat df = new DecimalFormat("0.00");
    
    // Get category filter from request parameter (if any)
    String categoryFilter = request.getParameter("category");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shop - Customer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .card-img-top {
            height: 200px;
            object-fit: cover;
        }
        .product-card {
            transition: transform 0.3s;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        .stock-badge {
            position: absolute;
            top: 10px;
            right: 10px;
        }
        .btn-cart, .btn-wishlist {
            width: 48%;
        }
        .cart-count {
            position: relative;
            top: -8px;
            right: 5px;
            background-color: red;
            color: white;
            border-radius: 50%;
            padding: 0.2rem 0.5rem;
            font-size: 0.8rem;
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
                    <li class="nav-item"><a class="nav-link active" href="shop.jsp">Shop</a></li>
                    <li class="nav-item"><a class="nav-link" href="my_orders.jsp">My Orders</a></li>
                    <li class="nav-item"><a class="nav-link" href="wishlist.jsp">Wishlist</a></li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="cart.jsp">
                            <i class="fas fa-shopping-cart"></i> Cart
                            <% 
                                // Get cart items count from session
                                List<Integer> cartItems = (List<Integer>) session.getAttribute("cart");
                                int cartCount = (cartItems != null) ? cartItems.size() : 0;
                                if (cartCount > 0) {
                            %>
                            <span class="cart-count"><%= cartCount %></span>
                            <% } %>
                        </a>
                    </li>
                    <li class="nav-item"><a class="nav-link" href="../logout">Logout</a></li>
                </ul>
            </div>
        </div>
    </nav>
    
    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col-md-6">
                <h2><i class="fas fa-store"></i> Shop Products</h2>
            </div>
            <div class="col-md-6">
                <form class="d-flex" action="shop.jsp" method="get">
                    <select name="category" class="form-select me-2">
                        <option value="">All Categories</option>
                        <% 
                            // Get unique categories
                            List<String> categories = new java.util.ArrayList<>();
                            for (Product p : products) {
                                if (p.getCategory() != null && !categories.contains(p.getCategory())) {
                                    categories.add(p.getCategory());
                                }
                            }
                            java.util.Collections.sort(categories);
                            
                            for (String category : categories) {
                        %>
                        <option value="<%= category %>" <%= category.equals(categoryFilter) ? "selected" : "" %>><%= category %></option>
                        <% } %>
                    </select>
                    <button class="btn btn-outline-primary" type="submit">Filter</button>
                </form>
            </div>
        </div>
        
        <% if (products.isEmpty()) { %>
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i> No products available yet. Please check back later.
            </div>
        <% } else { %>
            <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4">
            <% 
                for (Product product : products) {
                    // Skip if category filter is applied and doesn't match
                    if (categoryFilter != null && !categoryFilter.isEmpty() && 
                        (product.getCategory() == null || !product.getCategory().equals(categoryFilter))) {
                        continue;
                    }
                    
                    // Get stock status
                    String stockStatus = "";
                    String stockBadgeClass = "";
                    if (product.getStockQuantity() <= 0) {
                        stockStatus = "Out of Stock";
                        stockBadgeClass = "bg-danger";
                    } else if (product.getStockQuantity() < 10) {
                        stockStatus = "Low Stock";
                        stockBadgeClass = "bg-warning text-dark";
                    }
            %>
                <div class="col">
                    <div class="card h-100 product-card">
                        <% if (!stockStatus.isEmpty()) { %>
                            <span class="badge <%= stockBadgeClass %> stock-badge"><%= stockStatus %></span>
                        <% } %>
                        
                        <img src="<%= product.getImagePath() != null ? request.getContextPath() + "/" + product.getImagePath() : "https://via.placeholder.com/300x200?text=No+Image" %>" 
                             class="card-img-top" alt="<%= product.getProductName() %>">
                             
                        <div class="card-body">
                            <h5 class="card-title"><%= product.getProductName() %></h5>
                            <p class="card-text text-truncate"><%= product.getDescription() != null ? product.getDescription() : "No description available" %></p>
                            <p class="card-text">
                                <span class="badge bg-info text-dark"><%= product.getCategory() != null ? product.getCategory() : "Uncategorized" %></span>
                            </p>
                            <h5 class="card-text text-primary">$<%= df.format(product.getPrice()) %></h5>
                        </div>
                        <div class="card-footer bg-transparent">
                            <div class="d-flex justify-content-between">
                                <form action="../cart/add" method="post" class="d-inline">
                                    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                    <button type="submit" class="btn btn-primary btn-cart" <%= product.getStockQuantity() <= 0 ? "disabled" : "" %>>
                                        <i class="fas fa-cart-plus"></i> Add to Cart
                                    </button>
                                </form>
                                <form action="../wishlist/add" method="post" class="d-inline">
                                    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                    <button type="submit" class="btn btn-outline-danger btn-wishlist">
                                        <i class="fas fa-heart"></i> Wishlist
                                    </button>
                                </form>
                            </div>
                            <a href="product_details.jsp?id=<%= product.getProductId() %>" class="btn btn-outline-secondary w-100 mt-2">
                                <i class="fas fa-info-circle"></i> View Details
                            </a>
                        </div>
                    </div>
                </div>
            <% } %>
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