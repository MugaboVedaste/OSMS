-- Script to create the Address table for the OSMS project

-- Check if table exists
DROP TABLE IF EXISTS Address;

-- Create Address table
CREATE TABLE Address (
    AddressId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT NOT NULL,
    AddressName VARCHAR(100),
    FullName VARCHAR(255) NOT NULL,
    StreetAddress VARCHAR(255) NOT NULL,
    Apartment VARCHAR(100),
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    ZipCode VARCHAR(20) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    Phone VARCHAR(50) NOT NULL,
    DefaultAddress BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE CASCADE
);

-- Add some sample addresses
INSERT INTO Address (CustomerId, AddressName, FullName, StreetAddress, Apartment, City, State, ZipCode, Country, Phone, DefaultAddress)
VALUES 
(1, 'Home', 'John Doe', '123 Main Street', 'Apt 4B', 'New York', 'NY', '10001', 'United States', '(123) 456-7890', TRUE),
(1, 'Work', 'John Doe', '555 Business Ave', 'Suite 200', 'New York', 'NY', '10002', 'United States', '(123) 456-7890', FALSE),
(2, 'Home', 'Jane Smith', '456 Elm Street', NULL, 'Los Angeles', 'CA', '90001', 'United States', '(987) 654-3210', TRUE);

-- Create index on CustomerId
CREATE INDEX idx_address_customer ON Address(CustomerId); 