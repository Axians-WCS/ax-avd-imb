This scripts create a shortcut with install, uninstall and detectionscript.
The scripts creates a shortcut on desktop and/or Start-menu.

    [bool]$ShortcutOnDesktop         = $true,
    [bool]$ShortcutInStartMenu       = $true

Based on the param that are set in the install.ps file.

The name of the icon must be the same as in the $ShortcutName.

Package can be changed and is ready for Intune Deployment or AVD Image Deployment

