package com.osms.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.osms.dao.OrderDAO;
import com.osms.dao.OrderItemDAO;
import com.osms.dao.ProductDAO;
import com.osms.model.Order;
import com.osms.model.OrderItem;
import com.osms.model.Product;

@WebServlet("/admin/reportData")
public class ReportDataServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO = new OrderDAO();
    private ProductDAO productDAO = new ProductDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String reportType = request.getParameter("reportType");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date startDate = null;
        Date endDate = null;

        try {
            if (startDateStr != null && !startDateStr.isEmpty()) {
                startDate = sdf.parse(startDateStr);
            }
            if (endDateStr != null && !endDateStr.isEmpty()) {
                endDate = sdf.parse(endDateStr);
            }
        } catch (ParseException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid date format\"}");
            return;
        }

        // Placeholder for fetching data
        Object reportData = null;
        String errorMessage = null;

        try {
            switch (reportType) {
                case "Sales Report":
                    // Fetch sales data
                    reportData = fetchSalesReport(startDate, endDate);
                    break;
                case "Inventory Report":
                    // Fetch inventory data
                    reportData = fetchInventoryReport();
                    break;
                default:
                    errorMessage = "Unknown report type";
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            errorMessage = "Database error: " + e.getMessage();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

        PrintWriter out = response.getWriter();
        if (errorMessage != null) {
            out.write(new Gson().toJson(new ReportResponse(null, errorMessage)));
        } else if (reportData != null) {
            out.write(new Gson().toJson(new ReportResponse(reportData, null)));
        } else {
            out.write(new Gson().toJson(new ReportResponse(null, "No data found or error occurred.")));
        }
    }

    // Placeholder methods for fetching data
    private List<Order> fetchSalesReport(Date startDate, Date endDate) throws SQLException {
        // Implement sales report data fetching using OrderDAO and OrderItemDAO
        System.out.println("Fetching Sales Report from " + startDate + " to " + endDate);
        return orderDAO.getOrdersByDateRange(startDate, endDate);
    }

    private Object fetchInventoryReport() throws SQLException {
        System.out.println("Fetching Inventory Report");
        List<Product> products = productDAO.getAll();

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
            inventoryValue += product.getPrice() * product.getStockQuantity();
        }

        return new InventoryReportData(products, totalProducts, lowStockCount, outOfStockCount, inventoryValue);
    }

    // Helper class for JSON response
    class ReportResponse {
        Object data;
        String error;

        public ReportResponse(Object data, String error) {
            this.data = data;
            this.error = error;
        }
    }

    // Helper class for Inventory Report data
    class InventoryReportData {
        List<Product> products;
        int totalProducts;
        int lowStockCount;
        int outOfStockCount;
        double inventoryValue;

        public InventoryReportData(List<Product> products, int totalProducts, int lowStockCount, int outOfStockCount,
                double inventoryValue) {
            this.products = products;
            this.totalProducts = totalProducts;
            this.lowStockCount = lowStockCount;
            this.outOfStockCount = outOfStockCount;
            this.inventoryValue = inventoryValue;
        }
    }
}