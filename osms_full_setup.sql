-- OSMS Full Database Setup

-- Drop and recreate the database
DROP DATABASE IF EXISTS osms_db;
CREATE DATABASE osms_db;
USE osms_db;

-- Seller Table
CREATE TABLE Seller (
    SellerId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    ContactName VARCHAR(100),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(200),
    Password VARCHAR(100) NOT NULL,
    JoinedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Suppliers Table
CREATE TABLE Suppliers (
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
CREATE INDEX idx_supplier_email ON Suppliers(Email);
CREATE INDEX idx_supplier_company ON Suppliers(CompanyName);
CREATE INDEX idx_supplier_category ON Suppliers(Category);

-- Customer Table
CREATE TABLE Customer (
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
CREATE INDEX idx_customer_email ON Customer(Email);
CREATE INDEX idx_customer_name ON Customer(LastName, FirstName);

-- Product Table
CREATE TABLE Product (
    ProductId INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    StockQuantity INT NOT NULL DEFAULT 0,
    Category VARCHAR(100),
    SupplierId INT NULL,
    ExpirationDate DATE,
    FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Orders Table
CREATE TABLE Orders (
    OrderId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2),
    Status VARCHAR(50),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

-- OrderItem Table
CREATE TABLE OrderItem (
    OrderItemId INT AUTO_INCREMENT PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId)
);

-- Users Table
CREATE TABLE Users (
    UserId INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    UserType VARCHAR(20) NOT NULL, -- Admin, Customer, Seller
    CustomerId INT NULL,
    SellerId INT NULL,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE SET NULL,
    FOREIGN KEY (SellerId) REFERENCES Seller(SellerId) ON DELETE SET NULL
);

-- Sample Data

-- Sellers
INSERT INTO Seller (CompanyName, ContactName, Email, Phone, Address, Password, JoinedDate, RegistrationDate) VALUES
('Tech Solutions Ltd', 'John Smith', 'tech@example.com', '123-456-7890', '123 Tech St, Tech City', 'password123', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Hardware Plus', 'Jane Doe', 'hardware@example.com', '234-567-8901', '456 Hardware Ave, Gadget Town', 'password123', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Fresh Farms', 'John Smith', 'john@freshfarms.com', '123-456-7890', '123 Farm Road, Countryside', 'password123', '2023-01-15', '2023-01-15'),
('Organic Supplies', 'Mary Johnson', 'mary@organicsupplies.com', '234-567-8901', '456 Organic Lane, Greenville', 'password123', '2023-02-20', '2023-02-20'),
('Tech Gadgets Inc', 'Robert Williams', 'robert@techgadgets.com', '345-678-9012', '789 Tech Blvd, Silicon Valley', 'password123', '2023-03-10', '2023-03-10');

-- Suppliers
INSERT INTO Suppliers (CompanyName, ContactPerson, Email, Phone, Address, City, State, ZipCode, Country, Category, Status, Notes, JoinedDate) VALUES
('Supplier One', 'Alice Smith', 'alice.supplier@example.com', '111-222-3333', '1 Supplier St', 'CityA', 'StateA', '12345', 'CountryA', 'Electronics', 'Active', 'Top supplier', CURRENT_TIMESTAMP),
('Supplier Two', 'Bob Jones', 'bob.supplier@example.com', '222-333-4444', '2 Supplier Ave', 'CityB', 'StateB', '23456', 'CountryB', 'Clothing', 'Active', '', CURRENT_TIMESTAMP);

-- Customers
INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, Password, RegistrationDate) VALUES
('Alice', 'Brown', 'alice@example.com', '456-789-0123', '101 Main St', 'Anytown', 'password123', '2023-01-20'),
('Bob', 'Green', 'bob@example.com', '567-890-1234', '202 Oak Ave', 'Somecity', 'password123', '2023-02-15'),
('Carol', 'Davis', 'carol@example.com', '678-901-2345', '303 Pine St', 'Otherville', 'password123', '2023-03-05');

-- Products
INSERT INTO Product (ProductName, Description, Price, StockQuantity, Category, SupplierId, ExpirationDate) VALUES
('Fresh Apples', 'Crisp and sweet apples', 2.50, 100, 'Fruits', 1, '2023-12-31'),
('Organic Tomatoes', 'Organic red tomatoes', 3.00, 80, 'Vegetables', 2, '2023-11-30'),
('Laptop Computer', 'High performance laptop', 899.99, 20, 'Electronics', 1, NULL),
('Organic Carrots', 'Fresh organic carrots', 1.75, 60, 'Vegetables', 2, '2023-12-15'),
('Smartphone', 'Latest model smartphone', 100.00, 50, 'Electronics', 1, NULL),
('Fresh Oranges', 'Juicy oranges', 2.25, 120, 'Fruits', 1, '2023-12-20');

-- Orders
INSERT INTO Orders (CustomerId, OrderDate, TotalAmount, Status) VALUES
(1, '2023-06-10', 150.50, 'Delivered'),
(2, '2023-06-15', 75.25, 'Shipped'),
(3, '2023-06-20', 999.99, 'Processing'),
(1, '2023-06-25', 45.75, 'Pending');

-- Order Items
INSERT INTO OrderItem (OrderId, ProductId, Quantity, Price) VALUES
(1, 1, 5, 2.50),
(1, 4, 3, 3.00),
(1, 6, 4, 2.25),
(2, 2, 10, 1.75),
(2, 4, 5, 3.00),
(3, 3, 1, 899.99),
(3, 5, 1, 100.00),
(4, 1, 10, 2.50),
(4, 6, 8, 2.25);

-- Sample Users
INSERT INTO Users (Username, Password, UserType, CustomerId, SellerId) VALUES
('admin@osms.com', 'admin123', 'Admin', NULL, NULL),
('alice@example.com', 'password123', 'Customer', 1, NULL),
('bob@example.com', 'password123', 'Customer', 2, NULL),
('tech@example.com', 'password123', 'Seller', NULL, 1),
('hardware@example.com', 'password123', 'Seller', NULL, 2);

-- Create view for backward compatibility
DROP VIEW IF EXISTS supplier;
CREATE VIEW supplier AS SELECT * FROM Suppliers; 