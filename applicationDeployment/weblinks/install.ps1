param (
    [system.string]$ShortcutName     = "SharePoint WCS",
    [system.string]$ShortcutUrl      = "https://m365.cloud.microsoft/?auth=2&home=1",
    [system.string]$Desktop          = "C:\Users\Public\Desktop\",
    [system.string]$StartMenu        = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\",
    [system.string]$IntuneProgramDir = "$env:ProgramData\Icons",
    [System.String]$TempIcon         = "$IntuneProgramDir\$ShortcutName.ico",
    [bool]$ShortcutOnDesktop         = $true,
    [bool]$ShortcutInStartMenu       = $true
)

#Test if icon is currently present, if so delete it so we can update it
$IconPresent = Get-ChildItem -Path $Desktop | Where-Object {$_.Name -eq "$ShortcutName.lnk"}
If ($null -ne $IconPresent)
{
    Remove-Item $IconPresent.VersionInfo.FileName -Force -Confirm:$False
}

$IconPresent = Get-ChildItem -Path $StartMenu | Where-Object {$_.Name -eq "$ShortcutName.lnk"}
If ($null -ne $IconPresent)
{
    Remove-Item $IconPresent.VersionInfo.FileName -Force -Confirm:$False
}

$WScriptShell = New-Object -ComObject WScript.Shell

If ((Test-Path -Path $IntuneProgramDir) -eq $False)
{
    New-Item -ItemType Directory $IntuneProgramDir -Force -Confirm:$False
}

#Start download of the icon in blob storage 
Copy-Item -Path "$PSScriptRoot\$ShortcutName.ico" "$IntuneProgramDir\$ShortcutName.ico" -Force


if ($ShortcutOnDesktop)
{
    $Shortcut = $WScriptShell.CreateShortcut("$Desktop\$ShortcutName.lnk")
    $Shortcut.TargetPath = $ShortcutUrl
    $Shortcut.IconLocation = $TempIcon
    $Shortcut.Save()
}

if ($ShortCutInStartMenu)
{
    $Shortcut = $WScriptShell.CreateShortcut("$StartMenu\$ShortcutName.lnk")
    $Shortcut.TargetPath = $ShortcutUrl
    $Shortcut.IconLocation = $TempIcon
    $Shortcut.Save()
}
