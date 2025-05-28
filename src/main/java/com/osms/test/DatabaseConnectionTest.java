package com.osms.test;

import com.osms.util.DatabaseUtil;

/**
 * Simple test class to verify database connection
 */
public class DatabaseConnectionTest {
    
    public static void main(String[] args) {
        System.out.println("Testing database connection...");
        
        boolean connectionSuccessful = DatabaseUtil.testConnection();
        
        if (connectionSuccessful) {
            System.out.println("Database connection successful!");
        } else {
            System.out.println("Database connection failed. Please check your credentials and connection settings.");
        }
    }
} 