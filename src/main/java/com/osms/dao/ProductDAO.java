package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.osms.model.Product;
import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for Product entity
 */
public class ProductDAO {

    /**
     * Insert a new product into the database
     * 
     * @param product The product to insert
     * @return The ID of the inserted product, or -1 if insertion failed
     */
    public int insert(Product product) {
        // First try with Description column
        String sql = "INSERT INTO Product (ProductName, Description, Price, StockQuantity, Category, SupplierId, ExpirationDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, product.getProductName());
            stmt.setString(2, product.getDescription());
            stmt.setDouble(3, product.getPrice());
            stmt.setInt(4, product.getStockQuantity());
            stmt.setString(5, product.getCategory());
            stmt.setInt(6, product.getSupplierId());
            
            if (product.getExpirationDate() != null) {
                stmt.setDate(7, new java.sql.Date(product.getExpirationDate().getTime()));
            } else {
                stmt.setNull(7, java.sql.Types.DATE);
            }
            
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
            // If the error is about the Description column, try without it
            if (e.getMessage().contains("Description")) {
                return insertWithoutDescription(product);
            }
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
     * Alternative insert method without Description column
     */
    private int insertWithoutDescription(Product product) {
        String sql = "INSERT INTO Product (ProductName, Price, StockQuantity, Category, SupplierId, ExpirationDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, product.getProductName());
            stmt.setDouble(2, product.getPrice());
            stmt.setInt(3, product.getStockQuantity());
            stmt.setString(4, product.getCategory());
            stmt.setInt(5, product.getSupplierId());
            
            if (product.getExpirationDate() != null) {
                stmt.setDate(6, new java.sql.Date(product.getExpirationDate().getTime()));
            } else {
                stmt.setNull(6, java.sql.Types.DATE);
            }
            
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
     * Get a product by its ID
     * 
     * @param productId The ID of the product to retrieve
     * @return The product, or null if not found
     */
    public Product getById(int productId) {
        String sql = "SELECT * FROM Product WHERE ProductId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Product product = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, productId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                product = extractProductFromResultSet(rs);
            }
            
            return product;
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
     * Get all products
     * 
     * @return List of all products
     */
    public List<Product> getAll() {
        String sql = "SELECT * FROM Product";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Product> products = new ArrayList<>();
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Product product = extractProductFromResultSet(rs);
                products.add(product);
            }
            
            return products;
        } catch (SQLException e) {
            e.printStackTrace();
            return products;
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
     * Update an existing product
     * 
     * @param product The product to update
     * @return true if update was successful, false otherwise
     */
    public boolean update(Product product) {
        // First try with Description column
        String sql = "UPDATE Product SET ProductName = ?, Description = ?, Price = ?, " +
                     "StockQuantity = ?, Category = ?, SupplierId = ?, ExpirationDate = ? " +
                     "WHERE ProductId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, product.getProductName());
            stmt.setString(2, product.getDescription());
            stmt.setDouble(3, product.getPrice());
            stmt.setInt(4, product.getStockQuantity());
            stmt.setString(5, product.getCategory());
            stmt.setInt(6, product.getSupplierId());
            
            if (product.getExpirationDate() != null) {
                stmt.setDate(7, new java.sql.Date(product.getExpirationDate().getTime()));
            } else {
                stmt.setNull(7, java.sql.Types.DATE);
            }
            
            stmt.setInt(8, product.getProductId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            // If the error is about the Description column, try without it
            if (e.getMessage().contains("Description")) {
                return updateWithoutDescription(product);
            }
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
     * Alternative update method without Description column
     */
    private boolean updateWithoutDescription(Product product) {
        String sql = "UPDATE Product SET ProductName = ?, Price = ?, " +
                     "StockQuantity = ?, Category = ?, SupplierId = ?, ExpirationDate = ? " +
                     "WHERE ProductId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, product.getProductName());
            stmt.setDouble(2, product.getPrice());
            stmt.setInt(3, product.getStockQuantity());
            stmt.setString(4, product.getCategory());
            stmt.setInt(5, product.getSupplierId());
            
            if (product.getExpirationDate() != null) {
                stmt.setDate(6, new java.sql.Date(product.getExpirationDate().getTime()));
            } else {
                stmt.setNull(6, java.sql.Types.DATE);
            }
            
            stmt.setInt(7, product.getProductId());
            
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
     * Delete a product by its ID
     * 
     * @param productId The ID of the product to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean delete(int productId) {
        String sql = "DELETE FROM Product WHERE ProductId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, productId);
            
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
     * Get products by supplier ID
     * 
     * @param supplierId The ID of the supplier
     * @return List of products from the specified supplier
     */
    public List<Product> getBySupplierId(int supplierId) {
        String sql = "SELECT * FROM Product WHERE SupplierId = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Product> products = new ArrayList<>();
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, supplierId);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Product product = extractProductFromResultSet(rs);
                products.add(product);
            }
            
            return products;
        } catch (SQLException e) {
            e.printStackTrace();
            return products;
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

    private Product extractProductFromResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("ProductId"));
        product.setProductName(rs.getString("ProductName"));
        
        try {
            product.setDescription(rs.getString("Description"));
        } catch (SQLException e) {
            // Description column might not exist in the database
            product.setDescription("");
        }
        
        product.setPrice(rs.getDouble("Price"));
        product.setStockQuantity(rs.getInt("StockQuantity"));
        product.setCategory(rs.getString("Category"));
        product.setSupplierId(rs.getInt("SupplierId"));
        
        try {
            product.setExpirationDate(rs.getDate("ExpirationDate"));
        } catch (SQLException e) {
            // ExpirationDate column might not exist
            product.setExpirationDate(null);
        }
        
        return product;
    }
} 