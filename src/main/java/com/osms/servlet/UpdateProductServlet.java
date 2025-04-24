package com.osms.servlet;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.dao.ProductDAO;
import com.osms.model.Product;

/**
 * Servlet implementation class UpdateProductServlet
 * Handles updating existing products in the system
 */
public class UpdateProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UpdateProductServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get productId parameter and validate it
            String productIdParam = request.getParameter("productId");
            if (productIdParam == null || productIdParam.trim().isEmpty()) {
                // Instead of throwing an exception, set a friendly error message
                request.getSession().setAttribute("errorMessage", "Product ID is required");
                response.sendRedirect(request.getContextPath() + "/admin/products.jsp");
                return;
            }
            
            int productId;
            try {
                productId = Integer.parseInt(productIdParam);
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "Invalid Product ID format");
                response.sendRedirect(request.getContextPath() + "/admin/products.jsp");
                return;
            }
            
            // Get other parameters from the form with null checking
            String productName = request.getParameter("productName");
            if (productName == null || productName.trim().isEmpty()) {
                productName = "Unnamed Product"; // Default value to prevent null
            }
            
            String description = request.getParameter("description");
            String category = request.getParameter("category");
            
            // Parse numeric parameters with validation
            double price = 0.0;
            String priceParam = request.getParameter("price");
            if (priceParam != null && !priceParam.trim().isEmpty()) {
                try {
                    price = Double.parseDouble(priceParam);
                } catch (NumberFormatException e) {
                    // Invalid price format, use default
                    price = 0.0;
                }
            }
            
            int stockQuantity = 0;
            String stockParam = request.getParameter("stockQuantity");
            if (stockParam != null && !stockParam.trim().isEmpty()) {
                try {
                    stockQuantity = Integer.parseInt(stockParam);
                } catch (NumberFormatException e) {
                    // Invalid stock format, use default
                    stockQuantity = 0;
                }
            } else {
                // Try "stock" parameter for backward compatibility
                stockParam = request.getParameter("stock");
                if (stockParam != null && !stockParam.trim().isEmpty()) {
                    try {
                        stockQuantity = Integer.parseInt(stockParam);
                    } catch (NumberFormatException e) {
                        // Invalid stock format, use default
                        stockQuantity = 0;
                    }
                }
            }
            
            int supplierId = 0;
            String supplierParam = request.getParameter("supplierId");
            if (supplierParam != null && !supplierParam.trim().isEmpty()) {
                try {
                    supplierId = Integer.parseInt(supplierParam);
                } catch (NumberFormatException e) {
                    // Invalid supplier ID format, use default
                    supplierId = 0;
                }
            }
            
            // Parse expiration date if provided
            Date expirationDate = null;
            String dateParam = request.getParameter("expirationDate");
            if (dateParam != null && !dateParam.trim().isEmpty()) {
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    expirationDate = sdf.parse(dateParam);
                } catch (ParseException e) {
                    // Invalid date format, leave as null
                    e.printStackTrace();
                }
            }
            
            // First get the existing product to preserve any data not in the form
            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getById(productId);
            
            if (product != null) {
                // Update the product with the form data
                product.setProductName(productName);
                product.setDescription(description);
                product.setPrice(price);
                product.setStockQuantity(stockQuantity);
                product.setCategory(category);
                product.setSupplierId(supplierId);
                product.setExpirationDate(expirationDate);
                
                // Update the product in the database
                boolean success = productDAO.update(product);
                
                if (success) {
                    // Product updated successfully
                    request.getSession().setAttribute("successMessage", "Product updated successfully!");
                } else {
                    // Failed to update product
                    request.getSession().setAttribute("errorMessage", "Failed to update product. Please try again.");
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Product not found. Cannot update.");
            }
            
            // Redirect back to the products page
            response.sendRedirect(request.getContextPath() + "/admin/products.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/products.jsp");
        }
    }
} 