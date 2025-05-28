package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.osms.model.Seller;
import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for Seller entity
 */
public class SellerDAO {

    private Connection conn;
    
    public SellerDAO(Connection conn) {
        this.conn = conn;
    }
    
    /**
     * Insert a new seller into the database
     * 
     * @param seller The seller to insert
     * @return true if insertion was successful, false otherwise
     */
    public boolean insert(Seller seller) throws SQLException {
        String sql = "INSERT INTO Seller (CompanyName, ContactName, Email, Phone, Address, Password, JoinedDate, RegistrationDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, seller.getCompanyName());
            stmt.setString(2, seller.getContactName());
            stmt.setString(3, seller.getEmail());
            stmt.setString(4, seller.getPhone());
            stmt.setString(5, seller.getAddress());
            stmt.setString(6, seller.getPassword());
            stmt.setTimestamp(7, seller.getJoinedDate());
            stmt.setTimestamp(8, seller.getRegistrationDate());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        seller.setSellerId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    /**
     * Get a seller by their ID
     * 
     * @param sellerId The ID of the seller to retrieve
     * @return The seller, or null if not found
     */
    public Seller getById(int sellerId) throws SQLException {
        String sql = "SELECT * FROM Seller WHERE SellerId=?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, sellerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractSellerFromResultSet(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * Get a seller by their email
     * 
     * @param email The email of the seller to retrieve
     * @return The seller, or null if not found
     */
    public Seller getByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM Seller WHERE Email=?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractSellerFromResultSet(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * Get all sellers
     * 
     * @return List of all sellers
     */
    public List<Seller> getAll() throws SQLException {
        List<Seller> sellers = new ArrayList<>();
        String sql = "SELECT * FROM Seller ORDER BY CompanyName";
        
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                sellers.add(extractSellerFromResultSet(rs));
            }
        }
        return sellers;
    }
    
    /**
     * Update an existing seller
     * 
     * @param seller The seller to update
     * @return true if update was successful, false otherwise
     */
    public boolean update(Seller seller) throws SQLException {
        String sql = "UPDATE Seller SET CompanyName=?, ContactName=?, Email=?, Phone=?, Address=? " +
                     "WHERE SellerId=?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, seller.getCompanyName());
            stmt.setString(2, seller.getContactName());
            stmt.setString(3, seller.getEmail());
            stmt.setString(4, seller.getPhone());
            stmt.setString(5, seller.getAddress());
            stmt.setInt(6, seller.getSellerId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Delete a seller by their ID
     * 
     * @param sellerId The ID of the seller to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean delete(int sellerId) throws SQLException {
        String sql = "DELETE FROM Seller WHERE SellerId=?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, sellerId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Check if seller login credentials are valid
     * 
     * @param email Seller email
     * @param password Seller password
     * @return Seller object if login successful, null otherwise
     */
    public Seller login(String email, String password) {
        String sql = "SELECT * FROM Seller WHERE Email = ? AND Password = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Seller seller = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, password);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                seller = new Seller();
                seller.setSellerId(rs.getInt("SellerId"));
                seller.setCompanyName(rs.getString("CompanyName"));
                seller.setContactName(rs.getString("ContactName"));
                seller.setEmail(rs.getString("Email"));
                seller.setPhone(rs.getString("Phone"));
                seller.setAddress(rs.getString("Address"));
                seller.setPassword(rs.getString("Password"));
                // Handle the case when JoinedDate might not exist
                try {
                    seller.setJoinedDate(rs.getTimestamp("JoinedDate"));
                } catch (SQLException e) {
                    // JoinedDate column doesn't exist, set to current time
                    seller.setJoinedDate(new java.sql.Timestamp(System.currentTimeMillis()));
                }
            }
            
            return seller;
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
    
    private Seller extractSellerFromResultSet(ResultSet rs) throws SQLException {
        Seller seller = new Seller();
        seller.setSellerId(rs.getInt("SellerId"));
        seller.setCompanyName(rs.getString("CompanyName"));
        seller.setContactName(rs.getString("ContactName"));
        seller.setEmail(rs.getString("Email"));
        seller.setPhone(rs.getString("Phone"));
        seller.setAddress(rs.getString("Address"));
        seller.setPassword(rs.getString("Password"));
        // Handle the case when JoinedDate might not exist
        try {
            seller.setJoinedDate(rs.getTimestamp("JoinedDate"));
        } catch (SQLException e) {
            // JoinedDate column doesn't exist, set to current time
            seller.setJoinedDate(new java.sql.Timestamp(System.currentTimeMillis()));
        }
        return seller;
    }
} 