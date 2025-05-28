-- Fix Orders table schema to match OrderDAO requirements
USE osms_db;

-- Ensure TotalAmount and Status columns have the expected types and defaults
ALTER TABLE orders MODIFY COLUMN TotalAmount DECIMAL(10,2) NOT NULL DEFAULT 0.00;
ALTER TABLE orders MODIFY COLUMN Status VARCHAR(50) NOT NULL DEFAULT 'Pending';

-- Make sure we have at least some orders
INSERT IGNORE INTO orders (OrderId, CustomerId, OrderDate, TotalAmount, Status)
SELECT 1, 1, CURDATE(), 100.00, 'Delivered'
WHERE NOT EXISTS (SELECT 1 FROM orders LIMIT 1);

-- Print success message
SELECT 'Orders table schema fixed successfully' AS Message; 