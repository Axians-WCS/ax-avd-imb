# Register Features
Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages, Microsoft.Network, Microsoft.ManagedIdentity, Microsoft.ContainerInstance |
  Where-Object RegistrationState -ne Registered |
    Register-AzResourceProvider

# Variables
$imageResourceGroup = 'xyz-p1-imb-01' # Destination image resource group, change this to your own
$vnetResourceGroup = 'mgt-p1-hub-01' # Resource group of the hub where the vnet is deployed
$location = 'West Europe'

# Get the subscription ID
$subscriptionID = (Get-AzContext).Subscription.Id
Write-Output $subscriptionID

# Create the resource group for image builder resources if it doesn't exist
New-AzResourceGroup -Name $imageResourceGroup -Location $location -ErrorAction SilentlyContinue

# Create a unique identity name
[int]$timeInt = $(Get-Date -UFormat '%s')
$imageRoleDefName = "Azure Image Builder Image Def $timeInt"
$networkRoleDefName = "Azure Image Builder VNet Role $timeInt"
$identityName = "myIdentity$timeInt"
Write-Output $identityName

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
$myRoleVnetActionsPath = "aibRoleVnetActions.json"
$myRoleVnetActionsContent = Get-Content -Path $myRoleVnetActionsPath -Raw
$myRoleVnetActionsContent = $myRoleVnetActionsContent -replace '<subscriptionID>', $subscriptionID
$myRoleVnetActionsContent = $myRoleVnetActionsContent -replace '<rgName>', $vnetResourceGroup
$myRoleVnetActionsContent = $myRoleVnetActionsContent -replace 'Azure Image Builder VNet Actions Role', $networkRoleDefName
$myRoleVnetActionsContent | Out-File -FilePath $myRoleVnetActionsPath -Force

New-AzRoleDefinition -InputFile $myRoleVnetActionsPath

# Assign VNet role to Managed Identity
$RoleAssignVnetParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $networkRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$vnetResourceGroup"
}
New-AzRoleAssignment @RoleAssignVnetParams

Write-Host "Managed Identity and role assignments created successfully."