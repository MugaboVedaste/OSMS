<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Details - OSMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
     <style>
        .product-image {
            max-width: 100%;
            height: auto;
            border: 1px solid #ddd;
            padding: 10px;
            border-radius: 5px;
        }
     </style>
</head>
<body>
    <div class="container mt-4">
        <c:if test="${product == null}">
            <div class="alert alert-danger">Product not found.</div>
        </c:if>
        <c:if test="${product != null}">
            <h2>${product.productName}</h2>
            <div class="row">
                <div class="col-md-6">
                    <img src="${product.imagePath != null ? request.getContextPath() + '/' + product.imagePath : 'https://via.placeholder.com/400x300?text=No+Image'}" 
                         class="product-image" alt="${product.productName}">
                </div>
                <div class="col-md-6">
                    <h3>$${product.price}</h3>
                    <p><strong>Category:</strong> ${product.category != null ? product.category : 'Uncategorized'}</p>
                    <p><strong>Stock:</strong> 
                        <c:choose>
                            <c:when test="${product.stockQuantity <= 0}">
                                <span class="badge bg-danger">Out of Stock</span>
                            </c:when>
                            <c:when test="${product.stockQuantity < 10}">
                                <span class="badge bg-warning text-dark">Low Stock (${product.stockQuantity})</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-success">In Stock (${product.stockQuantity})</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <p><strong>Description:</strong> ${product.description != null ? product.description : 'No description available.'}</p>
                    
                    <div class="mt-4">
                        <h4>Actions</h4>
                         <div class="d-flex gap-2">
                            <form action="${pageContext.request.contextPath}/customer/cart/add" method="post" class="d-inline">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <button type="submit" class="btn btn-primary" ${product.stockQuantity <= 0 ? 'disabled' : ''}>
                                    <i class="fas fa-cart-plus"></i> Add to Cart
                                </button>
                            </form>
                            <form action="${pageContext.request.contextPath}/customer/wishlist/add" method="post" class="d-inline">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <button type="submit" class="btn btn-outline-danger">
                                    <i class="fas fa-heart"></i> Add to Wishlist
                                </button>
                            </form>
                         </div>
                    </div>
                </div>
            </div>
        </c:if>
         <div class="mt-4">
            <a href="${pageContext.request.contextPath}/customer/shop.jsp" class="btn btn-secondary">Back to Shop</a>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 
 
 