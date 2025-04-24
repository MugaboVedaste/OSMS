package com.osms.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.util.DatabaseUtil;

/**
 * Servlet to check the structure of database tables
 */
@WebServlet("/checkTables")
public class CheckTableStructureServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CheckTableStructureServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Database Structure</title>");
        out.println("<style>table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid #ddd; padding: 8px; } tr:nth-child(even) { background-color: #f2f2f2; } th { padding-top: 12px; padding-bottom: 12px; text-align: left; background-color: #4CAF50; color: white; }</style>");
        out.println("</head><body>");
        out.println("<h1>Database Table Structure</h1>");
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            
            // Get tables
            out.println("<h2>Tables</h2>");
            out.println("<table><tr><th>Table Name</th><th>Table Type</th></tr>");
            try (ResultSet tables = metaData.getTables(null, null, "%", new String[]{"TABLE"})) {
                while (tables.next()) {
                    String tableName = tables.getString("TABLE_NAME");
                    String tableType = tables.getString("TABLE_TYPE");
                    out.println("<tr><td>" + tableName + "</td><td>" + tableType + "</td></tr>");
                }
            }
            out.println("</table>");
            
            // Get Seller table columns
            out.println("<h2>Seller Table Columns</h2>");
            out.println("<table><tr><th>Column Name</th><th>Type</th><th>Size</th><th>Nullable</th></tr>");
            try (ResultSet columns = metaData.getColumns(null, null, "Seller", null)) {
                while (columns.next()) {
                    String columnName = columns.getString("COLUMN_NAME");
                    String columnType = columns.getString("TYPE_NAME");
                    int columnSize = columns.getInt("COLUMN_SIZE");
                    String nullable = columns.getInt("NULLABLE") == DatabaseMetaData.columnNullable ? "Yes" : "No";
                    out.println("<tr><td>" + columnName + "</td><td>" + columnType + "</td><td>" + columnSize + "</td><td>" + nullable + "</td></tr>");
                }
            }
            out.println("</table>");
            
            // Fix Actions section
            out.println("<h2>Fix Actions</h2>");
            
            // Check for and add missing columns
            Statement stmt = conn.createStatement();
            
            // Check for JoinedDate column
            boolean joinedDateExists = false;
            try (ResultSet rs = stmt.executeQuery("SHOW COLUMNS FROM Seller LIKE 'JoinedDate'")) {
                joinedDateExists = rs.next();
                if (!joinedDateExists) {
                    // Column doesn't exist, add it
                    out.println("<p>JoinedDate column doesn't exist. Adding it...</p>");
                    stmt.executeUpdate("ALTER TABLE Seller ADD COLUMN JoinedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
                    out.println("<p style='color:green'>JoinedDate column added successfully!</p>");
                } else {
                    out.println("<p>JoinedDate column already exists.</p>");
                }
            }
            
            // Check for RegistrationDate column
            boolean registrationDateExists = false;
            String defaultValue = null;
            try (ResultSet rs = stmt.executeQuery("SHOW COLUMNS FROM Seller LIKE 'RegistrationDate'")) {
                registrationDateExists = rs.next();
                if (registrationDateExists) {
                    defaultValue = rs.getString("Default");
                }
            }
            
            if (!registrationDateExists) {
                // Column doesn't exist, add it
                out.println("<p>RegistrationDate column doesn't exist. Adding it...</p>");
                stmt.executeUpdate("ALTER TABLE Seller ADD COLUMN RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
                out.println("<p style='color:green'>RegistrationDate column added successfully!</p>");
            } else if (defaultValue == null) {
                // Column exists but has no default value
                out.println("<p>RegistrationDate column exists but has no default value. Adding default value...</p>");
                stmt.executeUpdate("ALTER TABLE Seller MODIFY COLUMN RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
                out.println("<p style='color:green'>RegistrationDate default value added successfully!</p>");
            } else {
                out.println("<p>RegistrationDate column exists with default value: " + defaultValue + "</p>");
            }
            
            // Display update form to fix existing records with NULL RegistrationDate
            out.println("<h3>Fix Existing Records</h3>");
            out.println("<p>If you have existing records with NULL values for JoinedDate or RegistrationDate, click the button below to fix them:</p>");
            out.println("<form method='post' action='" + request.getContextPath() + "/checkTables'>");
            out.println("<input type='submit' value='Fix Existing Records' style='padding: 10px; background-color: #4CAF50; color: white; border: none; cursor: pointer;'>");
            out.println("</form>");
            
            // Link to the main page
            out.println("<p><a href='" + request.getContextPath() + "/admin/sellers.jsp'>Go to Sellers Page</a></p>");
            
        } catch (Exception e) {
            out.println("<h2>Error</h2>");
            out.println("<p style='color:red'>" + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
        out.println("</body></html>");
    }
    
    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Fix Existing Records</title>");
        out.println("<style>body { font-family: Arial, sans-serif; margin: 20px; }</style>");
        out.println("</head><body>");
        out.println("<h1>Fixing Existing Records</h1>");
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            Statement stmt = conn.createStatement();
            
            // Fix JoinedDate NULL values
            int joinedDateUpdated = stmt.executeUpdate("UPDATE Seller SET JoinedDate = CURRENT_TIMESTAMP WHERE JoinedDate IS NULL");
            out.println("<p>Fixed " + joinedDateUpdated + " records with NULL JoinedDate values.</p>");
            
            // Fix RegistrationDate NULL values
            int regDateUpdated = stmt.executeUpdate("UPDATE Seller SET RegistrationDate = CURRENT_TIMESTAMP WHERE RegistrationDate IS NULL");
            out.println("<p>Fixed " + regDateUpdated + " records with NULL RegistrationDate values.</p>");
            
            out.println("<p style='color:green'>Database fix completed successfully!</p>");
            out.println("<p><a href='" + request.getContextPath() + "/admin/sellers.jsp'>Return to Sellers Page</a></p>");
            
        } catch (Exception e) {
            out.println("<h2>Error</h2>");
            out.println("<p style='color:red'>" + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
        out.println("</body></html>");
    }
} 