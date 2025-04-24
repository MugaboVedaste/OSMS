package com.osms.servlet;

import java.io.IOException;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.dao.CustomerDAO;
import com.osms.model.Customer;
import com.osms.util.DatabaseUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Servlet implementation class AddCustomerServlet
 * Handles the addition of new customers to the system
 */
@WebServlet("/addCustomer")
public class AddCustomerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddCustomerServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get parameters from the form
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        
        Connection conn = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            // Start transaction
            conn.setAutoCommit(false);
            
            // Create a Customer object
            Customer customer = new Customer();
            customer.setFirstName(firstName);
            customer.setLastName(lastName);
            customer.setEmail(email);
            customer.setPhone(phone);
            customer.setAddress(address);
            customer.setCity(city);
            customer.setPassword(password);
            customer.setRegistrationDate(new Date());
            
            // Use the CustomerDAO to insert the customer
            CustomerDAO customerDAO = new CustomerDAO(conn);
            int customerId = customerDAO.insert(customer);
            
            if (customerId > 0) {
                // Customer added successfully, now add to Users table
                String addUserSql = "INSERT INTO Users (Username, Password, UserType, CustomerId) VALUES (?, ?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(addUserSql)) {
                    stmt.setString(1, email); // Use email as username
                    stmt.setString(2, password);
                    stmt.setString(3, "Customer");
                    stmt.setInt(4, customerId);
                    
                    int userRows = stmt.executeUpdate();
                    
                    if (userRows > 0) {
                        // Successfully added to Users table
                        conn.commit();
                        
                        // Check if this is a self-registration or admin adding a customer
                        if (request.getSession().getAttribute("userType") != null && 
                            request.getSession().getAttribute("userType").equals("Admin")) {
                            // Admin adding a customer
                            request.getSession().setAttribute("successMessage", "Customer added successfully!");
                            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                        } else {
                            // Self-registration
                            request.setAttribute("successMessage", "Registration successful! Please login with your email and password.");
                            request.getRequestDispatcher("/login.jsp").forward(request, response);
                        }
                    } else {
                        // Failed to add to Users table
                        conn.rollback();
                        request.setAttribute("errorMessage", "Failed to create user account. Please try again.");
                        
                        // Determine where to redirect based on user type
                        if (request.getSession().getAttribute("userType") != null && 
                            request.getSession().getAttribute("userType").equals("Admin")) {
                            request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
                        } else {
                            request.getRequestDispatcher("/register.jsp").forward(request, response);
                        }
                    }
                }
            } else {
                // Failed to add customer
                conn.rollback();
                request.setAttribute("errorMessage", "Failed to add customer. Please try again.");
                
                // Determine where to redirect based on user type
                if (request.getSession().getAttribute("userType") != null && 
                    request.getSession().getAttribute("userType").equals("Admin")) {
                    request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            
            // Determine where to redirect based on user type
            if (request.getSession().getAttribute("userType") != null && 
                request.getSession().getAttribute("userType").equals("Admin")) {
                request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/register.jsp").forward(request, response);
            }
        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
} 