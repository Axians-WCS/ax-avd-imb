#>

$FslogixUrl= "https://aka.ms/fslogix_download"

# Make directory to hold install files

mkdir "C:\Windows\Temp\fslogix\install" -Force

try {
    Invoke-WebRequest -Uri $FslogixUrl -OutFile "C:\Windows\Temp\fslogix\install\FSLogixAppsSetup.zip" -UseBasicParsing
} catch {
    Write-Error "ERROR: Failed to download FSLogix. $_"
    exit 1
}

Expand-Archive `
    -LiteralPath "C:\Windows\Temp\fslogix\install\FSLogixAppsSetup.zip" `
    -DestinationPath "C:\Windows\Temp\fslogix\install" `
    -Force `
    -Verbose
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
cd "C:\Windows\Temp\fslogix\install\"



# Install FSLogix. 
Write-Host "INFO: Installing FSLogix. . ."
Start-Process "C:\Windows\Temp\fslogix\install\x64\Release\FSLogixAppsSetup.exe" `
    -ArgumentList "/install /quiet" `
    -Wait `
    -Passthru `
  


Write-Host "INFO: FSLogix install finished."

# Cleanup
# Remove the install files
Remove-Item "C:\Windows\Temp\fslogix" -Recurse -Force


