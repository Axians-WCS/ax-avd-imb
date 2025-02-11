<#
.SYNOPSIS
    Azure Image Builder script to install or upgrade Winget.

.DESCRIPTION
    This script:
    - Ensures Winget is installed.
    - Initializes required services to ensure Winget functions properly.

.AUTHOR
    Luuk Ros

.VERSION
    1.4

.LAST UPDATED
    11-02-2025
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Installing or Upgrading Winget ***"

# Ensure Winget is Installed
function Check-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget is not installed. Installing now... ***"

        # Define the App Installer package URL (Latest Microsoft Store version)
        $wingetInstallerUrl = "https://aka.ms/getwinget"

        # Define the local download path
        $wingetInstallerPath = "$env:TEMP\AppInstaller.msixbundle"

        # Download Winget
        Write-Host "*** AIB CUSTOMIZER PHASE *** Downloading Winget installer... ***"
        try {
            Invoke-WebRequest -Uri $wingetInstallerUrl -OutFile $wingetInstallerPath -UseBasicParsing
        } catch {
            Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to download Winget installer. Exiting... ***"
            exit 1
        }

        # Install Winget (App Installer) normally
        Write-Host "*** AIB CUSTOMIZER PHASE *** Installing Winget (App Installer) ***"
        try {
            Add-AppxPackage -Path $wingetInstallerPath
            Write-Host "*** AIB CUSTOMIZER PHASE *** Winget installed successfully ***"
        } catch {
            Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to install Winget. Exiting... ***"
            exit 1
        }

        # Clean up installer file
        Remove-Item -Path $wingetInstallerPath -Force

        # Verify Winget installation
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Winget installation failed. Exiting... ***"
            exit 1
        }
    } else {
        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget is already available ***"
    }
}

# Run the function to check if Winget is installed
Check-Winget

# Ensure Winget Sources Are Updated
Write-Host "*** AIB CUSTOMIZER PHASE *** Updating Winget sources ***"
winget source update

# Ensure Winget initializes properly
Write-Host "*** AIB CUSTOMIZER PHASE *** Restarting services to ensure Winget works ***"

$services = @("AppXSvc", "ClipSVC")
foreach ($service in $services) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Restarting $service ***"
    Restart-Service -Name $service -Force -ErrorAction SilentlyContinue
}

Write-Host "*** AIB CUSTOMIZER PHASE *** Winget services restarted ***"

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Winget Installation Completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################