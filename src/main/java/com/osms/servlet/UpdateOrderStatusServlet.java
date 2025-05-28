package com.osms.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.osms.dao.OrderDAO;
import com.osms.model.Order;

/**
 * Servlet for updating order status
 */
public class UpdateOrderStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get session and check if user is a seller
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        Integer sellerId = (Integer) session.getAttribute("sellerId");

        if (userType == null || (!userType.equals("Seller") && !userType.equals("Admin")) ||
                (userType.equals("Seller") && sellerId == null)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Get order ID and new status from request
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String status = request.getParameter("status");

            // Validate inputs
            if (status == null || status.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Order status cannot be empty");
                response.sendRedirect(request.getContextPath() + "/seller/orders.jsp");
                return;
            }

            // Update order status
            OrderDAO orderDAO = new OrderDAO();
            boolean success = orderDAO.updateStatus(orderId, status);

            if (success) {
                session.setAttribute("successMessage", "Order status updated successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to update order status");
            }

            // Redirect back to orders page
            response.sendRedirect(request.getContextPath() + "/seller/orders.jsp");

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid order ID");
            response.sendRedirect(request.getContextPath() + "/seller/orders.jsp");
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/seller/orders.jsp");
        }
    }
}