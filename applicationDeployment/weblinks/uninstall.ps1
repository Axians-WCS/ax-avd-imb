param (
    [system.string]$ShortcutName     = "SharePoint WCS",
    [system.string]$Desktop          = "C:\Users\Public\Desktop\",
    [system.string]$StartMenu        = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"
)

# Remove the shortcut from the desktop if it exists
if (Test-Path "$Desktop\$ShortcutName.lnk") {
    Remove-Item "$Desktop\$ShortcutName.lnk" -Force -Confirm:$False
    Write-Output "Shortcut '$ShortcutName' removed from desktop."
}

# Remove the shortcut from the Start Menu if it exists
if (Test-Path "$StartMenu\$ShortcutName.lnk") {
    Remove-Item "$StartMenu\$ShortcutName.lnk" -Force -Confirm:$False
    Write-Output "Shortcut '$ShortcutName' removed from Start Menu."
}
