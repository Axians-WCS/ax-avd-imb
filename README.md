# ax-avd-imb
This repository will hold parameter files that can be retreived during a deployment of the Axians Image Builder resources. 

1. aibRoleImageCreation.json - This file has all the permissions needed by the managed identity to create images in the subscription.
2. createManagedIdentityAib.ps1 - This script will create the Managed Identity for Azure Imabe builder and uses the aibRoleImageCreation.json file to assign the permissions to the managed identity.