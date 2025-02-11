<#
.SYNOPSIS
    Azure Image Builder script to install and initialize Winget and Microsoft Store if missing.

.DESCRIPTION
    This script:
    - Ensures the Microsoft Store is installed and accessible.
    - Installs Winget if missing.
    - Initializes Microsoft Store to ensure Winget functions properly.

.AUTHOR
    Luuk Ros

.VERSION
    1.3

.LAST UPDATED
    10-02-2025
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Starting Winget & Microsoft Store Installation ***"

# Step 1: Ensure Microsoft Store is Installed
Write-Host "*** AIB CUSTOMIZER PHASE *** Checking if Microsoft Store is installed ***"

$storePackage = Get-AppxPackage -Name Microsoft.WindowsStore -ErrorAction SilentlyContinue

if (-not $storePackage) {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Microsoft Store is missing. Attempting to install... ***"

    # Define Microsoft Store package URL (Microsoft official link)
    $storeInstallUrl = "https://aka.ms/MicrosoftStoreApp"

    # Define local download path
    $storeInstallerPath = "$env:TEMP\MicrosoftStore.AppxBundle"

    # Download the Microsoft Store installer
    try {
        Invoke-WebRequest -Uri $storeInstallUrl -OutFile $storeInstallerPath -UseBasicParsing
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to download Microsoft Store. Exiting... ***"
        exit 1
    }

    # Install the Microsoft Store
    try {
        Add-AppxProvisionedPackage -Online -PackagePath $storeInstallerPath -SkipLicense
        Write-Host "*** AIB CUSTOMIZER PHASE *** Microsoft Store installed successfully! ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to install Microsoft Store. Exiting... ***"
        exit 1
    }

    # Clean up the installer file
    Remove-Item -Path $storeInstallerPath -Force
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE *** Microsoft Store is already installed. Skipping installation. ***"
}

# Step 2: Force Initialize the Microsoft Store
Write-Host "*** AIB CUSTOMIZER PHASE *** Ensuring Microsoft Store is initialized for Winget ***"

# Reinstall App Installer (which includes Winget)
Get-AppxPackage -Name Microsoft.DesktopAppInstaller | Foreach-Object { 
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" 
}

# Open Microsoft Store once to force initialization
Start-Process -FilePath "explorer.exe" -ArgumentList "ms-windows-store:" -WindowStyle Hidden
Start-Sleep -Seconds 10
Stop-Process -Name "WinStore.App" -ErrorAction SilentlyContinue

Write-Host "*** AIB CUSTOMIZER PHASE *** Microsoft Store has been initialized ***"

# Step 3: Ensure Winget is Installed
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

        # Install Winget (App Installer)
        Write-Host "*** AIB CUSTOMIZER PHASE *** Installing Winget (App Installer) ***"
        try {
            Add-AppxProvisionedPackage -Online -PackagePath $wingetInstallerPath -SkipLicense
        } catch {
            Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to install Winget. Exiting... ***"
            exit 1
        }

        # Clean up installer file
        Remove-Item -Path $wingetInstallerPath -Force

        # Wait a few seconds to ensure Winget is fully registered
        Start-Sleep -Seconds 5

        # Verify Winget installation
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Winget installation failed. Exiting... ***"
            exit 1
        }

        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget installed successfully ***"
    } else {
        Write-Host "*** AIB CUSTOMIZER PHASE *** Winget is already available ***"
    }
}

# Run the function to check if Winget is installed
Check-Winget

# Step 4: Ensure Winget Sources Are Updated
Write-Host "*** AIB CUSTOMIZER PHASE *** Updating Winget sources ***"
winget source update

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Winget & Microsoft Store Installation Completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################