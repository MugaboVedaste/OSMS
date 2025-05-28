@echo off
echo Building and deploying Online Shop Management System...

rem Set paths (modify these according to your environment)
set MAVEN_HOME=C:\Program Files\Apache Software Foundation\Maven\apache-maven-3.9.9
set TOMCAT_HOME=C:\Program Files\Apache Software Foundation\Tomcat 9.0
set CATALINA_HOME=C:\Program Files\Apache Software Foundation\Tomcat 9.0
set JAVA_HOME=C:\Program Files\Java\jdk-23
set PATH=%JAVA_HOME%\bin;%PATH%

rem Build the project with Maven
echo Building project with Maven...
call "%MAVEN_HOME%\bin\mvn" clean package

if %ERRORLEVEL% NEQ 0 (
    echo Maven build failed!
    exit /b %ERRORLEVEL%
)

echo Maven build successful!

rem Stop Tomcat if it's running
echo Stopping Tomcat...
call "%TOMCAT_HOME%\bin\shutdown.bat"

rem Remove old application deployment
echo Removing old deployment...
if exist "%TOMCAT_HOME%\webapps\osms.war" del "%TOMCAT_HOME%\webapps\osms.war"
if exist "%TOMCAT_HOME%\webapps\osms" rmdir /s /q "%TOMCAT_HOME%\webapps\osms"

rem Copy the new WAR file to Tomcat webapps directory
echo Deploying new WAR file...
copy target\osms.war "%TOMCAT_HOME%\webapps"

rem Start Tomcat
echo Starting Tomcat...
call "%TOMCAT_HOME%\bin\startup.bat"

echo Deployment complete! 
echo Application will be available at http://localhost:8080/osms 