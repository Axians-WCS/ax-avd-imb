param (
    [system.string]$ShortcutName     = "SharePoint WCS",
    [system.string]$Desktop          = "C:\Users\Public\Desktop\",
    [system.string]$StartMenu        = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"
)

# Check if the shortcut exists on the desktop
$DesktopShortcut = Test-Path "$Desktop\$ShortcutName.lnk"

# Check if the shortcut exists in the Start Menu
$StartMenuShortcut = Test-Path "$StartMenu\$ShortcutName.lnk"

if ($DesktopShortcut -or $StartMenuShortcut) {
    Write-Output "Shortcut '$ShortcutName' exists."
    exit 0
} else {
    Write-Output "Shortcut '$ShortcutName' does not exist."
    exit 1
}
