package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.osms.model.OrderItem;
import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for OrderItem entity
 */
public class OrderItemDAO {

    /**
     * Insert a new order item into the database
     * 
     * @param orderItem The order item to insert
     * @return The ID of the inserted order item, or -1 if insertion failed
     */
    public int insert(OrderItem orderItem) {
        String sql = "INSERT INTO orderitem (OrderId, ProductId, SellerId, Quantity, UnitPrice, Subtotal) VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, orderItem.getOrderId());
            stmt.setInt(2, orderItem.getProductId());
            stmt.setInt(3, orderItem.getSellerId());
            stmt.setInt(4, orderItem.getQuantity());
            stmt.setDouble(5, orderItem.getUnitPrice());
            stmt.setDouble(6, orderItem.getSubtotal());

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

    /**
     * Get an order item by its ID
     * 
     * @param orderItemId The ID of the order item to retrieve
     * @return The order item, or null if not found
     */
    public OrderItem getById(int orderItemId) {
        String sql = "SELECT * FROM orderitem WHERE OrderItemId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        OrderItem orderItem = null;

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, orderItemId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                orderItem = new OrderItem();
                orderItem.setOrderItemId(rs.getInt("OrderItemId"));
                orderItem.setOrderId(rs.getInt("OrderId"));
                orderItem.setProductId(rs.getInt("ProductId"));
                orderItem.setQuantity(rs.getInt("Quantity"));
                orderItem.setUnitPrice(rs.getDouble("UnitPrice"));
                orderItem.setSellerId(rs.getInt("SellerId"));
            }

            return orderItem;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
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

    /**
     * Get all order items for a specific order
     * 
     * @param orderId The ID of the order
     * @return List of order items
     */
    public List<OrderItem> getByOrderId(int orderId) {
        String sql = "SELECT * FROM orderitem WHERE OrderId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<OrderItem> orderItems = new ArrayList<>();

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, orderId);
            rs = stmt.executeQuery();

            while (rs.next()) {
                OrderItem orderItem = new OrderItem();
                orderItem.setOrderItemId(rs.getInt("OrderItemId"));
                orderItem.setOrderId(rs.getInt("OrderId"));
                orderItem.setProductId(rs.getInt("ProductId"));
                orderItem.setQuantity(rs.getInt("Quantity"));
                orderItem.setUnitPrice(rs.getDouble("UnitPrice"));
                orderItem.setSellerId(rs.getInt("SellerId"));
                orderItems.add(orderItem);
            }

            return orderItems;
        } catch (SQLException e) {
            e.printStackTrace();
            return orderItems;
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

    /**
     * Update an existing order item
     * 
     * @param orderItem The order item to update
     * @return true if update was successful, false otherwise
     */
    public boolean update(OrderItem orderItem) {
        String sql = "UPDATE orderitem SET OrderId = ?, ProductId = ?, Quantity = ?, UnitPrice = ?, Subtotal = ? WHERE OrderItemId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, orderItem.getOrderId());
            stmt.setInt(2, orderItem.getProductId());
            stmt.setInt(3, orderItem.getQuantity());
            stmt.setDouble(4, orderItem.getUnitPrice());
            stmt.setDouble(5, orderItem.getSubtotal());
            stmt.setInt(6, orderItem.getOrderItemId());

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null)
                    stmt.close();
                if (conn != null)
                    conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Delete an order item by its ID
     * 
     * @param orderItemId The ID of the order item to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean delete(int orderItemId) {
        String sql = "DELETE FROM orderitem WHERE OrderItemId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, orderItemId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null)
                    stmt.close();
                if (conn != null)
                    conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Delete all order items for a specific order
     * 
     * @param orderId The ID of the order
     * @return true if deletion was successful, false otherwise
     */
    public boolean deleteByOrderId(int orderId) {
        String sql = "DELETE FROM orderitem WHERE OrderId = ?";
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
                if (stmt != null)
                    stmt.close();
                if (conn != null)
                    conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Calculate the total amount for an order
     * 
     * @param orderId The ID of the order
     * @return The total amount
     */
    public double calculateOrderTotal(int orderId) {
        String sql = "SELECT SUM(Subtotal) AS Total FROM orderitem WHERE OrderId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        double total = 0.0;

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, orderId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                total = rs.getDouble("Total");
            }

            return total;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0.0;
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

    /**
     * Get all order items for a specific product
     * 
     * @param productId The ID of the product
     * @return List of order items containing the product
     */
    public List<OrderItem> getByProductId(int productId) {
        String sql = "SELECT * FROM orderitem WHERE ProductId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<OrderItem> orderItems = new ArrayList<>();

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, productId);
            rs = stmt.executeQuery();

            while (rs.next()) {
                OrderItem orderItem = new OrderItem();
                orderItem.setOrderItemId(rs.getInt("OrderItemId"));
                orderItem.setOrderId(rs.getInt("OrderId"));
                orderItem.setProductId(rs.getInt("ProductId"));
                orderItem.setQuantity(rs.getInt("Quantity"));
                orderItem.setUnitPrice(rs.getDouble("UnitPrice"));
                orderItem.setSellerId(rs.getInt("SellerId"));
                orderItems.add(orderItem);
            }

            return orderItems;
        } catch (SQLException e) {
            e.printStackTrace();
            return orderItems;
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

    /**
     * Insert multiple order items in a batch for better performance
     * 
     * @param orderItems List of order items to insert
     * @return true if insertion was successful, false otherwise
     */
    public boolean batchInsert(List<OrderItem> orderItems) {
        String sql = "INSERT INTO orderitem (OrderId, ProductId, SellerId, Quantity, UnitPrice, Subtotal) VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            stmt = conn.prepareStatement(sql);

            for (OrderItem item : orderItems) {
                stmt.setInt(1, item.getOrderId());
                stmt.setInt(2, item.getProductId());
                stmt.setInt(3, item.getSellerId());
                stmt.setInt(4, item.getQuantity());
                stmt.setDouble(5, item.getUnitPrice());
                stmt.setDouble(6, item.getSubtotal());
                stmt.addBatch();
            }

            int[] results = stmt.executeBatch();
            conn.commit();

            // Check if any insertions failed
            for (int result : results) {
                if (result <= 0) {
                    return false;
                }
            }

            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
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