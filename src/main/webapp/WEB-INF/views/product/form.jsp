<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.osms.dao.SupplierDAO, com.osms.model.Supplier, java.util.List" %>
<%
    // Get all suppliers for dropdown
    SupplierDAO supplierDAO = new SupplierDAO();
    List<Supplier> suppliers = supplierDAO.getAll();
    
    // Determine if this is an edit (product exists) or add (product is null)
    boolean isEdit = (request.getAttribute("product") != null);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${product != null ? 'Edit' : 'Add'} Product</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="row">
            <div class="col-md-12">
                <h2>${product != null ? 'Edit' : 'Add'} Product</h2>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="<c:url value='/products'/>">Products</a></li>
                        <li class="breadcrumb-item active">${product != null ? 'Edit' : 'Add'} Product</li>
                    </ol>
                </nav>
            </div>
        </div>
        
        <div class="card">
            <div class="card-body">
                <form action="<c:url value='/products/${product != null ? "update" : "insert"}'/>" method="post">
                    <c:if test="${product != null}">
                        <input type="hidden" name="productId" value="${product.productId}" />
                    </c:if>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="productName" class="form-label">Product Name</label>
                            <input type="text" class="form-control" id="productName" name="productName" 
                                   value="${product != null ? product.productName : ''}" required>
                        </div>
                        <div class="col-md-6">
                            <label for="category" class="form-label">Category</label>
                            <select class="form-select" id="category" name="category" required>
                                <option value="" disabled ${product == null ? 'selected' : ''}>Select a category</option>
                                <option value="Electronics" ${product != null && product.category == 'Electronics' ? 'selected' : ''}>Electronics</option>
                                <option value="Clothing" ${product != null && product.category == 'Clothing' ? 'selected' : ''}>Clothing</option>
                                <option value="Home & Kitchen" ${product != null && product.category == 'Home & Kitchen' ? 'selected' : ''}>Home & Kitchen</option>
                                <option value="Books" ${product != null && product.category == 'Books' ? 'selected' : ''}>Books</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label for="price" class="form-label">Price ($)</label>
                            <input type="number" step="0.01" class="form-control" id="price" name="price" 
                                   value="${product != null ? product.price : '0.00'}" required>
                        </div>
                        <div class="col-md-4">
                            <label for="stockQuantity" class="form-label">Stock Quantity</label>
                            <input type="number" class="form-control" id="stockQuantity" name="stockQuantity" 
                                   value="${product != null ? product.stockQuantity : '0'}" required>
                        </div>
                        <div class="col-md-4">
                            <label for="supplierId" class="form-label">Supplier</label>
                            <select class="form-select" id="supplierId" name="supplierId" required>
                                <option value="" disabled ${product == null ? 'selected' : ''}>Select a supplier</option>
                                <% for (Supplier supplier : suppliers) { %>
                                    <option value="<%= supplier.getSupplierId() %>" 
                                        ${product != null && product.supplierId == <%= supplier.getSupplierId() %> ? 'selected' : ''}>
                                        <%= supplier.getCompanyName() %>
                                    </option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" required>${product != null ? product.description : ''}</textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label for="expirationDate" class="form-label">Expiration Date</label>
                        <input type="date" class="form-control" id="expirationDate" name="expirationDate" 
                               value="${product != null && product.expirationDate != null ? product.expirationDate : ''}">
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="<c:url value='/products'/>" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${product != null ? 'Update' : 'Save'} Product
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2023 Online Shop Management System</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 