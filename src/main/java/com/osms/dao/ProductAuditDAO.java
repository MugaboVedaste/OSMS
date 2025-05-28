package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.osms.model.Product;
import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for Product Audit records
 */
public class ProductAuditDAO {

    /**
     * Log an update to a product
     * 
     * @param productId  The ID of the product being updated
     * @param adminId    The ID of the admin making the change
     * @param reason     The reason for the change
     * @param oldProduct The product before changes
     * @param newProduct The product after changes
     * @return true if the audit record was created successfully
     */
    public boolean logUpdate(int productId, int adminId, String reason, Product oldProduct, Product newProduct) {
        String sql = "INSERT INTO product_audit (product_id, admin_id, action_type, reason, changes) VALUES (?, ?, 'UPDATE', ?, ?)";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, productId);
            stmt.setInt(2, adminId);
            stmt.setString(3, reason);

            // Create a detailed record of changes
            StringBuilder changes = new StringBuilder();
            if (!oldProduct.getProductName().equals(newProduct.getProductName())) {
                changes.append("Name: ").append(oldProduct.getProductName()).append(" → ")
                        .append(newProduct.getProductName()).append("; ");
            }
            if (!oldProduct.getDescription().equals(newProduct.getDescription())) {
                changes.append("Description changed; ");
            }
            if (oldProduct.getPrice() != newProduct.getPrice()) {
                changes.append("Price: $").append(oldProduct.getPrice()).append(" → $").append(newProduct.getPrice())
                        .append("; ");
            }
            if (oldProduct.getStockQuantity() != newProduct.getStockQuantity()) {
                changes.append("Stock: ").append(oldProduct.getStockQuantity()).append(" → ")
                        .append(newProduct.getStockQuantity()).append("; ");
            }
            if (!oldProduct.getCategory().equals(newProduct.getCategory())) {
                changes.append("Category: ").append(oldProduct.getCategory()).append(" → ")
                        .append(newProduct.getCategory()).append("; ");
            }

            // Handle supplierId (which might be null)
            if ((oldProduct.getSupplierId() == null && newProduct.getSupplierId() != null) ||
                    (oldProduct.getSupplierId() != null && newProduct.getSupplierId() == null) ||
                    (oldProduct.getSupplierId() != null && newProduct.getSupplierId() != null &&
                            !oldProduct.getSupplierId().equals(newProduct.getSupplierId()))) {
                changes.append("Supplier changed; ");
            }

            // Handle imagePath changes
            if ((oldProduct.getImagePath() == null && newProduct.getImagePath() != null) ||
                    (oldProduct.getImagePath() != null && newProduct.getImagePath() == null) ||
                    (oldProduct.getImagePath() != null && newProduct.getImagePath() != null &&
                            !oldProduct.getImagePath().equals(newProduct.getImagePath()))) {
                changes.append("Image changed; ");
            }

            stmt.setString(4, changes.toString());

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
     * Log a deletion of a product
     * 
     * @param productId The ID of the product being deleted
     * @param adminId   The ID of the admin making the change
     * @param reason    The reason for the deletion
     * @param product   The product being deleted
     * @return true if the audit record was created successfully
     */
    public boolean logDelete(int productId, int adminId, String reason, Product product) {
        String sql = "INSERT INTO product_audit (product_id, admin_id, action_type, reason, changes) VALUES (?, ?, 'DELETE', ?, ?)";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, productId);
            stmt.setInt(2, adminId);
            stmt.setString(3, reason);

            // Create a detailed record of the deleted product
            StringBuilder changes = new StringBuilder();
            changes.append("Deleted product: ")
                    .append(product.getProductName())
                    .append(" (ID: ").append(product.getProductId()).append(")")
                    .append(", Category: ").append(product.getCategory())
                    .append(", Price: $").append(product.getPrice())
                    .append(", Stock: ").append(product.getStockQuantity());

            stmt.setString(4, changes.toString());

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
     * Get all audit records
     * 
     * @return List of audit records as maps
     */
    public List<Map<String, Object>> getAllAuditRecords() {
        String sql = "SELECT a.*, u.username as admin_name, p.ProductName as product_name " +
                "FROM product_audit a " +
                "LEFT JOIN users u ON a.admin_id = u.id " +
                "LEFT JOIN product p ON a.product_id = p.ProductId " +
                "ORDER BY a.change_date DESC";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> records = new ArrayList<>();

        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("id", rs.getInt("id"));
                record.put("productId", rs.getInt("product_id"));
                record.put("productName", rs.getString("product_name"));
                record.put("adminId", rs.getInt("admin_id"));
                record.put("adminName", rs.getString("admin_name"));
                record.put("actionType", rs.getString("action_type"));
                record.put("changeDate", rs.getTimestamp("change_date"));
                record.put("reason", rs.getString("reason"));
                record.put("changes", rs.getString("changes"));

                records.add(record);
            }

            return records;
        } catch (SQLException e) {
            e.printStackTrace();
            return records;
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