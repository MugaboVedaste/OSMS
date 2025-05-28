package com.osms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.osms.model.Address;
import com.osms.util.DatabaseUtil;

/**
 * Data Access Object for Address entity
 */
public class AddressDAO {
    private Connection conn;
    private boolean closeConnection;

    /**
     * Constructor with provided connection
     * 
     * @param conn Database connection
     */
    public AddressDAO(Connection conn) {
        this.conn = conn;
        this.closeConnection = false; // Don't close externally provided connections
    }

    /**
     * Default constructor that obtains a connection
     */
    public AddressDAO() {
        try {
            this.conn = DatabaseUtil.getConnection();
            this.closeConnection = true; // We created this connection, so we should close it
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Insert a new address into the database
     * 
     * @param address The address to insert
     * @return The ID of the inserted address, or -1 if insertion failed
     */
    public int insert(Address address) {
        String sql = "INSERT INTO Address (CustomerId, AddressName, FullName, StreetAddress, Apartment, " +
                "City, State, ZipCode, Country, Phone, DefaultAddress) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, address.getCustomerId());
            stmt.setString(2, address.getAddressName());
            stmt.setString(3, address.getFullName());
            stmt.setString(4, address.getStreetAddress());
            stmt.setString(5, address.getApartment());
            stmt.setString(6, address.getCity());
            stmt.setString(7, address.getState());
            stmt.setString(8, address.getZipCode());
            stmt.setString(9, address.getCountry());
            stmt.setString(10, address.getPhone());
            stmt.setBoolean(11, address.isDefaultAddress());

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
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Get an address by its ID
     * 
     * @param addressId The ID of the address to retrieve
     * @return The address, or null if not found
     */
    public Address getById(int addressId) {
        String sql = "SELECT * FROM Address WHERE AddressId = ?";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Address address = null;

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, addressId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                address = extractAddressFromResultSet(rs);
            }

            return address;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null)
                    rs.close();
                if (stmt != null)
                    stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Get all addresses for a customer
     * 
     * @param customerId The ID of the customer
     * @return List of addresses
     */
    public List<Address> getByCustomerId(int customerId) {
        String sql = "SELECT * FROM Address WHERE CustomerId = ?";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Address> addresses = new ArrayList<>();

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, customerId);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Address address = extractAddressFromResultSet(rs);
                addresses.add(address);
            }

            return addresses;
        } catch (SQLException e) {
            e.printStackTrace();
            return addresses;
        } finally {
            try {
                if (rs != null)
                    rs.close();
                if (stmt != null)
                    stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Get the default address for a customer
     * 
     * @param customerId The ID of the customer
     * @return The default address, or null if not found
     */
    public Address getDefaultAddress(int customerId) {
        String sql = "SELECT * FROM Address WHERE CustomerId = ? AND DefaultAddress = TRUE";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Address address = null;

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, customerId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                address = extractAddressFromResultSet(rs);
            }

            return address;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null)
                    rs.close();
                if (stmt != null)
                    stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Update an address in the database
     * 
     * @param address The address to update
     * @return True if update was successful, false otherwise
     */
    public boolean update(Address address) {
        String sql = "UPDATE Address SET CustomerId = ?, AddressName = ?, FullName = ?, " +
                "StreetAddress = ?, Apartment = ?, City = ?, State = ?, ZipCode = ?, " +
                "Country = ?, Phone = ?, DefaultAddress = ? WHERE AddressId = ?";

        PreparedStatement stmt = null;

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, address.getCustomerId());
            stmt.setString(2, address.getAddressName());
            stmt.setString(3, address.getFullName());
            stmt.setString(4, address.getStreetAddress());
            stmt.setString(5, address.getApartment());
            stmt.setString(6, address.getCity());
            stmt.setString(7, address.getState());
            stmt.setString(8, address.getZipCode());
            stmt.setString(9, address.getCountry());
            stmt.setString(10, address.getPhone());
            stmt.setBoolean(11, address.isDefaultAddress());
            stmt.setInt(12, address.getAddressId());

            int affectedRows = stmt.executeUpdate();

            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null)
                    stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Delete an address from the database
     * 
     * @param addressId The ID of the address to delete
     * @return True if deletion was successful, false otherwise
     */
    public boolean delete(int addressId) {
        String sql = "DELETE FROM Address WHERE AddressId = ?";
        PreparedStatement stmt = null;

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, addressId);

            int affectedRows = stmt.executeUpdate();

            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null)
                    stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Clear all default addresses for a customer
     * 
     * @param customerId The ID of the customer
     * @return True if update was successful, false otherwise
     */
    public boolean clearDefaultAddresses(int customerId) {
        String sql = "UPDATE Address SET DefaultAddress = FALSE WHERE CustomerId = ?";
        PreparedStatement stmt = null;

        try {
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, customerId);

            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (stmt != null)
                    stmt.close();
                if (this.closeConnection && this.conn != null) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Helper method to extract address from result set
     */
    private Address extractAddressFromResultSet(ResultSet rs) throws SQLException {
        Address address = new Address();
        address.setAddressId(rs.getInt("AddressId"));
        address.setCustomerId(rs.getInt("CustomerId"));
        address.setAddressName(rs.getString("AddressName"));
        address.setFullName(rs.getString("FullName"));
        address.setStreetAddress(rs.getString("StreetAddress"));
        address.setApartment(rs.getString("Apartment"));
        address.setCity(rs.getString("City"));
        address.setState(rs.getString("State"));
        address.setZipCode(rs.getString("ZipCode"));
        address.setCountry(rs.getString("Country"));
        address.setPhone(rs.getString("Phone"));
        address.setDefaultAddress(rs.getBoolean("DefaultAddress"));
        return address;
    }
}
