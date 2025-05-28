@echo off
echo Executing complete database fix...

rem Try standard location first for MySQL executable
set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist %MYSQL_PATH% (
    echo Using MySQL at %MYSQL_PATH%
    %MYSQL_PATH% -u root -pMugabo$123 < complete_db_fix.sql
) else (
    echo MySQL not found at standard location, trying system PATH...
    mysql -u root -pMugabo$123 < complete_db_fix.sql
)

if %ERRORLEVEL% NEQ 0 (
    echo Failed to execute SQL script. Error code: %ERRORLEVEL%
    echo.
    echo Please check that:
    echo 1. MySQL is installed correctly
    echo 2. Your password is correct
    echo 3. The complete_db_fix.sql file exists in the current directory
) else (
    echo Database structure has been completely fixed!
    echo.
    echo Now restarting Tomcat to apply changes...
    
    net stop "Apache Tomcat 9.0 Tomcat9"
    timeout /t 3 /nobreak > nul
    net start "Apache Tomcat 9.0 Tomcat9"
    
    echo Tomcat has been restarted. The changes should now be applied.
)

echo.
echo Press any key to exit...
pause > nul 