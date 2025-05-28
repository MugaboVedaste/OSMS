package com.osms.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.osms.dao.ProductDAO;
import com.osms.model.Product;

/**
 * Servlet responsible for managing cart operations.
 */
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // If no specific action is provided, redirect to cart page
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
            return;
        }

        // Get session and check if user is logged in as a customer
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        Integer customerId = (Integer) session.getAttribute("userId");

        if (userType == null || !userType.equals("Customer") || customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Handle different cart actions
        if (pathInfo.equals("/remove")) {
            handleRemoveFromCart(request, response);
        } else if (pathInfo.equals("/update")) {
            handleUpdateCart(request, response);
        } else if (pathInfo.equals("/clear")) {
            handleClearCart(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // Get session and check if user is logged in as a customer
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        Integer customerId = (Integer) session.getAttribute("userId");

        if (userType == null || !userType.equals("Customer") || customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Handle different cart actions
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/add")) {
            handleAddToCart(request, response);
        } else if (pathInfo.equals("/update")) {
            handleUpdateCart(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
        }
    }

    /**
     * Handle adding a product to the cart
     */
    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        try {
            // Get product ID from request parameter
            int productId = Integer.parseInt(request.getParameter("productId"));

            // Check if product exists and is in stock
            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getById(productId);

            if (product == null || product.getStockQuantity() <= 0) {
                // Product not found or out of stock
                response.sendRedirect(request.getContextPath() + "/customer/shop.jsp?error=Product+not+available");
                return;
            }

            // Get or create cart in session
            Map<Integer, Integer> cartItems = (Map<Integer, Integer>) session.getAttribute("cartItems");
            if (cartItems == null) {
                cartItems = new HashMap<>();
                session.setAttribute("cartItems", cartItems);
            }

            // Add product to cart or increment quantity
            int quantity = cartItems.getOrDefault(productId, 0) + 1;

            // Make sure we don't exceed available stock
            if (quantity > product.getStockQuantity()) {
                quantity = product.getStockQuantity();
            }

            cartItems.put(productId, quantity);

            // Keep a simple product ID list for easy count display
            List<Integer> cart = new ArrayList<>(cartItems.keySet());
            session.setAttribute("cart", cart);

            // Redirect back to previous page or shop
            String referer = request.getHeader("Referer");
            if (referer != null && !referer.isEmpty()) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/shop.jsp?success=Product+added+to+cart");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/shop.jsp?error=Invalid+product");
        }
    }

    /**
     * Handle removing a product from the cart
     */
    private void handleRemoveFromCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        try {
            // Get product ID from request parameter
            int productId = Integer.parseInt(request.getParameter("productId"));

            // Get cart from session
            Map<Integer, Integer> cartItems = (Map<Integer, Integer>) session.getAttribute("cartItems");

            if (cartItems != null) {
                // Remove product from cart
                cartItems.remove(productId);

                // Update the simplified cart list
                List<Integer> cart = new ArrayList<>(cartItems.keySet());
                session.setAttribute("cart", cart);
            }

            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=Invalid+product");
        }
    }

    /**
     * Handle updating cart quantities
     */
    private void handleUpdateCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        try {
            // Get product ID and quantity from request parameters
            int productId = Integer.parseInt(request.getParameter("productId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            // Validate quantity
            if (quantity <= 0) {
                // Remove item if quantity is 0 or negative
                handleRemoveFromCart(request, response);
                return;
            }

            // Check if product exists and validate against stock
            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getById(productId);

            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=Product+not+found");
                return;
            }

            // Make sure we don't exceed available stock
            if (quantity > product.getStockQuantity()) {
                quantity = product.getStockQuantity();
            }

            // Get cart from session
            Map<Integer, Integer> cartItems = (Map<Integer, Integer>) session.getAttribute("cartItems");

            if (cartItems != null) {
                // Update quantity
                cartItems.put(productId, quantity);
            }

            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=Invalid+input");
        }
    }

    /**
     * Handle clearing the entire cart
     */
    private void handleClearCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        // Remove cart from session
        session.removeAttribute("cartItems");
        session.removeAttribute("cart");

        response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
    }
}