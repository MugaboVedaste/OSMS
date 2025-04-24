# PowerShell script to fix the OSMS database

Write-Host "Fixing OSMS database..."

# Create a temporary SQL file
$sqlCommands = @"
USE osms_db;

-- 1. Add Price column to Product table if it doesn't exist
ALTER TABLE Product ADD COLUMN IF NOT EXISTS Price DECIMAL(10,2) NOT NULL DEFAULT 0.00;

-- 2. Add StockQuantity column to Product table if it doesn't exist
ALTER TABLE Product ADD COLUMN IF NOT EXISTS StockQuantity INT NOT NULL DEFAULT 0;

-- 3. Fix SupplierId constraint issues
SET foreign_key_checks = 0;

-- Try to drop constraints 
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
"@

# Write SQL commands to a temporary file
$sqlCommands | Out-File -FilePath "temp_fix.sql" -Encoding utf8

# Use cmd.exe to execute MySQL with redirection
Write-Host "Executing MySQL command..."
cmd.exe /c "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe -u root -pMugabo$123 osms_db < temp_fix.sql"

# Check if the operation was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Database fix completed successfully!"
} else {
    Write-Host "Failed to update database. Error code: $LASTEXITCODE"
    
    # Try alternative path
    Write-Host "Trying alternative MySQL path..."
    cmd.exe /c "mysql -u root -pMugabo$123 osms_db < temp_fix.sql"
}

# Clean up temporary file
Remove-Item "temp_fix.sql"

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 