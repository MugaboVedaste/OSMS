USE osms_db;

-- Create Customer table if not exists
CREATE TABLE IF NOT EXISTS Customer (
    CustomerId INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(50),
    Password VARCHAR(255) NOT NULL,
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastLogin DATETIME,
    Status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active'
);

-- Create Seller table if not exists
CREATE TABLE IF NOT EXISTS Seller (
    SellerId INT AUTO_INCREMENT PRIMARY KEY,
    BusinessName VARCHAR(100) NOT NULL,
    OwnerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(50),
    BusinessType VARCHAR(50),
    TaxId VARCHAR(50),
    Password VARCHAR(255) NOT NULL,
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ApprovalStatus ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    LastLogin DATETIME,
    Rating DECIMAL(3,2) DEFAULT 0.0,
    CommissionRate DECIMAL(5,2) DEFAULT 5.00,
    AccountBalance DECIMAL(10,2) DEFAULT 0.00
);

-- Create Orders table if not exists
CREATE TABLE IF NOT EXISTS Orders (
    OrderId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    ShippingAddress VARCHAR(255),
    ShippingCity VARCHAR(100),
    ShippingState VARCHAR(50),
    ShippingZipCode VARCHAR(20),
    ShippingCountry VARCHAR(50),
    PaymentMethod VARCHAR(50),
    PaymentStatus ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE SET NULL
);

-- Create OrderItem table if not exists
CREATE TABLE IF NOT EXISTS OrderItem (
    OrderItemId INT AUTO_INCREMENT PRIMARY KEY,
    OrderId INT,
    ProductId INT,
    SellerId INT,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE,
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId) ON DELETE SET NULL,
    FOREIGN KEY (SellerId) REFERENCES Seller(SellerId) ON DELETE SET NULL
);

-- Insert some sample data for testing
INSERT IGNORE INTO Customer (FirstName, LastName, Email, Phone, Address, City, State, Country, Password)
VALUES 
('John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Main St', 'New York', 'NY', 'USA', 'password123'),
('Jane', 'Smith', 'jane.smith@example.com', '987-654-3210', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', 'password123');

INSERT IGNORE INTO Seller (BusinessName, OwnerName, Email, Phone, Address, City, State, Country, BusinessType, TaxId, Password, ApprovalStatus)
VALUES 
('Tech Store Inc.', 'Bob Johnson', 'bob@techstore.com', '555-123-4567', '789 Tech Blvd', 'San Francisco', 'CA', 'USA', 'Electronics', 'TX123456', 'password123', 'Approved'),
('Fashion Hub', 'Alice Brown', 'alice@fashionhub.com', '555-987-6543', '321 Fashion St', 'New York', 'NY', 'USA', 'Clothing', 'TX654321', 'password123', 'Approved'); 