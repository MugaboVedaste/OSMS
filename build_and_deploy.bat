@echo off
REM Build and deploy script for Online Shop Management System

echo ===================================================
echo Building the OSMS project with Maven
echo ===================================================
call mvn clean package

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b %ERRORLEVEL%
)

echo ===================================================
echo Creating uploads directory if it doesn't exist
echo ===================================================
if not exist "C:\apache-tomcat\webapps\osms\uploads" (
    mkdir "C:\apache-tomcat\webapps\osms\uploads"
    echo Created uploads directory
) else (
    echo Uploads directory already exists
)

echo ===================================================
echo Copying WAR file to Tomcat webapps directory
echo ===================================================
copy /Y target\osms.war C:\apache-tomcat\webapps\

echo ===================================================
echo Deployment complete!
echo ===================================================
echo.
echo You can now access the application at:
echo http://localhost:8080/osms/
echo.

pause 