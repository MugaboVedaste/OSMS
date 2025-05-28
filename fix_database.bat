@echo off
echo This script will fix the OSMS database issues
echo.
echo Please enter your MySQL root password when prompted
echo.
echo Running MySQL fix script...
mysql -u root -p osms_db < fix_database_direct.sql
if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Failed to run the script automatically.
  echo.
  echo Please run these commands manually:
  echo 1. Open MySQL client with: mysql -u root -p
  echo 2. When connected, paste the contents of fix_database_direct.sql
  echo.
  pause
  exit /b 1
) else (
  echo.
  echo Database fix completed successfully!
  echo.
  pause
) 