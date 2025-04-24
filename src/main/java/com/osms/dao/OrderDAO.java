package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.osms.model.Order;
import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for Order entity
 */
public class OrderDAO {

    /**
     * Insert a new order into the database
     * 
     * @param order The order to insert
     * @return The ID of the inserted order, or -1 if insertion failed
     */
    public int insert(Order order) {
        String sql = "INSERT INTO Orders (CustomerId, OrderDate, TotalAmount, Status) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, order.getCustomerId());
            
            if (order.getOrderDate() != null) {
                stmt.setDate(2, new java.sql.Date(order.getOrderDate().getTime()));
            } else {
                stmt.setDate(2, new java.sql.Date(System.currentTimeMillis()));
            }
            
            stmt.setDouble(3, order.getTotalAmount());
            stmt.setString(4, order.getStatus());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows == 0) {
                return -1;
            }
            
            rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            } else {
                return -1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
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
     * Get an order by its ID
     * 
     * @param orderId The ID of the order to retrieve
     * @return The order, or null if not found
     */
    public Order getById(int orderId) {
        String sql = "SELECT * FROM Orders WHERE OrderId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Order order = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, orderId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                order = new Order();
                order.setOrderId(rs.getInt("OrderId"));
                order.setCustomerId(rs.getInt("CustomerId"));
                order.setOrderDate(rs.getDate("OrderDate"));
                order.setTotalAmount(rs.getDouble("TotalAmount"));
                order.setStatus(rs.getString("Status"));
            }
            
            return order;
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
     * Get all orders for a specific customer
     * 
     * @param customerId The ID of the customer
     * @return List of customer's orders
     */
    public List<Order> getByCustomerId(int customerId) {
        String sql = "SELECT * FROM Orders WHERE CustomerId = ? ORDER BY OrderDate DESC";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Order> orders = new ArrayList<>();
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, customerId);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("OrderId"));
                order.setCustomerId(rs.getInt("CustomerId"));
                order.setOrderDate(rs.getDate("OrderDate"));
                order.setTotalAmount(rs.getDouble("TotalAmount"));
                order.setStatus(rs.getString("Status"));
                orders.add(order);
            }
            
            return orders;
        } catch (SQLException e) {
            e.printStackTrace();
            return orders;
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
     * Get all orders
     * 
     * @return List of all orders
     */
    public List<Order> getAll() {
        String sql = "SELECT * FROM Orders ORDER BY OrderDate DESC";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Order> orders = new ArrayList<>();
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("OrderId"));
                order.setCustomerId(rs.getInt("CustomerId"));
                order.setOrderDate(rs.getDate("OrderDate"));
                order.setTotalAmount(rs.getDouble("TotalAmount"));
                order.setStatus(rs.getString("Status"));
                orders.add(order);
            }
            
            return orders;
        } catch (SQLException e) {
            e.printStackTrace();
            return orders;
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
     * Update an existing order
     * 
     * @param order The order to update
     * @return true if update was successful, false otherwise
     */
    public boolean update(Order order) {
        String sql = "UPDATE Orders SET CustomerId = ?, OrderDate = ?, TotalAmount = ?, Status = ? WHERE OrderId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, order.getCustomerId());
            
            if (order.getOrderDate() != null) {
                stmt.setDate(2, new java.sql.Date(order.getOrderDate().getTime()));
            } else {
                stmt.setDate(2, new java.sql.Date(System.currentTimeMillis()));
            }
            
            stmt.setDouble(3, order.getTotalAmount());
            stmt.setString(4, order.getStatus());
            stmt.setInt(5, order.getOrderId());
            
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
     * Update order status
     * 
     * @param orderId The ID of the order to update
     * @param status The new status
     * @return true if update was successful, false otherwise
     */
    public boolean updateStatus(int orderId, String status) {
        String sql = "UPDATE Orders SET Status = ? WHERE OrderId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, status);
            stmt.setInt(2, orderId);
            
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
     * Delete an order by its ID
     * 
     * @param orderId The ID of the order to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean delete(int orderId) {
        String sql = "DELETE FROM Orders WHERE OrderId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, orderId);
            
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