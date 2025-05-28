package com.osms.servlet;

import com.osms.dao.CustomerDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/deleteCustomer")
public class DeleteCustomerServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("customerId");
        try {
            int customerId = Integer.parseInt(idParam);
            CustomerDAO customerDAO = new CustomerDAO();
            boolean success = customerDAO.delete(customerId);
            if (success) {
                request.getSession().setAttribute("successMessage", "Customer deleted successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to delete customer.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
    }
}