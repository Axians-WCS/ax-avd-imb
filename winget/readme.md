# Install Winget and Applications

This repository contains scripts to install applications using **Winget** with **Azure Image Builder (AIB)**.

## How It Works
- The **`AibInstallWinget.ps1`** script ensures that **Winget is installed and ready to use** on the host.
- All other scripts install specific applications, following a **modular** approach.

## 📜 Script Overview

| Script Name                          | Description |
|--------------------------------------|-------------|
| **AibInstallWinget.ps1**            | Ensures Winget is installed and initialized. This script is required before running any other installation scripts. |
| **AibInstallAzureCLI.ps1**          | Installs **Azure CLI**, a command-line tool for managing Azure resources. |
| **AibInstallAzureStorageExplorer.ps1** | Installs **Azure Storage Explorer**, a GUI tool for managing Azure Storage accounts. |
| **AibInstallPowerBi.ps1**           | Installs **Microsoft Power BI Desktop**, used for data visualization and business intelligence. |
| **AibInstallSSMS.ps1**              | Installs **SQL Server Management Studio (SSMS)**, a tool for managing Microsoft SQL Server databases. |

## 🔧 Usage
1. **Run or Add `AibInstallWinget.ps1` first** to ensure Winget is available.
2. **Run or Add any other script as needed** to install specific applications.

This setup ensures a **modular and scalable** approach for managing applications in **Azure Image Builder** environments.