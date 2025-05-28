package com.osms.servlet;

import com.osms.dao.OrderDAO;
import com.osms.dao.WishlistDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/customer/dashboard")
public class CustomerDashboardServlet extends HttpServlet {

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

        OrderDAO orderDAO = new OrderDAO();
        WishlistDAO wishlistDAO = new WishlistDAO();

        try {
            // Get order count for the customer
            int orderCount = orderDAO.getOrderCountByCustomerId(customerId);
            request.setAttribute("orderCount", orderCount);

            // Get wishlist count for the customer
            int wishlistCount = wishlistDAO.getWishlistCountByCustomerId(customerId);
            request.setAttribute("wishlistCount", wishlistCount);

            // Forward to the dashboard JSP
            request.getRequestDispatcher("/customer/dashboard.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            // Handle exceptions, maybe redirect to an error page
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error loading dashboard data from database.");
        } catch (Exception e) {
            e.printStackTrace();
            // Handle exceptions, maybe redirect to an error page
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading dashboard data.");
        } finally {
            // Close DAOs if necessary (depends on DAO implementation)
            // orderDAO.closeConnection();
            // wishlistDAO.closeConnection();
        }
    }
}
