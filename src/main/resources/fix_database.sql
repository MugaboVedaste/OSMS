-- Fix database schema issues
USE osms_db;

-- 1. Check if the Price column exists in Product table and add it if not
SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = 'osms_db' 
      AND TABLE_NAME = 'Product' 
      AND COLUMN_NAME = 'Price'
    ),
    'SELECT 1', -- Do nothing if exists
    'ALTER TABLE Product ADD COLUMN Price DECIMAL(10,2) NOT NULL DEFAULT 0.00'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Check if StockQuantity column exists in Product table and add it if not
SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = 'osms_db' 
      AND TABLE_NAME = 'Product' 
      AND COLUMN_NAME = 'StockQuantity'
    ),
    'SELECT 1', -- Do nothing if exists
    'ALTER TABLE Product ADD COLUMN StockQuantity INT NOT NULL DEFAULT 0'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. Fix SupplierId constraint issues
-- First drop existing constraint if exists
SET @fkName = (
  SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
  WHERE TABLE_SCHEMA = 'osms_db' 
  AND TABLE_NAME = 'Product'
  AND COLUMN_NAME = 'SupplierId'
  AND REFERENCED_TABLE_NAME = 'Suppliers'
);

SET @sql = CONCAT('ALTER TABLE Product DROP FOREIGN KEY ', @fkName);

SET @sql_drop_fk = (
  SELECT IF(
    @fkName IS NOT NULL,
    @sql,
    'SELECT 1' -- Do nothing if no constraint exists
  )
);
PREPARE stmt FROM @sql_drop_fk;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Then make SupplierId nullable
ALTER TABLE Product MODIFY COLUMN SupplierId INT NULL;

-- Add the correct foreign key constraint
SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT * FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
      WHERE TABLE_SCHEMA = 'osms_db' 
      AND TABLE_NAME = 'Product'
      AND COLUMN_NAME = 'SupplierId'
      AND REFERENCED_TABLE_NAME = 'Suppliers'
    ),
    'SELECT 1', -- Do nothing if constraint already exists
    'ALTER TABLE Product ADD CONSTRAINT fk_product_supplier FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId) ON DELETE SET NULL ON UPDATE CASCADE'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. Create a view called 'supplier' (lowercase) for backward compatibility
SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT * FROM INFORMATION_SCHEMA.VIEWS
      WHERE TABLE_SCHEMA = 'osms_db' 
      AND TABLE_NAME = 'supplier'
    ),
    'DROP VIEW supplier', -- Drop if exists to recreate
    'SELECT 1' -- Do nothing if not exists
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Create the view
CREATE VIEW supplier AS SELECT * FROM Suppliers;

-- Done
SELECT 'Database schema fixed successfully' AS Message; 