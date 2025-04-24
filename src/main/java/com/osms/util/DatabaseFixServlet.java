package com.osms.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet to fix database issues
 */
@WebServlet("/fixDatabase")
public class DatabaseFixServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DatabaseFixServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Database Fix</title></head><body>");
        out.println("<h1>Database Fix Tool</h1>");
        
        try {
            // Get the SQL script from resources
            InputStream is = getServletContext().getResourceAsStream("/WEB-INF/classes/db/fix_seller_table.sql");
            BufferedReader reader = new BufferedReader(new InputStreamReader(is));
            
            // Build the SQL script as a string
            StringBuilder sqlScript = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sqlScript.append(line).append("\n");
            }
            
            // Split the script by semicolon to execute each statement separately
            String[] statements = sqlScript.toString().split(";");
            
            // Get a database connection
            Connection conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);
            
            try {
                // Execute each SQL statement
                for (String sql : statements) {
                    sql = sql.trim();
                    if (!sql.isEmpty()) {
                        Statement stmt = conn.createStatement();
                        out.println("<p>Executing: " + sql + "</p>");
                        stmt.execute(sql);
                        stmt.close();
                    }
                }
                
                // Commit the transaction
                conn.commit();
                out.println("<p style='color:green;font-weight:bold;'>All SQL statements executed successfully!</p>");
                out.println("<p>The Seller table has been fixed. You can now <a href='" + 
                    request.getContextPath() + "/admin/sellers.jsp'>go back to the Seller page</a>.</p>");
            } catch (Exception e) {
                // Rollback the transaction if an error occurs
                conn.rollback();
                out.println("<p style='color:red;font-weight:bold;'>Error executing SQL: " + e.getMessage() + "</p>");
                e.printStackTrace();
            } finally {
                // Close the connection
                conn.setAutoCommit(true);
                conn.close();
            }
            
        } catch (Exception e) {
            out.println("<p style='color:red;font-weight:bold;'>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
        out.println("</body></html>");
    }
} 