<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.osms.dao.ProductDAO" %>
<%@ page import="com.osms.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="com.osms.util.DatabaseUtil" %>
<%
    // Check if user is logged in and is a seller
    String userType = (String) session.getAttribute("userType");
    Integer sellerId = (Integer) session.getAttribute("sellerId");
    if (userType == null || !userType.equals("Seller") || sellerId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get the product ID from the request
    String productIdParam = request.getParameter("id");
    if (productIdParam == null || productIdParam.isEmpty()) {
        response.sendRedirect("my_products.jsp");
        return;
    }
    
    int productId = 0;
    try {
        productId = Integer.parseInt(productIdParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("my_products.jsp");
        return;
    }
    
    // Get the product details
    ProductDAO productDAO = new ProductDAO();
    Product product = productDAO.getById(productId);
    
    // Verify that the product belongs to this seller
    if (product == null || product.getSellerId() != sellerId) {
        response.sendRedirect("my_products.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product - Seller</title>
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
                    <li class="nav-item"><a class="nav-link active" href="my_products.jsp">My Products</a></li>
                    <li class="nav-item"><a class="nav-link" href="orders.jsp">Orders</a></li>
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
        <h2>Edit Product</h2>
        
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
        
        <div class="card">
            <div class="card-body">
                <form action="../updateProduct" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                    <input type="hidden" name="sellerId" value="<%= sellerId %>">
                    
                    <div class="mb-3">
                        <label for="productName" class="form-label">Product Name</label>
                        <input type="text" class="form-control" id="productName" name="productName" value="<%= product.getProductName() %>" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="price" class="form-label">Price</label>
                            <div class="input-group">
                                <span class="input-group-text">$</span>
                                <input type="number" class="form-control" id="price" name="price" step="0.01" min="0" value="<%= product.getPrice() %>" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label for="stockQuantity" class="form-label">Stock Quantity</label>
                            <input type="number" class="form-control" id="stockQuantity" name="stockQuantity" min="0" value="<%= product.getStockQuantity() %>" required>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="category" class="form-label">Category</label>
                        <select class="form-select" id="category" name="category">
                            <option value="">Select a category</option>
                            <option value="Electronics" <%= "Electronics".equals(product.getCategory()) ? "selected" : "" %>>Electronics</option>
                            <option value="Clothing" <%= "Clothing".equals(product.getCategory()) ? "selected" : "" %>>Clothing</option>
                            <option value="Home & Kitchen" <%= "Home & Kitchen".equals(product.getCategory()) ? "selected" : "" %>>Home & Kitchen</option>
                            <option value="Books" <%= "Books".equals(product.getCategory()) ? "selected" : "" %>>Books</option>
                            <option value="Toys & Games" <%= "Toys & Games".equals(product.getCategory()) ? "selected" : "" %>>Toys & Games</option>
                            <option value="Beauty & Personal Care" <%= "Beauty & Personal Care".equals(product.getCategory()) ? "selected" : "" %>>Beauty & Personal Care</option>
                            <option value="Sports & Outdoors" <%= "Sports & Outdoors".equals(product.getCategory()) ? "selected" : "" %>>Sports & Outdoors</option>
                            <option value="Other" <%= "Other".equals(product.getCategory()) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>
                    
                    <div class="mb-3">
                        <label for="productImage" class="form-label">Product Image</label>
                        <input type="file" class="form-control" id="productImage" name="productImage" accept="image/*">
                        <small class="text-muted">Upload a new image to replace the current one (optional)</small>
                        
                        <% if (product.getImagePath() != null && !product.getImagePath().isEmpty()) { %>
                            <div class="mt-2">
                                <p>Current image:</p>
                                <img src="<%= request.getContextPath() + "/" + product.getImagePath() %>" alt="Product Image" style="max-width: 200px; max-height: 200px;" class="img-thumbnail">
                            </div>
                        <% } %>
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="my_products.jsp" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Update Product</button>
                    </div>
                </form>
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