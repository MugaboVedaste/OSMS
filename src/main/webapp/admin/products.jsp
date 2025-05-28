<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.osms.dao.ProductDAO, com.osms.model.Product, java.util.List, java.text.DecimalFormat" %>
<%@ page import="com.osms.dao.SupplierDAO, com.osms.model.Supplier" %>
<%
    // Check if user is logged in and is an admin
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("Admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get all products
    ProductDAO productDAO = new ProductDAO();
    List<Product> products = productDAO.getAll();
    
    // Get all suppliers for dropdown
    SupplierDAO supplierDAO = new SupplierDAO();
    List<Supplier> suppliers = supplierDAO.getAll();
    
    // Format for currency
    DecimalFormat df = new DecimalFormat("#,##0.00");
    
    // Get messages from session if any
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    
    // Clear messages after retrieving them
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Products - OSMS</title>
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
            <a class="navbar-brand" href="#">OSMS Admin</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="products.jsp">Products</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="sellers.jsp">Sellers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="suppliers.jsp">Suppliers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="reports.jsp">Reports</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="product_audit.jsp">Product Audit</a>
                    </li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="../logout">Logout</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col-md-8">
                <h2>Manage Products</h2>
            </div>
            <div class="col-md-4 text-end">
                <p class="alert alert-info mb-0">
                    <i class="fas fa-info-circle"></i> Admins can only edit or delete products
                </p>
            </div>
        </div>

        <!-- Search and Filter Section -->
        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-body">
                        <form class="row g-3">
                            <div class="col-md-4">
                                <input type="text" class="form-control" placeholder="Search products...">
                            </div>
                            <div class="col-md-3">
                                <select class="form-select">
                                    <option selected>All Categories</option>
                                    <option>Electronics</option>
                                    <option>Clothing</option>
                                    <option>Home & Kitchen</option>
                                    <option>Books</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <select class="form-select">
                                    <option selected>All Status</option>
                                    <option>In Stock</option>
                                    <option>Low Stock</option>
                                    <option>Out of Stock</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <button type="submit" class="btn btn-primary w-100">Filter</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Products Table -->
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-body">
                        <% if (successMessage != null && !successMessage.isEmpty()) { %>
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <%= successMessage %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>
                        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <%= errorMessage %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Image</th>
                                        <th>Product Name</th>
                                        <th>Category</th>
                                        <th>Price</th>
                                        <th>Stock</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (products.size() > 0) { %>
                                        <% for (Product product : products) { %>
                                            <tr>
                                                <td><%= product.getProductId() %></td>
                                                <td><img src="../img/products/default.jpg" alt="<%= product.getProductName() %>" width="50" height="50"></td>
                                                <td><%= product.getProductName() %></td>
                                                <td><%= product.getCategory() %></td>
                                                <td>$<%= df.format(product.getPrice()) %></td>
                                                <td><%= product.getStockQuantity() %></td>
                                                <td>
                                                    <% if (product.getStockQuantity() <= 0) { %>
                                                        <span class="badge bg-danger">Out of Stock</span>
                                                    <% } else if (product.getStockQuantity() < 10) { %>
                                                        <span class="badge bg-warning">Low Stock</span>
                                                    <% } else { %>
                                                        <span class="badge bg-success">In Stock</span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <div class="btn-group">
                                                        <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#editProductModal" 
                                                            data-product-id="<%= product.getProductId() %>"
                                                            data-product-name="<%= product.getProductName() %>"
                                                            data-description="<%= product.getDescription() %>"
                                                            data-price="<%= product.getPrice() %>"
                                                            data-stock="<%= product.getStockQuantity() %>"
                                                            data-category="<%= product.getCategory() %>"
                                                            data-supplier-id="<%= product.getSupplierId() %>"
                                                            data-expiration-date="<%= product.getExpirationDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(product.getExpirationDate()) : "" %>"
                                                        >
                                                            <i class="fas fa-edit"></i>
                                                        </button>
                                                        <button type="button" class="btn btn-sm btn-danger" onclick="confirmDelete(<%= product.getProductId() %>)">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    <% } else { %>
                                        <tr>
                                            <td colspan="8" class="text-center">No products found. Add your first product!</td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Product Modal -->
    <div class="modal fade" id="editProductModal" tabindex="-1" aria-labelledby="editProductModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editProductModalLabel">Edit Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editProductForm" action="../updateProduct" method="post" enctype="multipart/form-data">
                        <input type="hidden" id="editProductId" name="productId">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="editProductName" class="form-label">Product Name</label>
                                <input type="text" class="form-control" id="editProductName" name="productName" required>
                            </div>
                            <div class="col-md-6">
                                <label for="editCategory" class="form-label">Category</label>
                                <select class="form-select" id="editCategory" name="category" required>
                                    <option value="" selected disabled>Select a category</option>
                                    <option value="Electronics">Electronics</option>
                                    <option value="Clothing">Clothing</option>
                                    <option value="Home & Kitchen">Home & Kitchen</option>
                                    <option value="Books">Books</option>
                                </select>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label for="editPrice" class="form-label">Price ($)</label>
                                <input type="number" step="0.01" class="form-control" id="editPrice" name="price" required>
                            </div>
                            <div class="col-md-4">
                                <label for="editStockQuantity" class="form-label">Stock Quantity</label>
                                <input type="number" class="form-control" id="editStockQuantity" name="stockQuantity" required>
                            </div>
                            <div class="col-md-4">
                                <label for="editSupplierId" class="form-label">Supplier</label>
                                <select class="form-select" id="editSupplierId" name="supplierId" required>
                                    <option value="" selected disabled>Select a supplier</option>
                                    <% for (Supplier supplier : suppliers) { %>
                                        <option value="<%= supplier.getSupplierId() %>"><%= supplier.getCompanyName() %></option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="editDescription" class="form-label">Description</label>
                            <textarea class="form-control" id="editDescription" name="description" rows="3" required></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="editExpirationDate" class="form-label">Expiration Date</label>
                            <input type="date" class="form-control" id="editExpirationDate" name="expirationDate">
                        </div>
                        <div class="mb-3">
                            <label for="editProductImage" class="form-label">Product Image</label>
                            <input type="file" class="form-control" id="editProductImage" name="productImage">
                            <small class="form-text text-muted">Leave empty to keep the current image.</small>
                        </div>
                        <div class="mb-3">
                            <label for="updateReason" class="form-label">Reason for Update</label>
                            <textarea class="form-control" id="updateReason" name="updateReason" rows="2" required placeholder="Please provide a reason for this update (required for audit purposes)"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" form="editProductForm" class="btn btn-primary">Update Product</button>
                </div>
            </div>
        </div>
    </div>

    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2025 Online Shop Management System</p>
        </div>
    </footer>

    <!-- Add Delete Product Modal -->
    <div class="modal fade" id="deleteProductModal" tabindex="-1" aria-labelledby="deleteProductModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteProductModalLabel">Confirm Delete Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="deleteProductForm" action="../deleteProduct" method="post">
                        <input type="hidden" id="deleteProductId" name="productId">
                        <p>Are you sure you want to delete this product? This action cannot be undone.</p>
                        <div class="mb-3">
                            <label for="deleteReason" class="form-label">Reason for Deletion</label>
                            <textarea class="form-control" id="deleteReason" name="deleteReason" rows="2" required placeholder="Please provide a reason for deleting this product (required for audit purposes)"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" form="deleteProductForm" class="btn btn-danger">Delete Product</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function confirmDelete(productId) {
            // Set the product ID in the delete form
            document.getElementById('deleteProductId').value = productId;
            
            // Show the delete confirmation modal
            var deleteModal = new bootstrap.Modal(document.getElementById('deleteProductModal'));
            deleteModal.show();
        }
        
        // Handle populating the edit modal with product data
        document.addEventListener('DOMContentLoaded', function() {
            var editProductModal = document.getElementById('editProductModal');
            if (editProductModal) {
                editProductModal.addEventListener('show.bs.modal', function(event) {
                    // Button that triggered the modal
                    var button = event.relatedTarget;
                    
                    // Extract data attributes
                    var productId = button.getAttribute('data-product-id');
                    var productName = button.getAttribute('data-product-name');
                    var description = button.getAttribute('data-description');
                    var price = button.getAttribute('data-price');
                    var stock = button.getAttribute('data-stock');
                    var category = button.getAttribute('data-category');
                    var supplierId = button.getAttribute('data-supplier-id');
                    var expirationDate = button.getAttribute('data-expiration-date');
                    
                    // Populate the form fields
                    var modal = this;
                    modal.querySelector('#editProductId').value = productId;
                    modal.querySelector('#editProductName').value = productName;
                    modal.querySelector('#editDescription').value = description;
                    modal.querySelector('#editPrice').value = price;
                    modal.querySelector('#editStockQuantity').value = stock;
                    
                    // Set the category dropdown
                    var categorySelect = modal.querySelector('#editCategory');
                    for (var i = 0; i < categorySelect.options.length; i++) {
                        if (categorySelect.options[i].value === category) {
                            categorySelect.options[i].selected = true;
                            break;
                        }
                    }
                    
                    // Set the supplier dropdown
                    if (supplierId) {
                        var supplierSelect = modal.querySelector('#editSupplierId');
                        for (var i = 0; i < supplierSelect.options.length; i++) {
                            if (supplierSelect.options[i].value === supplierId) {
                                supplierSelect.options[i].selected = true;
                                break;
                            }
                        }
                    }
                    
                    // Set the expiration date
                    if (expirationDate) {
                        var expirationDateInput = modal.querySelector('#editExpirationDate');
                        expirationDateInput.value = expirationDate;
                    }
                });
            }
        });
    </script>
</body>
</html> 