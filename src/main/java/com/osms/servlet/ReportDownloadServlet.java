package com.osms.servlet;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.osms.dao.OrderDAO;
import com.osms.dao.ProductDAO;
import com.osms.model.Order;
import com.osms.model.Product;
import com.osms.servlet.ReportDataServlet.InventoryReportData;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet("/admin/downloadReport")
public class ReportDownloadServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO = new OrderDAO();
    private ProductDAO productDAO = new ProductDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
        } catch (java.text.ParseException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format.");
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"report.pdf\"");

        try {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            document.add(new Paragraph("OSMS Admin Report"));
            document.add(new Paragraph("Report Type: " + reportType));
            if (startDate != null || endDate != null) {
                document.add(new Paragraph("Date Range: " + (startDate != null ? startDate.toString() : "N/A") + " to "
                        + (endDate != null ? endDate.toString() : "N/A")));
            }
            document.add(new Paragraph("\n")); // Add some space

            switch (reportType) {
                case "Sales Report":
                    addSalesReportContent(document, startDate, endDate);
                    break;
                case "Inventory Report":
                    addInventoryReportContent(document);
                    break;
                default:
                    document.add(new Paragraph("Unknown report type requested."));
                    break;
            }

            document.close();

        } catch (DocumentException | SQLException e) {
            e.printStackTrace();
            throw new ServletException("Error generating PDF report", e);
        }
    }

    private void addSalesReportContent(Document document, Date startDate, Date endDate)
            throws DocumentException, SQLException {
        document.add(new Paragraph("Sales Report"));
        document.add(new Paragraph("\n"));

        List<Order> orders = orderDAO.getOrdersByDateRange(startDate, endDate);

        if (orders.isEmpty()) {
            document.add(new Paragraph("No sales data found for the selected date range."));
            return;
        }

        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.addCell("Order ID");
        table.addCell("Date");
        table.addCell("Customer ID"); // Using Customer ID for simplicity in PDF
        table.addCell("Total Amount");
        table.addCell("Status");

        for (Order order : orders) {
            table.addCell(String.valueOf(order.getOrderId()));
            table.addCell(order.getOrderDate().toString()); // Consider formatting date nicely
            table.addCell(String.valueOf(order.getCustomerId()));
            table.addCell(String.valueOf(order.getTotalAmount())); // Consider formatting currency nicely
            table.addCell(order.getStatus());
        }
        document.add(table);
    }

    private void addInventoryReportContent(Document document) throws DocumentException, SQLException {
        document.add(new Paragraph("Inventory Report"));
        document.add(new Paragraph("\n"));

        List<Product> products = productDAO.getAll();

        if (products.isEmpty()) {
            document.add(new Paragraph("No products found in inventory."));
            return;
        }

        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.addCell("Product ID");
        table.addCell("Name");
        table.addCell("Category");
        table.addCell("Stock Quantity");
        table.addCell("Price");

        for (Product product : products) {
            table.addCell(String.valueOf(product.getProductId()));
            table.addCell(product.getProductName());
            table.addCell(product.getCategory());
            table.addCell(String.valueOf(product.getStockQuantity()));
            table.addCell(String.valueOf(product.getPrice())); // Consider formatting currency nicely
        }
        document.add(table);
    }
}