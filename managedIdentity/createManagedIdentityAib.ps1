<#
.SYNOPSIS
    Creates a Managed Identity for Azure Image Builder and assigns the necessary permissions.

.DESCRIPTION
    This script creates a Managed Identity for Azure Image Builder, registers necessary resource providers,
    and assigns custom roles for image creation and VNet access.

.AUTHOR
    Michel Kleine & Luuk Ros

.LAST UPDATED
    14-11-2024

.NOTES
    - Requires Owner or User Access Administrator permissions.
    - Az PowerShell module must be installed.

.PREREQUISITES
    - Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
    - Connect-AzAccount
#>

# Variables
$subscriptionID = "setsubid"
$imageResourceGroup = 'xyz-p1-imb-01'
$vnetResourceGroup = 'xyz-p1-hub-01'
$location = 'West Europe'

# Set the subscription context
Set-AzContext -SubscriptionId $subscriptionID

# Register required resource providers
Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages, Microsoft.Network, Microsoft.ManagedIdentity, Microsoft.ContainerInstance |
  Where-Object RegistrationState -ne Registered |
    Register-AzResourceProvider

# Ensure the resource group exists
New-AzResourceGroup -Name $imageResourceGroup -Location $location -ErrorAction SilentlyContinue

# Generate a unique Managed Identity name
$cleanedRgName = $imageResourceGroup -replace '-', ''
$baseIdentityName = "$($cleanedRgName)mi"
$index = 1
do {
    $identityName = "$baseIdentityName$($index.ToString("D2"))"
    $existingIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName -ErrorAction SilentlyContinue
    $index++
} while ($existingIdentity -ne $null)

# Create Managed Identity
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName -Location $location
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

# Define roles
$timeInt = $(Get-Date -UFormat '%s')
$imageRoleDefName = "Azure Image Builder Image Def $timeInt"
$networkRoleDefName = "Azure Image Builder VNet Role $timeInt"

# Download and configure aibRoleImageCreation.json
$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/Axians-WCS/ax-avd-imb/refs/heads/main/managedIdentity/aibRoleImageCreation.json'
$myRoleImageCreationPath = "myRoleImageCreation.json"
Invoke-WebRequest -Uri $myRoleImageCreationUrl -OutFile $myRoleImageCreationPath -UseBasicParsing
(Get-Content $myRoleImageCreationPath -Raw) -replace '<subscriptionID>', $subscriptionID -replace '<rgName>', $imageResourceGroup -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName | Set-Content $myRoleImageCreationPath
New-AzRoleDefinition -InputFile $myRoleImageCreationPath

# Assign the image creation role
New-AzRoleAssignment -ObjectId $identityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"

# Download and configure aibRoleVnetActions.json
$myRoleVnetActionsUrl = 'https://raw.githubusercontent.com/Axians-WCS/ax-avd-imb/refs/heads/main/managedIdentity/aibRoleVnetActions.json'
$myRoleVnetActionsPath = "aibRoleVnetActions.json"
Invoke-WebRequest -Uri $myRoleVnetActionsUrl -OutFile $myRoleVnetActionsPath -UseBasicParsing
(Get-Content $myRoleVnetActionsPath -Raw) -replace '<subscriptionID>', $subscriptionID -replace '<vnetRgName>', $vnetResourceGroup -replace 'Azure Image Builder Service Image Creation Role', $networkRoleDefName | Set-Content $myRoleVnetActionsPath
New-AzRoleDefinition -InputFile $myRoleVnetActionsPath

# Assign the VNet role
New-AzRoleAssignment -ObjectId $identityNamePrincipalId -RoleDefinitionName $networkRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$vnetResourceGroup"

Write-Host "Managed Identity and role assignments created successfully."