<#
.SYNOPSIS
    Azure Image Builder script to install Remote Desktop Manager using Winget.

.DESCRIPTION
    - Ensures .NET Desktop Runtime 8.x AND 9.x are installed before installing Remote Desktop Manager.
    - Installs both .NET 8 and .NET 9 for maximum compatibility.
    - Installs Remote Desktop Manager using Winget.
    - Dynamically finds the installation path and creates Start Menu shortcut.

.AUTHOR
    Luuk Ros

.VERSION
    2.0

.LAST UPDATED
    23-09-2025
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

# Check and install .NET Desktop Runtime 8 and 9
$dotnetPath = "$env:SystemDrive\Program Files\dotnet\dotnet.exe"
$dotnet8Installed = $false
$dotnet9Installed = $false

if (Test-Path $dotnetPath) {
    $runtimes = & $dotnetPath --list-runtimes
    $dotnet8Installed = $runtimes | Select-String "Microsoft.WindowsDesktop.App 8."
    $dotnet9Installed = $runtimes | Select-String "Microsoft.WindowsDesktop.App 9."
}

# Install .NET 8 Desktop Runtime if not present
if (-not $dotnet8Installed) {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 8 is missing. Installing latest available version via Winget... ***"
    
    try {
        Start-Process -FilePath $wingetPath `
            -ArgumentList "install --id Microsoft.DotNet.DesktopRuntime.8 --accept-source-agreements --accept-package-agreements --silent --scope machine" `
            -Wait -NoNewWindow
        Write-Host "*** AIB CUSTOMIZER PHASE: Successfully installed latest .NET Desktop Runtime 8.x ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Failed to install .NET Desktop Runtime 8 [$($_.Exception.Message)] ***"
        # Don't exit, try to continue with .NET 9
    }
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 8 is already installed. Skipping installation. ***"
}

# Install .NET 9 Desktop Runtime if not present
if (-not $dotnet9Installed) {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 9 is missing. Installing latest available version via Winget... ***"
    
    try {
        Start-Process -FilePath $wingetPath `
            -ArgumentList "install --id Microsoft.DotNet.DesktopRuntime.9 --accept-source-agreements --accept-package-agreements --silent --scope machine" `
            -Wait -NoNewWindow
        Write-Host "*** AIB CUSTOMIZER PHASE: Successfully installed latest .NET Desktop Runtime 9.x ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Failed to install .NET Desktop Runtime 9 [$($_.Exception.Message)] ***"
        exit 1
    }
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE: .NET Desktop Runtime 9 is already installed. Skipping installation. ***"
}

Start-Sleep -Seconds 60

# Define application details
$wingetAppId = "Devolutions.RemoteDesktopManager"
$wingetAppName = "Remote Desktop Manager"

# Install Remote Desktop Manager using Winget
Write-Host "*** AIB CUSTOMIZER PHASE *** Installing $wingetAppName ($wingetAppId) using Winget ***"
try {
    Start-Process -FilePath $wingetPath `
        -ArgumentList "install --id $wingetAppId --accept-source-agreements --accept-package-agreements --scope machine --silent" `
        -Wait -NoNewWindow
    Write-Host "*** AIB CUSTOMIZER PHASE *** Successfully installed $wingetAppName ***"
} catch {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Failed to install $wingetAppName [$($_.Exception.Message)] ***"
    exit 1
}

# Wait a moment for installation to complete
Start-Sleep -Seconds 5

# Dynamically find the installation path
Write-Host "*** AIB CUSTOMIZER PHASE: Searching for Remote Desktop Manager installation path ***"

$possiblePaths = @(
    "C:\Program Files\Devolutions\Remote Desktop Manager",
    "C:\Program Files (x86)\Devolutions\Remote Desktop Manager",
    "C:\Program Files\Remote Desktop Manager",
    "C:\Program Files (x86)\Remote Desktop Manager"
)

$rdmExePath = $null
foreach ($path in $possiblePaths) {
    $testPath = Join-Path $path "RemoteDesktopManager.exe"
    if (Test-Path $testPath) {
        $rdmExePath = $testPath
        Write-Host "*** AIB CUSTOMIZER PHASE: Found Remote Desktop Manager at: $testPath ***"
        break
    }
}

# If not found in standard locations, search for it
if (-not $rdmExePath) {
    Write-Host "*** AIB CUSTOMIZER PHASE: Searching for RemoteDesktopManager.exe in Program Files... ***"
    $searchResult = Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Recurse -Filter "RemoteDesktopManager.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($searchResult) {
        $rdmExePath = $searchResult.FullName
        Write-Host "*** AIB CUSTOMIZER PHASE: Found Remote Desktop Manager at: $rdmExePath ***"
    }
}

# Create the Start Menu shortcut if the executable was found
if ($rdmExePath) {
    Write-Host "*** AIB CUSTOMIZER PHASE: Creating Start Menu Shortcut for $wingetAppName ***"
    
    $shortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Remote Desktop Manager.lnk"
    $workingDirectory = Split-Path $rdmExePath -Parent
    
    try {
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $rdmExePath
        $Shortcut.WorkingDirectory = $workingDirectory
        $Shortcut.IconLocation = "$rdmExePath,0"
        $Shortcut.Description = "Remote Desktop Manager"
        $Shortcut.Save()
        
        # Release COM object
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WScriptShell) | Out-Null
        
        Write-Host "*** AIB CUSTOMIZER PHASE: Successfully created Start Menu shortcut for $wingetAppName ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE WARNING: Failed to create shortcut [$($_.Exception.Message)] ***"
    }
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE WARNING: Remote Desktop Manager executable not found. Skipping shortcut creation. ***"
    Write-Host "*** AIB CUSTOMIZER PHASE: Installation may have failed or requires a reboot. ***"
}

# Verify installation via winget
Write-Host "*** AIB CUSTOMIZER PHASE: Verifying installation via Winget ***"
Start-Process -FilePath $wingetPath `
    -ArgumentList "list --id $wingetAppId" `
    -Wait -NoNewWindow

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Installation of $wingetAppName completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################
