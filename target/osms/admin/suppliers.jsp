<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="com.osms.model.Supplier" %>
<%@ page import="com.osms.dao.SupplierDAO" %>
<%
    // Check if user is logged in and is an admin
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("Admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get all suppliers from database
    SupplierDAO supplierDAO = new SupplierDAO();
    List<Supplier> suppliersList = null;
    String debugMessage = "";
    try {
        suppliersList = supplierDAO.getAll();
        debugMessage = "SupplierDAO.getAll() returned " + (suppliersList != null ? suppliersList.size() : "null") + " suppliers";
    } catch (Exception e) {
        e.printStackTrace();
        debugMessage = "Error in SupplierDAO.getAll(): " + e.getMessage();
        request.setAttribute("errorMessage", "Error loading suppliers: " + e.getMessage());
    }
    request.setAttribute("suppliers", suppliersList);
    request.setAttribute("debugMessage", debugMessage);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Suppliers - OSMS</title>
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
                        <a class="nav-link" href="products.jsp">Products</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="sellers.jsp">Sellers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="suppliers.jsp">Suppliers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="reports.jsp">Reports</a>
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
        <!-- Debug information - remove in production -->
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <strong>Debug:</strong> ${debugMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        
        <!-- Success message display -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% session.removeAttribute("successMessage"); %>
        </c:if>
        
        <!-- Error message display -->
        <c:if test="${not empty requestScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${requestScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        
        <div class="row mb-4">
            <div class="col-md-8">
                <h2>Manage Suppliers</h2>
            </div>
            <div class="col-md-4 text-end">
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSupplierModal">
                    <i class="fas fa-plus-circle"></i> Add New Supplier
                </button>
            </div>
        </div>

        <!-- Search and Filter Section -->
        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-body">
                        <form class="row g-3">
                            <div class="col-md-5">
                                <input type="text" class="form-control" placeholder="Search suppliers...">
                            </div>
                            <div class="col-md-4">
                                <select class="form-select">
                                    <option selected>All Categories</option>
                                    <option>Electronics</option>
                                    <option>Clothing</option>
                                    <option>Home & Kitchen</option>
                                    <option>Books</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <button type="submit" class="btn btn-primary w-100">Filter</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Suppliers Table -->
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Company Name</th>
                                        <th>Contact Person</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Category</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty suppliers}">
                                            <tr>
                                                <td colspan="8" class="text-center">No suppliers found. Add your first supplier!</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${suppliers}" var="supplier">
                                                <tr>
                                                    <td>${supplier.supplierId}</td>
                                                    <td>${supplier.companyName}</td>
                                                    <td>${supplier.contactPerson}</td>
                                                    <td>${supplier.email}</td>
                                                    <td>${supplier.phone}</td>
                                                    <td>${supplier.category}</td>
                                                    <td>
                                                        <span class="badge bg-${supplier.status eq 'Active' ? 'success' : 'danger'}">
                                                            ${supplier.status}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <button class="btn btn-sm btn-info">
                                                            <i class="fas fa-edit"></i>
                                                        </button>
                                                        <button class="btn btn-sm btn-danger" onclick="confirmDelete(${supplier.supplierId})">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Supplier Modal -->
    <div class="modal fade" id="addSupplierModal" tabindex="-1" aria-labelledby="addSupplierModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addSupplierModalLabel">Add New Supplier</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="addSupplierForm" action="../addSupplier" method="post">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="companyName" class="form-label">Company Name</label>
                                <input type="text" class="form-control" id="companyName" name="companyName" required>
                            </div>
                            <div class="col-md-6">
                                <label for="contactPerson" class="form-label">Contact Person</label>
                                <input type="text" class="form-control" id="contactPerson" name="contactPerson" required>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" name="email" required>
                            </div>
                            <div class="col-md-6">
                                <label for="phone" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="phone" name="phone" required>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label for="address" class="form-label">Address</label>
                                <textarea class="form-control" id="address" name="address" rows="2" required></textarea>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="city" class="form-label">City</label>
                                <input type="text" class="form-control" id="city" name="city" required>
                            </div>
                            <div class="col-md-6">
                                <label for="state" class="form-label">State/Province</label>
                                <input type="text" class="form-control" id="state" name="state" required>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="zipCode" class="form-label">ZIP/Postal Code</label>
                                <input type="text" class="form-control" id="zipCode" name="zipCode" required>
                            </div>
                            <div class="col-md-6">
                                <label for="country" class="form-label">Country</label>
                                <input type="text" class="form-control" id="country" name="country" required>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="category" class="form-label">Main Category</label>
                                <select class="form-select" id="category" name="category" required>
                                    <option value="" selected disabled>Select a category</option>
                                    <option value="Electronics">Electronics</option>
                                    <option value="Clothing">Clothing</option>
                                    <option value="Home & Kitchen">Home & Kitchen</option>
                                    <option value="Books">Books</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="status" class="form-label">Status</label>
                                <select class="form-select" id="status" name="status" required>
                                    <option value="Active" selected>Active</option>
                                    <option value="Inactive">Inactive</option>
                                </select>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="notes" class="form-label">Notes</label>
                            <textarea class="form-control" id="notes" name="notes" rows="3"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" form="addSupplierForm" class="btn btn-primary">Add Supplier</button>
                </div>
            </div>
        </div>
    </div>

    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2023 Online Shop Management System</p>
        </div>
    </footer>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    function confirmDelete(supplierId) {
        if (confirm('Are you sure you want to delete this supplier?')) {
            window.location.href = '../deleteSupplier?supplierId=' + supplierId;
        }
    }
    </script>
</body>
</html> 