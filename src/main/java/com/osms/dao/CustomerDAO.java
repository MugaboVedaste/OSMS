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

    /**
     * Constructor with provided connection
     * 
     * @param conn Database connection
     */
    public CustomerDAO(Connection conn) {
        // This constructor still takes a connection, useful if the caller wants to
        // manage it.
        // We might not use this in the servlet, but keep it for flexibility.
        // The logic related to `this.conn` and `this.closeConnection` will be removed.
        // This constructor will need adjustments based on how it's used elsewhere.
        // For now, just removing the instance variable assignments.
    }

    /**
     * Default constructor that obtains a connection
     * Removed the logic to obtain a connection here.
     * Methods will now get their own connections using try-with-resources.
     */
    public CustomerDAO() {
        // No connection setup here anymore.
    }

    /**
     * Insert a new customer into the database
     * 
     * @param customer The customer to insert
     * @return The ID of the inserted customer, or -1 if insertion failed
     */
    public int insert(Customer customer) {
        String sql = "INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, Password, RegistrationDate, State, ZipCode, Country) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, customer.getFirstName());
            pstmt.setString(2, customer.getLastName());
            pstmt.setString(3, customer.getEmail());
            pstmt.setString(4, customer.getPhone());
            pstmt.setString(5, customer.getAddress());
            pstmt.setString(6, customer.getCity());
            pstmt.setString(7, customer.getPassword());

            if (customer.getRegistrationDate() != null) {
                pstmt.setDate(8, new java.sql.Date(customer.getRegistrationDate().getTime()));
            } else {
                pstmt.setDate(8, new java.sql.Date(System.currentTimeMillis()));
            }
            // Add new fields
            pstmt.setString(9, customer.getState());
            pstmt.setString(10, customer.getZipCode());
            pstmt.setString(11, customer.getCountry());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                return -1;
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    return -1;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
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
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, customerId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer();
                    customer.setCustomerId(rs.getInt("CustomerId"));
                    customer.setFirstName(rs.getString("FirstName"));
                    customer.setLastName(rs.getString("LastName"));
                    customer.setEmail(rs.getString("Email"));
                    customer.setPhone(rs.getString("Phone"));
                    customer.setAddress(rs.getString("Address"));
                    customer.setCity(rs.getString("City"));
                    customer.setPassword(rs.getString("Password"));
                    customer.setRegistrationDate(rs.getDate("RegistrationDate"));
                    return customer;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get a customer by their email
     * 
     * @param email The email of the customer to retrieve
     * @return The customer, or null if not found
     */
    public Customer getByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM Customer WHERE Email = ?";
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer();
                    customer.setCustomerId(rs.getInt("CustomerId"));
                    customer.setFirstName(rs.getString("FirstName"));
                    customer.setLastName(rs.getString("LastName"));
                    customer.setEmail(rs.getString("Email"));
                    customer.setPhone(rs.getString("Phone"));
                    customer.setAddress(rs.getString("Address"));
                    customer.setCity(rs.getString("City"));
                    customer.setPassword(rs.getString("Password"));
                    customer.setRegistrationDate(rs.getDate("RegistrationDate"));
                    return customer;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return null;
    }

    /**
     * Get all customers
     * 
     * @return List of all customers
     */
    public List<Customer> getAll() {
        String sql = "SELECT * FROM Customer";
        // Removed instance variables, so use try-with-resources for connection,
        // statement, and result set
        List<Customer> customers = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

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
        }
    }

    /**
     * Update an existing customer
     * 
     * @param customer The customer to update
     * @return true if update was successful, false otherwise
     */
    public boolean update(Customer customer) {
        String sql = "UPDATE Customer SET FirstName = ?, LastName = ?, Email = ?, Phone = ?, Address = ?, City = ?, Password = ?, State = ?, ZipCode = ?, Country = ? WHERE CustomerId = ?";
        // Removed instance variables, so use try-with-resources for connection and
        // statement

        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, customer.getFirstName());
            stmt.setString(2, customer.getLastName());
            stmt.setString(3, customer.getEmail());
            stmt.setString(4, customer.getPhone());
            stmt.setString(5, customer.getAddress());
            stmt.setString(6, customer.getCity());
            stmt.setString(7, customer.getPassword());
            // Add new fields
            stmt.setString(8, customer.getState());
            stmt.setString(9, customer.getZipCode());
            stmt.setString(10, customer.getCountry());
            stmt.setInt(11, customer.getCustomerId());

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
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
        // Removed instance variables, so use try-with-resources for connection and
        // statement

        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, customerId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Authenticate a customer by email and password
     * 
     * @param email    The customer's email
     * @param password The customer's password
     * @return The customer object if authentication is successful, null otherwise
     */
    public Customer login(String email, String password) {
        String sql = "SELECT * FROM Customer WHERE Email = ? AND Password = ?";
        // Removed instance variables, so use try-with-resources for connection,
        // statement, and result set

        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            pstmt.setString(2, password); // NOTE: Passwords should be hashed and compared securely!

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer();
                    customer.setCustomerId(rs.getInt("CustomerId"));
                    customer.setFirstName(rs.getString("FirstName"));
                    customer.setLastName(rs.getString("LastName"));
                    customer.setEmail(rs.getString("Email"));
                    customer.setPhone(rs.getString("Phone"));
                    customer.setAddress(rs.getString("Address"));
                    customer.setCity(rs.getString("City"));
                    customer.setPassword(rs.getString("Password"));
                    customer.setRegistrationDate(rs.getDate("RegistrationDate"));
                    return customer;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
        return null;
    }
}