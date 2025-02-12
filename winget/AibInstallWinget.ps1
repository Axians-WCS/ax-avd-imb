<#
.SYNOPSIS
    Azure Image Builder script to install or upgrade Winget.

.DESCRIPTION
    This script:
    - Always downloads and installs the latest version of Winget.
    - Uses the same logic as the working Packer solution.
    - Restarts required services to ensure Winget functions properly.

.AUTHOR
    Luuk Ros (Based on avd-installapplications by Niek Pruntel)

.VERSION
    1.5

.LAST UPDATED
    12-02-2025
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Installing or Upgrading Winget ***"

# Define Installer Folder
$InstallerFolder = Join-Path $env:ProgramData "CustomScripts"
if (!(Test-Path $InstallerFolder)) {
    New-Item -Path $InstallerFolder -ItemType Directory -Force -Confirm:$false
}

# Define Winget Installer URL & Path
$WinGetURL = "https://aka.ms/getwinget"
$WingetInstallerPath = "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

# Download Winget MSIXBundle
Write-Host "*** AIB CUSTOMIZER PHASE *** Downloading Winget installer... ***"
try {
    Invoke-WebRequest -Uri $WinGetURL -OutFile $WingetInstallerPath -UseBasicParsing
    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget downloaded successfully ***"
} catch {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to download Winget installer. Exiting... ***"
    exit 1
}

# Install Winget MSIXBundle
Write-Host "*** AIB CUSTOMIZER PHASE *** Installing Winget ***"
try {
    Add-AppxProvisionedPackage -Online -PackagePath $WingetInstallerPath -SkipLicense
    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget installed successfully ***"
} catch {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to install Winget. Exiting... ***"
    exit 1
}

# Remove Installer File
Remove-Item -Path $WingetInstallerPath -Force -ErrorAction SilentlyContinue
Write-Host "*** AIB CUSTOMIZER PHASE *** Winget installation cleanup complete ***"

# Restart Services to Ensure Winget Works
Write-Host "*** AIB CUSTOMIZER PHASE *** Restarting services to ensure Winget functions correctly ***"
$services = @("AppXSvc", "ClipSVC")
foreach ($service in $services) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Restarting $service ***"
    Restart-Service -Name $service -Force -ErrorAction SilentlyContinue
}

Write-Host "*** AIB CUSTOMIZER PHASE *** Winget services restarted ***"

# Wait for system to register Winget
Write-Host "*** AIB CUSTOMIZER PHASE *** Waiting for Winget to become available ***"
Start-Sleep -Seconds 5

# Attempt to Get Winget Version
$WingetPath = Get-ChildItem "C:\Program Files\WindowsApps\" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($WingetPath) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget found at: $($WingetPath.FullName) ***"
    & "$($WingetPath.FullName)" -v
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Winget is not recognized. A reboot may be required. ***"
}

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Winget Installation Completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################