<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
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
    
    // Get cart items from session
    Map<Integer, Integer> cartItems = (Map<Integer, Integer>) session.getAttribute("cartItems");
    if (cartItems == null || cartItems.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=Your+cart+is+empty");
        return;
    }
    
    // Get product information for each cart item
    ProductDAO productDAO = new ProductDAO();
    List<Product> cartProducts = new ArrayList<>();
    double subtotal = 0;
    double shipping = 5.00; // Fixed shipping cost
    
    // Format for prices
    DecimalFormat df = new DecimalFormat("0.00");
    
    // Process cart to get products and calculate total
    for (Map.Entry<Integer, Integer> entry : cartItems.entrySet()) {
        int productId = entry.getKey();
        int quantity = entry.getValue();
        
        Product product = productDAO.getById(productId);
        if (product != null) {
            cartProducts.add(product);
            subtotal += product.getPrice() * quantity;
        }
    }
    
    double total = subtotal + shipping;
    
    // Check for error message
    String errorMsg = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Checkout - Customer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .product-image {
            width: 60px;
            height: 60px;
            object-fit: cover;
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
                    <li class="nav-item"><a class="nav-link" href="wishlist.jsp">Wishlist</a></li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="cart.jsp">
                            <i class="fas fa-shopping-cart"></i> Cart
                            <% 
                                // Get cart items count
                                int cartCount = cartItems.size();
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
        <div class="row">
            <div class="col-md-8">
                <h2><i class="fas fa-credit-card"></i> Checkout</h2>
                
                <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                
                <div class="card mt-3">
                    <div class="card-header bg-light">
                        <h5 class="mb-0">Order Summary</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Product</th>
                                        <th>Price</th>
                                        <th>Quantity</th>
                                        <th class="text-end">Subtotal</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Product product : cartProducts) { 
                                        int quantity = cartItems.get(product.getProductId());
                                        double itemSubtotal = product.getPrice() * quantity;
                                    %>
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <img src="<%= product.getImagePath() != null ? request.getContextPath() + "/" + product.getImagePath() : "https://via.placeholder.com/60x60?text=No+Image" %>" 
                                                     class="product-image me-2" alt="<%= product.getProductName() %>">
                                                <div>
                                                    <%= product.getProductName() %>
                                                    <div class="small text-muted"><%= product.getCategory() != null ? product.getCategory() : "Uncategorized" %></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>$<%= df.format(product.getPrice()) %></td>
                                        <td><%= quantity %></td>
                                        <td class="text-end">$<%= df.format(itemSubtotal) %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <div class="card mt-4">
                    <div class="card-header bg-light">
                        <h5 class="mb-0">Shipping Information</h5>
                    </div>
                    <div class="card-body">
                        <form id="shippingForm" action="../checkout" method="post">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="firstName" class="form-label">First Name</label>
                                    <input type="text" class="form-control" id="firstName" name="firstName" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="lastName" class="form-label">Last Name</label>
                                    <input type="text" class="form-control" id="lastName" name="lastName" required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="address" class="form-label">Street Address</label>
                                <input type="text" class="form-control" id="address" name="address" required>
                            </div>
                            
                            <div class="mb-3">
                                <label for="apartment" class="form-label">Apartment/Suite/Unit (Optional)</label>
                                <input type="text" class="form-control" id="apartment" name="apartment">
                            </div>
                            
                            <div class="row">
                                <div class="col-md-5 mb-3">
                                    <label for="city" class="form-label">City</label>
                                    <input type="text" class="form-control" id="city" name="city" required>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label for="state" class="form-label">State</label>
                                    <input type="text" class="form-control" id="state" name="state" required>
                                </div>
                                <div class="col-md-3 mb-3">
                                    <label for="zipCode" class="form-label">Zip Code</label>
                                    <input type="text" class="form-control" id="zipCode" name="zipCode" required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="phone" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="phone" name="phone" required>
                            </div>
                        </form>
                    </div>
                </div>
                
                <div class="card mt-4">
                    <div class="card-header bg-light">
                        <h5 class="mb-0">Payment Method</h5>
                    </div>
                    <div class="card-body">
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="radio" name="paymentMethod" id="paymentCOD" value="cod" checked>
                            <label class="form-check-label" for="paymentCOD">
                                <i class="fas fa-money-bill-wave me-2"></i> Cash on Delivery
                            </label>
                        </div>
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="radio" name="paymentMethod" id="paymentCard" value="card">
                            <label class="form-check-label" for="paymentCard">
                                <i class="fas fa-credit-card me-2"></i> Credit/Debit Card (disabled)
                            </label>
                            <div class="form-text text-muted">Card payment option is currently unavailable</div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card mt-5 sticky-top" style="top: 20px;">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0">Order Total</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Subtotal:</span>
                            <span>$<%= df.format(subtotal) %></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Shipping:</span>
                            <span>$<%= df.format(shipping) %></span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between mb-3 fw-bold">
                            <span>Total:</span>
                            <span>$<%= df.format(total) %></span>
                        </div>
                        
                        <button type="submit" form="shippingForm" class="btn btn-primary w-100 btn-lg">
                            <i class="fas fa-check-circle me-2"></i> Place Order
                        </button>
                        
                        <div class="d-flex justify-content-between mt-3">
                            <a href="cart.jsp" class="btn btn-outline-secondary">
                                <i class="fas fa-arrow-left"></i> Back to Cart
                            </a>
                            <a href="shop.jsp" class="btn btn-outline-primary">
                                <i class="fas fa-shopping-bag"></i> Continue Shopping
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <footer class="mt-5 py-3 bg-light">
        <div class="container text-center">
            <p>&copy; 2025 Online Shop Management System</p>
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 