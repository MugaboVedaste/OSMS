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
 * Servlet implementation class AddProductServlet
 * Handles the addition of new products to the system
 */
public class AddProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddProductServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get parameters from the form with validation
            String productName = request.getParameter("productName");
            if (productName == null || productName.trim().isEmpty()) {
                // Instead of throwing an exception, set a friendly error message
                request.getSession().setAttribute("errorMessage", "Product name is required");
                response.sendRedirect(request.getContextPath() + "/admin/products.jsp");
                return;
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
            
            // Create a Product object with the form data
            Product product = new Product();
            product.setProductName(productName);
            product.setDescription(description);
            product.setPrice(price);
            product.setStockQuantity(stockQuantity);
            product.setCategory(category);
            product.setSupplierId(supplierId);
            product.setExpirationDate(expirationDate);
            
            // Insert the product into the database
            ProductDAO productDAO = new ProductDAO();
            int productId = productDAO.insert(product);
            
            if (productId > 0) {
                // Product added successfully
                request.getSession().setAttribute("successMessage", "Product added successfully!");
            } else {
                // Failed to add product
                request.getSession().setAttribute("errorMessage", "Failed to add product. Please try again.");
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