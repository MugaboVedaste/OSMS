package com.osms.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.osms.dao.CustomerDAO;
import com.osms.model.Customer;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final Gson gson = new Gson();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("userId");

        if (customerId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        Customer customer = customerDAO.getById(customerId);

        if (customer == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found");
            return;
        }

        request.setAttribute("customer", customer);
        request.getRequestDispatcher("/customer/profile.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("userId");

        if (customerId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        Customer customer = customerDAO.getById(customerId);

        if (customer == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found");
            return;
        }

        // Get form data
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        // Get password fields if provided
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Update customer object
        customer.setFirstName(firstName);
        customer.setLastName(lastName);
        customer.setEmail(email);
        customer.setPhone(phone);

        // Check if password change was requested
        boolean passwordChanged = false;
        String message = "Profile updated successfully!";

        if (currentPassword != null && !currentPassword.isEmpty() &&
                newPassword != null && !newPassword.isEmpty() &&
                confirmPassword != null && !confirmPassword.isEmpty()) {

            // Verify current password
            if (!customer.getPassword().equals(currentPassword)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                JsonObject jsonResponse = new JsonObject();
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Current password is incorrect");
                response.setContentType("application/json");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Verify new passwords match
            if (!newPassword.equals(confirmPassword)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                JsonObject jsonResponse = new JsonObject();
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "New passwords do not match");
                response.setContentType("application/json");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Update password
            customer.setPassword(newPassword);
            passwordChanged = true;
            message = "Profile and password updated successfully!";
        }

        // Save customer
        boolean updated = customerDAO.update(customer);

        if (!updated) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Failed to update profile");
            response.setContentType("application/json");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        // Return success response
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", true);
        jsonResponse.addProperty("message", message);
        jsonResponse.addProperty("passwordChanged", passwordChanged);

        response.setContentType("application/json");
        response.getWriter().write(jsonResponse.toString());
    }
}