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
    
    // Get products for this seller
    ProductDAO productDAO = new ProductDAO();
    List<Product> products = productDAO.getBySellerId(sellerId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Products - Seller</title>
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
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>My Products</h2>
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addProductModal">
                <i class="fas fa-plus"></i> Add New Product
            </button>
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
        
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Product Name</th>
                        <th>Description</th>
                        <th>Price</th>
                        <th>Stock</th>
                        <th>Category</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (products.isEmpty()) { %>
                        <tr>
                            <td colspan="7" class="text-center">No products found. Add your first product!</td>
                        </tr>
                    <% } else { %>
                        <% for (Product product : products) { %>
                            <tr>
                                <td><%= product.getProductId() %></td>
                                <td><%= product.getProductName() %></td>
                                <td><%= product.getDescription() != null ? product.getDescription() : "N/A" %></td>
                                <td>$<%= String.format("%.2f", product.getPrice()) %></td>
                                <td><%= product.getStockQuantity() %></td>
                                <td><%= product.getCategory() != null ? product.getCategory() : "N/A" %></td>
                                <td>
                                    <button class="btn btn-sm btn-primary" onclick="editProduct(<%= product.getProductId() %>)">Edit</button>
                                    <button class="btn btn-sm btn-danger" onclick="deleteProduct(<%= product.getProductId() %>)">Delete</button>
                                </td>
                            </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <!-- Add Product Modal -->
    <div class="modal fade" id="addProductModal" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addProductModalLabel">Add New Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="../addProduct" method="post" enctype="multipart/form-data">
                    <div class="modal-body">
                        <input type="hidden" name="sellerId" value="<%= sellerId %>">
                        
                        <div class="mb-3">
                            <label for="productName" class="form-label">Product Name</label>
                            <input type="text" class="form-control" id="productName" name="productName" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="description" class="form-label">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="price" class="form-label">Price</label>
                                <div class="input-group">
                                    <span class="input-group-text">$</span>
                                    <input type="number" class="form-control" id="price" name="price" step="0.01" min="0" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label for="stockQuantity" class="form-label">Stock Quantity</label>
                                <input type="number" class="form-control" id="stockQuantity" name="stockQuantity" min="0" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="category" class="form-label">Category</label>
                            <select class="form-select" id="category" name="category">
                                <option value="">Select a category</option>
                                <option value="Electronics">Electronics</option>
                                <option value="Clothing">Clothing</option>
                                <option value="Home & Kitchen">Home & Kitchen</option>
                                <option value="Books">Books</option>
                                <option value="Toys & Games">Toys & Games</option>
                                <option value="Beauty & Personal Care">Beauty & Personal Care</option>
                                <option value="Sports & Outdoors">Sports & Outdoors</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="productImage" class="form-label">Product Image</label>
                            <input type="file" class="form-control" id="productImage" name="productImage" accept="image/*">
                            <small class="text-muted">Upload an image of your product (optional)</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Add Product</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Hidden form for delete -->
    <form id="deleteForm" action="../deleteProduct" method="post" style="display: none;">
        <input type="hidden" id="deleteProductId" name="productId">
    </form>
    
    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2025 Online Shop Management System</p>
        </div>
    </footer>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function editProduct(productId) {
            window.location.href = 'edit_product.jsp?id=' + productId;
        }
        
        function deleteProduct(productId) {
            if (confirm('Are you sure you want to delete this product?')) {
                document.getElementById('deleteProductId').value = productId;
                document.getElementById('deleteForm').submit();
            }
        }
    </script>
</body>
</html> 