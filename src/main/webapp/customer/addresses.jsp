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
    <title>My Addresses - OSMS</title>
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
            <a class="navbar-brand" href="dashboard.jsp">OSMS Customer</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="dashboard.jsp">Dashboard</a>
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
                            <li><a class="dropdown-item active" href="addresses.jsp">My Addresses</a></li>
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
            <div class="col-md-3">
                <div class="card">
                    <div class="card-header bg-light">
                        <h5 class="mb-0">Account</h5>
                    </div>
                    <div class="list-group list-group-flush">
                        <a href="profile.jsp" class="list-group-item list-group-item-action">Profile</a>
                        <a href="addresses.jsp" class="list-group-item list-group-item-action active">Addresses</a>
                        <a href="my_orders.jsp" class="list-group-item list-group-item-action">Orders</a>
                        <a href="wishlist.jsp" class="list-group-item list-group-item-action">Wishlist</a>
                    </div>
                </div>
            </div>
            <div class="col-md-9">
                <div class="card">
                    <div class="card-header bg-light d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">My Addresses</h5>
                        <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                            <i class="fas fa-plus"></i> Add New Address
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="alert alert-info">
                            You don't have any saved addresses yet. Please add an address.
                        </div>
                        
                        <div class="row d-none">
                            <!-- Address cards will appear here -->
                            <div class="col-md-6 mb-3">
                                <div class="card h-100">
                                    <div class="card-body">
                                        <h6>Home</h6>
                                        <p class="mb-1">John Doe</p>
                                        <p class="mb-1">123 Main Street</p>
                                        <p class="mb-1">Apt 4B</p>
                                        <p class="mb-1">New York, NY 10001</p>
                                        <p class="mb-1">United States</p>
                                        <p class="mb-1">Phone: (123) 456-7890</p>
                                        
                                        <div class="mt-3">
                                            <span class="badge bg-primary">Default</span>
                                        </div>
                                    </div>
                                    <div class="card-footer bg-white border-top-0">
                                        <div class="d-flex justify-content-between">
                                            <button class="btn btn-sm btn-outline-primary">Edit</button>
                                            <button class="btn btn-sm btn-outline-danger">Delete</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Address Modal -->
    <div class="modal fade" id="addAddressModal" tabindex="-1" aria-labelledby="addAddressModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addAddressModalLabel">Add New Address</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="addressForm">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="addressName" class="form-label">Address Name</label>
                                <input type="text" class="form-control" id="addressName" name="addressName" placeholder="Home, Work, etc.">
                            </div>
                            <div class="col-md-6">
                                <label for="fullName" class="form-label">Full Name</label>
                                <input type="text" class="form-control" id="fullName" name="fullName">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="streetAddress" class="form-label">Street Address</label>
                            <input type="text" class="form-control" id="streetAddress" name="streetAddress">
                        </div>
                        
                        <div class="mb-3">
                            <label for="apartment" class="form-label">Apartment, Suite, etc. (optional)</label>
                            <input type="text" class="form-control" id="apartment" name="apartment">
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label for="city" class="form-label">City</label>
                                <input type="text" class="form-control" id="city" name="city">
                            </div>
                            <div class="col-md-4">
                                <label for="state" class="form-label">State</label>
                                <input type="text" class="form-control" id="state" name="state">
                            </div>
                            <div class="col-md-4">
                                <label for="zipCode" class="form-label">Zip Code</label>
                                <input type="text" class="form-control" id="zipCode" name="zipCode">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="country" class="form-label">Country</label>
                            <select class="form-select" id="country" name="country">
                                <option value="US">United States</option>
                                <option value="CA">Canada</option>
                                <option value="UK">United Kingdom</option>
                                <!-- More options would be here -->
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="phone" class="form-label">Phone Number</label>
                            <input type="text" class="form-control" id="phone" name="phone">
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="defaultAddress" name="defaultAddress">
                            <label class="form-check-label" for="defaultAddress">Set as default address</label>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveAddressBtn">Save Address</button>
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
    
    <script>
        // Simple form handling
        document.getElementById('saveAddressBtn').addEventListener('click', function() {
            // Here would be the form validation and ajax submission
            // For now just close the modal
            var modal = bootstrap.Modal.getInstance(document.getElementById('addAddressModal'));
            modal.hide();
            
            // Show success message or update UI as needed
            alert('Address saved successfully!');
        });
    </script>
</body>
</html> 