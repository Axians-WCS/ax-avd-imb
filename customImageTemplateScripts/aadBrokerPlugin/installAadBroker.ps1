$scheduledtasks = "C:\ProgramData\ScheduledTasks"
if (-not (Test-Path -Path $scheduledtasks)) {
    New-Item -ItemType Directory -Path $scheduledtasks
}
# download location of brokerscript
$Brokerscript= "https://github.com/Axians-WCS/ax-avd-imb/blob/main/customImageTemplateScripts/aadBrokerPlugin/Register.Microsoft.AAD.BrokerPlugin.ps1"
# Define the path to the new file
$filePath = "$scheduledtasks\Register.Microsoft.AAD.BrokerPlugin.ps1"

try {
    Invoke-WebRequest -Uri $Brokerscript -OutFile $filePath -UseBasicParsing
} catch {
    Write-Error "ERROR: Failed to download Brokerscript. $_"
    exit 1
}

# Define the scheduled task short name
$ShedShortName = "Register Microsoft AAD BrokerPlugin"

# Check if the task already exists, and if it does, remove it
if (Get-ScheduledTask -TaskName $ShedShortName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $ShedShortName -Confirm:$false
}

# Create a trigger to run the task at logon
$trigger1 = New-ScheduledTaskTrigger -AtLogOn 

# Define the action to execute the script using PowerShell
$action = New-ScheduledTaskAction -Execute 'PowerShell' -Argument "-NoLogo -WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File $filePath"

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