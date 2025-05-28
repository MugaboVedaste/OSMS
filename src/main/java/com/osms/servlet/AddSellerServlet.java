package com.osms.servlet;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.dao.SellerDAO;
import com.osms.dao.UserDAO;
import com.osms.model.Seller;
import com.osms.util.DatabaseUtil;

/**
 * Servlet implementation class AddSellerServlet
 * Handles the addition of new sellers to the system
 */
@WebServlet("/addSeller")
public class AddSellerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddSellerServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get parameters from the form
        String companyName = request.getParameter("sellerName"); // Using sellerName as company name from form
        String contactName = request.getParameter("contactName");
        if (contactName == null || contactName.isEmpty()) {
            contactName = companyName; // Use company name as contact name if not provided
        }
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String address = request.getParameter("address");
        
        try {
            // Create a Seller object
            Seller seller = new Seller();
            seller.setCompanyName(companyName);
            seller.setContactName(contactName);
            seller.setEmail(email);
            seller.setPhone(phone);
            seller.setAddress(address);
            seller.setPassword(password);
            
            // Set both date fields
            Timestamp currentTime = new Timestamp(System.currentTimeMillis());
            seller.setJoinedDate(currentTime);
            seller.setRegistrationDate(currentTime);
            
            // Use the SellerDAO to insert the seller
            SellerDAO sellerDAO = new SellerDAO(DatabaseUtil.getConnection());
            boolean success = sellerDAO.insert(seller);
            
            if (success) {
                // Seller added successfully, now add user entry
                UserDAO userDAO = new UserDAO();
                boolean userAdded = userDAO.addUser(email, password, "Seller", null, seller.getSellerId());
                
                if (userAdded) {
                    // Redirect to seller list with success message
                    request.getSession().setAttribute("successMessage", "Seller added successfully!");
                    response.sendRedirect(request.getContextPath() + "/admin/sellers.jsp");
                } else {
                    // Failed to add user
                    sellerDAO.delete(seller.getSellerId()); // Clean up seller if user creation failed
                    request.setAttribute("errorMessage", "Failed to create user account. Please try again.");
                    request.getRequestDispatcher("/admin/sellers.jsp").forward(request, response);
                }
            } else {
                // Failed to add seller
                request.setAttribute("errorMessage", "Failed to add seller. Please try again.");
                request.getRequestDispatcher("/admin/sellers.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/admin/sellers.jsp").forward(request, response);
        }
    }
} 