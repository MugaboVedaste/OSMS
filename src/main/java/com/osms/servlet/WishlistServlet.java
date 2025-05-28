package com.osms.servlet;

import java.io.IOException;
import java.sql.SQLException;
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
import com.osms.dao.WishlistDAO;
import com.osms.model.Product;

/**
 * Servlet responsible for managing wishlist operations.
 */
public class WishlistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // If no specific action is provided, redirect to wishlist page
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp");
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

        // Handle different wishlist actions
        if (pathInfo.equals("/remove")) {
            handleRemoveFromWishlist(request, response);
        } else if (pathInfo.equals("/clear")) {
            handleClearWishlist(request, response);
        } else if (pathInfo.equals("/moveToCart")) {
            handleMoveToCart(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp");
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

        // Handle different wishlist actions
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/add")) {
            handleAddToWishlist(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp");
        }
    }

    /**
     * Handle adding a product to the wishlist
     */
    private void handleAddToWishlist(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Get product ID from request parameter
            int productId = Integer.parseInt(request.getParameter("productId"));

            // Check if product exists
            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getById(productId);

            if (product == null) {
                // Product not found
                response.sendRedirect(request.getContextPath() + "/customer/shop.jsp?error=Product+not+found");
                return;
            }

            // Use WishlistDAO to add to database
            WishlistDAO wishlistDAO = new WishlistDAO();
            boolean added = wishlistDAO.addItem(customerId, productId);

            if (added) {
                // Redirect back to previous page or shop with success message
                String referer = request.getHeader("Referer");
                if (referer != null && !referer.isEmpty()) {
                    response.sendRedirect(referer + "?success=Added+to+wishlist");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/shop.jsp?success=Added+to+wishlist");
                }
            } else {
                // Handle case where item could not be added (e.g., already exists, database
                // error)
                // For now, let's assume if it wasn't added, it already exists or there was a DB
                // issue
                response.sendRedirect(request.getContextPath()
                        + "/customer/shop.jsp?info=Product+already+in+wishlist+or+could+not+be+added");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/shop.jsp?error=Invalid+product");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/customer/shop.jsp?error=Database+error+adding+to+wishlist");
        }
    }

    /**
     * Handle removing a product from the wishlist
     */
    private void handleRemoveFromWishlist(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        try {
            // Get product ID from request parameter
            int productId = Integer.parseInt(request.getParameter("productId"));

            // Get wishlist from session
            List<Integer> wishlist = (List<Integer>) session.getAttribute("wishlist");

            if (wishlist != null) {
                // Remove product from wishlist
                wishlist.remove(Integer.valueOf(productId));
            }

            response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp?error=Invalid+product");
        }
    }

    /**
     * Handle clearing the entire wishlist
     */
    private void handleClearWishlist(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        // Remove wishlist from session
        session.removeAttribute("wishlist");

        response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp");
    }

    /**
     * Handle moving a product from wishlist to cart
     */
    private void handleMoveToCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();

        try {
            // Get product ID from request parameter
            int productId = Integer.parseInt(request.getParameter("productId"));

            // Check if product exists and is in stock
            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getById(productId);

            if (product == null || product.getStockQuantity() <= 0) {
                // Product not found or out of stock
                response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp?error=Product+not+available");
                return;
            }

            // Get wishlist from session
            List<Integer> wishlist = (List<Integer>) session.getAttribute("wishlist");

            if (wishlist != null && wishlist.contains(productId)) {
                // Remove from wishlist
                wishlist.remove(Integer.valueOf(productId));

                // Add to cart
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

                // Update simple cart list
                List<Integer> cart = new ArrayList<>(cartItems.keySet());
                session.setAttribute("cart", cart);
            }

            response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp?success=Moved+to+cart");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/wishlist.jsp?error=Invalid+product");
        }
    }
}