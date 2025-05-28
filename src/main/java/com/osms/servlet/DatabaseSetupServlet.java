package com.osms.servlet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.util.DatabaseSetup;

/**
 * Servlet that runs at application startup to set up or fix the database schema
 */
public class DatabaseSetupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    public void init() throws ServletException {
        super.init();

        try {
            // Run database setup using the DatabaseSetup utility class
            boolean success = DatabaseSetup.initialize();

            if (success) {
                // Log success
                getServletContext().log("Database setup completed successfully");
            } else {
                // Log failure and throw exception
                getServletContext().log("Database setup failed");
                throw new ServletException("Database setup failed");
            }
        } catch (Exception e) {
            getServletContext().log("Database setup failed: " + e.getMessage(), e);
            throw new ServletException("Database setup failed", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        // This servlet does not handle HTTP requests directly
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
    }
}