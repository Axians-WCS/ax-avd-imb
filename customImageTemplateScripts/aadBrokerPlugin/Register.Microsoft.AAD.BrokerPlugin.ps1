function Write-Log {
    [CmdletBinding()]
    param(
         [Parameter(Mandatory=$True)]
         [ValidateNotNullOrEmpty()]
         [string]$Source,
 
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [int]$EventId = 0,
                         
         [Parameter(Mandatory=$True)]
         [ValidateNotNullOrEmpty()]
         [string]$Message,
  
         [Parameter(Mandatory=$True)]
         [ValidateNotNullOrEmpty()]
         [ValidateSet('Information','Warning','Error')]
         [string]$EntryType = 'Information'
     )
 
    $LogFolder = "$($env:ProgramData)\IntuneLogging"
    $LogFile = "$($LogFolder )\$($Source).log"
    if(-not (Test-Path $LogFolder)) {
        New-Item -Path $LogFolder -ItemType directory
    }
    if(-not (Test-Path $LogFile)) {
        Add-Content -Path $LogFile -Value "Date;Level;Message" -ErrorAction SilentlyContinue
    }
    Add-Content -Path $LogFile -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss");$($EntryType);($env:username);$($Message)" -ErrorAction SilentlyContinue
 
 }
if (-not (Get-AppxPackage Microsoft.AAD.BrokerPlugin)) 
{ 
	Add-AppxPackage -Register "$env:windir\SystemApps\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\Appxmanifest.xml" -DisableDevelopmentMode -ForceApplicationShutdown 
}

Write-Log -Source "Microsoft.AAD.BrokerPlugin" -Message "Registration of AAD Broker Plugin finished. Time: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")" -EntryType Information