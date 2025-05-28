package com.osms.dao;

import com.osms.util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Data Access Object for Wishlist functionality
 */
public class WishlistDAO {

    /**
     * Get the number of items in a customer's wishlist.
     *
     * @param customerId The ID of the customer.
     * @return The number of items in the wishlist.
     * @throws SQLException if a database access error occurs.
     */
    public int getWishlistCountByCustomerId(int customerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE CustomerId = ?";
        int count = 0;
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, customerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        }
        return count;
    }

    /**
     * Add an item to the customer's wishlist in the database.
     *
     * @param customerId The ID of the customer.
     * @param productId  The ID of the product to add.
     * @return true if the item was added successfully, false otherwise (e.g.,
     *         already exists).
     * @throws SQLException if a database access error occurs.
     */
    public boolean addItem(int customerId, int productId) throws SQLException {
        // First, check if the item is already in the wishlist
        if (isItemInWishlist(customerId, productId)) {
            return false; // Item already exists
        }

        String sql = "INSERT INTO wishlist (CustomerId, ProductId) VALUES (?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, customerId);
            pstmt.setInt(2, productId);
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        }
    }

    /**
     * Check if an item is already in the customer's wishlist.
     *
     * @param customerId The ID of the customer.
     * @param productId  The ID of the product.
     * @return true if the item is in the wishlist, false otherwise.
     * @throws SQLException if a database access error occurs.
     */
    public boolean isItemInWishlist(int customerId, int productId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE CustomerId = ? AND ProductId = ?";
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, customerId);
            pstmt.setInt(2, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    // You can add other wishlist related methods here (e.g., add, remove, get
    // items)
}
