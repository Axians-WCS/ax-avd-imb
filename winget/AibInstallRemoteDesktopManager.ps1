<#
.SYNOPSIS
    Azure Image Builder script to install Remote Desktop Manager using Winget.

.DESCRIPTION
    - Ensures .NET Desktop Runtime 8.x is installed before installing Remote Desktop Manager.
    - Installs the latest available .NET 8 version dynamically.
    - Installs Remote Desktop Manager using Winget.

.AUTHOR
    Luuk Ros

.VERSION
    1.6

.LAST UPDATED
    12-02-2025
#>

#################################################################
#                 START AIB IMAGE BUILDER PHASE                 #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AIB CUSTOMIZER PHASE: Installing Remote Desktop Manager ***"

# Locate Winget dynamically
$wingetPath = Get-ChildItem -Path "$env:SystemDrive\Program Files\WindowsApps" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1

if (-not $wingetPath) {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Winget not found. Exiting... ***"
    exit 1
}

Write-Host "*** Using Winget from: $wingetPath ***"

# Check if any .NET 8 Desktop Runtime is installed
$dotnetInstalled = & "$env:SystemDrive\Program Files\dotnet\dotnet.exe" --list-runtimes | Select-String "Microsoft.WindowsDesktop.App 8."

if (-not $dotnetInstalled) {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 8 is missing. Installing latest available version via Winget... ***"
    
    try {
        Start-Process -FilePath $wingetPath `
            -ArgumentList "install --id Microsoft.DotNet.DesktopRuntime.8 --accept-source-agreements --accept-package-agreements --silent" `
            -Wait -NoNewWindow
        Write-Host "*** AIB CUSTOMIZER PHASE: Successfully installed latest .NET Desktop Runtime 8.x ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Failed to install .NET Desktop Runtime 8 [$($_.Exception.Message)] ***"
        exit 1
    }
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 8 is already installed. Skipping installation. ***"
}

# Check if any .NET 8 Desktop Runtime is installed
$dotnetInstalled = & "$env:SystemDrive\Program Files\dotnet\dotnet.exe" --list-runtimes | Select-String "Microsoft.WindowsDesktop.App 9."

if (-not $dotnetInstalled) {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 9 is missing. Installing latest available version via Winget... ***"
    
    try {
        Start-Process -FilePath $wingetPath `
            -ArgumentList "install --id Microsoft.DotNet.DesktopRuntime.9 --accept-source-agreements --accept-package-agreements --silent" `
            -Wait -NoNewWindow
        Write-Host "*** AIB CUSTOMIZER PHASE: Successfully installed latest .NET Desktop Runtime 9.x ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Failed to install .NET Desktop Runtime 9 [$($_.Exception.Message)] ***"
        exit 1
    }
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 9 is already installed. Skipping installation. ***"
}

# Define application details
$wingetAppId = "Devolutions.RemoteDesktopManager"
$wingetAppName = "Remote Desktop Manager"

# Install Remote Desktop Manager using Winget
Write-Host "*** AIB CUSTOMIZER PHASE *** Installing $wingetAppName ($wingetAppId) using Winget ***"
try {
    Start-Process -FilePath $wingetPath `
        -ArgumentList "install --id $wingetAppId --accept-source-agreements --accept-package-agreements --scope machine --silent --custom ALLUSERS=1" `
        -Wait -NoNewWindow
    Write-Host "*** AIB CUSTOMIZER PHASE *** Successfully installed $wingetAppName ***"
} catch {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Failed to install $wingetAppName [$($_.Exception.Message)] ***"
    exit 1
}

# Manually create the Start Menu shortcut
Write-Host "*** AIB CUSTOMIZER PHASE: Verifying Start Menu Shortcut for $wingetAppName ***"

$shortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Remote Desktop Manager.lnk"
$targetPath = "C:\Program Files\Devolutions\Remote Desktop Manager\RemoteDesktopManager.exe"

if (Test-Path $targetPath) {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.WorkingDirectory = "C:\Program Files\Remote Desktop Manager"
    $Shortcut.Save()
    Write-Host "*** AIB CUSTOMIZER PHASE: Successfully created Start Menu shortcut for $wingetAppName ***"
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE WARNING: Installation path not found. Skipping shortcut creation. ***"
}

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Installation of $wingetAppName completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################
