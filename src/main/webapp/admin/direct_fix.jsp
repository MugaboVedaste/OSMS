<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.osms.util.DatabaseUtil" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Direct Database Fix</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <div class="container mt-5">
        <h2>Database Fix Results</h2>
        <div class="card">
            <div class="card-body">
                <%
                Connection conn = null;
                Statement stmt = null;
                
                try {
                    // Get connection
                    conn = DatabaseUtil.getConnection();
                    stmt = conn.createStatement();
                    
                    out.println("<h4>Executing database fixes...</h4>");
                    
                    // 1. Add Price column if it doesn't exist
                    try {
                        stmt.executeUpdate("ALTER TABLE Product ADD COLUMN Price DECIMAL(10,2) NOT NULL DEFAULT 0.00");
                        out.println("<div class='alert alert-success'>Added Price column to Product table.</div>");
                    } catch (SQLException e) {
                        if (e.getMessage().contains("Duplicate column")) {
                            out.println("<div class='alert alert-info'>Price column already exists.</div>");
                        } else {
                            throw e;
                        }
                    }
                    
                    // 2. Add StockQuantity column if it doesn't exist
                    try {
                        stmt.executeUpdate("ALTER TABLE Product ADD COLUMN StockQuantity INT NOT NULL DEFAULT 0");
                        out.println("<div class='alert alert-success'>Added StockQuantity column to Product table.</div>");
                    } catch (SQLException e) {
                        if (e.getMessage().contains("Duplicate column")) {
                            out.println("<div class='alert alert-info'>StockQuantity column already exists.</div>");
                        } else {
                            throw e;
                        }
                    }
                    
                    // 3. Fix foreign key constraint issues
                    // First disable foreign key checks
                    stmt.executeUpdate("SET foreign_key_checks = 0");
                    
                    // Try to drop foreign keys (might fail if they don't exist)
                    try {
                        stmt.executeUpdate("ALTER TABLE Product DROP FOREIGN KEY Product_ibfk_1");
                        out.println("<div class='alert alert-success'>Dropped foreign key Product_ibfk_1.</div>");
                    } catch (SQLException e) {
                        out.println("<div class='alert alert-info'>Foreign key Product_ibfk_1 doesn't exist or already dropped.</div>");
                    }
                    
                    try {
                        stmt.executeUpdate("ALTER TABLE Product DROP FOREIGN KEY fk_product_supplier");
                        out.println("<div class='alert alert-success'>Dropped foreign key fk_product_supplier.</div>");
                    } catch (SQLException e) {
                        out.println("<div class='alert alert-info'>Foreign key fk_product_supplier doesn't exist or already dropped.</div>");
                    }
                    
                    // Make SupplierId nullable
                    stmt.executeUpdate("ALTER TABLE Product MODIFY COLUMN SupplierId INT NULL");
                    out.println("<div class='alert alert-success'>Made SupplierId column nullable.</div>");
                    
                    // Add back the correct foreign key
                    try {
                        stmt.executeUpdate("ALTER TABLE Product ADD CONSTRAINT fk_product_supplier FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId) ON DELETE SET NULL ON UPDATE CASCADE");
                        out.println("<div class='alert alert-success'>Added proper foreign key constraint.</div>");
                    } catch (SQLException e) {
                        out.println("<div class='alert alert-warning'>Could not add foreign key: " + e.getMessage() + "</div>");
                    }
                    
                    // Re-enable foreign key checks
                    stmt.executeUpdate("SET foreign_key_checks = 1");
                    
                    // 4. Create supplier view
                    try {
                        stmt.executeUpdate("DROP VIEW IF EXISTS supplier");
                        stmt.executeUpdate("CREATE VIEW supplier AS SELECT * FROM Suppliers");
                        out.println("<div class='alert alert-success'>Created 'supplier' view for backward compatibility.</div>");
                    } catch (SQLException e) {
                        out.println("<div class='alert alert-warning'>Could not create supplier view: " + e.getMessage() + "</div>");
                    }
                    
                    out.println("<div class='alert alert-success mt-3'><strong>Database fix completed successfully!</strong></div>");
                    
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                    e.printStackTrace();
                } finally {
                    try {
                        if (stmt != null) stmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                %>
                
                <div class="mt-4">
                    <a href="products.jsp" class="btn btn-primary">Go to Products</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 