<#
.SYNOPSIS
    Azure Image Builder script to install or upgrade Winget.

.DESCRIPTION
    This script:
    - Checks if Winget is already installed and skips unnecessary installs.
    - Downloads and installs the latest version of Winget.
    - Ensures Winget is preconfigured for use in automated builds.
    - Restarts required services only if necessary.

.AUTHOR
    Luuk Ros (Based on avd-installapplications by Niek Pruntel)

.VERSION
    1.7

.LAST UPDATED
    12-02-2025
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Installing or Upgrading Winget ***"

# Check if Winget is Already Installed
$wingetPath = Get-ChildItem -Path "$env:SystemDrive\Program Files\WindowsApps" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
if ($WingetPath) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget already installed at: $WingetPath ***"
    $currentWingetVersion = & "$WingetPath" -v
    Write-Host "*** AIB CUSTOMIZER PHASE *** Current Winget Version: $currentWingetVersion ***"
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
}

# Ensure Winget is Fully Functional
Write-Host "*** AIB CUSTOMIZER PHASE *** Ensuring Winget is preconfigured ***"

# Reset and Update Sources
Start-Process -FilePath $WingetPath `
    -ArgumentList "source reset --force" `
    -Wait -NoNewWindow

Start-Process -FilePath $WingetPath `
    -ArgumentList "source update" `
    -Wait -NoNewWindow

# Enable `msstore` Source and Accept Agreements
Start-Process -FilePath $WingetPath `
    -ArgumentList "source enable --name msstore" `
    -Wait -NoNewWindow

# Ensure Winget Sends Region Data
$settingsPath = "$env:TEMP\winget-settings.json"

Start-Process -FilePath $WingetPath `
    -ArgumentList "settings export -o $settingsPath" `
    -Wait -NoNewWindow

if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath | ConvertFrom-Json
    $settings.InstallBehavior |= @{ "SendRegion" = $true }
    $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath

    Start-Process -FilePath $WingetPath `
        -ArgumentList "settings import -i $settingsPath" `
        -Wait -NoNewWindow
}

Write-Host "*** AIB CUSTOMIZER PHASE *** Winget preconfiguration complete ***"

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
$wingetPath = Get-ChildItem -Path "$env:SystemDrive\Program Files\WindowsApps" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
if ($WingetPath) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget found at: $WingetPath ***"
    $newWingetVersion = & "$WingetPath" -v
    Write-Host "*** AIB CUSTOMIZER PHASE *** Installed Winget Version: $newWingetVersion ***"
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