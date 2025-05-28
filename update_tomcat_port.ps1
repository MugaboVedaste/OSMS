# Script to update Tomcat port from 8080 to 8081
$configFile = "C:\Program Files\Apache Software Foundation\Tomcat 9.0\conf\server.xml"

# Read the file content
$content = Get-Content -Path $configFile -Raw

# Make a backup of server.xml
Copy-Item -Path $configFile -Destination "$configFile.bak" -Force

# Replace the port number
$updatedContent = $content -replace '<Connector port="8080"', '<Connector port="8081"'

# Write the updated content back to the file
Set-Content -Path $configFile -Value $updatedContent

# Verify the change was made
$newContent = Get-Content -Path $configFile -Raw
if ($newContent -match '<Connector port="8081"') {
    Write-Host "Tomcat port successfully updated from 8080 to 8081!"
} else {
    Write-Host "Warning: Could not verify port change. Please check $configFile manually."
}

Write-Host "Tomcat port has been updated from 8080 to 8081. Please restart Tomcat to apply changes." 