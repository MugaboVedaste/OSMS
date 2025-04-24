@echo off
echo Fixing Product table Category column...

rem Try standard location first for MySQL executable
set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist %MYSQL_PATH% (
    echo Using MySQL at %MYSQL_PATH%
    %MYSQL_PATH% -u root -pMugabo$123 < fix_category_issue.sql
) else (
    echo MySQL not found at standard location, trying system PATH...
    mysql -u root -pMugabo$123 < fix_category_issue.sql
)

if %ERRORLEVEL% NEQ 0 (
    echo Failed to execute SQL script. Error code: %ERRORLEVEL%
    echo.
    echo Please check that:
    echo 1. MySQL is installed correctly
    echo 2. Your password is correct
    echo 3. The fix_category_issue.sql file exists in the current directory
) else (
    echo Product table structure fixed successfully!
)

echo.
echo Press any key to exit...
pause > nul 