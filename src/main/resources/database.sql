-- Create database
CREATE DATABASE IF NOT EXISTS osms_db;
USE osms_db;

-- Product table
CREATE TABLE IF NOT EXISTS Product (
    ProductId INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    SupplierId INT NOT NULL,
    ExpirationDate DATE
);

-- Category table
CREATE TABLE IF NOT EXISTS Category (
    CategoryId INT AUTO_INCREMENT PRIMARY KEY,
    ProductId INT NOT NULL,
    Category VARCHAR(50) NOT NULL,
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId)
);

-- Customers table
CREATE TABLE IF NOT EXISTS Customers (
    CustomerId INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telephone VARCHAR(20),
    Address VARCHAR(255)
);

-- Store table
CREATE TABLE IF NOT EXISTS Store (
    StoreId INT AUTO_INCREMENT PRIMARY KEY,
    ProductId INT NOT NULL,
    Status ENUM('Full', 'Average', 'Empty') NOT NULL,
    Location VARCHAR(255) NOT NULL,
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId)
);

-- Seller table
CREATE TABLE IF NOT EXISTS Seller (
    SellerId INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telephone VARCHAR(20),
    StoreId INT NOT NULL,
    FOREIGN KEY (StoreId) REFERENCES Store(StoreId)
);

-- Suppliers table
CREATE TABLE IF NOT EXISTS Suppliers (
    SupplierId INT AUTO_INCREMENT PRIMARY KEY,
    ProductId INT NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telephone VARCHAR(20),
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId)
);

-- Order table (using Orders as table name since Order is a reserved keyword)
CREATE TABLE IF NOT EXISTS Orders (
    OrderId INT AUTO_INCREMENT PRIMARY KEY,
    ProductId INT NOT NULL,
    CustomerId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalByProduct DECIMAL(10,2) NOT NULL,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

-- Payment table
CREATE TABLE IF NOT EXISTS Payment (
    PaymentId INT AUTO_INCREMENT PRIMARY KEY,
    OrderId INT NOT NULL,
    CustomerId INT NOT NULL,
    PaidAmount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

-- Shipping table
CREATE TABLE IF NOT EXISTS Shipping (
    ShippingId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderId INT NOT NULL,
    Location VARCHAR(255) NOT NULL,
    ShipDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId)
);

-- Users table
CREATE TABLE IF NOT EXISTS Users (
    UserId INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    UserType ENUM('Admin', 'Seller', 'Customer') NOT NULL,
    CustomerId INT NULL,
    SellerId INT NULL,
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (SellerId) REFERENCES Seller(SellerId)
);

-- Insert initial admin user
INSERT INTO Users (Username, Password, UserType) VALUES ('admin', 'admin123', 'Admin'); 