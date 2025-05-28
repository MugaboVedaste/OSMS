package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for Users authentication
 */
public class UserDAO {

    /**
     * Add a new user to the authentication system
     * 
     * @param username Username (usually email)
     * @param password Password
     * @param userType Type of user (Admin, Customer, Seller)
     * @param customerId ID of customer if userType is Customer, null otherwise
     * @param sellerId ID of seller if userType is Seller, null otherwise
     * @return true if user was added successfully, false otherwise
     */
    public boolean addUser(String username, String password, String userType, Integer customerId, Integer sellerId) {
        String sql = "INSERT INTO Users (Username, Password, UserType, CustomerId, SellerId) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password);
            stmt.setString(3, userType);
            
            if (customerId != null) {
                stmt.setInt(4, customerId);
            } else {
                stmt.setNull(4, java.sql.Types.INTEGER);
            }
            
            if (sellerId != null) {
                stmt.setInt(5, sellerId);
            } else {
                stmt.setNull(5, java.sql.Types.INTEGER);
            }
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Authenticate a user
     * 
     * @param username Username (usually email)
     * @param password Password
     * @return Map with authentication result or null if authentication failed
     */
    public Map<String, Object> authenticate(String username, String password) {
        String sql = "SELECT * FROM Users WHERE Username = ? AND Password = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("userId", rs.getInt("UserId"));
                userInfo.put("username", rs.getString("Username"));
                userInfo.put("userType", rs.getString("UserType"));
                
                // Get the ID based on user type
                String userType = rs.getString("UserType");
                if ("Customer".equals(userType)) {
                    userInfo.put("entityId", rs.getInt("CustomerId"));
                } else if ("Seller".equals(userType)) {
                    userInfo.put("entityId", rs.getInt("SellerId"));
                }
                
                return userInfo;
            }
            
            return null;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Update user password
     * 
     * @param userId User ID
     * @param newPassword New password
     * @return true if update was successful, false otherwise
     */
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE Users SET Password = ? WHERE UserId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, newPassword);
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Delete a user
     * 
     * @param userId User ID
     * @return true if deletion was successful, false otherwise
     */
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM Users WHERE UserId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
} 