package com.osms.util;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;

/**
 * Utility class to set up database tables and schema
 */
public class DatabaseSetup {

    /**
     * Initialize the database schema
     * 
     * @return true if successful, false otherwise
     */
    public static boolean initialize() {
        Connection conn = null;
        Statement stmt = null;

        try {
            // Get a connection to the database
            conn = DatabaseUtil.getConnection();
            stmt = conn.createStatement();

            // Check if the Suppliers table exists
            boolean suppliersExists = tableExists(conn, "suppliers");

            // Check if the Product table exists
            boolean productExists = tableExists(conn, "product");

            // Check if the Seller table exists
            boolean sellerExists = tableExists(conn, "seller");

            // Check if the Customer table exists
            boolean customerExists = tableExists(conn, "customer");

            // Check if the Orders table exists
            boolean ordersExists = tableExists(conn, "orders");

            // Check if the OrderItem table exists
            boolean orderItemExists = tableExists(conn, "orderitem");

            // Create any missing tables
            if (!suppliersExists) {
                createSuppliersTable(conn);
                System.out.println("Suppliers table created successfully.");
            }

            if (!productExists) {
                createProductTable(conn);
                System.out.println("Product table created successfully.");
            } else {
                // Fix the Product table if it exists but has issues
                fixProductTable(conn);
            }

            if (!customerExists) {
                createCustomerTable(conn);
                System.out.println("Customer table created successfully.");
            }

            if (!sellerExists) {
                createSellerTable(conn);
                System.out.println("Seller table created successfully.");
            }

            if (!ordersExists) {
                createOrdersTable(conn);
                System.out.println("Orders table created successfully.");
            }

            if (!orderItemExists) {
                createOrderItemTable(conn);
                System.out.println("OrderItem table created successfully.");
            }

            // Insert sample data if needed
            insertSampleData(conn);

            System.out.println("Database schema initialization completed successfully.");
            return true;
        } catch (SQLException e) {
            System.err.println("Error initializing database schema: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null)
                    stmt.close();
                if (conn != null)
                    conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Check if a table exists in the database
     * 
     * @param conn      Database connection
     * @param tableName Name of the table to check
     * @return true if the table exists, false otherwise
     */
    private static boolean tableExists(Connection conn, String tableName) throws SQLException {
        ResultSet rs = conn.getMetaData().getTables(null, null, tableName, null);
        boolean exists = rs.next();
        rs.close();
        return exists;
    }

    /**
     * Create Suppliers table
     * 
     * @param conn Database connection
     */
    private static void createSuppliersTable(Connection conn) throws SQLException {
        Statement stmt = conn.createStatement();

        stmt.executeUpdate(
                "CREATE TABLE Suppliers (" +
                        "SupplierId INT AUTO_INCREMENT PRIMARY KEY, " +
                        "CompanyName VARCHAR(255) NOT NULL, " +
                        "ContactPerson VARCHAR(255), " +
                        "Email VARCHAR(255), " +
                        "Phone VARCHAR(50), " +
                        "Address VARCHAR(255), " +
                        "City VARCHAR(100), " +
                        "State VARCHAR(100), " +
                        "ZipCode VARCHAR(20), " +
                        "Country VARCHAR(100), " +
                        "Category VARCHAR(100), " +
                        "Status VARCHAR(50) DEFAULT 'Active', " +
                        "Notes TEXT, " +
                        "JoinedDate DATETIME DEFAULT CURRENT_TIMESTAMP" +
                        ")");

        // Insert a default supplier
        stmt.executeUpdate(
                "INSERT INTO Suppliers (CompanyName, ContactPerson, Email, Phone, Address, City, State, Country, Category) "
                        +
                        "VALUES ('Default Supplier', 'John Doe', 'contact@defaultsupplier.com', '123-456-7890', " +
                        "'123 Main St', 'New York', 'NY', 'USA', 'General')");

        stmt.close();
    }

    /**
     * Create Product table
     * 
     * @param conn Database connection
     */
    private static void createProductTable(Connection conn) throws SQLException {
        Statement stmt = conn.createStatement();

        stmt.executeUpdate(
                "CREATE TABLE Product (" +
                        "ProductId INT AUTO_INCREMENT PRIMARY KEY, " +
                        "ProductName VARCHAR(255) NOT NULL, " +
                        "Description TEXT, " +
                        "Price DECIMAL(10, 2) NOT NULL, " +
                        "StockQuantity INT NOT NULL DEFAULT 0, " +
                        "Category VARCHAR(100), " +
                        "SupplierId INT, " +
                        "ExpirationDate DATE, " +
                        "FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId)" +
                        ")");

        stmt.close();
    }

    /**
     * Fix the Product table if it exists but has issues
     * 
     * @param conn Database connection
     */
    private static void fixProductTable(Connection conn) throws SQLException {
        Statement stmt = conn.createStatement();

        try {
            // Check if Description column exists
            ResultSet rs = conn.getMetaData().getColumns(null, null, "Product", "Description");
            if (!rs.next()) {
                // Add Description column if it doesn't exist
                stmt.executeUpdate("ALTER TABLE Product ADD COLUMN Description TEXT");
                System.out.println("Added Description column to Product table.");
            }
            rs.close();

            // Try to drop any existing foreign key constraints on SupplierId
            try {
                // Try standard constraint name
                stmt.executeUpdate("ALTER TABLE Product DROP FOREIGN KEY Product_ibfk_1");
                System.out.println("Dropped foreign key Product_ibfk_1");
            } catch (SQLException e) {
                // Ignore error if constraint doesn't exist
                System.out.println("Product_ibfk_1 does not exist: " + e.getMessage());
            }

            try {
                // Try our custom constraint name
                stmt.executeUpdate("ALTER TABLE Product DROP FOREIGN KEY fk_product_supplier");
                System.out.println("Dropped foreign key fk_product_supplier");
            } catch (SQLException e) {
                // Ignore error if constraint doesn't exist
                System.out.println("fk_product_supplier does not exist: " + e.getMessage());
            }

            // Check if the foreign key constraint already exists
            ResultSet fkRs = conn.createStatement().executeQuery(
                    "SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE " +
                            "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Product' AND CONSTRAINT_NAME = 'fk_product_supplier_rel'");
            boolean fkExists = fkRs.next();
            fkRs.close();

            if (!fkExists) {
                // Add the foreign key constraint with a new name to avoid conflicts
                stmt.executeUpdate(
                        "ALTER TABLE Product " +
                                "ADD CONSTRAINT fk_product_supplier_rel " +
                                "FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId) " +
                                "ON DELETE SET NULL " +
                                "ON UPDATE CASCADE");
                System.out.println("Added Product table foreign key constraint 'fk_product_supplier_rel'.");
            } else {
                System.out.println("Foreign key constraint 'fk_product_supplier_rel' already exists. Skipping add.");
            }
        } catch (SQLException e) {
            System.err.println("Error fixing Product table: " + e.getMessage());
            throw e;
        } finally {
            stmt.close();
        }
    }

    /**
     * Create Customer table
     * 
     * @param conn Database connection
     */
    private static void createCustomerTable(Connection conn) throws SQLException {
        Statement stmt = conn.createStatement();

        stmt.executeUpdate(
                "CREATE TABLE Customer (" +
                        "CustomerId INT AUTO_INCREMENT PRIMARY KEY, " +
                        "FirstName VARCHAR(50) NOT NULL, " +
                        "LastName VARCHAR(50) NOT NULL, " +
                        "Email VARCHAR(100) UNIQUE NOT NULL, " +
                        "Phone VARCHAR(20), " +
                        "Address VARCHAR(255), " +
                        "City VARCHAR(100), " +
                        "State VARCHAR(50), " +
                        "ZipCode VARCHAR(20), " +
                        "Country VARCHAR(50), " +
                        "Password VARCHAR(255) NOT NULL, " +
                        "RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "LastLogin DATETIME, " +
                        "Status VARCHAR(20) DEFAULT 'Active'" +
                        ")");

        stmt.close();
    }

    /**
     * Create Seller table
     * 
     * @param conn Database connection
     */
    private static void createSellerTable(Connection conn) throws SQLException {
        Statement stmt = conn.createStatement();

        stmt.executeUpdate(
                "CREATE TABLE Seller (" +
                        "SellerId INT AUTO_INCREMENT PRIMARY KEY, " +
                        "BusinessName VARCHAR(100) NOT NULL, " +
                        "OwnerName VARCHAR(100) NOT NULL, " +
                        "Email VARCHAR(100) UNIQUE NOT NULL, " +
                        "Phone VARCHAR(20), " +
                        "Address VARCHAR(255), " +
                        "City VARCHAR(100), " +
                        "State VARCHAR(50), " +
                        "ZipCode VARCHAR(20), " +
                        "Country VARCHAR(50), " +
                        "BusinessType VARCHAR(50), " +
                        "TaxId VARCHAR(50), " +
                        "Password VARCHAR(255) NOT NULL, " +
                        "RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "ApprovalStatus VARCHAR(20) DEFAULT 'Pending', " +
                        "LastLogin DATETIME, " +
                        "Rating DECIMAL(3,2) DEFAULT 0.0, " +
                        "CommissionRate DECIMAL(5,2) DEFAULT 5.00, " +
                        "AccountBalance DECIMAL(10,2) DEFAULT 0.00" +
                        ")");

        stmt.close();
    }

    /**
     * Create Orders table
     * 
     * @param conn Database connection
     */
    private static void createOrdersTable(Connection conn) throws SQLException {
        Statement stmt = conn.createStatement();

        stmt.executeUpdate(
                "CREATE TABLE Orders (" +
                        "OrderId INT AUTO_INCREMENT PRIMARY KEY, " +
                        "CustomerId INT, " +
                        "OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "TotalAmount DECIMAL(10,2) NOT NULL, " +
                        "Status VARCHAR(20) DEFAULT 'Pending', " +
                        "ShippingAddress VARCHAR(255), " +
                        "ShippingCity VARCHAR(100), " +
                        "ShippingState VARCHAR(50), " +
                        "ShippingZipCode VARCHAR(20), " +
                        "ShippingCountry VARCHAR(50), " +
                        "PaymentMethod VARCHAR(50), " +
                        "PaymentStatus VARCHAR(20) DEFAULT 'Pending', " +
                        "FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE SET NULL" +
                        ")");

        stmt.close();
    }

    /**
     * Create OrderItem table
     * 
     * @param conn Database connection
     */
    private static void createOrderItemTable(Connection conn) throws SQLException {
        Statement stmt = conn.createStatement();

        // Check if orderitem table exists
        boolean orderItemExists = tableExists(conn, "orderitem");

        if (!orderItemExists) {
            // Create the table if it doesn't exist
            stmt.executeUpdate(
                    "CREATE TABLE orderitem (" +
                            "OrderItemId INT AUTO_INCREMENT PRIMARY KEY, " +
                            "OrderId INT NOT NULL, " +
                            "ProductId INT, " + // ProductId can be null if product is deleted
                            "Quantity INT NOT NULL, " +
                            "UnitPrice DECIMAL(10, 2) NOT NULL, " +
                            "SellerId INT, " + // Added SellerId
                            "FOREIGN KEY (OrderId) REFERENCES orders(OrderId) ON DELETE CASCADE, " +
                            "FOREIGN KEY (ProductId) REFERENCES product(ProductId) ON DELETE SET NULL, " + // Allow NULL
                            "FOREIGN KEY (SellerId) REFERENCES seller(SellerId) ON DELETE SET NULL" + // Added SellerId
                                                                                                      // foreign key
                            ")");
            System.out.println("OrderItem table created successfully with SellerId.");
        } else {
            // If table exists, check if SellerId column exists
            boolean sellerIdColumnExists = columnExists(conn, "orderitem", "SellerId");
            if (!sellerIdColumnExists) {
                // Add SellerId column if it doesn't exist
                stmt.executeUpdate("ALTER TABLE orderitem ADD COLUMN SellerId INT");
                System.out.println("Added SellerId column to existing orderitem table.");
                // Add foreign key constraint after adding the column
                // Check if the foreign key constraint already exists to avoid errors
                try (ResultSet rs = conn.getMetaData().getImportedKeys(null, null, "orderitem")) {
                    boolean fkExists = false;
                    while (rs.next()) {
                        String fkColumnName = rs.getString("FKCOLUMN_NAME");
                        String pkTableName = rs.getString("PKTABLE_NAME");
                        if ("SellerId".equalsIgnoreCase(fkColumnName) && "seller".equalsIgnoreCase(pkTableName)) {
                            fkExists = true;
                            break;
                        }
                    }
                    if (!fkExists) {
                        stmt.executeUpdate(
                                "ALTER TABLE orderitem ADD CONSTRAINT fk_orderitem_seller FOREIGN KEY (SellerId) REFERENCES seller(SellerId) ON DELETE SET NULL");
                        System.out.println("Added foreign key constraint for SellerId to orderitem table.");
                    }
                }
            }
        }

        stmt.close();
    }

    /**
     * Check if a column exists in a table
     *
     * @param conn       Database connection
     * @param tableName  Name of the table
     * @param columnName Name of the column to check
     * @return true if the column exists, false otherwise
     */
    private static boolean columnExists(Connection conn, String tableName, String columnName) throws SQLException {
        ResultSet rs = conn.getMetaData().getColumns(null, null, tableName, columnName);
        boolean exists = rs.next();
        rs.close();
        return exists;
    }

    /**
     * Insert sample data for testing
     * 
     * @param conn Database connection
     */
    private static void insertSampleData(Connection conn) throws SQLException {
        Statement stmt = conn.createStatement();

        System.out.println("Attempting to insert sample data...");

        // Check if we already have suppliers
        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM suppliers");
        rs.next();
        int supplierCount = rs.getInt(1);
        rs.close();

        System.out.println("Suppliers count: " + supplierCount);

        // Add sample suppliers only if the table is empty
        if (supplierCount == 0) {
            stmt.executeUpdate(
                    "INSERT INTO suppliers (CompanyName, ContactPerson, Email, Phone, Address, City, State, Country, Category) "
                            +
                            "VALUES ('Default Supplier', 'John Doe', 'contact@defaultsupplier.com', '123-456-7890', " +
                            "'123 Main St', 'New York', 'NY', 'USA', 'General')");
        }

        // Check if we have sample customers
        rs = stmt.executeQuery("SELECT COUNT(*) FROM customer");
        if (rs.next() && rs.getInt(1) == 0) {
            stmt.executeUpdate(
                    "INSERT INTO customer (FirstName, LastName, Email, Phone, Address, City, State, Country, Password) "
                            +
                            "VALUES ('John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Main St', 'New York', 'NY', 'USA', 'password123'), "
                            +
                            "('Jane', 'Smith', 'jane.smith@example.com', '987-654-3210', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', 'password123')");
        }
        rs.close();

        // Check if we have sample sellers
        rs = stmt.executeQuery("SELECT COUNT(*) FROM seller");
        if (rs.next() && rs.getInt(1) == 0) {
            stmt.executeUpdate(
                    "INSERT INTO seller (BusinessName, OwnerName, Email, Phone, Address, City, State, Country, BusinessType, TaxId, Password, ApprovalStatus) "
                            +
                            "VALUES ('Tech Store Inc.', 'Bob Johnson', 'bob@techstore.com', '555-123-4567', '789 Tech Blvd', 'San Francisco', 'CA', 'USA', 'Electronics', 'TX123456', 'password123', 'Approved'), "
                            +
                            "('Fashion Hub', 'Alice Brown', 'alice@fashionhub.com', '555-987-6543', '321 Fashion St', 'New York', 'NY', 'USA', 'Clothing', 'TX654321', 'password123', 'Approved')");
        }
        rs.close();

        // Check if we have sample orders
        rs = stmt.executeQuery("SELECT COUNT(*) FROM orders");
        if (rs.next() && rs.getInt(1) == 0) {
            // Insert sample orders only if the table is empty
            stmt.executeUpdate(
                    "INSERT INTO orders (CustomerId, OrderDate, TotalAmount, Status) " +
                            "VALUES " +
                            "(1, '2023-01-15', 175.50, 'Delivered')," +
                            "(2, '2023-02-20', 89.99, 'Shipped')," +
                            "(1, '2023-03-10', 45.75, 'Processing')," +
                            "(3, '2023-04-05', 120.00, 'Pending')");
        }
        rs.close();

        // Check if we have sample order items
        rs = stmt.executeQuery("SELECT COUNT(*) FROM orderitem");
        rs.next();
        int orderItemCount = rs.getInt(1);
        rs.close();

        System.out.println("OrderItem count: " + orderItemCount);

        // Insert sample order items only if the table is empty
        if (orderItemCount == 0) {
            // Ensure these sample items link to existing orders, products, and sellers
            stmt.executeUpdate(
                    "INSERT INTO orderitem (OrderId, ProductId, SellerId, Quantity, UnitPrice, Subtotal) VALUES " +
                            "(1, 1, 1, 2, 25.00, 50.00)," + // Example: Order 1, Product 1 (from Seller 1)
                            "(1, 2, 1, 1, 125.50, 125.50)," + // Example: Order 1, Product 2 (from Seller 1)
                            "(2, 3, 2, 3, 29.99, 89.97)," + // Example: Order 2, Product 3 (from Seller 2)
                            "(3, 4, 1, 1, 45.75, 45.75)," + // Example: Order 3, Product 4 (from Seller 1)
                            "(4, 5, 2, 2, 60.00, 120.00)" // Example: Order 4, Product 5 (from Seller 2)
            );
        }

        stmt.close();
    }
}