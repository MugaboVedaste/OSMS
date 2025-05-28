package com.osms.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.osms.util.DatabaseUtil;

/**
 * Servlet implementation class LoginServlet
 */
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to login page
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String userType = request.getParameter("userType");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();

            // Special case for admin login
            if ("Admin".equals(userType)) {
                String adminSql = "SELECT * FROM Users WHERE Username = ? AND Password = ? AND UserType = 'Admin'";
                try (PreparedStatement adminStmt = conn.prepareStatement(adminSql)) {
                    adminStmt.setString(1, username);
                    adminStmt.setString(2, password);
                    try (ResultSet adminRs = adminStmt.executeQuery()) {
                        if (adminRs.next()) {
                            // Admin found, create session
                            HttpSession session = request.getSession();
                            session.setAttribute("userId", adminRs.getInt("UserId"));
                            session.setAttribute("username", username);
                            session.setAttribute("userType", "Admin");

                            // Redirect to admin dashboard
                            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
                            return;
                        }
                    }
                }
            }

            // First, check if the user exists in the Users table
            String sql = "SELECT * FROM Users WHERE Username = ? AND Password = ?";
            if (userType != null && !userType.isEmpty()) {
                sql = "SELECT * FROM Users WHERE Username = ? AND Password = ? AND UserType = ?";
            }

            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password);

            if (userType != null && !userType.isEmpty()) {
                stmt.setString(3, userType);
            }

            rs = stmt.executeQuery();

            if (rs.next()) {
                // User found, create session
                HttpSession session = request.getSession();
                session.setAttribute("userId", rs.getInt("UserId"));
                session.setAttribute("username", username);

                // Get the user type if not specified
                if (userType == null || userType.isEmpty()) {
                    userType = rs.getString("UserType");
                }

                session.setAttribute("userType", userType);

                // Set the appropriate ID based on user type
                try {
                    int sellerId = rs.getInt("SellerId");
                    if (sellerId > 0) {
                        session.setAttribute("sellerId", sellerId);
                    }
                } catch (SQLException e) {
                    // SellerId column might not exist, ignore
                }

                try {
                    int customerId = rs.getInt("CustomerId");
                    if (customerId > 0) {
                        session.setAttribute("customerId", customerId);
                    }
                } catch (SQLException e) {
                    // CustomerId column might not exist, ignore
                }

                try {
                    int supplierId = rs.getInt("SupplierId");
                    if (supplierId > 0) {
                        session.setAttribute("supplierId", supplierId);
                    }
                } catch (SQLException e) {
                    // SupplierId column might not exist, ignore
                }

                // Redirect based on user type
                switch (userType) {
                    case "Admin":
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
                        break;
                    case "Seller":
                        response.sendRedirect(request.getContextPath() + "/seller/dashboard.jsp");
                        break;
                    case "Customer":
                        response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
                        break;
                    default:
                        response.sendRedirect(request.getContextPath() + "/login.jsp");
                }
            } else {
                // Try to find the customer by email (username) and password directly
                if ("Customer".equals(userType) || userType == null || userType.isEmpty()) {
                    String customerSql = "SELECT * FROM Customer WHERE Email = ? AND Password = ?";
                    try (PreparedStatement custStmt = conn.prepareStatement(customerSql)) {
                        custStmt.setString(1, username);
                        custStmt.setString(2, password);

                        try (ResultSet custRs = custStmt.executeQuery()) {
                            if (custRs.next()) {
                                // Customer found, but not in Users table - fix this
                                int customerId = custRs.getInt("CustomerId");

                                // Add entry to Users table
                                String addUserSql = "INSERT INTO Users (Username, Password, UserType, CustomerId) VALUES (?, ?, ?, ?)";
                                try (PreparedStatement addUserStmt = conn.prepareStatement(addUserSql)) {
                                    addUserStmt.setString(1, username);
                                    addUserStmt.setString(2, password);
                                    addUserStmt.setString(3, "Customer");
                                    addUserStmt.setInt(4, customerId);

                                    addUserStmt.executeUpdate();

                                    // Create session
                                    HttpSession session = request.getSession();
                                    session.setAttribute("username", username);
                                    session.setAttribute("userType", "Customer");
                                    session.setAttribute("customerId", customerId);

                                    // Redirect to customer dashboard
                                    response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
                                    return;
                                }
                            }
                        }
                    }
                }

                // Invalid credentials
                request.setAttribute("errorMessage", "Invalid username, password, or user type.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } finally {
            try {
                if (rs != null)
                    rs.close();
                if (stmt != null)
                    stmt.close();
                if (conn != null)
                    conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}