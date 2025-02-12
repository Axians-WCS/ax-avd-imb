<#
.SYNOPSIS
    Azure Image Builder script to install or upgrade Winget.

.DESCRIPTION
    This script:
    - Downloads and installs the latest version of Winget.
    - Checks if Winget is already installed and skips unnecessary installs.
    - Restarts required services only if necessary.
    - Provides logging for debugging in AIB.

.AUTHOR
    Luuk Ros (Based on avd-installapplications by Niek Pruntel)

.VERSION
    1.6

.LAST UPDATED
    12-02-2025
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Installing or Upgrading Winget ***"

# Check if Winget is Already Installed
$WingetPath = Get-ChildItem "C:\Program Files\WindowsApps\" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
if ($WingetPath) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget already installed at: $WingetPath ***"
    $currentWingetVersion = & "$WingetPath" -v
    Write-Host "*** AIB CUSTOMIZER PHASE *** Current Winget Version: $currentWingetVersion ***"
    Write-Host "*** AIB CUSTOMIZER PHASE: Skipping installation. ***"
} else {
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
    Invoke-WebRequest -Uri $WinGetURL -OutFile $WingetInstallerPath -UseBasicParsing
    if (!(Test-Path $WingetInstallerPath)) {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to download Winget. Exiting... ***"
        exit 1
    }
    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget downloaded successfully ***"

    # Install Winget MSIXBundle
    Write-Host "*** AIB CUSTOMIZER PHASE *** Installing Winget ***"
    try {
        Add-AppxProvisionedPackage -Online -PackagePath $WingetInstallerPath -SkipLicense
        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget installed successfully ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to install Winget [$($_.Exception.Message)]. Exiting... ***"
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

    # Check if Winget is installed successfully
    $WingetPath = Get-ChildItem "C:\Program Files\WindowsApps\" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
    if ($WingetPath) {
        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget found at: $WingetPath ***"
        $newWingetVersion = & "$WingetPath" -v
        Write-Host "*** AIB CUSTOMIZER PHASE *** Installed Winget Version: $newWingetVersion ***"
    } else {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Winget is not recognized. A reboot may be required. ***"
    }
}

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Winget Installation Completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################