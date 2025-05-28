package com.osms.servlet;

import com.osms.dao.OrderDAO;
import com.osms.dao.OrderItemDAO;
import com.osms.dao.ProductDAO;
import com.osms.model.Order;
import com.osms.model.OrderItem;
import com.osms.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import java.text.SimpleDateFormat;

@WebServlet("/SellerOrderReport")
public class SellerOrderReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get sellerId from request parameters
        String sellerIdParam = request.getParameter("sellerId");
        int sellerId;
        try {
            sellerId = Integer.parseInt(sellerIdParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Seller ID");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        OrderItemDAO orderItemDAO = new OrderItemDAO();
        ProductDAO productDAO = new ProductDAO();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm"); // Define date format

        // Get orders containing products from this seller
        List<Order> sellerOrders = orderDAO.getOrdersBySellerId(sellerId);

        // Set response headers for PDF
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"seller_order_report_" + sellerId + ".pdf\"");

        // Create PDF Document
        Document document = new Document();

        try {
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Add a title
            document.add(new Paragraph("Seller Order Report for Seller ID: " + sellerId));
            document.add(new Paragraph("\n")); // Add some space

            if (sellerOrders != null && !sellerOrders.isEmpty()) {
                // Create a table for order items
                PdfPTable table = new PdfPTable(8); // Number of columns
                table.setWidthPercentage(100); // Table width
                table.setSpacingBefore(10f); // Space before table
                table.setSpacingAfter(10f); // Space after table

                // Set column widths
                float[] columnWidths = { 1f, 1.5f, 1f, 1f, 1f, 2f, 1f, 1f }; // Adjust as needed
                table.setWidths(columnWidths);

                // Add table headers
                String[] headers = { "Order ID", "Order Date", "Customer ID", "Total Amount", "Status", "Product Name",
                        "Quantity", "Unit Price" };
                for (String header : headers) {
                    PdfPCell headerCell = new PdfPCell(new Phrase(header));
                    headerCell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                    headerCell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                    table.addCell(headerCell);
                }

                // Add table data
                for (Order order : sellerOrders) {
                    List<OrderItem> orderItems = orderItemDAO.getByOrderId(order.getOrderId());

                    if (orderItems != null) {
                        for (OrderItem item : orderItems) {
                            if (item.getSellerId() == sellerId) {
                                String productName = "Unknown Product";
                                Product product = productDAO.getById(item.getProductId());
                                if (product != null) {
                                    productName = product.getProductName();
                                }

                                table.addCell(String.valueOf(order.getOrderId()));
                                table.addCell(dateFormat.format(order.getOrderDate()));
                                table.addCell(String.valueOf(order.getCustomerId()));
                                table.addCell(String.format("%.2f", order.getTotalAmount()));
                                table.addCell(order.getStatus());
                                table.addCell(productName);
                                table.addCell(String.valueOf(item.getQuantity()));
                                table.addCell(String.format("%.2f", item.getUnitPrice()));
                            }
                        }
                    }
                }
                document.add(table);
            } else {
                document.add(new Paragraph("No orders found for seller ID " + sellerId));
            }

            document.close();

        } catch (DocumentException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating PDF report");
        }
    }
}