package com.osms.servlet;

import com.osms.dao.OrderDAO;
import com.osms.model.Order;
import com.osms.util.DatabaseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

@WebServlet("/admin/testReport")
public class TestReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.println("<html><head><title>Report Test</title></head><body>");
        out.println("<h1>Report Servlet Test</h1>");

        try {
            // Test database connection
            out.println("<h2>Testing Database Connection</h2>");
            boolean connectionOk = DatabaseUtil.testConnection();
            out.println("<p>Database connection: " + (connectionOk ? "OK" : "FAILED") + "</p>");

            // Test Orders table
            out.println("<h2>Testing Orders Table</h2>");
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                conn = DatabaseUtil.getConnection();
                stmt = conn.createStatement();

                // Check if Orders table exists
                rs = conn.getMetaData().getTables(null, null, "Orders", null);
                boolean tableExists = rs.next();
                out.println("<p>Orders table exists: " + (tableExists ? "YES" : "NO") + "</p>");

                if (tableExists) {
                    // Get column info
                    out.println("<h3>Orders Table Structure:</h3>");
                    out.println("<ul>");
                    rs = conn.getMetaData().getColumns(null, null, "Orders", null);
                    while (rs.next()) {
                        String columnName = rs.getString("COLUMN_NAME");
                        String columnType = rs.getString("TYPE_NAME");
                        out.println("<li>" + columnName + " - " + columnType + "</li>");
                    }
                    out.println("</ul>");

                    // Test query
                    out.println("<h3>Orders Table Data:</h3>");
                    rs = stmt.executeQuery("SELECT * FROM Orders LIMIT 5");

                    if (!rs.next()) {
                        out.println("<p>No orders found in the database.</p>");
                    } else {
                        out.println("<table border='1'>");
                        out.println(
                                "<tr><th>OrderId</th><th>CustomerId</th><th>OrderDate</th><th>TotalAmount</th><th>Status</th></tr>");

                        do {
                            out.println("<tr>");
                            out.println("<td>" + rs.getInt("OrderId") + "</td>");
                            out.println("<td>" + rs.getInt("CustomerId") + "</td>");
                            out.println("<td>" + rs.getDate("OrderDate") + "</td>");
                            out.println("<td>" + rs.getDouble("TotalAmount") + "</td>");
                            out.println("<td>" + rs.getString("Status") + "</td>");
                            out.println("</tr>");
                        } while (rs.next());

                        out.println("</table>");
                    }
                }
            } finally {
                if (rs != null)
                    rs.close();
                if (stmt != null)
                    stmt.close();
                if (conn != null)
                    conn.close();
            }

            // Test OrderDAO
            out.println("<h2>Testing OrderDAO</h2>");
            OrderDAO orderDAO = new OrderDAO();
            List<Order> orders = orderDAO.getAll();

            out.println("<p>OrderDAO.getAll() returned: " + (orders != null ? orders.size() : "null") + " orders</p>");

            if (orders != null && !orders.isEmpty()) {
                out.println("<table border='1'>");
                out.println(
                        "<tr><th>OrderId</th><th>CustomerId</th><th>OrderDate</th><th>TotalAmount</th><th>Status</th></tr>");

                for (Order order : orders) {
                    out.println("<tr>");
                    out.println("<td>" + order.getOrderId() + "</td>");
                    out.println("<td>" + order.getCustomerId() + "</td>");
                    out.println("<td>" + order.getOrderDate() + "</td>");
                    out.println("<td>" + order.getTotalAmount() + "</td>");
                    out.println("<td>" + order.getStatus() + "</td>");
                    out.println("</tr>");
                }

                out.println("</table>");
            }

        } catch (Exception e) {
            out.println("<h2>Error</h2>");
            out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
            out.println("<h3>Stack Trace:</h3>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        }

        out.println("</body></html>");
    }
}