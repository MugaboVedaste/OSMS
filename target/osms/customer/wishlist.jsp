<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.osms.dao.ProductDAO" %>
<%@ page import="com.osms.model.Product" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    // Check if user is logged in and is a customer
    String userType = (String) session.getAttribute("userType");
    Integer customerId = (Integer) session.getAttribute("userId");
    if (userType == null || !userType.equals("Customer") || customerId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get wishlist from session
    List<Integer> wishlist = (List<Integer>) session.getAttribute("wishlist");
    if (wishlist == null) {
        wishlist = new ArrayList<>();
        session.setAttribute("wishlist", wishlist);
    }
    
    // Get product information for each wishlist item
    ProductDAO productDAO = new ProductDAO();
    List<Product> wishlistProducts = new ArrayList<>();
    
    // Format for prices
    DecimalFormat df = new DecimalFormat("0.00");
    
    // Process wishlist to get products
    for (Integer productId : wishlist) {
        Product product = productDAO.getById(productId);
        if (product != null) {
            wishlistProducts.add(product);
        }
    }
    
    // Check for message parameters
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Wishlist - Customer</title>
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
                    <li class="nav-item"><a class="nav-link" href="my_orders.jsp">My Orders</a></li>
                    <li class="nav-item"><a class="nav-link active" href="wishlist.jsp">Wishlist</a></li>
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
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-heart text-danger"></i> My Wishlist</h2>
            <% if (!wishlistProducts.isEmpty()) { %>
                <a href="../wishlist/clear" class="btn btn-outline-danger">
                    <i class="fas fa-trash"></i> Clear Wishlist
                </a>
            <% } %>
        </div>
        
        <% if (successMsg != null && !successMsg.isEmpty()) { %>
            <div class="alert alert-success alert-dismissible fade show">
                <i class="fas fa-check-circle"></i> <%= successMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        
        <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
            <div class="alert alert-danger alert-dismissible fade show">
                <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        
        <% if (wishlistProducts.isEmpty()) { %>
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i> Your wishlist is empty. 
                <a href="shop.jsp" class="alert-link">Browse products</a> to add items to your wishlist.
            </div>
        <% } else { %>
            <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4">
            <% 
                for (Product product : wishlistProducts) {
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
                            <h5 class="card-text text-primary">$<%= df.format(product.getPrice()) %></h5>
                            <p class="card-text">
                                <span class="badge bg-info text-dark"><%= product.getCategory() != null ? product.getCategory() : "Uncategorized" %></span>
                                <% if (product.getStockQuantity() > 0) { %>
                                    <span class="badge bg-success">In Stock: <%= product.getStockQuantity() %></span>
                                <% } %>
                            </p>
                        </div>
                        <div class="card-footer bg-transparent">
                            <div class="d-flex justify-content-between">
                                <a href="../wishlist/moveToCart?productId=<%= product.getProductId() %>" class="btn btn-primary btn-cart <%= product.getStockQuantity() <= 0 ? "disabled" : "" %>">
                                    <i class="fas fa-cart-plus"></i> Add to Cart
                                </a>
                                <a href="../wishlist/remove?productId=<%= product.getProductId() %>" class="btn btn-outline-danger btn-wishlist">
                                    <i class="fas fa-trash"></i> Remove
                                </a>
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