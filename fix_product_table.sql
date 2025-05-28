-- Fix duplicate foreign key constraint issue in Product table
USE osms_db;

-- First, check if the constraint exists and drop it
SET @constraint_exists = (
    SELECT COUNT(*)
    FROM information_schema.table_constraints 
    WHERE constraint_schema = 'osms_db' 
    AND table_name = 'Product' 
    AND constraint_name = 'fk_product_supplier'
);

-- If the constraint exists, drop it
SET @sql = IF(@constraint_exists > 0,
    'ALTER TABLE Product DROP FOREIGN KEY fk_product_supplier',
    'SELECT ''Constraint does not exist'' AS message');
    
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check for any other foreign key constraints on the SupplierId column
ALTER TABLE Product DROP FOREIGN KEY IF EXISTS Product_ibfk_1;

-- Add the correct foreign key constraint with a different name
ALTER TABLE Product
ADD CONSTRAINT fk_product_supplier_new
FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- Verify the table structure
SHOW CREATE TABLE Product; 