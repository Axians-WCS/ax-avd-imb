<#
.SYNOPSIS
    Creates a scheduled task to run the AAD Broker Plugin script at user logon.

.DESCRIPTION
    - Downloads Register.Microsoft.AAD.BrokerPlugin.ps1 from a public GitHub repo to C:\Axians.
    - Registers a scheduled task that runs it at user logon.

.AUTHOR
    Luuk Ros

.VERSION
    1.3

.LAST UPDATED
    07-03-2025
#>

#################################################################
#                 CREATE AAD BROKER SCHEDULED TASK              #
#################################################################

$ShedShortName = "Register Microsoft AAD BrokerPlugin"
$installPath = "C:\Axians"
$scriptPath = Join-Path $installPath "Register.Microsoft.AAD.BrokerPlugin.ps1"
$scriptUrl = "https://raw.githubusercontent.com/Axians-WCS/ax-avd-imb/refs/heads/main/customImageTemplateScripts/aadBrokerPlugin/Register.Microsoft.AAD.BrokerPlugin.ps1"

# Ensure the installation folder exists
if (-not (Test-Path -Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    Write-Host "Created installation folder: $installPath"
}

# Download the script from GitHub
Write-Host "Downloading AAD Broker Plugin script from GitHub..."
try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -UseBasicParsing
    Write-Host "Downloaded AAD Broker Plugin script to $scriptPath"
} catch {
    Write-Host "ERROR: Failed to download script from $scriptUrl"
    exit 1
}

# Define Triger and Scheduled Task
$trigger1 = New-ScheduledTaskTrigger -AtLogOn 
$action = New-ScheduledTaskAction -Execute 'PowerShell' -Argument "-NoLogo -WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File 'C:\Axians\Register.Microsoft.AAD.BrokerPlugin.ps1'"

# Create a trigger array with the logon trigger
$trigger = @(
    $trigger1		
)

# Define the principal and settings for the scheduled task
$principal = New-ScheduledTaskPrincipal -GroupId S-1-5-32-545
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

# Create and register the scheduled task
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings
Register-ScheduledTask $ShedShortName -InputObject $task

# Start the scheduled task
Start-ScheduledTask $ShedShortName

#################################################################
#                         END OF SCRIPT                         #
#################################################################