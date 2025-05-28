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
import com.osms.model.Product;

/**
 * Servlet implementation class AddProductServlet
 * Handles the addition of new products to the system
 */
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 1024 * 1024 * 10, // 10 MB
        maxRequestSize = 1024 * 1024 * 50 // 50 MB
)
public class AddProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddProductServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get parameters from the form with validation
            String productName = request.getParameter("productName");
            if (productName == null || productName.trim().isEmpty()) {
                // Instead of throwing an exception, set a friendly error message
                request.getSession().setAttribute("errorMessage", "Product name is required");
                redirectBack(request, response);
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

            // Get supplier ID if available
            Integer supplierId = null;
            String supplierParam = request.getParameter("supplierId");
            if (supplierParam != null && !supplierParam.trim().isEmpty()) {
                try {
                    supplierId = Integer.parseInt(supplierParam);
                    // If supplierId is 0 or negative, set it to null
                    if (supplierId <= 0) {
                        supplierId = null;
                    }
                } catch (NumberFormatException e) {
                    // Invalid supplier ID format, use null instead of 0
                    supplierId = null;
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
            product.setSellerId(sellerId);
            product.setExpirationDate(expirationDate);

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
                    product.setImagePath("uploads/" + uniqueFileName);
                }
            }

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