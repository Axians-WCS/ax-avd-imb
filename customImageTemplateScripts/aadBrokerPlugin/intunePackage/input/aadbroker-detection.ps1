$ShedShortName = "Register Microsoft AAD BrokerPlugin"
$ScriptPath = "C:\Axians\Register.Microsoft.AAD.BrokerPlugin.ps1"

# Check if the scheduled task exists
$ShedShortNameExists = Get-ScheduledTask -TaskName $ShedShortName -ErrorAction SilentlyContinue

# Check if the script file exists
$ScriptExists = Test-Path $ScriptPath

if ($ShedShortNameExists -ne $null -and $ScriptExists)
{
    Write-Output "Microsoft AAD BrokerPlugin installed."
    exit 0
}
else
{
    Write-Output "Microsoft AAD BrokerPlugin not installed."
    exit 1
}