package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.osms.model.Supplier;
import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for Supplier entity
 */
public class SupplierDAO {

    private Connection conn;
    
    public SupplierDAO(Connection conn) {
        this.conn = conn;
    }
    
    /**
     * Default constructor that obtains a connection
     */
    public SupplierDAO() {
        try {
            this.conn = DatabaseUtil.getConnection();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Insert a new supplier into the database
     * 
     * @param supplier The supplier to insert
     * @return The ID of the newly inserted supplier, or -1 if failed
     */
    public int insert(Supplier supplier) throws SQLException {
        String sql = "INSERT INTO Suppliers (CompanyName, ContactPerson, Email, Phone, Address, City, State, ZipCode, " +
                     "Country, Category, Status, Notes, JoinedDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, supplier.getCompanyName());
            stmt.setString(2, supplier.getContactPerson());
            stmt.setString(3, supplier.getEmail());
            stmt.setString(4, supplier.getPhone());
            stmt.setString(5, supplier.getAddress());
            stmt.setString(6, supplier.getCity());
            stmt.setString(7, supplier.getState());
            stmt.setString(8, supplier.getZipCode());
            stmt.setString(9, supplier.getCountry());
            stmt.setString(10, supplier.getCategory());
            stmt.setString(11, supplier.getStatus());
            stmt.setString(12, supplier.getNotes());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int id = generatedKeys.getInt(1);
                        supplier.setSupplierId(id);
                        return id;
                    }
                }
            }
        }
        return -1;
    }
    
    /**
     * Get a supplier by their ID
     * 
     * @param supplierId The ID of the supplier to retrieve
     * @return The supplier, or null if not found
     */
    public Supplier getById(int supplierId) throws SQLException {
        String sql = "SELECT * FROM Suppliers WHERE SupplierId=?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, supplierId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractSupplierFromResultSet(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * Get a supplier by their email
     * 
     * @param email The email of the supplier to retrieve
     * @return The supplier, or null if not found
     */
    public Supplier getByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM Suppliers WHERE Email=?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractSupplierFromResultSet(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * Get all suppliers
     * 
     * @return List of all suppliers
     */
    public List<Supplier> getAll() throws SQLException {
        List<Supplier> suppliers = new ArrayList<>();
        String sql = "SELECT * FROM Suppliers ORDER BY CompanyName";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            System.out.println("SupplierDAO.getAll(): Connection obtained: " + (conn != null));
            
            stmt = conn.createStatement();
            System.out.println("SupplierDAO.getAll(): Statement created: " + (stmt != null));
            
            System.out.println("SupplierDAO.getAll(): Executing SQL: " + sql);
            rs = stmt.executeQuery(sql);
            System.out.println("SupplierDAO.getAll(): ResultSet obtained: " + (rs != null));
            
            int count = 0;
            while (rs.next()) {
                count++;
                System.out.println("SupplierDAO.getAll(): Processing row " + count);
                suppliers.add(extractSupplierFromResultSet(rs));
            }
            System.out.println("SupplierDAO.getAll(): Found " + count + " suppliers");
            
            return suppliers;
        } catch (SQLException e) {
            System.out.println("SupplierDAO.getAll(): SQL Exception: " + e.getMessage());
            e.printStackTrace();
            throw e;
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
     * Update an existing supplier
     * 
     * @param supplier The supplier to update
     * @return true if update was successful, false otherwise
     */
    public boolean update(Supplier supplier) throws SQLException {
        String sql = "UPDATE Suppliers SET CompanyName=?, ContactPerson=?, Email=?, Phone=?, " +
                     "Address=?, City=?, State=?, ZipCode=?, Country=?, Category=?, Status=?, Notes=? " +
                     "WHERE SupplierId=?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, supplier.getCompanyName());
            stmt.setString(2, supplier.getContactPerson());
            stmt.setString(3, supplier.getEmail());
            stmt.setString(4, supplier.getPhone());
            stmt.setString(5, supplier.getAddress());
            stmt.setString(6, supplier.getCity());
            stmt.setString(7, supplier.getState());
            stmt.setString(8, supplier.getZipCode());
            stmt.setString(9, supplier.getCountry());
            stmt.setString(10, supplier.getCategory());
            stmt.setString(11, supplier.getStatus());
            stmt.setString(12, supplier.getNotes());
            stmt.setInt(13, supplier.getSupplierId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Delete a supplier by their ID
     * 
     * @param supplierId The ID of the supplier to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean delete(int supplierId) throws SQLException {
        String sql = "DELETE FROM Suppliers WHERE SupplierId=?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, supplierId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Helper method to extract supplier data from a ResultSet
     */
    private Supplier extractSupplierFromResultSet(ResultSet rs) throws SQLException {
        Supplier supplier = new Supplier();
        supplier.setSupplierId(rs.getInt("SupplierId"));
        supplier.setCompanyName(rs.getString("CompanyName"));
        supplier.setContactPerson(rs.getString("ContactPerson"));
        supplier.setEmail(rs.getString("Email"));
        supplier.setPhone(rs.getString("Phone"));
        supplier.setAddress(rs.getString("Address"));
        supplier.setCity(rs.getString("City"));
        supplier.setState(rs.getString("State"));
        supplier.setZipCode(rs.getString("ZipCode"));
        supplier.setCountry(rs.getString("Country"));
        supplier.setCategory(rs.getString("Category"));
        supplier.setStatus(rs.getString("Status"));
        supplier.setNotes(rs.getString("Notes"));
        supplier.setJoinedDate(rs.getTimestamp("JoinedDate"));
        return supplier;
    }
} 