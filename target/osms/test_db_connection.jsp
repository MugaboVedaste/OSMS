<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.osms.util.DatabaseUtil" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Database Connection Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .success { color: green; }
        .error { color: red; }
        table { border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Database Connection Test</h1>
    
    <h2>Database Settings</h2>
    <p>JDBC URL: <%= DatabaseUtil.JDBC_URL %></p>
    <p>JDBC User: <%= DatabaseUtil.JDBC_USER %></p>
    <p>JDBC Password: [hidden for security]</p>
    
    <h2>Connection Test Results:</h2>
    
    <%
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        // Load the JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Establish connection
        conn = DriverManager.getConnection(
            DatabaseUtil.JDBC_URL, 
            DatabaseUtil.JDBC_USER, 
            DatabaseUtil.JDBC_PASSWORD
        );
        
        if (conn != null) {
            out.println("<p class='success'>✅ Database connection successful!</p>");
            
            // Get database metadata
            DatabaseMetaData metaData = conn.getMetaData();
            out.println("<p>Connected to: " + metaData.getDatabaseProductName() + " " + 
                      metaData.getDatabaseProductVersion() + "</p>");
            
            // Show tables
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SHOW TABLES");
            
            if (rs.next()) {
                out.println("<h3>Tables in database:</h3>");
                out.println("<table>");
                out.println("<tr><th>Table Name</th></tr>");
                
                do {
                    out.println("<tr><td>" + rs.getString(1) + "</td></tr>");
                } while (rs.next());
                
                out.println("</table>");
            } else {
                out.println("<p>No tables found in the database.</p>");
            }
            
            // Test suppliers table if it exists
            try {
                rs = stmt.executeQuery("SELECT COUNT(*) FROM Suppliers");
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("<p>Number of suppliers in database: " + count + "</p>");
                }
            } catch (SQLException e) {
                out.println("<p class='error'>Error checking suppliers: " + e.getMessage() + "</p>");
            }
        }
    } catch (ClassNotFoundException e) {
        out.println("<p class='error'>❌ JDBC Driver not found: " + e.getMessage() + "</p>");
    } catch (SQLException e) {
        out.println("<p class='error'>❌ Database connection failed: " + e.getMessage() + "</p>");
    } finally {
        // Close resources
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            out.println("<p class='error'>Error closing resources: " + e.getMessage() + "</p>");
        }
    }
    %>
</body>
</html> 