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

$taskName = "AAD Broker Plugin Fix"
$installPath = "C:\Axians"
$scriptPath = Join-Path $installPath "Register.Microsoft.AAD.BrokerPlugin.ps1"
$scriptUrl = "https://raw.githubusercontent.com/Axians-WCS/ax-avd-imb/main/customImageTemplateScripts/AADBrokerPlugin/Register.Microsoft.AAD.BrokerPlugin.ps1"

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

# Define scheduled task parameters
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "BUILTIN\Users" -LogonType Interactive
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register the scheduled task
try {
    Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings -Force
    Write-Host "Scheduled task '$taskName' created successfully."
} catch {
    Write-Host "ERROR: Failed to create scheduled task: $_"
    exit 1
}

#################################################################
#                         END OF SCRIPT                         #
#################################################################