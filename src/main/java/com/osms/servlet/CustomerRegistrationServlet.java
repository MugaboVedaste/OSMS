package com.osms.servlet;

import com.osms.dao.CustomerDAO;
import com.osms.model.Customer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/customerRegister")
public class CustomerRegistrationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get registration details from form parameters
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String zipCode = request.getParameter("zipCode");
        String country = request.getParameter("country");

        // Basic validation (more comprehensive validation might be needed)
        if (firstName == null || firstName.isEmpty() || lastName == null || lastName.isEmpty() ||
                email == null || email.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "Please fill in all required fields.");
            request.getRequestDispatcher("/customer_register.jsp").forward(request, response);
            return;
        }

        // Create a new Customer object
        Customer customer = new Customer();
        customer.setFirstName(firstName);
        customer.setLastName(lastName);
        customer.setEmail(email);
        customer.setPassword(password); // In a real application, hash the password!
        customer.setPhone(phone);
        customer.setAddress(address);
        customer.setCity(city);
        customer.setState(state);
        customer.setZipCode(zipCode);
        customer.setCountry(country);

        CustomerDAO customerDAO = new CustomerDAO();
        boolean registrationSuccess = false;
        try {
            // Check if email already exists
            if (customerDAO.getByEmail(email) != null) {
                request.setAttribute("errorMessage", "Email address is already registered.");
                request.getRequestDispatcher("/customer_register.jsp").forward(request, response);
                return;
            }

            // Insert the new customer into the database
            int newCustomerId = customerDAO.insert(customer);
            if (newCustomerId != -1) {
                registrationSuccess = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred during registration. Please try again.");
            request.getRequestDispatcher("/customer_register.jsp").forward(request, response);
            return;
        }

        if (registrationSuccess) {
            // Redirect to login page with success message
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp?message=Registration+successful.+Please+login.");
        } else {
            // Should ideally not reach here if database insertion failed, but as a fallback
            request.setAttribute("errorMessage", "Failed to register customer. Please try again.");
            request.getRequestDispatcher("/customer_register.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Direct GET requests to the registration JSP
        request.getRequestDispatcher("/customer_register.jsp").forward(request, response);
    }
}
