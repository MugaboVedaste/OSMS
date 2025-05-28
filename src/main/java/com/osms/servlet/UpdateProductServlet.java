package com.osms.servlet;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.osms.dao.ProductDAO;
import com.osms.dao.ProductAuditDAO;
import com.osms.model.Product;

/**
 * Servlet implementation class UpdateProductServlet
 * Handles updating existing products in the system
 */
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 1024 * 1024 * 10, // 10 MB
        maxRequestSize = 1024 * 1024 * 50 // 50 MB
)
public class UpdateProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public UpdateProductServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get productId parameter and validate it
            String productIdParam = request.getParameter("productId");
            if (productIdParam == null || productIdParam.trim().isEmpty()) {
                // Instead of throwing an exception, set a friendly error message
                request.getSession().setAttribute("errorMessage", "Product ID is required");
                redirectBack(request, response);
                return;
            }

            int productId;
            try {
                productId = Integer.parseInt(productIdParam);
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "Invalid Product ID format");
                redirectBack(request, response);
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

            // Get supplier ID if available
            Integer supplierId = null; // Changed from int to Integer
            String supplierParam = request.getParameter("supplierId");
            if (supplierParam != null && !supplierParam.trim().isEmpty()) {
                try {
                    supplierId = Integer.parseInt(supplierParam);
                    // If supplierId is 0 or negative, set it to null
                    if (supplierId <= 0) {
                        supplierId = null;
                    }
                } catch (NumberFormatException e) {
                    // Invalid supplier ID format, use null
                    supplierId = null;
                }
            }

            // Try to get seller ID if available
            int sellerId = 0;
            String sellerParam = request.getParameter("sellerId");
            if (sellerParam != null && !sellerParam.trim().isEmpty()) {
                try {
                    sellerId = Integer.parseInt(sellerParam);
                } catch (NumberFormatException e) {
                    // Invalid seller ID format, use default
                    sellerId = 0;
                }
            }

            // If seller ID is still 0, try to get it from the session
            if (sellerId == 0 && request.getSession().getAttribute("sellerId") != null) {
                try {
                    sellerId = (Integer) request.getSession().getAttribute("sellerId");
                } catch (Exception e) {
                    // Error retrieving from session, leave as 0
                    e.printStackTrace();
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

            // Get the reason for the update (new field for admins)
            String updateReason = request.getParameter("updateReason");
            if (updateReason == null || updateReason.trim().isEmpty()) {
                updateReason = "No reason provided";
            }

            // First get the existing product to preserve any data not in the form
            ProductDAO productDAO = new ProductDAO();
            Product oldProduct = productDAO.getById(productId); // Store old product for audit

            if (oldProduct != null) {
                // Create a copy of the old product for audit purposes
                Product newProduct = new Product();
                newProduct.setProductId(oldProduct.getProductId());
                newProduct.setProductName(productName);
                newProduct.setDescription(description);
                newProduct.setPrice(price);
                newProduct.setStockQuantity(stockQuantity);
                newProduct.setCategory(category);
                newProduct.setSupplierId(supplierId);
                newProduct.setSellerId(oldProduct.getSellerId()); // Keep the original seller ID
                newProduct.setExpirationDate(expirationDate);

                // Handle file upload for product image
                Part filePart = request.getPart("productImage");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = getSubmittedFileName(filePart);
                    if (fileName != null && !fileName.isEmpty()) {
                        // Create a unique filename to avoid collisions
                        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;

                        // Determine upload directory: first try the configured path,
                        // then fall back to default within the webapp
                        String uploadPath = getServletContext().getInitParameter("file-upload");
                        if (uploadPath == null || uploadPath.isEmpty()) {
                            uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                        }

                        // Create the directory if it doesn't exist
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdir();
                        }

                        // Save the file
                        String filePath = uploadPath + File.separator + uniqueFileName;
                        filePart.write(filePath);

                        // Store the relative path in the database
                        newProduct.setImagePath("uploads/" + uniqueFileName);
                    }
                } else {
                    // Keep the original image path if no new image is provided
                    newProduct.setImagePath(oldProduct.getImagePath());
                }

                // Update the product in the database
                boolean success = productDAO.update(newProduct);

                if (success) {
                    // Log the update in the audit table (for admins only)
                    if ("Admin".equals(request.getSession().getAttribute("userType"))) {
                        try {
                            Integer adminId = (Integer) request.getSession().getAttribute("userId");
                            if (adminId != null) {
                                ProductAuditDAO auditDAO = new ProductAuditDAO();
                                auditDAO.logUpdate(productId, adminId, updateReason, oldProduct, newProduct);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            // Don't stop the process if audit logging fails
                        }
                    }

                    // Product updated successfully
                    request.getSession().setAttribute("successMessage", "Product updated successfully!");
                } else {
                    // Failed to update product
                    request.getSession().setAttribute("errorMessage", "Failed to update product. Please try again.");
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Product not found. Cannot update.");
            }

            // Redirect back to the appropriate page
            redirectBack(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            redirectBack(request, response);
        }
    }

    /**
     * Helper method to redirect back to the appropriate page based on the user type
     */
    private void redirectBack(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Check if the user is a seller
        if ("Seller".equals(request.getSession().getAttribute("userType"))) {
            response.sendRedirect(request.getContextPath() + "/seller/my_products.jsp");
        } else {
            // Default to admin products page
            response.sendRedirect(request.getContextPath() + "/admin/products.jsp");
        }
    }

    /**
     * Utility method to get the filename from a Part
     */
    private String getSubmittedFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return item.substring(item.indexOf("=") + 2, item.length() - 1);
            }
        }
        return null;
    }
}