# ax-avd-imb
This repository will host Scripts and parameter files that are used in a deployment of the Axians Image Builder resources or the creation of an Image within the Custom Image Template resource.

## Managed Identity
The folder **managedIdentity** will hold the scripts and parameter files that can be used to create a Managed Identity for Azure Image Builder. The Managed Identity is used to create images in the subscription.

- createManagedIdentityAib.ps1 - This script will create the Managed Identity and assign the correct permissions.
- aibRoleImageCreation.json - This file has all the permissions needed by the managed identity to create images in the subscription.
- createManagedIdentityAib.ps1 - This script will create the Managed Identity for Azure Imabe builder and uses the aibRoleImageCreation.json file to assign the permissions to the managed identity.

## Custom Image Template Scripts
The folder **customImageTemplateScripts** will hold the scripts that can be used in the Custom Image Template resource in Azure. The scripts are used to install software, configure the VM, and other tasks that are needed to create the image.

- runFullScan.ps1 - This script will perform a Full System Scan using Windows Defender.