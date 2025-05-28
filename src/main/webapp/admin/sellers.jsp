<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="com.osms.model.Seller" %>
<%@ page import="com.osms.dao.SellerDAO" %>
<%@ page import="com.osms.util.DatabaseUtil" %>
<%@ page import="java.sql.Connection" %>
<%
    // Check if user is logged in and is an admin
    String userType = (String) session.getAttribute("userType");
    if (userType == null || !userType.equals("Admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get all sellers from database
    Connection conn = null;
    List<Seller> sellersList = null;
    String debugMessage = "";
    try {
        conn = DatabaseUtil.getConnection();
        SellerDAO sellerDAO = new SellerDAO(conn);
        sellersList = sellerDAO.getAll();
        debugMessage = "SellerDAO.getAll() returned " + (sellersList != null ? sellersList.size() : "null") + " sellers";
    } catch (Exception e) {
        e.printStackTrace();
        debugMessage = "Error in SellerDAO.getAll(): " + e.getMessage();
        request.setAttribute("errorMessage", "Error loading sellers: " + e.getMessage());
    } finally {
        try {
            if (conn != null) conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    request.setAttribute("sellers", sellersList);
    request.setAttribute("debugMessage", debugMessage);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Sellers - OSMS</title>
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
                        <a class="nav-link active" href="sellers.jsp">Sellers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="customers.jsp">Customers</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="suppliers.jsp">Suppliers</a>
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
                <h2>Manage Sellers</h2>
            </div>
            <div class="col-md-4 text-end">
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSellerModal">
                    <i class="fas fa-plus-circle"></i> Add New Seller
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
                                <input type="text" class="form-control" placeholder="Search sellers...">
                            </div>
                            <div class="col-md-4">
                                <select class="form-select">
                                    <option selected>All Status</option>
                                    <option>Active</option>
                                    <option>Inactive</option>
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
        
        <!-- Sellers Table -->
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
                                        <th>Contact Name</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Registration Date</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty sellers}">
                                            <tr>
                                                <td colspan="7" class="text-center">No sellers found. Add your first seller!</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${sellers}" var="seller">
                                                <tr>
                                                    <td>${seller.sellerId}</td>
                                                    <td>${seller.companyName}</td>
                                                    <td>${seller.contactName}</td>
                                                    <td>${seller.email}</td>
                                                    <td>${seller.phone}</td>
                                                    <td><fmt:formatDate value="${seller.joinedDate}" pattern="yyyy-MM-dd" /></td>
                                                    <td>
                                                        <button class="btn btn-sm btn-info">
                                                            <i class="fas fa-edit"></i>
                                                        </button>
                                                        <button class="btn btn-sm btn-danger" onclick="confirmDelete(${seller.sellerId})">
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

    <!-- Add Seller Modal -->
    <div class="modal fade" id="addSellerModal" tabindex="-1" aria-labelledby="addSellerModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addSellerModalLabel">Add New Seller</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="addSellerForm" action="../addSeller" method="post">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="sellerName" class="form-label">Company Name</label>
                                <input type="text" class="form-control" id="sellerName" name="sellerName" required>
                            </div>
                            <div class="col-md-6">
                                <label for="contactName" class="form-label">Contact Name</label>
                                <input type="text" class="form-control" id="contactName" name="contactName" required>
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
                            <div class="col-md-6">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                            </div>
                            <div class="col-md-6">
                                <label for="confirmPassword" class="form-label">Confirm Password</label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label for="address" class="form-label">Address</label>
                                <textarea class="form-control" id="address" name="address" rows="2" required></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" form="addSellerForm" class="btn btn-primary">Add Seller</button>
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
    
    <!-- Validate password confirmation -->
    <script>
        document.getElementById('addSellerForm').addEventListener('submit', function(event) {
            var password = document.getElementById('password').value;
            var confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                event.preventDefault();
                alert('Passwords do not match!');
            }
        });
    </script>
    <script>
    function confirmDelete(sellerId) {
        if (confirm('Are you sure you want to delete this seller?')) {
            window.location.href = '../deleteSeller?sellerId=' + sellerId;
        }
    }
    </script>
</body>
</html> 