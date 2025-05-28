-- Complete database fix script
USE osms_db;

-- Set foreign_key_checks to 0 to avoid constraint issues during modifications
SET foreign_key_checks = 0;

-- 1. Check and drop all foreign key constraints on Product table
SELECT GROUP_CONCAT(CONCAT('ALTER TABLE Product DROP FOREIGN KEY ', CONSTRAINT_NAME, ';'))
INTO @drop_fk_stmt
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'osms_db'
  AND TABLE_NAME = 'Product'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Execute the drop constraints if any were found
SET @drop_exec = IF(@drop_fk_stmt IS NOT NULL, @drop_fk_stmt, 'SELECT "No foreign keys found to drop"');
PREPARE stmt FROM @drop_exec;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Check if there are data integrity issues with existing products referencing non-existent suppliers
-- First create a backup of problematic products if they exist
CREATE TABLE IF NOT EXISTS Product_Backup (
  ProductId INT PRIMARY KEY,
  ProductName VARCHAR(255) NOT NULL,
  Description TEXT,
  Price DECIMAL(10,2) DEFAULT 0.00,
  StockQuantity INT DEFAULT 0,
  Category VARCHAR(100),
  SupplierId INT,
  ExpirationDate DATE
);

-- Backup any existing products
INSERT IGNORE INTO Product_Backup
SELECT * FROM Product;

-- 3. Drop and recreate the Product table with correct structure
DROP TABLE IF EXISTS Product;

CREATE TABLE Product (
  ProductId INT AUTO_INCREMENT PRIMARY KEY,
  ProductName VARCHAR(255) NOT NULL,
  Description TEXT,
  Price DECIMAL(10,2) NOT NULL DEFAULT 0.00, 
  StockQuantity INT NOT NULL DEFAULT 0,
  Category VARCHAR(100) NULL,
  SupplierId INT NULL,
  ExpirationDate DATE NULL
);

-- 4. Restore any valid products from backup that have valid SupplierId references
INSERT INTO Product (ProductId, ProductName, Description, Price, StockQuantity, Category, SupplierId, ExpirationDate)
SELECT pb.ProductId, 
       COALESCE(pb.ProductName, 'Unnamed Product') AS ProductName, 
       pb.Description, 
       COALESCE(pb.Price, 0.00) AS Price, 
       COALESCE(pb.StockQuantity, 0) AS StockQuantity, 
       pb.Category, 
       CASE 
         WHEN s.SupplierId IS NULL THEN NULL 
         ELSE pb.SupplierId 
       END AS SupplierId,
       pb.ExpirationDate
FROM Product_Backup pb
LEFT JOIN Suppliers s ON pb.SupplierId = s.SupplierId;

-- 5. Add foreign key constraint with new name
ALTER TABLE Product
ADD CONSTRAINT fk_product_supplier_new
FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- 6. Create Category table if it doesn't exist
CREATE TABLE IF NOT EXISTS ProductCategory (
  CategoryId INT AUTO_INCREMENT PRIMARY KEY,
  CategoryName VARCHAR(100) NOT NULL UNIQUE,
  Description TEXT,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some default categories
INSERT IGNORE INTO ProductCategory (CategoryName)
VALUES ('Food'), ('Electronics'), ('Clothing'), ('Home Goods'), ('Beauty'), ('Other');

-- 7. Ensure supplier view exists for backward compatibility
DROP VIEW IF EXISTS supplier;
CREATE VIEW supplier AS SELECT * FROM Suppliers;

-- 8. Re-enable foreign key checks
SET foreign_key_checks = 1;

-- Show the results
SHOW TABLES;
DESCRIBE Product;
DESCRIBE Suppliers;
DESCRIBE ProductCategory;

-- Done
SELECT 'Database structure completely fixed' AS Message; 