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
    if (cartItems == null) {
        cartItems = new HashMap<>();
        session.setAttribute("cartItems", cartItems);
    }
    
    // Get product information for each cart item
    ProductDAO productDAO = new ProductDAO();
    List<Product> cartProducts = new ArrayList<>();
    double totalAmount = 0;
    
    // Format for prices
    DecimalFormat df = new DecimalFormat("0.00");
    
    // Process cart to get products and calculate total
    for (Map.Entry<Integer, Integer> entry : cartItems.entrySet()) {
        int productId = entry.getKey();
        int quantity = entry.getValue();
        
        Product product = productDAO.getById(productId);
        if (product != null) {
            cartProducts.add(product);
            totalAmount += product.getPrice() * quantity;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - OSMS</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="../css/style.css" rel="stylesheet">
    <style>
        .quantity-input {
            width: 80px;
        }
        .product-image {
            height: 100px;
            object-fit: cover;
        }
    </style>
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
                        <a class="nav-link active" href="cart.jsp">
                            <i class="fas fa-shopping-cart"></i> Cart
                            <% 
                                // Get cart items count
                                int cartCount = cartItems.size();
                                if (cartCount > 0) {
                            %>
                            <span class="position-relative top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                <%= cartCount %>
                            </span>
                            <% } %>
                        </a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            ${sessionScope.username}
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
                            <li><a class="dropdown-item" href="profile.jsp">My Profile</a></li>
                            <li><a class="dropdown-item" href="addresses.jsp">My Addresses</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="../logout">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h2><i class="fas fa-shopping-cart"></i> Shopping Cart</h2>
        
        <% if (cartProducts.isEmpty()) { %>
            <div class="alert alert-info mt-3">
                <i class="fas fa-info-circle"></i> Your shopping cart is empty. 
                <a href="shop.jsp" class="alert-link">Browse products</a> to add items to your cart.
            </div>
        <% } else { %>
            <div class="card mt-3">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th scope="col">Product</th>
                                    <th scope="col">Price</th>
                                    <th scope="col">Quantity</th>
                                    <th scope="col">Subtotal</th>
                                    <th scope="col">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Product product : cartProducts) { 
                                    int quantity = cartItems.get(product.getProductId());
                                    double subtotal = product.getPrice() * quantity;
                                %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <img src="<%= product.getImagePath() != null ? request.getContextPath() + "/" + product.getImagePath() : "https://via.placeholder.com/300x200?text=No+Image" %>"
                                                alt="<%= product.getProductName() %>" class="me-3 product-image">
                                            <div>
                                                <h6 class="mb-0"><%= product.getProductName() %></h6>
                                                <small class="text-muted">Category: <%= product.getCategory() != null ? product.getCategory() : "Uncategorized" %></small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>$<%= df.format(product.getPrice()) %></td>
                                    <td>
                                        <form action="../cart/update" method="post" class="d-flex">
                                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                            <input type="number" name="quantity" value="<%= quantity %>" min="1" max="<%= product.getStockQuantity() %>" 
                                                class="form-control quantity-input me-2">
                                            <button type="submit" class="btn btn-sm btn-outline-primary">
                                                <i class="fas fa-sync-alt"></i>
                                            </button>
                                        </form>
                                    </td>
                                    <td>$<%= df.format(subtotal) %></td>
                                    <td>
                                        <a href="../cart/remove?productId=<%= product.getProductId() %>" class="btn btn-sm btn-outline-danger">
                                            <i class="fas fa-trash"></i> Remove
                                        </a>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="3" class="text-end fw-bold">Total:</td>
                                    <td class="fw-bold">$<%= df.format(totalAmount) %></td>
                                    <td></td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
                <div class="card-footer d-flex justify-content-between">
                    <a href="shop.jsp" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left"></i> Continue Shopping
                    </a>
                    <div>
                        <a href="../cart/clear" class="btn btn-outline-danger me-2">
                            <i class="fas fa-trash"></i> Clear Cart
                        </a>
                        <a href="checkout.jsp" class="btn btn-success">
                            <i class="fas fa-credit-card"></i> Proceed to Checkout
                        </a>
                    </div>
                </div>
            </div>
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