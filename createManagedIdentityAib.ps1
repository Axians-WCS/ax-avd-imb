<#
.SYNOPSIS
    Creates a Managed Identity for Azure Image Builder and assigns the necessary permissions.

.DESCRIPTION
    This script automates the creation of a Managed Identity for Azure Image Builder, along with the required permissions.
    It ensures that the Managed Identity can perform image creation tasks, access gallery images, and join virtual networks.
    Additionally, it checks for and registers any missing resource providers needed for Azure Image Builder functionality.

    The script downloads role definition templates, updates them with environment-specific values, and assigns custom roles 
    to the Managed Identity in both the Image Builder resource group and the Virtual Network resource group.

.AUTHOR
    Michel Kleine & Luuk Ros

.LAST UPDATED
    14-11-2024

.NOTES
    - Ensure you have the appropriate permissions to manage Azure resources (Owner or User Access Administrator role).
    - This script requires the Az PowerShell module.
    - Customize the variables ($subscriptionID, $imageResourceGroup, $vnetResourceGroup, $location) to fit your environment.

.PREREQUISITES
    - Install the Az PowerShell module:
      Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
    
     - Have the URLs for the role definition templates (`aibRoleImageCreation.json` and `aibRoleVnetActions.json`) accessible.
    
      - Connect to your Azure account:
      Connect-AzAccount
#>

# Register Features
Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages, Microsoft.Network, Microsoft.ManagedIdentity, Microsoft.ContainerInstance |
  Where-Object RegistrationState -ne Registered |
    Register-AzResourceProvider

# Variables
$subscriptionID = "1b1d5253-7f5a-4359-aa8c-f2a8cfc09f67" # Set the subscription ID where the resources will be deployed
$imageResourceGroup = 'xyz-p1-imb-01' # Resource group name for the image builder resources
$vnetResourceGroup = 'xyz-p1-hub-01' # Resource group where the vnet is deployed
$location = 'West Europe'

# Set the subscription context
Set-AzContext -SubscriptionId $subscriptionID
Write-Output (Get-AzContext)

# Create the resource group for image builder resources if it doesn't exist
New-AzResourceGroup -Name $imageResourceGroup -Location $location -ErrorAction SilentlyContinue

# Generate Managed Identity name based on the resource group name
[int]$timeInt = $(Get-Date -UFormat '%s')
$cleanedRgName = $imageResourceGroup -replace '-', ''
$identityName = "$($cleanedRgName)mi$timeInt"
$imageRoleDefName = "Azure Image Builder Image Def $timeInt"
$networkRoleDefName = "Azure Image Builder VNet Role $timeInt"

# Create the User Identity
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName -Location $location
$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

# Process aibRoleImageCreation.json
$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/Axians-WCS/ax-avd-imb/refs/heads/main/aibRoleImageCreation.json'
$myRoleImageCreationPath = "myRoleImageCreation.json"
Invoke-WebRequest -Uri $myRoleImageCreationUrl -OutFile $myRoleImageCreationPath -UseBasicParsing

$Content = Get-Content -Path $myRoleImageCreationPath -Raw
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force

New-AzRoleDefinition -InputFile $myRoleImageCreationPath

# Assign role to Managed Identity
$RoleAssignParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $imageRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams

# Process aibRoleVnetActions.json
$myRoleVnetActionsUrl = 'https://raw.githubusercontent.com/Axians-WCS/ax-avd-imb/refs/heads/main/aibRoleVnetActions.json'
$myRoleVnetActionsPath = "aibRoleVnetActions.json"
Invoke-WebRequest -Uri $myRoleVnetActionsUrl -OutFile $myRoleVnetActionsPath -UseBasicParsing

$VnetContent = Get-Content -Path $myRoleVnetActionsPath -Raw
$VnetContent = $VnetContent -replace '<subscriptionID>', $subscriptionID
$VnetContent = $VnetContent -replace '<vnetRgName>', $vnetResourceGroup
$VnetContent = $VnetContent -replace 'Azure Image Builder Service Image Creation Role', $networkRoleDefName
$VnetContent | Out-File -FilePath $myRoleVnetActionsPath -Force

New-AzRoleDefinition -InputFile $myRoleVnetActionsPath

# Assign VNet role to Managed Identity
$RoleAssignVnetParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $networkRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$vnetResourceGroup"
}
New-AzRoleAssignment @RoleAssignVnetParams

Write-Host "Managed Identity and role assignments created successfully."