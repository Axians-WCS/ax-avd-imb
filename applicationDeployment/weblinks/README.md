# Weblinks Deployment
These scripts create a shortcut with install, uninstall and detectionscript.

## Usage
The scripts creates a shortcut on desktop and/or Start-menu. this is based on param in the install.ps1 file. 

    [bool]$ShortcutOnDesktop         = $true,
    [bool]$ShortcutInStartMenu       = $true

The name of the icon in the package must be the same as in the $ShortcutName.

Package can be changed and is ready for Intune Deployment or AVD Image Deployment

