package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.osms.model.Customer;
import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for Customer entity
 */
public class CustomerDAO {

    private Connection conn;
    private boolean closeConnection;
    
    /**
     * Constructor with provided connection
     * 
     * @param conn Database connection
     */
    public CustomerDAO(Connection conn) {
        this.conn = conn;
        this.closeConnection = false; // Don't close externally provided connections
    }
    
    /**
     * Default constructor that obtains a connection
     */
    public CustomerDAO() {
        try {
            this.conn = DatabaseUtil.getConnection();
            this.closeConnection = true; // We created this connection, so we should close it
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Insert a new customer into the database
     * 
     * @param customer The customer to insert
     * @return The ID of the inserted customer, or -1 if insertion failed
     */
    public int insert(Customer customer) {
        String sql = "INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, Password, RegistrationDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, customer.getFirstName());
            stmt.setString(2, customer.getLastName());
            stmt.setString(3, customer.getEmail());
            stmt.setString(4, customer.getPhone());
            stmt.setString(5, customer.getAddress());
            stmt.setString(6, customer.getCity());
            stmt.setString(7, customer.getPassword());
            
            if (customer.getRegistrationDate() != null) {
                stmt.setDate(8, new java.sql.Date(customer.getRegistrationDate().getTime()));
            } else {
                stmt.setDate(8, new java.sql.Date(System.currentTimeMillis()));
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
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Get a customer by their ID
     * 
     * @param customerId The ID of the customer to retrieve
     * @return The customer, or null if not found
     */
    public Customer getById(int customerId) {
        String sql = "SELECT * FROM Customer WHERE CustomerId = ?";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Customer customer = null;
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, customerId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                customer = new Customer();
                customer.setCustomerId(rs.getInt("CustomerId"));
                customer.setFirstName(rs.getString("FirstName"));
                customer.setLastName(rs.getString("LastName"));
                customer.setEmail(rs.getString("Email"));
                customer.setPhone(rs.getString("Phone"));
                customer.setAddress(rs.getString("Address"));
                customer.setCity(rs.getString("City"));
                customer.setPassword(rs.getString("Password"));
                customer.setRegistrationDate(rs.getDate("RegistrationDate"));
            }
            
            return customer;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Get a customer by their email
     * 
     * @param email The email of the customer to retrieve
     * @return The customer, or null if not found
     */
    public Customer getByEmail(String email) {
        String sql = "SELECT * FROM Customer WHERE Email = ?";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Customer customer = null;
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                customer = new Customer();
                customer.setCustomerId(rs.getInt("CustomerId"));
                customer.setFirstName(rs.getString("FirstName"));
                customer.setLastName(rs.getString("LastName"));
                customer.setEmail(rs.getString("Email"));
                customer.setPhone(rs.getString("Phone"));
                customer.setAddress(rs.getString("Address"));
                customer.setCity(rs.getString("City"));
                customer.setPassword(rs.getString("Password"));
                customer.setRegistrationDate(rs.getDate("RegistrationDate"));
            }
            
            return customer;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Get all customers
     * 
     * @return List of all customers
     */
    public List<Customer> getAll() {
        String sql = "SELECT * FROM Customer";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Customer> customers = new ArrayList<>();
        
        try {
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("CustomerId"));
                customer.setFirstName(rs.getString("FirstName"));
                customer.setLastName(rs.getString("LastName"));
                customer.setEmail(rs.getString("Email"));
                customer.setPhone(rs.getString("Phone"));
                customer.setAddress(rs.getString("Address"));
                customer.setCity(rs.getString("City"));
                customer.setPassword(rs.getString("Password"));
                
                // Handle DATE type for RegistrationDate
                java.sql.Date sqlDate = rs.getDate("RegistrationDate");
                if (sqlDate != null) {
                    customer.setRegistrationDate(new java.util.Date(sqlDate.getTime()));
                }
                
                customers.add(customer);
            }
            
            return customers;
        } catch (SQLException e) {
            e.printStackTrace();
            return customers;
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Update an existing customer
     * 
     * @param customer The customer to update
     * @return true if update was successful, false otherwise
     */
    public boolean update(Customer customer) {
        String sql = "UPDATE Customer SET FirstName = ?, LastName = ?, Email = ?, Phone = ?, Address = ?, City = ?, Password = ? WHERE CustomerId = ?";
        PreparedStatement stmt = null;
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, customer.getFirstName());
            stmt.setString(2, customer.getLastName());
            stmt.setString(3, customer.getEmail());
            stmt.setString(4, customer.getPhone());
            stmt.setString(5, customer.getAddress());
            stmt.setString(6, customer.getCity());
            stmt.setString(7, customer.getPassword());
            stmt.setInt(8, customer.getCustomerId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Delete a customer by their ID
     * 
     * @param customerId The ID of the customer to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean delete(int customerId) {
        String sql = "DELETE FROM Customer WHERE CustomerId = ?";
        PreparedStatement stmt = null;
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, customerId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Check if customer login credentials are valid
     * 
     * @param email Customer email
     * @param password Customer password
     * @return Customer object if login successful, null otherwise
     */
    public Customer login(String email, String password) {
        String sql = "SELECT * FROM Customer WHERE Email = ? AND Password = ?";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Customer customer = null;
        
        try {
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, password);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                customer = new Customer();
                customer.setCustomerId(rs.getInt("CustomerId"));
                customer.setFirstName(rs.getString("FirstName"));
                customer.setLastName(rs.getString("LastName"));
                customer.setEmail(rs.getString("Email"));
                customer.setPhone(rs.getString("Phone"));
                customer.setAddress(rs.getString("Address"));
                customer.setCity(rs.getString("City"));
                customer.setPassword(rs.getString("Password"));
                customer.setRegistrationDate(rs.getDate("RegistrationDate"));
            }
            
            return customer;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
} 