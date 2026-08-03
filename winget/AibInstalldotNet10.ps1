<#
.SYNOPSIS
    Azure Image Builder script to install .NET 10 using Winget.

.DESCRIPTION
    - Installs the latest available .NET 10 version dynamically.

.AUTHOR
    Erik Woldhuis

.VERSION
    1.0

.LAST UPDATED
    03-08-2026
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Installing  .NET 10 ***"

# Locate Winget dynamically
$wingetPath = Get-ChildItem -Path "$env:SystemDrive\Program Files\WindowsApps" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1

if (-not $wingetPath) {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Winget not found. Exiting... ***"
    exit 1
}

Write-Host "*** Using Winget from: $wingetPath ***"

# Check if any .NET 10 Desktop Runtime is installed
$dotnetInstalled = & "$env:SystemDrive\Program Files\dotnet\dotnet.exe" --list-runtimes | Select-String "Microsoft.WindowsDesktop.App 10."

if (-not $dotnetInstalled) {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 10 is missing. Installing latest available version via Winget... ***"

    try {
        Start-Process -FilePath $wingetPath `
            -ArgumentList "install --id Microsoft.DotNet.DesktopRuntime.10 --accept-source-agreements --accept-package-agreements --silent" `
            -Wait -NoNewWindow

        Write-Host "*** AIB CUSTOMIZER PHASE: Successfully installed latest .NET Desktop Runtime 10.x ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Failed to install .NET Desktop Runtime 10 [$($_.Exception.Message)] ***"
        exit 1
    }
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 10 is already installed. Skipping installation. ***"
}
