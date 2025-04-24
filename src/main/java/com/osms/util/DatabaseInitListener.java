package com.osms.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Application Lifecycle Listener to initialize the database when the application starts
 */
@WebListener
public class DatabaseInitListener implements ServletContextListener {

    /**
     * Default constructor. 
     */
    public DatabaseInitListener() {
        // Default constructor
    }

    /**
     * @see ServletContextListener#contextDestroyed(ServletContextEvent)
     */
    public void contextDestroyed(ServletContextEvent sce) {
        // No cleanup needed
    }

    /**
     * @see ServletContextListener#contextInitialized(ServletContextEvent)
     */
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Initializing database schema...");
        try {
            boolean success = DatabaseSetup.initialize();
            if (success) {
                System.out.println("Database initialization completed successfully.");
            } else {
                System.err.println("Database initialization failed.");
            }
        } catch (Exception e) {
            System.err.println("Error during database initialization: " + e.getMessage());
            e.printStackTrace();
        }
    }
} 