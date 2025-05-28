package com.osms.servlet;

import com.osms.dao.OrderDAO;
import com.osms.dao.ProductDAO;
import com.osms.dao.CustomerDAO;
import com.osms.model.Order;
import com.osms.model.Product;
import com.osms.model.Customer;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.Calendar;

public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();
    private final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String reportType = request.getParameter("reportType");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        Map<String, Object> result = new HashMap<>();

        try {
            // Set default date range if not provided (last 30 days)
            Date startDate = null;
            Date endDate = null;

            if (startDateStr == null || startDateStr.isEmpty()) {
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.MONTH, -1);
                startDate = cal.getTime();
                startDateStr = dateFormat.format(startDate);
            } else {
                startDate = dateFormat.parse(startDateStr);
            }

            if (endDateStr == null || endDateStr.isEmpty()) {
                endDate = new Date(); // Today
                endDateStr = dateFormat.format(endDate);
            } else {
                endDate = dateFormat.parse(endDateStr);
            }

            if ("Sales Report".equalsIgnoreCase(reportType)) {
                generateSalesReport(result, startDate, endDate);
            } else if ("Inventory Report".equalsIgnoreCase(reportType)) {
                generateInventoryReport(result);
            } else if ("Product Audit Report".equalsIgnoreCase(reportType)) {
                result.put("redirect", "product_audit.jsp");
            } else {
                result.put("error", "Unknown report type");
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("error", e.getMessage());
        }

        out.print(gson.toJson(result));
        out.flush();
    }

    private void generateSalesReport(Map<String, Object> result, Date startDate, Date endDate) {
        try {
            OrderDAO orderDAO = new OrderDAO();
            CustomerDAO customerDAO = new CustomerDAO();
            List<Order> orders = orderDAO.getOrdersByDateRange(startDate, endDate);
            List<Map<String, Object>> enhancedOrders = new ArrayList<>();

            double totalSales = 0;

            // Check if we have orders
            if (orders == null) {
                orders = new ArrayList<>();
            }

            for (Order order : orders) {
                Map<String, Object> enhancedOrder = new HashMap<>();
                enhancedOrder.put("orderId", order.getOrderId());
                enhancedOrder.put("customerId", order.getCustomerId());
                enhancedOrder.put("orderDate", dateFormat.format(order.getOrderDate()));
                enhancedOrder.put("totalAmount", order.getTotalAmount());
                enhancedOrder.put("status", order.getStatus());

                // Get customer name
                Customer customer = null;
                try {
                    customer = customerDAO.getById(order.getCustomerId());
                } catch (Exception e) {
                    // Ignore customer retrieval errors
                }

                if (customer != null) {
                    enhancedOrder.put("customerName", customer.getFirstName() + " " + customer.getLastName());
                } else {
                    enhancedOrder.put("customerName", "Unknown");
                }

                enhancedOrders.add(enhancedOrder);
                totalSales += order.getTotalAmount();
            }

            result.put("orders", enhancedOrders);
            result.put("totalSales", totalSales);
            result.put("orderCount", orders.size());
            result.put("startDate", dateFormat.format(startDate));
            result.put("endDate", dateFormat.format(endDate));
        } catch (Exception e) {
            e.printStackTrace();
            result.put("error", "Error generating sales report: " + e.getMessage());

            // Provide empty data to avoid client-side errors
            result.put("orders", new ArrayList<>());
            result.put("totalSales", 0);
            result.put("orderCount", 0);
            result.put("startDate", dateFormat.format(startDate));
            result.put("endDate", dateFormat.format(endDate));
        }
    }

    private void generateInventoryReport(Map<String, Object> result) {
        try {
            ProductDAO productDAO = new ProductDAO();
            List<Product> products = productDAO.getAll();

            // Check if we have products
            if (products == null) {
                products = new ArrayList<>();
            }

            int totalProducts = products.size();
            int lowStockCount = 0;
            int outOfStockCount = 0;
            double inventoryValue = 0;

            for (Product product : products) {
                if (product.getStockQuantity() <= 0) {
                    outOfStockCount++;
                } else if (product.getStockQuantity() < 10) {
                    lowStockCount++;
                }
                inventoryValue += (product.getPrice() * product.getStockQuantity());
            }

            result.put("products", products);
            result.put("totalProducts", totalProducts);
            result.put("lowStockCount", lowStockCount);
            result.put("outOfStockCount", outOfStockCount);
            result.put("inventoryValue", inventoryValue);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("error", "Error generating inventory report: " + e.getMessage());

            // Provide empty data to avoid client-side errors
            result.put("products", new ArrayList<>());
            result.put("totalProducts", 0);
            result.put("lowStockCount", 0);
            result.put("outOfStockCount", 0);
            result.put("inventoryValue", 0);
        }
    }
}