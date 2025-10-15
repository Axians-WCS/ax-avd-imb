# Install Winget and Applications

This repository contains scripts to install applications using Winget with Azure Image Builder (AIB).

## How It Works
- The `AibInstallWinget.ps1` script ensures that Winget is installed and ready to use on the host.
- All other scripts install specific applications, following a modular approach.

## 📜 Script Overview

| Script Name                          | Description |
|--------------------------------------|-------------|
| **AibInstallWinget.ps1**            | Ensures Winget is installed and initialized. This script is required before running any other installation scripts. |
| **AibInstallAgentRansack.ps1**      | Installs Agent Ransack, a file searching utility. |
| **AibInstallAzureCLI.ps1**          | Installs Azure CLI, a command-line tool for managing Azure resources. |
| **AibInstallAzureStorageExplorer.ps1** | Installs Azure Storage Explorer, a GUI tool for managing Azure Storage accounts. |
| **aibInstallDaxStudios.ps1**        | Installs DAX Studio, a tool for analyzing and optimizing DAX queries. |
| **AibInstallKeePassXC.ps1**         | Installs KeePassXC, a password manager. |
| **AibInstallmRemoteNG.ps1**        | Installs mRemoteNG, a multi-protocol remote connections manager. |
| **AibInstallNotepad++.ps1**         | Installs Notepad++, an advanced text editor. |
| **aibInstallOctoparse.ps1**         | Installs Octoparse, a web scraping tool. |
| **aibInstallOdbc17.ps1**            | Installs ODBC Driver 17 for SQL Server. |
| **aibInstallOdbc18.ps1**            | Installs ODBC Driver 18 for SQL Server. |
| **AibInstallPostman.ps1**           | Installs Postman, an API platform for building and using APIs. |
| **AibInstallPowerBi.ps1**           | Installs Microsoft Power BI Desktop, used for data visualization and business intelligence. |
| **AibInstallPutty.ps1**             | Installs Putty, a terminal emulator and SSH client. |
| **AibInstallRemoteDesktopManager.ps1** | Installs Devolutions Remote Desktop Manager, a tool for managing servers remotely. |
| **AibInstallSSMS.ps1**              | Installs SQL Server Management Studio (SSMS), a tool for managing Microsoft SQL Server databases. |
| **AibInstallTeamViewer.ps1**        | Installs TeamViewer, a remote access and support tool. |
| **AibInstallWinScp.ps1**            | Installs WinSCP, a file transfer tool for SFTP, FTP, and SCP. |

## ⚠️ Known Issues
- The Postman installation script (`AibInstallPostman.ps1`) is currently not working and needs investigation.

## 🔧 Usage
Add the scripts during the Customizations step in Azure Image Builder by clicking `+ Add your own` script and providing the script URL and giving it a name.
1. Add `AibInstallWinget.ps1` first to ensure Winget is available.
2. Add any other script as needed to install specific applications.

This setup ensures a modular and scalable approach for managing applications in Azure Image Builder environments.