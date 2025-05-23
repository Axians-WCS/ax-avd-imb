# Axians AVD Image Builder

This repository hosts scripts and parameter files used by Axians to create custom AVD images for their customers as part of the Axians AVD Managed Services. These files support the deployment of Axians Image Builder resources and the creation of images within the Custom Image Template resource in Azure.

## 📂 Repository Structure

| Folder Name                      | Description |
|----------------------------------|-------------|
| **customImageTemplateScripts**   | Scripts for configuring and optimizing VMs in the Custom Image Template resource. |
| **managedIdentity**              | Scripts and parameter files for setting up a Managed Identity for Azure Image Builder. |
| **winget**                       | Scripts to install applications using Winget within an Azure Image Builder deployment. |
| **applicationDeployment**        | Example scripts for installing applications AVD or Intune                              |

---

## 🔐 **Managed Identity**
The managedIdentity folder contains scripts to create and configure a Managed Identity for Azure Image Builder. This identity is required to create images within the subscription.

### 📜 Script Overview
| Script Name                       | Description |
|----------------------------------|-------------|
| **createManagedIdentityAib.ps1** | Creates a Managed Identity for Azure Image Builder and assigns the necessary permissions. |
| **aibRoleImageCreation.json**    | Defines the required role permissions for the Managed Identity to create images. |
| **aibVnetImageCreation.json**    | Defines the required role permissions for the Managed Identity to add VMs to subnets. |

---

## 🖥 **Custom Image Template Scripts**
The customImageTemplateScripts folder contains scripts that help configure and optimize VMs for use within the Custom Image Template resource in Azure.

### 📜 Script Overview
| Script Name                      | Description |
|----------------------------------|-------------|
| **runFullScan.ps1**              | Performs a full system scan using Windows Defender to detect and report threats. |
| **setDefaultUserSettings.ps1**   | Optimizes Default User Settings for Azure Virtual Desktop (AVD) based on a configuration file stored in the ConfigurationFiles subfolder. |

---

## 📦 **Winget Application Installations**
The winget folder contains scripts that install applications using Winget in an Azure Image Builder (AIB) deployment. These scripts ensure that essential tools and applications are available in the image.

### 📜 Script Overview
| Script Name                      | Description |
|----------------------------------|-------------|
| **aibInstallWinget.ps1**         | Ensures Winget is installed and initialized. Required before running any other installation scripts. |
| **aibInstallAzureCLI.ps1**       | Installs Azure CLI, a command-line tool for managing Azure resources. |
| **aibInstallAzureStorageExplorer.ps1** | Installs Azure Storage Explorer, a GUI tool for managing Azure Storage accounts. |
| **aibInstallPowerBi.ps1**        | Installs Microsoft Power BI Desktop, used for data visualization and business intelligence. |
| **aibInstallSSMS.ps1**           | Installs SQL Server Management Studio (SSMS), a tool for managing Microsoft SQL Server databases. |
| **aibInstallRemoteDesktopManager.ps1** | Installs Devolutions Remote Desktop Manager, a tool for managing remote server connections. |
