-- Use the database
USE osms_db;

-- 1. Fix the Seller table
DROP TABLE IF EXISTS Seller;

CREATE TABLE Seller (
    SellerId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    ContactName VARCHAR(100),
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    Address TEXT,
    Password VARCHAR(100),
    JoinedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert a sample seller
INSERT INTO Seller (CompanyName, ContactName, Email, Phone, Address, Password)
VALUES ('Test Company', 'John Doe', 'test@example.com', '123-456-7890', '123 Test Street', 'password123');

-- 2. Fix the Customer table
DROP TABLE IF EXISTS Customer;

CREATE TABLE Customer (
    CustomerId INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    Address TEXT,
    City VARCHAR(50),
    Password VARCHAR(100) NOT NULL,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert a sample customer
INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, Password)
VALUES ('Jane', 'Doe', 'jane@example.com', '123-456-7890', '456 Sample Ave', 'Sampleville', 'password123');

-- 3. Fix the Users table
DROP TABLE IF EXISTS Users;

CREATE TABLE Users (
    UserId INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    UserType ENUM('Admin', 'Seller', 'Customer') NOT NULL,
    SellerId INT NULL,
    CustomerId INT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert admin user
INSERT INTO Users (Username, Password, UserType)
VALUES ('admin', 'admin123', 'Admin');

-- Add customer user
INSERT INTO Users (Username, Password, UserType, CustomerId)
VALUES ('jane@example.com', 'password123', 'Customer', 1);

-- Add seller user
INSERT INTO Users (Username, Password, UserType, SellerId)
VALUES ('test@example.com', 'password123', 'Seller', 1);

-- 4. Fix the Product table
DROP TABLE IF EXISTS Product;

CREATE TABLE Product (
    ProductId INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    Category VARCHAR(50),
    SupplierId INT,
    ExpirationDate DATE NULL
);

-- Insert sample product
INSERT INTO Product (ProductName, Description, Price, StockQuantity, Category)
VALUES ('Sample Product', 'This is a sample product', 19.99, 100, 'Sample Category');

-- 5. Fix the Orders and OrderItem tables
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS Orders;

CREATE TABLE Orders (
    OrderId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending'
);

CREATE TABLE OrderItem (
    OrderItemId INT AUTO_INCREMENT PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL
); 