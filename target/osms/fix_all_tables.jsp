<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.osms.util.DatabaseUtil" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Fix All Database Tables</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
        h1, h2 { color: #333; }
        .success { color: green; }
        .error { color: red; }
        .warning { color: orange; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 5px; overflow: auto; }
        .container { max-width: 800px; margin: 0 auto; }
        .table-info { margin-bottom: 30px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Database Schema Fix Tool</h1>
        <p>This tool will update all database tables to match the application code.</p>
        
        <% 
        Connection conn = null;
        Statement stmt = null;
        
        try {
            // Get database connection
            conn = DatabaseUtil.getConnection();
            stmt = conn.createStatement();
            
            out.println("<p class='success'>Connected to database successfully.</p>");
            
            // 1. Fix the Seller table
            out.println("<div class='table-info'>");
            out.println("<h2>Fixing Seller Table</h2>");
            
            // Drop the existing Seller table
            stmt.executeUpdate("DROP TABLE IF EXISTS Seller");
            out.println("<p>Dropped existing Seller table.</p>");
            
            // Create the new Seller table with the correct columns
            String createSellerTableSQL = "CREATE TABLE Seller (" +
                    "SellerId INT AUTO_INCREMENT PRIMARY KEY, " +
                    "CompanyName VARCHAR(100) NOT NULL, " +
                    "ContactName VARCHAR(100), " +
                    "Email VARCHAR(100) NOT NULL UNIQUE, " +
                    "Phone VARCHAR(20), " +
                    "Address TEXT, " +
                    "Password VARCHAR(100), " +
                    "JoinedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
            
            stmt.executeUpdate(createSellerTableSQL);
            out.println("<p>Created new Seller table with the correct structure.</p>");
            
            // Insert a sample seller
            String insertSellerSQL = "INSERT INTO Seller (CompanyName, ContactName, Email, Phone, Address, Password) " +
                    "VALUES ('Test Company', 'John Doe', 'test@example.com', '123-456-7890', '123 Test Street', 'password123')";
            
            stmt.executeUpdate(insertSellerSQL);
            out.println("<p>Inserted sample seller record.</p>");
            out.println("</div>");
            
            // 2. Check and fix the Customer table
            out.println("<div class='table-info'>");
            out.println("<h2>Checking Customer Table</h2>");
            
            ResultSet rs = stmt.executeQuery("SHOW TABLES LIKE 'Customer'");
            boolean customerTableExists = rs.next();
            
            if (customerTableExists) {
                out.println("<p>Customer table exists, checking structure...</p>");
                
                // Create new Customer table with correct structure
                stmt.executeUpdate("DROP TABLE IF EXISTS Customer");
                out.println("<p>Dropped existing Customer table.</p>");
            } else {
                out.println("<p>Customer table does not exist, creating it...</p>");
            }
            
            String createCustomerTableSQL = "CREATE TABLE Customer (" +
                    "CustomerId INT AUTO_INCREMENT PRIMARY KEY, " +
                    "FirstName VARCHAR(50) NOT NULL, " +
                    "LastName VARCHAR(50) NOT NULL, " +
                    "Email VARCHAR(100) NOT NULL UNIQUE, " +
                    "Phone VARCHAR(20), " +
                    "Address TEXT, " +
                    "City VARCHAR(50), " +
                    "Password VARCHAR(100) NOT NULL, " +
                    "RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
            
            stmt.executeUpdate(createCustomerTableSQL);
            out.println("<p>Created Customer table with the correct structure.</p>");
            
            // Insert a sample customer
            String insertCustomerSQL = "INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, Password) " +
                    "VALUES ('Jane', 'Doe', 'jane@example.com', '123-456-7890', '456 Sample Ave', 'Sampleville', 'password123')";
            
            stmt.executeUpdate(insertCustomerSQL);
            out.println("<p>Inserted sample customer record.</p>");
            out.println("</div>");
            
            // 3. Check and fix the Users table
            out.println("<div class='table-info'>");
            out.println("<h2>Checking Users Table</h2>");
            
            rs = stmt.executeQuery("SHOW TABLES LIKE 'Users'");
            boolean usersTableExists = rs.next();
            
            if (usersTableExists) {
                out.println("<p>Users table exists, checking structure...</p>");
                
                // Drop Users table to recreate with correct structure
                stmt.executeUpdate("DROP TABLE IF EXISTS Users");
                out.println("<p>Dropped existing Users table.</p>");
            } else {
                out.println("<p>Users table does not exist, creating it...</p>");
            }
            
            String createUsersTableSQL = "CREATE TABLE Users (" +
                    "UserId INT AUTO_INCREMENT PRIMARY KEY, " +
                    "Username VARCHAR(100) NOT NULL UNIQUE, " +
                    "Password VARCHAR(100) NOT NULL, " +
                    "UserType ENUM('Admin', 'Seller', 'Customer') NOT NULL, " +
                    "SellerId INT NULL, " +
                    "CustomerId INT NULL, " +
                    "CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
            
            stmt.executeUpdate(createUsersTableSQL);
            out.println("<p>Created Users table with the correct structure.</p>");
            
            // Insert admin user
            String insertAdminSQL = "INSERT INTO Users (Username, Password, UserType) " +
                    "VALUES ('admin', 'admin123', 'Admin')";
            
            stmt.executeUpdate(insertAdminSQL);
            out.println("<p>Inserted admin user record.</p>");
            
            // Add customer user
            String insertCustomerUserSQL = "INSERT INTO Users (Username, Password, UserType, CustomerId) " +
                    "VALUES ('jane@example.com', 'password123', 'Customer', 1)";
            
            stmt.executeUpdate(insertCustomerUserSQL);
            out.println("<p>Inserted customer user record.</p>");
            
            // Add seller user
            String insertSellerUserSQL = "INSERT INTO Users (Username, Password, UserType, SellerId) " +
                    "VALUES ('test@example.com', 'password123', 'Seller', 1)";
            
            stmt.executeUpdate(insertSellerUserSQL);
            out.println("<p>Inserted seller user record.</p>");
            out.println("</div>");
            
            // 4. Check and fix the Product table
            out.println("<div class='table-info'>");
            out.println("<h2>Checking Product Table</h2>");
            
            rs = stmt.executeQuery("SHOW TABLES LIKE 'Product'");
            boolean productTableExists = rs.next();
            
            if (productTableExists) {
                out.println("<p>Product table exists, checking structure...</p>");
                
                // Drop Product table to recreate with correct structure
                stmt.executeUpdate("DROP TABLE IF EXISTS Product");
                out.println("<p>Dropped existing Product table.</p>");
            } else {
                out.println("<p>Product table does not exist, creating it...</p>");
            }
            
            String createProductTableSQL = "CREATE TABLE Product (" +
                    "ProductId INT AUTO_INCREMENT PRIMARY KEY, " +
                    "ProductName VARCHAR(100) NOT NULL, " +
                    "Description TEXT, " +
                    "Price DECIMAL(10,2) NOT NULL, " +
                    "StockQuantity INT NOT NULL DEFAULT 0, " +
                    "Category VARCHAR(50), " +
                    "SupplierId INT, " +
                    "ExpirationDate DATE NULL)";
            
            stmt.executeUpdate(createProductTableSQL);
            out.println("<p>Created Product table with the correct structure.</p>");
            
            // Insert sample product
            String insertProductSQL = "INSERT INTO Product (ProductName, Description, Price, StockQuantity, Category) " +
                    "VALUES ('Sample Product', 'This is a sample product', 19.99, 100, 'Sample Category')";
            
            stmt.executeUpdate(insertProductSQL);
            out.println("<p>Inserted sample product record.</p>");
            out.println("</div>");
            
            // 5. Check and fix the Orders and OrderItem tables if needed
            out.println("<div class='table-info'>");
            out.println("<h2>Checking Orders & OrderItem Tables</h2>");
            
            // Check if Orders table exists
            rs = stmt.executeQuery("SHOW TABLES LIKE 'Orders'");
            boolean ordersTableExists = rs.next();
            
            if (ordersTableExists) {
                out.println("<p>Orders table exists, checking structure...</p>");
                
                // Drop Orders table to recreate with correct structure
                stmt.executeUpdate("DROP TABLE IF EXISTS Orders");
                out.println("<p>Dropped existing Orders table.</p>");
            } else {
                out.println("<p>Orders table does not exist, creating it...</p>");
            }
            
            String createOrdersTableSQL = "CREATE TABLE Orders (" +
                    "OrderId INT AUTO_INCREMENT PRIMARY KEY, " +
                    "CustomerId INT NOT NULL, " +
                    "OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "TotalAmount DECIMAL(10,2) NOT NULL, " +
                    "Status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending')";
            
            stmt.executeUpdate(createOrdersTableSQL);
            out.println("<p>Created Orders table with the correct structure.</p>");
            
            // Check if OrderItem table exists
            rs = stmt.executeQuery("SHOW TABLES LIKE 'OrderItem'");
            boolean orderItemTableExists = rs.next();
            
            if (orderItemTableExists) {
                out.println("<p>OrderItem table exists, checking structure...</p>");
                
                // Drop OrderItem table to recreate with correct structure
                stmt.executeUpdate("DROP TABLE IF EXISTS OrderItem");
                out.println("<p>Dropped existing OrderItem table.</p>");
            } else {
                out.println("<p>OrderItem table does not exist, creating it...</p>");
            }
            
            String createOrderItemTableSQL = "CREATE TABLE OrderItem (" +
                    "OrderItemId INT AUTO_INCREMENT PRIMARY KEY, " +
                    "OrderId INT NOT NULL, " +
                    "ProductId INT NOT NULL, " +
                    "SellerId INT, " +
                    "Quantity INT NOT NULL, " +
                    "UnitPrice DECIMAL(10,2) NOT NULL, " +
                    "Subtotal DECIMAL(10,2) NOT NULL, " +
                    "FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE, " +
                    "FOREIGN KEY (ProductId) REFERENCES Product(ProductId) ON DELETE SET NULL, " +
                    "FOREIGN KEY (SellerId) REFERENCES Seller(SellerId) ON DELETE SET NULL" +
                    ")";
            
            stmt.executeUpdate(createOrderItemTableSQL);
            out.println("<p>Created OrderItem table with the correct structure.</p>");
            out.println("</div>");
            
            out.println("<h2 class='success'>Database schema update completed successfully!</h2>");
            out.println("<p>All tables have been properly configured for the application to work correctly.</p>");
            
        } catch (Exception e) {
            out.println("<p class='error'>Error updating database schema: " + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre>");
        } finally {
            // Close resources
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
                out.println("<p>Database resources closed.</p>");
            } catch (Exception e) {
                out.println("<p class='error'>Error closing database resources: " + e.getMessage() + "</p>");
            }
        }
        %>
        
        <div style="margin-top: 30px">
            <p><a href="index.jsp">Return to Home</a></p>
        </div>
    </div>
</body>
</html> 