<#
.SYNOPSIS
    Azure Image Builder script to install Microsoft ODBC 17 using Winget.

.DESCRIPTION
    This script:
    - Assumes Winget is already installed.
    - Dynamically locates Winget to ensure execution.
    - Installs Microsoft ODBC 17 machine-wide.

.AUTHOR
    Luuk Ros

.VERSION
    1.0

.LAST UPDATED
    19-02-2025
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Installing Microsoft ODBC 17 ***"

# Locate winget dynamically
$wingetPath = Get-ChildItem -Path "$env:SystemDrive\Program Files\WindowsApps" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1

# If winget is still not found, fail gracefully
if (-not $wingetPath) {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Winget not found in WindowsApps. Exiting... ***"
    exit 1
}

Write-Host "*** Using Winget from: $wingetPath ***"

# Define application details
$wingetAppId = "Microsoft.msodbcsql.17"
$wingetAppName = "Microsoft ODBC 17"

# Install Microsoft ODBC 17 using Winget (Machine-Wide)
Write-Host "*** AIB CUSTOMIZER PHASE: Installing $wingetAppName ($wingetAppId) using Winget ***"
try {
    Start-Process -FilePath $wingetPath `
        -ArgumentList "install --id $wingetAppId --accept-source-agreements --accept-package-agreements --scope machine --silent" `
        -Wait -NoNewWindow
    Write-Host "*** AIB CUSTOMIZER PHASE: Successfully installed $wingetAppName ***"
} catch {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Failed to install $wingetAppName [$($_.Exception.Message)] ***"
    exit 1
}

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Installation of $wingetAppName completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################