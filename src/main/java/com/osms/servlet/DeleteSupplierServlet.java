package com.osms.servlet;

import com.osms.dao.SupplierDAO;
import com.osms.util.DatabaseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/deleteSupplier")
public class DeleteSupplierServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("supplierId");
        try {
            int supplierId = Integer.parseInt(idParam);
            SupplierDAO supplierDAO = new SupplierDAO(DatabaseUtil.getConnection());
            boolean success = supplierDAO.delete(supplierId);
            if (success) {
                request.getSession().setAttribute("successMessage", "Supplier deleted successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to delete supplier.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin/suppliers.jsp");
    }
}