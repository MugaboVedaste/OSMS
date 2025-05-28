-- Update Orders table to match OrderDAO requirements
USE osms_db;

-- Check if Orders table exists
SET @tableExists = (
  SELECT COUNT(*) FROM information_schema.tables 
  WHERE table_schema = 'osms_db' 
  AND table_name = 'orders'
);

-- Drop existing Orders table if it doesn't match our schema
SET @sql = (
  SELECT IF(
    @tableExists > 0,
    'DROP TABLE orders',
    'SELECT 1' -- Do nothing if table doesn't exist
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Create the Orders table with the correct schema
CREATE TABLE orders (
    OrderId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    Status VARCHAR(50) NOT NULL DEFAULT 'Pending'
);

-- Create OrderItem table to store individual items in an order
SET @orderItemTableExists = (
  SELECT COUNT(*) FROM information_schema.tables 
  WHERE table_schema = 'osms_db' 
  AND table_name = 'orderitem'
);

-- Drop existing OrderItem table if it exists
SET @sql = (
  SELECT IF(
    @orderItemTableExists > 0,
    'DROP TABLE orderitem',
    'SELECT 1' -- Do nothing if table doesn't exist
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Create OrderItem table
CREATE TABLE orderitem (
    OrderItemId INT AUTO_INCREMENT PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT,
    SellerId INT,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES orders(OrderId) ON DELETE CASCADE,
    FOREIGN KEY (ProductId) REFERENCES product(ProductId) ON DELETE SET NULL,
    FOREIGN KEY (SellerId) REFERENCES seller(SellerId) ON DELETE SET NULL
);

-- Insert some sample data
INSERT INTO orders (CustomerId, OrderDate, TotalAmount, Status)
VALUES 
    (1, '2023-01-15', 175.50, 'Delivered'),
    (2, '2023-02-20', 89.99, 'Shipped'),
    (1, '2023-03-10', 45.75, 'Processing'),
    (3, '2023-04-05', 120.00, 'Pending');

-- Make sure Customer table exists
SET @customerTableExists = (
  SELECT COUNT(*) FROM information_schema.tables 
  WHERE table_schema = 'osms_db' 
  AND table_name = 'customer'
);

-- Create Customer table if it doesn't exist
SET @sql = (
  SELECT IF(
    @customerTableExists = 0,
    'CREATE TABLE customer (
        CustomerId INT AUTO_INCREMENT PRIMARY KEY,
        FirstName VARCHAR(50) NOT NULL,
        LastName VARCHAR(50) NOT NULL,
        Email VARCHAR(100) UNIQUE NOT NULL,
        Phone VARCHAR(20),
        Address VARCHAR(255),
        City VARCHAR(100),
        Password VARCHAR(255),
        RegistrationDate DATE
    )',
    'SELECT 1' -- Do nothing if table exists
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Insert sample customers if the table is empty
SET @customerCount = (SELECT COUNT(*) FROM customer);
SET @sql = (
  SELECT IF(
    @customerCount = 0,
    'INSERT INTO customer (FirstName, LastName, Email, Phone, Address, City, Password, RegistrationDate)
     VALUES 
        ("John", "Doe", "john@example.com", "555-1234", "123 Main St", "New York", "password1", NOW()),
        ("Jane", "Smith", "jane@example.com", "555-5678", "456 Oak Ave", "Chicago", "password2", NOW()),
        ("Bob", "Johnson", "bob@example.com", "555-9012", "789 Pine Blvd", "Los Angeles", "password3", NOW())',
    'SELECT 1' -- Do nothing if customers exist
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Done
SELECT 'Orders table updated successfully' AS Message; 