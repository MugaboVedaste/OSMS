package com.osms.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.util.DatabaseUtil;

/**
 * Servlet to fix database issues with product table foreign key constraints
 */
@WebServlet("/admin/fixDatabase")
public class FixDatabaseServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    public FixDatabaseServlet() {
        super();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Fix Database</title></head><body>");
        out.println("<h1>Database Fix Results</h1>");
        
        Connection conn = null;
        Statement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.createStatement();
            
            // Fix Product table foreign key issues
            out.println("<h2>Fixing Product table foreign key constraints...</h2>");
            
            try {
                // Try to drop standard constraint name
                stmt.executeUpdate("ALTER TABLE Product DROP FOREIGN KEY Product_ibfk_1");
                out.println("<p>Dropped foreign key Product_ibfk_1</p>");
            } catch (SQLException e) {
                out.println("<p>Product_ibfk_1 does not exist: " + e.getMessage() + "</p>");
            }
            
            try {
                // Try to drop custom constraint name
                stmt.executeUpdate("ALTER TABLE Product DROP FOREIGN KEY fk_product_supplier");
                out.println("<p>Dropped foreign key fk_product_supplier</p>");
            } catch (SQLException e) {
                out.println("<p>fk_product_supplier does not exist: " + e.getMessage() + "</p>");
            }
            
            // Add the foreign key constraint with a new name
            stmt.executeUpdate(
                "ALTER TABLE Product " +
                "ADD CONSTRAINT fk_product_supplier_rel " +
                "FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId) " +
                "ON DELETE SET NULL " +
                "ON UPDATE CASCADE"
            );
            
            out.println("<p>Successfully added new foreign key constraint 'fk_product_supplier_rel'</p>");
            out.println("<p style='color: green; font-weight: bold;'>Database fixed successfully!</p>");
            
            // Add a link to go back to the products page
            out.println("<a href='../admin/products.jsp'>Return to Products Page</a>");
            
        } catch (SQLException e) {
            out.println("<p style='color: red;'>Error fixing database: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            
            out.println("</body></html>");
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
} 