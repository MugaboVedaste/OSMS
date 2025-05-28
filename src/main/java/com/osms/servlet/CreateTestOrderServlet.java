package com.osms.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.dao.CustomerDAO;
import com.osms.dao.OrderDAO;
import com.osms.dao.OrderItemDAO;
import com.osms.dao.ProductDAO;
import com.osms.dao.SellerDAO;
import com.osms.model.Customer;
import com.osms.model.Order;
import com.osms.model.OrderItem;
import com.osms.model.Product;
import com.osms.model.Seller;
import com.osms.util.DatabaseUtil;

/**
 * Servlet for creating a test order to demonstrate the seller-order
 * relationship
 */
public class CreateTestOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");

        try {
            Connection conn = DatabaseUtil.getConnection();

            // Get a customer
            CustomerDAO customerDAO = new CustomerDAO();
            Customer customer = null;
            List<Customer> customers = customerDAO.getAll();
            if (!customers.isEmpty()) {
                customer = customers.get(0);
            }

            // If no customer exists, create one
            if (customer == null) {
                customer = new Customer();
                customer.setFirstName("Test");
                customer.setLastName("Customer");
                customer.setEmail("test@example.com");
                customer.setPhone("1234567890");
                customer.setPassword("password");
                customer.setAddress("123 Test St");
                customer.setCity("Test City");
                customer.setRegistrationDate(new Date());
                int customerId = customerDAO.insert(customer);
                if (customerId > 0) {
                    customer.setCustomerId(customerId);
                } else {
                    response.getWriter().println("<h2>Error creating customer</h2>");
                    return;
                }
            }

            // Get a seller using LoginServlet approach
            SellerDAO sellerDAO = new SellerDAO(conn);
            List<Seller> sellers = new ArrayList<>();
            try {
                sellers = sellerDAO.getAll();
            } catch (SQLException e) {
                response.getWriter().println("<h2>Error getting sellers: " + e.getMessage() + "</h2>");
                e.printStackTrace();
            }

            Seller seller = null;
            if (!sellers.isEmpty()) {
                seller = sellers.get(0);
            }

            // If no seller exists, create one
            if (seller == null) {
                seller = new Seller();
                seller.setCompanyName("Test Company");
                seller.setContactName("Test Seller");
                seller.setEmail("seller@example.com");
                seller.setPhone("1234567890");
                seller.setAddress("456 Seller St");
                seller.setPassword("password");
                seller.setJoinedDate(new Timestamp(System.currentTimeMillis()));
                seller.setRegistrationDate(new Timestamp(System.currentTimeMillis()));

                try {
                    boolean result = sellerDAO.insert(seller);
                    if (!result) {
                        response.getWriter().println("<h2>Error creating seller</h2>");
                        return;
                    }

                    // Get the seller ID after insertion
                    sellers = sellerDAO.getAll();
                    for (Seller s : sellers) {
                        if (s.getEmail().equals("seller@example.com")) {
                            seller = s;
                            break;
                        }
                    }

                    if (seller == null || seller.getSellerId() <= 0) {
                        response.getWriter().println("<h2>Error retrieving seller ID after creation</h2>");
                        return;
                    }
                } catch (Exception e) {
                    response.getWriter().println("<h2>Error inserting seller: " + e.getMessage() + "</h2>");
                    e.printStackTrace();
                    return;
                }
            }

            // Get or create a product for the seller
            ProductDAO productDAO = new ProductDAO();
            Product product = null;
            List<Product> sellerProducts = productDAO.getBySellerId(seller.getSellerId());
            if (!sellerProducts.isEmpty()) {
                product = sellerProducts.get(0);
            }

            // If no product exists for this seller, create one
            if (product == null) {
                product = new Product();
                product.setProductName("Test Product");
                product.setDescription("This is a test product");
                product.setPrice(99.99);
                product.setStockQuantity(100);
                product.setCategory("Test Category");
                product.setSellerId(seller.getSellerId());
                product.setImagePath("default.jpg");
                int productId = productDAO.insert(product);
                if (productId > 0) {
                    product.setProductId(productId);
                } else {
                    response.getWriter().println("<h2>Error creating product</h2>");
                    return;
                }
            }

            // Create an order
            OrderDAO orderDAO = new OrderDAO();
            Order order = new Order();
            order.setCustomerId(customer.getCustomerId());
            order.setOrderDate(new Date());
            order.setStatus("Pending");
            order.setTotalAmount(product.getPrice() * 2); // Ordering 2 of the product

            int orderId = orderDAO.insert(order);
            if (orderId <= 0) {
                response.getWriter().println("<h2>Error creating order</h2>");
                return;
            }

            // Add order item
            OrderItemDAO orderItemDAO = new OrderItemDAO();
            OrderItem orderItem = new OrderItem();
            orderItem.setOrderId(orderId);
            orderItem.setProductId(product.getProductId());
            orderItem.setQuantity(2);
            orderItem.setPrice(product.getPrice());

            int orderItemId = orderItemDAO.insert(orderItem);
            if (orderItemId <= 0) {
                response.getWriter().println("<h2>Error creating order item</h2>");
                return;
            }

            // Success message
            response.getWriter().println("<html><body>");
            response.getWriter().println("<h2>Test Order Created Successfully</h2>");
            response.getWriter().println("<p>Order ID: " + orderId + "</p>");
            response.getWriter()
                    .println("<p>Customer: " + customer.getFirstName() + " " + customer.getLastName() + "</p>");
            response.getWriter().println("<p>Seller: " + seller.getCompanyName() + "</p>");
            response.getWriter().println("<p>Seller ID: " + seller.getSellerId() + "</p>");
            response.getWriter().println("<p>Product: " + product.getProductName() + "</p>");
            response.getWriter().println("<p>Product ID: " + product.getProductId() + "</p>");
            response.getWriter().println("<p>Quantity: 2</p>");
            response.getWriter().println("<p>Total: $" + order.getTotalAmount() + "</p>");
            response.getWriter().println("<p><a href='seller/orders.jsp'>Go to Seller Orders Page</a></p>");
            response.getWriter().println("<p><a href='customer/my_orders.jsp'>Go to Customer Orders Page</a></p>");
            response.getWriter().println("</body></html>");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<h2>Error: " + e.getMessage() + "</h2>");
            response.getWriter().println("<pre>");
            for (StackTraceElement ste : e.getStackTrace()) {
                response.getWriter().println(ste.toString());
            }
            response.getWriter().println("</pre>");
        }
    }
}