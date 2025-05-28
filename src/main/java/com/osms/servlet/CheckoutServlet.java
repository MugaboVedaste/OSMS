package com.osms.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.osms.dao.OrderDAO;
import com.osms.dao.OrderItemDAO;
import com.osms.dao.ProductDAO;
import com.osms.model.Order;
import com.osms.model.OrderItem;
import com.osms.model.Product;

/**
 * Servlet responsible for processing checkout and creating orders.
 */
@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to checkout page
        request.getRequestDispatcher("/customer/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get session and check if user is logged in as a customer
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (userType == null || !userType.equals("Customer") || customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get cart items from session
        Map<Integer, Integer> cartItems = (Map<Integer, Integer>) session.getAttribute("cartItems");
        if (cartItems == null || cartItems.isEmpty()) {
            // Empty cart, redirect back to cart page
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=Cart+is+empty");
            return;
        }

        // Create a new order
        Order order = new Order();
        order.setCustomerId(customerId);
        order.setOrderDate(new Date());
        order.setStatus("Pending");

        // Calculate order total and validate products
        double totalAmount = 0;
        ProductDAO productDAO = new ProductDAO();
        Map<Integer, Product> productsMap = new HashMap<>();
        boolean hasValidProducts = false;

        for (Map.Entry<Integer, Integer> entry : cartItems.entrySet()) {
            int productId = entry.getKey();
            int quantity = entry.getValue();

            Product product = productDAO.getById(productId);
            if (product != null && product.getStockQuantity() >= quantity) {
                productsMap.put(productId, product);
                totalAmount += product.getPrice() * quantity;
                hasValidProducts = true;
            }
        }

        if (!hasValidProducts) {
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=No+valid+products+in+cart");
            return;
        }

        order.setTotalAmount(totalAmount);

        // Insert order into database
        OrderDAO orderDAO = new OrderDAO();
        int orderId = orderDAO.insert(order);

        if (orderId > 0) {
            // Order created successfully

            // Create OrderItems for this order
            OrderItemDAO orderItemDAO = new OrderItemDAO();
            List<OrderItem> orderItems = new ArrayList<>();
            boolean allItemsCreated = true;

            for (Map.Entry<Integer, Integer> entry : cartItems.entrySet()) {
                int productId = entry.getKey();
                int quantity = entry.getValue();

                Product product = productsMap.get(productId);
                if (product != null) {
                    OrderItem orderItem = new OrderItem();
                    orderItem.setOrderId(orderId);
                    orderItem.setProductId(productId);
                    orderItem.setQuantity(quantity);
                    orderItem.setUnitPrice(product.getPrice());
                    orderItem.setSubtotal(product.getPrice() * quantity);
                    orderItem.setSellerId(product.getSellerId());

                    // Add to batch list
                    orderItems.add(orderItem);

                    // Update product stock quantities
                    int newStockQuantity = product.getStockQuantity() - quantity;
                    if (newStockQuantity < 0)
                        newStockQuantity = 0;

                    product.setStockQuantity(newStockQuantity);
                    if (!productDAO.update(product)) {
                        allItemsCreated = false;
                        break;
                    }
                }
            }

            // Batch insert all order items at once
            if (!orderItems.isEmpty() && allItemsCreated) {
                if (orderItemDAO.batchInsert(orderItems)) {
                    // Clear cart
                    session.removeAttribute("cartItems");
                    session.removeAttribute("cart");

                    // Redirect to order confirmation page
                    response.sendRedirect(
                            request.getContextPath() + "/customer/order_confirmation.jsp?orderId=" + orderId);
                    return;
                }
            }

            // If we get here, something went wrong with order items
            // Delete the order and redirect back to cart
            orderDAO.delete(orderId);
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=Failed+to+create+order+items");
        } else {
            // Order creation failed
            response.sendRedirect(request.getContextPath() + "/customer/checkout.jsp?error=Failed+to+create+order");
        }
    }
}