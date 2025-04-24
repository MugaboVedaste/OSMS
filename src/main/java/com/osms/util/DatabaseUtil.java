package com.osms.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class for database operations
 */
public class DatabaseUtil {
    public static final String JDBC_URL = "jdbc:mysql://localhost:3306/osms_db";
    public static final String JDBC_USER = "root";
    // Update password to match what you're actually using in MySQL
    public static final String JDBC_PASSWORD = "Mugabo$123";  // MySQL root password

    /**
     * Get a database connection
     * 
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Return connection
            System.out.println("DatabaseUtil: Connecting to database at " + JDBC_URL);
            return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
        } catch (ClassNotFoundException e) {
            System.out.println("DatabaseUtil: MySQL JDBC Driver not found");
            throw new SQLException("MySQL JDBC Driver not found", e);
        } catch (SQLException e) {
            System.out.println("DatabaseUtil: Failed to connect to database: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Close a database connection safely
     * 
     * @param conn Connection to close
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Test database connection
     * 
     * @return true if connection is successful, false otherwise
     */
    public static boolean testConnection() {
        Connection connection = null;
        try {
            connection = getConnection();
            return connection != null;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeConnection(connection);
        }
    }
} 