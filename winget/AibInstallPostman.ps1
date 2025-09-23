<#
.SYNOPSIS
    Azure Image Builder script to install Postman using Winget.
.DESCRIPTION
    This script:
    - Assumes Winget is already installed and initialized.
    - Dynamically locates Winget to ensure execution.
    - Installs Postman (handles user-scope installation).
    - Creates Start Menu shortcut for all users.
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
Write-Host "*** AIB CUSTOMIZER PHASE: Installing Postman ***"

# Locate winget dynamically
$wingetPath = Get-ChildItem -Path "$env:SystemDrive\Program Files\WindowsApps" -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1

# If winget is still not found, fail gracefully
if (-not $wingetPath) {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR: Winget not found in WindowsApps. Exiting... ***"
    exit 1
}
Write-Host "*** Using Winget from: $wingetPath ***"

# Define application details
$wingetAppId = "Postman.Postman"
$wingetAppName = "Postman"

# Install Postman using Winget (without scope machine as it's not supported)
Write-Host "*** AIB CUSTOMIZER PHASE *** Installing $wingetAppName ($wingetAppId) using Winget ***"
Write-Host "*** Note: Postman installs per-user. Installing for current user and creating shared shortcut. ***"

try {
    # First attempt: Try with --scope machine (in case it becomes supported)
    $installArgs = "install --id $wingetAppId --accept-source-agreements --accept-package-agreements --scope machine --silent"
    $process = Start-Process -FilePath $wingetPath -ArgumentList $installArgs -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -ne 0) {
        Write-Host "*** AIB CUSTOMIZER PHASE: Machine-wide installation not supported, trying user installation... ***"
        
        # Second attempt: Install without scope machine
        $installArgs = "install --id $wingetAppId --accept-source-agreements --accept-package-agreements --silent"
        Start-Process -FilePath $wingetPath -ArgumentList $installArgs -Wait -NoNewWindow
    }
    
    Write-Host "*** AIB CUSTOMIZER PHASE *** Successfully installed $wingetAppName ***"
} catch {
    Write-Host "*** AIB CUSTOMIZER PHASE ERROR *** Failed to install $wingetAppName [$($_.Exception.Message)] ***"
    exit 1
}

# Wait for installation to complete
Start-Sleep -Seconds 10

# Find Postman installation path
Write-Host "*** AIB CUSTOMIZER PHASE: Searching for Postman installation path ***"

$possiblePaths = @(
    "$env:LOCALAPPDATA\Postman\Postman.exe",
    "$env:APPDATA\Postman\Postman.exe",
    "C:\Users\$env:USERNAME\AppData\Local\Postman\Postman.exe",
    "$env:ProgramFiles\Postman\Postman.exe",
    "${env:ProgramFiles(x86)}\Postman\Postman.exe"
)

$postmanExePath = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $postmanExePath = $path
        Write-Host "*** AIB CUSTOMIZER PHASE: Found Postman at: $path ***"
        break
    }
}

# If not found in standard locations, search for it
if (-not $postmanExePath) {
    Write-Host "*** AIB CUSTOMIZER PHASE: Searching for Postman.exe in common directories... ***"
    
    $searchPaths = @(
        "$env:LOCALAPPDATA",
        "$env:APPDATA",
        "$env:ProgramFiles",
        "${env:ProgramFiles(x86)}"
    )
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            $searchResult = Get-ChildItem -Path $searchPath -Recurse -Filter "Postman.exe" -ErrorAction SilentlyContinue | 
                           Where-Object { $_.FullName -like "*Postman\Postman.exe" } | 
                           Select-Object -First 1
            if ($searchResult) {
                $postmanExePath = $searchResult.FullName
                Write-Host "*** AIB CUSTOMIZER PHASE: Found Postman at: $postmanExePath ***"
                break
            }
        }
    }
}

# Create Start Menu shortcut for all users
if ($postmanExePath) {
    Write-Host "*** AIB CUSTOMIZER PHASE: Creating Start Menu Shortcut for all users ***"
    
    $shortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Postman.lnk"
    $workingDirectory = Split-Path $postmanExePath -Parent
    
    try {
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $postmanExePath
        $Shortcut.WorkingDirectory = $workingDirectory
        $Shortcut.IconLocation = "$postmanExePath,0"
        $Shortcut.Description = "Postman API Platform"
        $Shortcut.Save()
        
        # Release COM object
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WScriptShell) | Out-Null
        
        Write-Host "*** AIB CUSTOMIZER PHASE: Successfully created Start Menu shortcut for all users ***"
    } catch {
        Write-Host "*** AIB CUSTOMIZER PHASE WARNING: Failed to create shortcut [$($_.Exception.Message)] ***"
    }
    
    # For AIB: Copy to a location accessible by all users (optional)
    Write-Host "*** AIB CUSTOMIZER PHASE: Checking if Postman needs to be made available system-wide ***"
    
    $systemWidePath = "C:\Program Files\Postman"
    if (-not (Test-Path $systemWidePath)) {
        try {
            Write-Host "*** AIB CUSTOMIZER PHASE: Copying Postman to Program Files for system-wide access ***"
            $sourceDir = Split-Path $postmanExePath -Parent
            Copy-Item -Path $sourceDir -Destination $systemWidePath -Recurse -Force
            
            # Update shortcut to point to system-wide location
            $systemPostmanExe = Join-Path $systemWidePath "Postman.exe"
            if (Test-Path $systemPostmanExe) {
                $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
                $Shortcut.TargetPath = $systemPostmanExe
                $Shortcut.WorkingDirectory = $systemWidePath
                $Shortcut.Save()
                Write-Host "*** AIB CUSTOMIZER PHASE: Updated shortcut to use system-wide installation ***"
            }
        } catch {
            Write-Host "*** AIB CUSTOMIZER PHASE WARNING: Could not copy to Program Files [$($_.Exception.Message)] ***"
        }
    }
} else {
    Write-Host "*** AIB CUSTOMIZER PHASE WARNING: Postman executable not found. Installation may have failed. ***"
}

# Verify installation via winget
Write-Host "*** AIB CUSTOMIZER PHASE: Verifying installation via Winget ***"
Start-Process -FilePath $wingetPath `
    -ArgumentList "list --id $wingetAppId" `
    -Wait -NoNewWindow

# Finalize script execution
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AIB CUSTOMIZER PHASE: Installation of $wingetAppName Completed in $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################
