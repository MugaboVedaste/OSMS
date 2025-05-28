<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.osms.dao.ProductDAO" %>
<%@ page import="com.osms.model.Product" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    // Check if user is logged in and is a seller
    String userType = (String) session.getAttribute("userType");
    Integer sellerId = (Integer) session.getAttribute("sellerId");
    if (userType == null || !userType.equals("Seller") || sellerId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get all products for this seller
    ProductDAO productDAO = new ProductDAO();
    List<Product> allProducts = productDAO.getBySellerId(sellerId);
    
    // Group products by category
    Map<String, List<Product>> productsByCategory = new HashMap<>();
    for (Product product : allProducts) {
        String category = product.getCategory();
        if (category == null || category.trim().isEmpty()) {
            category = "Uncategorized";
        }
        
        if (!productsByCategory.containsKey(category)) {
            productsByCategory.put(category, new ArrayList<>());
        }
        
        productsByCategory.get(category).add(product);
    }
    
    // Sort categories alphabetically
    List<String> categories = new ArrayList<>(productsByCategory.keySet());
    Collections.sort(categories);
    
    // For formatting prices
    DecimalFormat df = new DecimalFormat("#,##0.00");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Store - Seller</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .product-card {
            height: 100%;
            transition: transform 0.3s;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }
        .product-img-container {
            height: 200px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            background-color: #f8f9fa;
        }
        .product-img {
            max-height: 100%;
            max-width: 100%;
            object-fit: contain;
        }
        .product-status {
            position: absolute;
            top: 10px;
            right: 10px;
            z-index: 10;
        }
        .stock-badge {
            font-size: 0.8rem;
        }
        .category-header {
            border-bottom: 2px solid #dee2e6;
            padding-bottom: 0.5rem;
            margin-top: 2rem;
            margin-bottom: 1.5rem;
        }
    </style>
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
                    <li class="nav-item"><a class="nav-link" href="orders.jsp">Orders</a></li>
                    <li class="nav-item"><a class="nav-link active" href="my_store.jsp">My Store</a></li>
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
            <h2>My Store</h2>
            <a href="my_products.jsp" class="btn btn-primary">
                <i class="fas fa-plus"></i> Add New Products
            </a>
        </div>
        
        <% if (allProducts.isEmpty()) { %>
            <div class="alert alert-info">
                <h4 class="alert-heading">Your store is empty!</h4>
                <p>You haven't added any products to your store yet. Click the button above to start adding products.</p>
            </div>
        <% } else { %>
            <div class="alert alert-info">
                <h4 class="alert-heading">Store Overview</h4>
                <p>You have <%= allProducts.size() %> products in <%= categories.size() %> categories.</p>
                <hr>
                <p class="mb-0">Products are displayed below grouped by category.</p>
            </div>
            
            <% for (String category : categories) { %>
                <div class="category-header">
                    <h3><i class="fas fa-tag me-2"></i><%= category %></h3>
                </div>
                
                <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4 mb-4">
                    <% for (Product product : productsByCategory.get(category)) { %>
                        <div class="col">
                            <div class="card h-100 product-card">
                                <% if (product.getStockQuantity() <= 0) { %>
                                    <div class="product-status">
                                        <span class="badge bg-danger">Out of Stock</span>
                                    </div>
                                <% } else if (product.getStockQuantity() < 5) { %>
                                    <div class="product-status">
                                        <span class="badge bg-warning text-dark">Low Stock</span>
                                    </div>
                                <% } %>
                                
                                <div class="product-img-container">
                                    <% if (product.getImagePath() != null && !product.getImagePath().isEmpty()) { %>
                                        <img src="<%= request.getContextPath() + "/" + product.getImagePath() %>" 
                                             alt="<%= product.getProductName() %>" class="product-img">
                                    <% } else { %>
                                        <img src="<%= request.getContextPath() %>/assets/images/placeholder.png" 
                                             alt="No Image" class="product-img">
                                    <% } %>
                                </div>
                                
                                <div class="card-body">
                                    <h5 class="card-title"><%= product.getProductName() %></h5>
                                    <p class="card-text text-truncate"><%= product.getDescription() != null ? product.getDescription() : "No description available" %></p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="fs-5 fw-bold text-primary">$<%= df.format(product.getPrice()) %></span>
                                        <span class="stock-badge badge bg-secondary">Stock: <%= product.getStockQuantity() %></span>
                                    </div>
                                </div>
                                
                                <div class="card-footer bg-transparent">
                                    <div class="d-grid gap-2">
                                        <a href="edit_product.jsp?id=<%= product.getProductId() %>" class="btn btn-outline-primary btn-sm">
                                            <i class="fas fa-edit"></i> Edit
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        <% } %>
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