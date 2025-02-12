<#
.SYNOPSIS
    Azure Image Builder script to install or upgrade Winget.

.DESCRIPTION
    This script:
    - Ensures Winget is installed.
    - Restarts services to ensure Winget functions properly.

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

# Function to Check if Winget Exists
function Check-Winget {
    # Check if Winget is available via command
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget is already available ***"
        return $true
    }

    # Check if Winget.exe exists in WindowsApps
    $WingetProgLocation = Get-ChildItem "C:\Program Files\WindowsApps\" -Recurse -Filter "winget.exe" | Select-Object -First 1
    if ($WingetProgLocation) {
        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget.exe found in $($WingetProgLocation.Directory.FullName) ***"
        return $true
    }

    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget is not installed ***"
    return $false
}

# Function to Install Winget
function Install-Winget {
    if (Check-Winget) {
        return
    }

    Write-Host "*** AIB CUSTOMIZER PHASE *** Winget is missing. Installing now... ***"

    # Define Winget Installer URL
    $wingetInstallerUrl = "https://aka.ms/getwinget"
    $wingetInstallerPath = "$env:TEMP\AppInstaller.msixbundle"

    # Download Winget
    Write-Host "*** AIB CUSTOMIZER PHASE *** Downloading Winget installer... ***"
    try {
        Invoke-WebRequest -Uri $wingetInstallerUrl -OutFile $wingetInstallerPath -UseBasicParsing
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to download Winget installer. Exiting... ***"
        exit 1
    }

    # Install Winget using `AppInstaller.exe`
    Write-Host "*** AIB CUSTOMIZER PHASE *** Installing Winget using AppInstaller.exe ***"
    try {
        Start-Process -FilePath "C:\Windows\System32\AppInstallerCLI.exe" -ArgumentList "install $wingetInstallerPath" -Wait -NoNewWindow
        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget installed successfully ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to install Winget. Exiting... ***"
        exit 1
    }

    # Clean up installer file
    Remove-Item -Path $wingetInstallerPath -Force

    # Verify Winget installation
    if (-not (Check-Winget)) {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Winget installation failed. Exiting... ***"
        exit 1
    }
}

# Install Winget
Install-Winget

# Restart Required Services to Ensure Winget Works
Write-Host "*** AIB CUSTOMIZER PHASE *** Restarting services to ensure Winget functions correctly ***"

$services = @("AppXSvc", "ClipSVC")
foreach ($service in $services) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Restarting $service ***"
    Restart-Service -Name $service -Force -ErrorAction SilentlyContinue
}

Write-Host "*** AIB CUSTOMIZER PHASE *** Winget services restarted ***"

# Ensure Winget Sources Are Updated
Write-Host "*** AIB CUSTOMIZER PHASE *** Updating Winget sources ***"
winget source update

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Winget Installation Completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################