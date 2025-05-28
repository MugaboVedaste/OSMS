package com.osms.servlet;

import com.osms.dao.SellerDAO;
import com.osms.util.DatabaseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/deleteSeller")
public class DeleteSellerServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("sellerId");
        try {
            int sellerId = Integer.parseInt(idParam);
            SellerDAO sellerDAO = new SellerDAO(DatabaseUtil.getConnection());
            boolean success = sellerDAO.delete(sellerId);
            if (success) {
                request.getSession().setAttribute("successMessage", "Seller deleted successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to delete seller.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin/sellers.jsp");
    }
}