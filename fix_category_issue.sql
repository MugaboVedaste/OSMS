-- Fix Product table structure - add Category column and fix foreign key
USE osms_db;

-- Disable foreign key checks
SET foreign_key_checks = 0;

-- 1. Drop any existing foreign key constraints on the Product table
SELECT CONCAT('ALTER TABLE Product DROP FOREIGN KEY ', CONSTRAINT_NAME, ';')
INTO @dropConstraintSQL
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'osms_db'
  AND TABLE_NAME = 'Product'
  AND COLUMN_NAME = 'SupplierId'
  AND REFERENCED_TABLE_NAME = 'Suppliers'
  AND CONSTRAINT_NAME IS NOT NULL
LIMIT 1;

-- Execute the drop constraint command if a constraint was found
SET @preparedStmt = IF(@dropConstraintSQL IS NOT NULL, @dropConstraintSQL, 'SELECT "No constraint found"');
PREPARE stmt FROM @preparedStmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Add the Category column if it doesn't exist
SET @checkCategory = (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'osms_db' 
  AND TABLE_NAME = 'Product' 
  AND COLUMN_NAME = 'Category'
);

SET @addCategorySQL = IF(@checkCategory = 0, 
                      'ALTER TABLE Product ADD COLUMN Category VARCHAR(100) NULL', 
                      'SELECT "Category column already exists"');
PREPARE stmt FROM @addCategorySQL;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. Make SupplierId nullable if it isn't already
ALTER TABLE Product MODIFY COLUMN SupplierId INT NULL;

-- 4. Add back the foreign key constraint with a new name
ALTER TABLE Product ADD CONSTRAINT fk_product_supplier_new 
FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId)
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- Re-enable foreign key checks
SET foreign_key_checks = 1;

-- Show the updated Product table structure
DESCRIBE Product;

-- Done
SELECT 'Product table structure fixed successfully' AS Message; 