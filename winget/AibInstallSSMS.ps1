<#
.SYNOPSIS
    Azure Image Builder script to install Microsoft SQL Server Management Studio using Winget.

.DESCRIPTION
    This script:
    - Assumes Winget is already installed and initialized.
    - Installs Microsoft SQL Server Management Studio.

.AUTHOR
    Luuk Ros

.VERSION
    1.1

.LAST UPDATED
    10-02-2025
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Installing Microsoft SQL Server Management Studio ***"

# Ensure Winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Winget is not installed or not available. Exiting... ***"
    exit 1
}

# Define application details
$wingetAppId = "Microsoft.SQLServerManagementStudio"
$wingetAppName = "Microsoft SQL Server Management Studio"

# Install Power BI Desktop using Winget
Write-Host "*** AIB CUSTOMIZER PHASE *** Installing $wingetAppName ($wingetAppId) using Winget ***"
try {
    winget install -e --id $wingetAppId --accept-source-agreements --accept-package-agreements --silent
    Write-Host "*** AIB CUSTOMIZER PHASE *** Successfully installed $wingetAppName ***"
} catch {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to install $wingetAppName [$(${_}.Exception.Message)] ***"
    exit 1
}

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Installation of $wingetAppName Completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################