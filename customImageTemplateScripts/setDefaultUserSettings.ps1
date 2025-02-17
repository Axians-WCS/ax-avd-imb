<#
.SYNOPSIS
    Apply Default User Settings for AVD

.DESCRIPTION
    This script:
    - Fetches the default user settings from a JSON file on the AxiansWCS Github
    - Sets the default user settings in the Default User Registry Hive

.AUTHOR
    Luuk Ros

.VERSION
    1.0

.LAST UPDATED
    17-02-2024
#>

#################################################################
#               Apply Default User Settings                     #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AVD AIB CUSTOMIZER PHASE: Apply Default User Settings ***"

# Define the GitHub URL for JSON configuration
$DefaultUserSettingsUrl = "https://raw.githubusercontent.com/Axians-WCS/ax-avd-imb/refs/heads/main/customImageTemplateScripts/configurationFiles/defaultUserSettings.json"

# Fetch the JSON file from GitHub
Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Fetching Default User Settings from GitHub ***"
try {
    $UserSettings = Invoke-RestMethod -Uri $DefaultUserSettingsUrl
    if ($null -eq $UserSettings) {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Failed to fetch Default User Settings. Exiting. ***"
        exit 1
    }
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Default User Settings JSON retrieved successfully. ***"
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Error fetching JSON: [$($_.Exception.Message)] ***"
    exit 1
}

# Apply settings to Default User Registry Hive
Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Applying Default User Settings ***"
try {
    if ($UserSettings.Count -gt 0) {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Loading Default User Registry Hive ***"
        Start-Process reg -ArgumentList "LOAD HKLM\VDOT_TEMP C:\Users\Default\NTUSER.DAT" -PassThru -Wait

        foreach ($Item in $UserSettings) {
            if ($Item.SetProperty -eq $true) {
                $Value = if ($Item.PropertyType -eq "BINARY") { [byte[]]($Item.PropertyValue.Split(",")) } else { $Item.PropertyValue }
                
                if (!(Test-Path $Item.HivePath)) {
                    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Creating new Registry Key: $($Item.HivePath) ***"
                    New-Item -Path $Item.HivePath -Force | Out-Null
                }
                
                if (Get-ItemProperty -Path $Item.HivePath -ErrorAction SilentlyContinue) {
                    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Setting Property: $($Item.HivePath) - $($Item.KeyName) = $Value ***"
                    Set-ItemProperty -Path $Item.HivePath -Name $Item.KeyName -Value $Value -Type $Item.PropertyType -Force
                } else {
                    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Creating New Property: $($Item.HivePath) - $($Item.KeyName) ***"
                    New-ItemProperty -Path $Item.HivePath -Name $Item.KeyName -PropertyType $Item.PropertyType -Value $Value -Force | Out-Null
                }
            }
        }

        Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Unloading Default User Registry Hive ***"
        Start-Process reg -ArgumentList "UNLOAD HKLM\VDOT_TEMP" -PassThru -Wait
    } else {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE *** No Default User Settings to Apply. ***"
    }
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Error applying Default User Settings: [$($_.Exception.Message)] ***"
    exit 1
}

# Finalize the script
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Apply Default User Settings - Exit Code: $LASTEXITCODE ***"
Write-Host "*** Ending AVD AIB CUSTOMIZER PHASE: Apply Default User Settings - Time taken: $elapsedTime ***"

#################################################################
#                         END OF SCRIPT                         #
#################################################################