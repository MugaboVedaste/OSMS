-- Fix database schema issues for OSMS
USE osms_db;

-- 1. Add Price column to Product table if it doesn't exist
ALTER TABLE Product ADD COLUMN IF NOT EXISTS Price DECIMAL(10,2) NOT NULL DEFAULT 0.00;

-- 2. Add StockQuantity column to Product table if it doesn't exist
ALTER TABLE Product ADD COLUMN IF NOT EXISTS StockQuantity INT NOT NULL DEFAULT 0;

-- 3. Fix SupplierId constraint issues
-- Try to drop the foreign key constraint if it exists (can't use IF EXISTS on constraints directly)
SET foreign_key_checks = 0;

-- Try to drop each possible constraint name (since we don't know the exact name)
-- These will error if the constraint doesn't exist, but that's ok
ALTER TABLE Product DROP FOREIGN KEY IF EXISTS Product_ibfk_1;
ALTER TABLE Product DROP FOREIGN KEY IF EXISTS fk_product_supplier;

-- Make SupplierId nullable
ALTER TABLE Product MODIFY COLUMN SupplierId INT NULL;

-- Re-add the correct foreign key constraint
ALTER TABLE Product ADD CONSTRAINT fk_product_supplier 
FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

SET foreign_key_checks = 1;

-- 4. Create a view called 'supplier' (lowercase) for backward compatibility
DROP VIEW IF EXISTS supplier;
CREATE VIEW supplier AS SELECT * FROM Suppliers;

-- Done
SELECT 'Database schema fixed successfully' AS Message; 