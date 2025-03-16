# Define the path for Axians directory
$AxiansPath = "C:\Axians"

# Check if the directory exists; if not, create it as a directory
if (-not (Test-Path -Path $AxiansPath)) {
    New-Item -Path $AxiansPath -ItemType Directory -Force
}

# Copy the script to the Axians directory
Copy-Item -Path ".\Register.Microsoft.AAD.BrokerPlugin.ps1" -Destination "C:\Axians" -Force

# Define the scheduled task short name
$ShedShortName = "Register Microsoft AAD BrokerPlugin2"

# Check if the task already exists, and if it does, remove it
if (Get-ScheduledTask -TaskName $ShedShortName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $ShedShortName -Confirm:$false
}

# Create a trigger to run the task at logon
$trigger1 = New-ScheduledTaskTrigger -AtLogOn 

# Define the action to execute the script using PowerShell
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