<#
.SYNOPSIS
    Azure Image Builder script to install or upgrade Winget.

.DESCRIPTION
    This script:
    - Ensures Winget is installed.
    - Uses DISM to install Winget since AIB runs as SYSTEM.
    - Initializes required services to ensure Winget functions properly.

.AUTHOR
    Luuk Ros

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

# Step 1: Ensure Winget is Installed Using DISM
function Install-Winget {
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

        # Install Winget using DISM (Provisioning for all users)
        Write-Host "*** AIB CUSTOMIZER PHASE *** Installing Winget using DISM ***"
        try {
            Add-ProvisionedAppxPackage -Online -PackagePath $wingetInstallerPath -SkipLicense
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

# Run the function to check/install Winget
Install-Winget

# Step 2: Restart Required Services to Ensure Winget Works
Write-Host "*** AIB CUSTOMIZER PHASE *** Restarting services to ensure Winget functions correctly ***"

$services = @("AppXSvc", "ClipSVC")
foreach ($service in $services) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Restarting $service ***"
    Restart-Service -Name $service -Force -ErrorAction SilentlyContinue
}

Write-Host "*** AIB CUSTOMIZER PHASE *** Winget services restarted ***"

# Step 3: Ensure Winget Sources Are Updated
Write-Host "*** AIB CUSTOMIZER PHASE *** Updating Winget sources ***"
winget source update

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Winget Installation Completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################