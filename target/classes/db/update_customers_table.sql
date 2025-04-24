-- Drop the existing Customers table if it exists
DROP TABLE IF EXISTS Customer;

-- Create the updated Customer table with fields matching the model
CREATE TABLE IF NOT EXISTS Customer (
    CustomerId INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Password VARCHAR(100) NOT NULL,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for performance
CREATE INDEX idx_customer_email ON Customer(Email);
CREATE INDEX idx_customer_name ON Customer(LastName, FirstName); 