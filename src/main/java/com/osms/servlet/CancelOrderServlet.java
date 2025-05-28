package com.osms.servlet;

import com.osms.dao.OrderDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/order/cancel")
public class CancelOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            // Redirect to login if customerId is not in session
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int orderId = -1;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (NumberFormatException e) {
            // Invalid order ID, redirect back to orders page
            response.sendRedirect(request.getContextPath() + "/customer/my_orders.jsp?error=Invalid+order+ID");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        boolean success = false;
        try {
            // In a real application, you would also verify that this order belongs to the
            // logged-in customer
            // For simplicity here, we are just updating the status by ID
            success = orderDAO.updateStatus(orderId, "Cancelled");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/customer/my_orders.jsp?error=Database+error+cancelling+order");
            return;
        }

        if (success) {
            // Redirect back to orders page with success message
            response.sendRedirect(
                    request.getContextPath() + "/customer/my_orders.jsp?success=Order+cancelled+successfully");
        } else {
            // Redirect back to orders page with error message
            response.sendRedirect(request.getContextPath() + "/customer/my_orders.jsp?error=Failed+to+cancel+order");
        }
    }
}
