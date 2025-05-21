# AAD Broker Plugin - Azure Image Builder Deployment
This repository provides a solution for ensuring AAD Broker Plugin is properly registered on Azure Virtual Desktop (AVD) machines. The AAD Broker Plugin is required to facilitate OneDrive sign-in and seamless authentication for Microsoft services.

## 🖥 Installation via Azure Image Builder

For customers using Azure Image Builder to prepare their AVD images, we provide an installation script that ensures the AAD Broker Plugin is correctly registered. This script is automatically executed during the image build process and ensures that:

- The AAD Broker Plugin is properly registered on the system.
- A scheduled task is created to re-register the plugin on user logon.
- The script is installed in C:\Axians

### 🏗️ How It Works

1. The AIB pipeline downloads the installation script from this repository.
2. The script runs during image creation, ensuring proper registration of AAD Broker Plugin.
3. A scheduled task is created, which executes the broker registration script at each user logon.
4. Users experience seamless sign-in with OneDrive and Microsoft 365 apps.


## 📦 Alternative: Intune Deployment

For customers where we still want to use Intune to deploy this configuration, the Intune package is available in the `intunePackage\output` subfolder. If you need to update the package you can edit the scripts in the `intunePackage\input` subfolder and use `setup packager for intune` to generate a new package. Within the `intunePackage\input` subfolder you will also find a detection script to set as the detection rule in Intune and an image to use as the logo for the app.    

## 📌 Why This is Important

Without the AAD Broker Plugin properly registered, users on AVD may face issues such as:

OneDrive not signing in automatically  
Outlook prompting for credentials repeatedly  
General authentication failures with Microsoft services  

This solution prevents these issues and ensures a smooth experience for users on Azure Virtual Desktop. 