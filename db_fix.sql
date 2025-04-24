-- Script to fix database schema issues

-- Check if the Product table exists and add the Description column if it doesn't already have it
ALTER TABLE Product ADD COLUMN IF NOT EXISTS Description TEXT;

-- Create table structure if Product table doesn't exist
CREATE TABLE IF NOT EXISTS Product (
    ProductId INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    Description TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    Category VARCHAR(100),
    SupplierId INT,
    ExpirationDate DATE,
    FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId)
);

-- Create Suppliers table if it doesn't exist
CREATE TABLE IF NOT EXISTS Suppliers (
    SupplierId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(255) NOT NULL,
    ContactPerson VARCHAR(255),
    Email VARCHAR(255),
    Phone VARCHAR(50),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    ZipCode VARCHAR(20),
    Country VARCHAR(100),
    Category VARCHAR(100),
    Status VARCHAR(50) DEFAULT 'Active',
    Notes TEXT,
    JoinedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Check database structure
SHOW TABLES;
DESCRIBE Product;
DESCRIBE Suppliers; 