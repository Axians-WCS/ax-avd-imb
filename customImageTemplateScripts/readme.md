# Custom Image Template Scripts

This repository contains scripts that can be used to create custom image templates for use with Azure VM Image Builder (AIB).

## 📜 Script Overview

| Script Name                      | Description |
|----------------------------------|-------------|
| **runFullScan.ps1**              | Runs a full system scan using Windows Defender to detect and report threats. |
| **setDefaultUserSettings.ps1**   | Optimizes Default User Settings for Azure Virtual Desktop (AVD) based on a configuration file stored in the ConfigurationFiles subfolder. |

## 🔍 Script Details

### **runFullScan.ps1**
This script performs a full system scan using Windows Defender, ensuring the system is free of malware and security threats.

- Checks if Windows Defender is installed and enabled before proceeding.
- Initiates a full system scan to detect any malicious threats.
- Monitors scan progress and provides real-time status updates.
- Retrieves and reports detected threats, if any are found.
- Logs the scan duration and completion status for tracking purposes.

This script helps maintain system security by identifying and reporting potential threats in an AIB-deployed VM.

### **`setDefaultUserSettings.ps1`**
This script applies Default User Settings in AVD, ensuring a consistent and optimized user experience for new profiles. The configuration is pulled from a GitHub-hosted JSON file located in the ConfigurationFiles subfolder.

- Disables unnecessary notifications, suggestions, and animations to reduce distractions.
- Optimizes UI settings to enhance system responsiveness.
- Prevents Thumbs.db creation on network shares for improved file access speed.
- Keeps Storage Sense enabled to automate disk space management.

The script loads the Default User registry hive, applies the required optimizations, and then unloads the hive, ensuring every new user logs into a performance-optimized environment tailored for AVD.

## 🔧 **Usage**
Add the scripts during the Customizations step in Azure Image Builder by clicking "+ Add your own script" and providing the script URL and giving it a name.
1. Add `setDefaultUserSettings.ps1` to apply default user settings based on the ConfigurationFiles JSON.
2. Add `runFullScan.ps1` to perform a security scan after deployment.

This setup ensures a modular and scalable approach for optimizing AVD environments and maintaining security in AIB deployments.
