@echo off
echo Fixing OSMS database...

rem Create a temporary SQL file
echo USE osms_db; > temp_fix.sql
echo. >> temp_fix.sql

rem Add Price column if it doesn't exist (using procedure approach)
echo -- 1. Add Price column to Product table if it doesn't exist >> temp_fix.sql
echo SET @stmt = CONCAT('SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ''osms_db'' AND TABLE_NAME = ''Product'' AND COLUMN_NAME = ''Price'''); >> temp_fix.sql
echo PREPARE stmt FROM @stmt; >> temp_fix.sql
echo EXECUTE stmt; >> temp_fix.sql
echo DEALLOCATE PREPARE stmt; >> temp_fix.sql
echo. >> temp_fix.sql
echo SET @count = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'osms_db' AND TABLE_NAME = 'Product' AND COLUMN_NAME = 'Price'); >> temp_fix.sql
echo SET @stmt = IF(@count = 0, 'ALTER TABLE Product ADD COLUMN Price DECIMAL(10,2) NOT NULL DEFAULT 0.00', 'SELECT ''Price column already exists'''); >> temp_fix.sql
echo PREPARE stmt FROM @stmt; >> temp_fix.sql
echo EXECUTE stmt; >> temp_fix.sql
echo DEALLOCATE PREPARE stmt; >> temp_fix.sql
echo. >> temp_fix.sql

rem Add StockQuantity column if it doesn't exist
echo -- 2. Add StockQuantity column to Product table if it doesn't exist >> temp_fix.sql
echo SET @count = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'osms_db' AND TABLE_NAME = 'Product' AND COLUMN_NAME = 'StockQuantity'); >> temp_fix.sql
echo SET @stmt = IF(@count = 0, 'ALTER TABLE Product ADD COLUMN StockQuantity INT NOT NULL DEFAULT 0', 'SELECT ''StockQuantity column already exists'''); >> temp_fix.sql
echo PREPARE stmt FROM @stmt; >> temp_fix.sql
echo EXECUTE stmt; >> temp_fix.sql
echo DEALLOCATE PREPARE stmt; >> temp_fix.sql
echo. >> temp_fix.sql

rem Fix SupplierId constraint issues
echo -- 3. Fix SupplierId constraint issues >> temp_fix.sql
echo SET foreign_key_checks = 0; >> temp_fix.sql
echo. >> temp_fix.sql

rem Try to drop each possible constraint name
echo -- Drop existing foreign keys if they exist >> temp_fix.sql
echo SET @constraint_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = 'osms_db' AND TABLE_NAME = 'Product' AND REFERENCED_TABLE_NAME = 'Suppliers' LIMIT 1); >> temp_fix.sql
echo SET @query = IF(@constraint_name IS NOT NULL, CONCAT('ALTER TABLE Product DROP FOREIGN KEY ', @constraint_name), 'SELECT ''No foreign key constraint found'''); >> temp_fix.sql
echo PREPARE stmt FROM @query; >> temp_fix.sql
echo EXECUTE stmt; >> temp_fix.sql
echo DEALLOCATE PREPARE stmt; >> temp_fix.sql
echo. >> temp_fix.sql

rem Make SupplierId nullable
echo -- Make SupplierId nullable >> temp_fix.sql
echo ALTER TABLE Product MODIFY COLUMN SupplierId INT NULL; >> temp_fix.sql
echo. >> temp_fix.sql

rem Add correct foreign key constraint
echo -- Re-add the correct foreign key constraint >> temp_fix.sql
echo ALTER TABLE Product ADD CONSTRAINT fk_product_supplier FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId) ON DELETE SET NULL ON UPDATE CASCADE; >> temp_fix.sql
echo. >> temp_fix.sql
echo SET foreign_key_checks = 1; >> temp_fix.sql
echo. >> temp_fix.sql

rem Create supplier view
echo -- 4. Create a view called 'supplier' (lowercase) for backward compatibility >> temp_fix.sql
echo DROP VIEW IF EXISTS supplier; >> temp_fix.sql
echo CREATE VIEW supplier AS SELECT * FROM Suppliers; >> temp_fix.sql
echo. >> temp_fix.sql

echo -- Done >> temp_fix.sql
echo SELECT 'Database schema fixed successfully' AS Message; >> temp_fix.sql

rem Try to locate MySQL executable
set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist %MYSQL_PATH% (
    echo Found MySQL at %MYSQL_PATH%
    %MYSQL_PATH% -u root -pMugabo$123 osms_db < temp_fix.sql
) else (
    echo MySQL not found at %MYSQL_PATH%, trying 'mysql' command...
    mysql -u root -pMugabo$123 osms_db < temp_fix.sql
)

if %ERRORLEVEL% NEQ 0 (
    echo Failed to update database. Error code: %ERRORLEVEL%
    echo.
    echo Please check that:
    echo 1. MySQL is installed correctly
    echo 2. Your MySQL password is correct
    echo 3. The osms_db database exists
) else (
    echo Database fix completed successfully!
)

rem Clean up temporary file
del temp_fix.sql

echo.
pause 