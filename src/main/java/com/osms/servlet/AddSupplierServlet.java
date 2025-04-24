package com.osms.servlet;

import java.io.IOException;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.dao.SupplierDAO;
import com.osms.dao.UserDAO;
import com.osms.model.Supplier;

/**
 * Servlet implementation class AddSupplierServlet
 * Handles the addition of new suppliers to the system
 */
@WebServlet("/addSupplier")
public class AddSupplierServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddSupplierServlet() {
        super();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get parameters from the form
        String companyName = request.getParameter("companyName");
        String contactPerson = request.getParameter("contactPerson");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String zipCode = request.getParameter("zipCode");
        String country = request.getParameter("country");
        String category = request.getParameter("category");
        String status = request.getParameter("status");
        String notes = request.getParameter("notes");
        
        try {
            // Create a Supplier object
            Supplier supplier = new Supplier();
            supplier.setCompanyName(companyName);
            supplier.setContactPerson(contactPerson);
            supplier.setEmail(email);
            supplier.setPhone(phone);
            supplier.setAddress(address);
            supplier.setCity(city);
            supplier.setState(state);
            supplier.setZipCode(zipCode);
            supplier.setCountry(country);
            supplier.setCategory(category);
            supplier.setStatus(status);
            supplier.setNotes(notes);
            
            // Use the SupplierDAO to insert the supplier
            SupplierDAO supplierDAO = new SupplierDAO();
            int supplierId = supplierDAO.insert(supplier);
            
            if (supplierId > 0) {
                // Supplier added successfully, set success message
                request.getSession().setAttribute("successMessage", "Supplier added successfully!");
                response.sendRedirect(request.getContextPath() + "/admin/suppliers.jsp");
            } else {
                // Failed to add supplier
                request.setAttribute("errorMessage", "Failed to add supplier. Please try again.");
                request.getRequestDispatcher("/admin/suppliers.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/admin/suppliers.jsp").forward(request, response);
        }
    }
} 