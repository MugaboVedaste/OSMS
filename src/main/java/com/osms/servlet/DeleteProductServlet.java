package com.osms.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.dao.ProductDAO;
import com.osms.dao.ProductAuditDAO;
import com.osms.model.Product;

/**
 * Servlet implementation class DeleteProductServlet
 * Handles deletion of products from the system
 */
public class DeleteProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public DeleteProductServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get product ID from request parameter
            int productId;

            // Try to get productId first, fall back to id for backward compatibility
            if (request.getParameter("productId") != null) {
                productId = Integer.parseInt(request.getParameter("productId"));
            } else if (request.getParameter("id") != null) {
                productId = Integer.parseInt(request.getParameter("id"));
            } else {
                throw new IllegalArgumentException("No product ID provided");
            }

            // Get the delete reason (for admins)
            String deleteReason = request.getParameter("deleteReason");
            if (deleteReason == null || deleteReason.trim().isEmpty()) {
                deleteReason = "No reason provided";
            }

            // Get the product first (for audit and checking seller)
            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getById(productId);

            if (product == null) {
                request.getSession().setAttribute("errorMessage", "Product not found. Cannot delete.");
                redirectBack(request, response);
                return;
            }

            // Get current user type and ID
            String userType = (String) request.getSession().getAttribute("userType");
            Integer userId = (Integer) request.getSession().getAttribute("userId");
            Integer sellerId = (Integer) request.getSession().getAttribute("sellerId");

            // Security check: Sellers can only delete their own products
            if ("Seller".equals(userType) && product.getSellerId() != sellerId) {
                request.getSession().setAttribute("errorMessage", "You do not have permission to delete this product.");
                redirectBack(request, response);
                return;
            }

            // Log the delete action for admins
            if ("Admin".equals(userType) && userId != null) {
                // Create audit record before deleting
                ProductAuditDAO auditDAO = new ProductAuditDAO();
                auditDAO.logDelete(productId, userId, deleteReason, product);
            }

            // Delete the product using the DAO
            boolean success = productDAO.delete(productId);

            if (success) {
                // Product deleted successfully
                request.getSession().setAttribute("successMessage", "Product deleted successfully!");
            } else {
                // Failed to delete product
                request.getSession().setAttribute("errorMessage", "Failed to delete product. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "An error occurred: " + e.getMessage());
        }

        // Redirect back to the appropriate page
        redirectBack(request, response);
    }

    /**
     * Support GET method for backward compatibility
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
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
}