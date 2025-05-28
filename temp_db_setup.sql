CREATE DATABASE IF NOT EXISTS osms_db;
USE osms_db;

DROP TABLE IF EXISTS Product;
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
    JoinedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Product (
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

INSERT INTO Suppliers (CompanyName, ContactPerson, Email, Phone, Address, City, State, Country, Category)
VALUES ('Default Supplier', 'John Doe', 'contact@defaultsupplier.com', '123-456-7890', '123 Main St', 'New York', 'NY', 'USA', 'General'); 