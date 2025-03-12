$ShedShortName = "Register Microsoft AAD BrokerPlugin"
$exeSchTasks = "schtasks.exe"
$ScriptPath = "C:\Axians\Register.Microsoft.AAD.BrokerPlugin.ps1"

# Delete the scheduled task
Start-Process -FilePath $exeSchTasks -ArgumentList "/delete /tn `"$ShedShortName`" /f" -NoNewWindow -Wait -ErrorAction Stop

# Check if the script file exists and delete it
if (Test-Path $ScriptPath) {
    Remove-Item -Path $ScriptPath -Force -ErrorAction Stop
    Write-Output "Script file deleted successfully."
} else {
    Write-Output "Script file not found, nothing to delete."
}