package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
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
        String sql = "INSERT INTO orders (CustomerId, OrderDate, TotalAmount, Status) VALUES (?, ?, ?, ?)";
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
     * Get an order by its ID
     * 
     * @param orderId The ID of the order to retrieve
     * @return The order, or null if not found
     */
    public Order getById(int orderId) {
        String sql = "SELECT * FROM orders WHERE OrderId = ?";
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
     * Get all orders for a specific customer
     * 
     * @param customerId The ID of the customer
     * @return List of customer's orders
     */
    public List<Order> getByCustomerId(int customerId) {
        String sql = "SELECT * FROM orders WHERE CustomerId = ? ORDER BY OrderDate DESC";
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
     * Get all orders
     * 
     * @return List of all orders
     */
    public List<Order> getAll() {
        String sql = "SELECT * FROM orders ORDER BY OrderDate DESC";
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
     * Update an existing order
     * 
     * @param order The order to update
     * @return true if update was successful, false otherwise
     */
    public boolean update(Order order) {
        String sql = "UPDATE orders SET CustomerId = ?, OrderDate = ?, TotalAmount = ?, Status = ? WHERE OrderId = ?";
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
     * Update order status
     * 
     * @param orderId The ID of the order to update
     * @param status  The new status
     * @return true if update was successful, false otherwise
     */
    public boolean updateStatus(int orderId, String status) {
        String sql = "UPDATE orders SET Status = ? WHERE OrderId = ?";
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
     * Delete an order by its ID
     * 
     * @param orderId The ID of the order to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean delete(int orderId) {
        String sql = "DELETE FROM orders WHERE OrderId = ?";
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
     * Get orders by date range
     * 
     * @param startDate Start date (inclusive)
     * @param endDate   End date (inclusive)
     * @return List of orders in the date range
     */
    public List<Order> getOrdersByDateRange(Date startDate, Date endDate) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE 1=1";
        if (startDate != null)
            sql += " AND OrderDate >= ?";
        if (endDate != null)
            sql += " AND OrderDate <= ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            int idx = 1;
            if (startDate != null)
                stmt.setDate(idx++, new java.sql.Date(startDate.getTime()));
            if (endDate != null)
                stmt.setDate(idx++, new java.sql.Date(endDate.getTime()));
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
        } catch (SQLException e) {
            e.printStackTrace();
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
        return orders;
    }

    /**
     * Get all orders containing products from a specific seller
     * 
     * @param sellerId The ID of the seller
     * @return List of orders
     */
    public List<Order> getBySellerId(int sellerId) {
        String sql = "SELECT DISTINCT o.* FROM orders o " +
                "JOIN orderitem oi ON o.OrderId = oi.OrderId " +
                "JOIN product p ON oi.ProductId = p.ProductId " +
                "WHERE p.SellerId = ? " +
                "ORDER BY o.OrderDate DESC";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Order> orders = new ArrayList<>();

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, sellerId);
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
     * Get all orders that contain products from a specific seller.
     *
     * @param sellerId The ID of the seller.
     * @return A list of orders containing products from the seller.
     */
    public List<Order> getOrdersBySellerId(int sellerId) {
        List<Order> sellerOrders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        String sql = "SELECT DISTINCT o.* FROM orders o JOIN orderitem oi ON o.OrderId = oi.OrderId WHERE oi.SellerId = ?";

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, sellerId);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("OrderId"));
                order.setCustomerId(rs.getInt("CustomerId"));
                order.setOrderDate(rs.getDate("OrderDate"));
                order.setTotalAmount(rs.getDouble("TotalAmount"));
                order.setStatus(rs.getString("Status"));
                // Set other order fields as needed
                sellerOrders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
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
        return sellerOrders;
    }

    /**
     * Get the count of orders for a specific customer.
     *
     * @param customerId The ID of the customer.
     * @return The number of orders for the customer.
     * @throws SQLException if a database access error occurs.
     */
    public int getOrderCountByCustomerId(Integer customerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM orders WHERE CustomerId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        int orderCount = 0;

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, customerId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                orderCount = rs.getInt(1);
            }
        } finally {
            try {
                if (rs != null)
                    rs.close();
                if (stmt != null)
                    stmt.close();
                if (conn != null)
                    conn.close();
            } catch (SQLException e) {
                e.printStackTrace(); // Log the exception
            }
        }
        return orderCount;
    }
}