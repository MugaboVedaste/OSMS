USE osms_db;

-- Check product and supplier tables
SELECT * FROM information_schema.tables WHERE table_schema = 'osms_db';

-- Check product table structure
DESCRIBE Product;

-- Check supplier table structure
DESCRIBE Suppliers;

-- Check foreign keys
SELECT * FROM information_schema.key_column_usage WHERE table_schema = 'osms_db' AND referenced_table_name IS NOT NULL;

-- Drop existing foreign key constraint if there's an issue
ALTER TABLE Product DROP FOREIGN KEY Product_ibfk_1;

-- Recreate the Product table with the correct schema if needed
ALTER TABLE Product 
ADD CONSTRAINT fk_supplier 
FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- Check if there are any suppliers
SELECT * FROM Suppliers LIMIT 10;

-- Display any products
SELECT * FROM Product LIMIT 10; 