package com.osms.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Application Lifecycle Listener to initialize the database when the
 * application starts
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
            // Set an attribute to track initialization
            if (sce.getServletContext().getAttribute("databaseInitialized") == null) {
                boolean success = DatabaseSetup.initialize();
                if (success) {
                    System.out.println("Database initialization completed successfully.");
                    sce.getServletContext().setAttribute("databaseInitialized", true);
                } else {
                    System.err.println("Database initialization failed.");
                }
            } else {
                System.out.println("Database already initialized, skipping initialization.");
            }
        } catch (Exception e) {
            System.err.println("Error during database initialization: " + e.getMessage());
            e.printStackTrace();
        }
    }
}