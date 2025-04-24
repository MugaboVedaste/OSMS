package com.osms.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.dao.ProductDAO;

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
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
            
            // Delete the product using the DAO
            ProductDAO productDAO = new ProductDAO();
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
        
        // Redirect back to the products page
        response.sendRedirect(request.getContextPath() + "/admin/products.jsp");
    }
} 