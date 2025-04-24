-- Drop the existing Suppliers table if it exists
DROP TABLE IF EXISTS Suppliers;

-- Create the updated Suppliers table with fields matching the model
CREATE TABLE IF NOT EXISTS Suppliers (
    SupplierId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    ZipCode VARCHAR(20) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Active',
    Notes TEXT,
    JoinedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for performance
CREATE INDEX idx_supplier_email ON Suppliers(Email);
CREATE INDEX idx_supplier_company ON Suppliers(CompanyName);
CREATE INDEX idx_supplier_category ON Suppliers(Category); 