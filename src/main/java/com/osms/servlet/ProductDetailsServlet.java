package com.osms.servlet;

import com.osms.dao.ProductDAO;
import com.osms.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/customer/product_details")
public class ProductDetailsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int productId = -1;
        try {
            productId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            // Invalid product ID, redirect to shop page
            response.sendRedirect(request.getContextPath() + "/customer/shop.jsp?error=Invalid+product+ID");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        Product product = productDAO.getById(productId);

        if (product == null) {
            // Product not found, redirect to shop page
            response.sendRedirect(request.getContextPath() + "/customer/shop.jsp?error=Product+not+found");
            return;
        }

        request.setAttribute("product", product);
        request.getRequestDispatcher("/customer/product_details.jsp").forward(request, response);
    }
}
