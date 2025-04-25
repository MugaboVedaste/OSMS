-- Complete Database Fix Script for OSMS
-- This script will properly set up all tables with the correct structure and relationships

-- Use the database
USE osms_db;

-- 1. Fix the Suppliers table first since it has foreign key relationships
DROP TABLE IF EXISTS Suppliers;

CREATE TABLE Suppliers (
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
    JoinedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default supplier
INSERT INTO Suppliers (CompanyName, ContactPerson, Email, Phone, Address, City, State, Country, Category)
VALUES ('ABC Electronics', 'John Doe', 'contact@abcelectronics.com', '123-456-7890', 
'123 Main St', 'New York', 'NY', 'USA', 'Electronics');

-- 2. Fix the Product table
DROP TABLE IF EXISTS Product;

CREATE TABLE Product (
    ProductId INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    StockQuantity INT NOT NULL DEFAULT 0,
    Category VARCHAR(50),
    SupplierId INT,
    ExpirationDate DATE NULL,
    CONSTRAINT fk_product_supplier_new FOREIGN KEY (SupplierId)
    REFERENCES Suppliers(SupplierId) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Insert sample products
INSERT INTO Product (ProductName, Description, Price, StockQuantity, Category, SupplierId)
VALUES 
('Organic Tomatoes', 'Fresh organic tomatoes', 2.99, 100, 'Produce', 1),
('Laptop Computer', 'High-performance laptop', 899.99, 10, 'Electronics', 1),
('Organic Carrots', 'Fresh organic carrots', 1.99, 150, 'Produce', 1),
('Smartphone', 'Latest smartphone model', 699.99, 25, 'Electronics', 1),
('Fresh Oranges', 'Juicy oranges', 3.99, 80, 'Produce', 1);

-- 3. Fix the Customer table
DROP TABLE IF EXISTS Customer;

CREATE TABLE Customer (
    CustomerId INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address TEXT,
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(50),
    Password VARCHAR(100) NOT NULL,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample customers
INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, State, Country, Password)
VALUES 
('John', 'Doe', 'john@example.com', '123-456-7890', '123 Main St', 'Anytown', 'CA', 'USA', 'password123'),
('Jane', 'Smith', 'jane@example.com', '234-567-8901', '456 Oak Ave', 'Somecity', 'NY', 'USA', 'password123'),
('Bob', 'Johnson', 'bob@example.com', '345-678-9012', '789 Pine St', 'Otherville', 'TX', 'USA', 'password123');

-- 4. Fix the Seller table
DROP TABLE IF EXISTS Seller;

CREATE TABLE Seller (
    SellerId INT AUTO_INCREMENT PRIMARY KEY,
    BusinessName VARCHAR(100) NOT NULL,
    OwnerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address TEXT,
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(50),
    BusinessType VARCHAR(50),
    TaxId VARCHAR(50),
    Password VARCHAR(100) NOT NULL,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ApprovalStatus VARCHAR(20) DEFAULT 'Pending'
);

-- Insert sample sellers
INSERT INTO Seller (BusinessName, OwnerName, Email, Phone, Address, City, State, Country, BusinessType, TaxId, Password, ApprovalStatus)
VALUES 
('Tech Store Inc.', 'Bob Smith', 'bob@techstore.com', '555-123-4567', '789 Tech Blvd', 'San Francisco', 'CA', 'USA', 'Electronics', 'TX123456', 'password123', 'Approved'),
('Fashion Hub', 'Alice Brown', 'alice@fashionhub.com', '555-987-6543', '321 Fashion St', 'New York', 'NY', 'USA', 'Clothing', 'TX654321', 'password123', 'Approved');

-- 5. Fix the Orders table (must be after Customer)
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS Orders;

CREATE TABLE Orders (
    OrderId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Status VARCHAR(20) DEFAULT 'Pending',
    ShippingAddress VARCHAR(255),
    ShippingCity VARCHAR(100),
    ShippingState VARCHAR(50),
    ShippingZipCode VARCHAR(20),
    ShippingCountry VARCHAR(50),
    PaymentMethod VARCHAR(50),
    PaymentStatus VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE SET NULL
);

-- Insert sample orders
INSERT INTO Orders (CustomerId, OrderDate, TotalAmount, Status)
VALUES 
(1, NOW(), 150.50, 'Delivered'),
(2, NOW(), 75.25, 'Processing'),
(3, NOW(), 999.99, 'Pending'),
(1, NOW(), 45.75, 'Shipped');

-- 6. Fix the OrderItem table (must be after Orders and Product)
CREATE TABLE OrderItem (
    OrderItemId INT AUTO_INCREMENT PRIMARY KEY,
    OrderId INT,
    ProductId INT,
    SellerId INT,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE,
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId) ON DELETE SET NULL,
    FOREIGN KEY (SellerId) REFERENCES Seller(SellerId) ON DELETE SET NULL
);

-- Insert sample order items
INSERT INTO OrderItem (OrderId, ProductId, Quantity, UnitPrice, Subtotal)
VALUES 
(1, 1, 5, 2.50, 12.50),
(1, 4, 3, 3.00, 9.00),
(2, 2, 10, 1.75, 17.50),
(3, 3, 1, 899.99, 899.99),
(4, 1, 10, 2.50, 25.00),
(4, 5, 8, 2.25, 18.00);

-- 7. Fix the Users table (must be after Customer and Seller)
DROP TABLE IF EXISTS Users;

CREATE TABLE Users (
    UserId INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    UserType ENUM('Admin', 'Seller', 'Customer') NOT NULL,
    SellerId INT NULL,
    CustomerId INT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SellerId) REFERENCES Seller(SellerId) ON DELETE SET NULL,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE SET NULL
);

-- Insert admin user
INSERT INTO Users (Username, Password, UserType)
VALUES ('admin', 'admin123', 'Admin');

-- Map existing customers to users
INSERT INTO Users (Username, Password, UserType, CustomerId)
VALUES 
('john@example.com', 'password123', 'Customer', 1),
('jane@example.com', 'password123', 'Customer', 2),
('bob@example.com', 'password123', 'Customer', 3);

-- Map existing sellers to users
INSERT INTO Users (Username, Password, UserType, SellerId)
VALUES 
('bob@techstore.com', 'password123', 'Seller', 1),
('alice@fashionhub.com', 'password123', 'Seller', 2);

-- Verify the constraint names for future reference
SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'osms_db' AND REFERENCED_TABLE_NAME IS NOT NULL; 