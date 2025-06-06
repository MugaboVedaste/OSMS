package com.osms.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import com.osms.util.DatabaseSetup;

/**
 * Servlet that provides a manual database initialization endpoint
 * Note: Database initialization is now handled by DatabaseInitListener
 * This servlet only provides a manual re-initialization endpoint
 */
@WebServlet(name = "DatabaseInitServlet", urlPatterns = { "/init-database" })
public class DatabaseInitServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        // Database initialization is now handled by DatabaseInitListener
        // This servlet only provides a manual re-initialization endpoint
    }

    /**
     * Handles the HTTP GET method - allows manual re-initialization of database
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        boolean success = DatabaseSetup.initialize();

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Database Initialization</title>");
            out.println("<style>");
            out.println("body { font-family: Arial, sans-serif; margin: 30px; line-height: 1.6; }");
            out.println(".container { max-width: 800px; margin: 0 auto; }");
            out.println(".success { color: green; }");
            out.println(".error { color: red; }");
            out.println("</style>");
            out.println("</head>");
            out.println("<body>");
            out.println("<div class='container'>");
            out.println("<h1>Database Initialization</h1>");

            if (success) {
                out.println("<p class='success'>Database schema initialized successfully!</p>");
                out.println("<p>All required tables have been created and sample data has been loaded.</p>");
            } else {
                out.println("<p class='error'>Failed to initialize database schema.</p>");
                out.println("<p>Check server logs for more details.</p>");
            }

            out.println("<p><a href='/osms/admin/products.jsp'>Go to Products Page</a></p>");
            out.println("<p><a href='/osms/index.jsp'>Go to Home Page</a></p>");
            out.println("</div>");
            out.println("</body>");
            out.println("</html>");
        }
    }
}