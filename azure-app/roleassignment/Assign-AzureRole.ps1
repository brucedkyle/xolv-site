#Requires -Version 5.1
#Requires -Modules Az.Resources
<#
.SYNOPSIS
    Sets permissions to a resource group or resource for a user, group, or service principal.
.DESCRIPTION
    Sets permissions to a resource group or resource for a user, group, or service principal.
.PARAMETER SubscriptionId
    The subscription ID (as a GUID)
.PARAMETER roleDefinitionID
  The default is to set Reader permission to the scope. Get the built in role from https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
.PARAMETER principalId
  The objectId of the user or group or service principal or managed identity that you want to set. Use the Get-ObjectId powershell in this same folder to get an object Id.
.PARAMETER scope
    The scope of where you want to assign the permissions
.REMARKS
    Log in using both Connect-AzAccount and Connect-AzureAdAccount

#>


$SubscriptionId = "9f241d6e-16e2-4b2b-a485-cc546f04799b" # "76d5aee2-6a43-4ec9-8248-77f888fb917c"
$roleDefinitionId = "acdd72a7-3385-48ef-bd42-f606fba81ae7" # reader
$principalId = "54c2ee1b-1a2e-474c-bf71-508fe9ca6591"
$resourceGroupName = "rg-wus-sampleproject-01"

Set-AzContext -Name "AzureContext" -SubscriptionId $SubscriptionId -Force

## Assign to a subscription

$paramObject = @{
    'roleDefinitionID'  = $roleDefinitionId
    'principalId' = $principalId
    'scope' = "/subscriptions/$SubscriptionId"
}

$templateFile = ".\azuredeploy.json"

$suffix = Get-Random -Maximum 1000

New-AzSubscriptionDeployment  -Name "RoleAssignmentForSubscription$suffix"  -TemplateFile $templateFile -TemplateParameterObject $paramObject -Location westus

## Assign to a resource group

New-AzResourceGroup -Name $resourceGroupName -Location westus
$scope = ((Get-AzResourceGroup -Name $resourceGroupName).ResourceId)
Write-Output $scope # will look like this: /subscriptions/9f241d6e-16e2-4b2b-a485-cc546f04799b/resourceGroups/rg-wus-sampleproject-01

$paramObject = @{
    'roleDefinitionID'  = $roleDefinitionId
    'principalId' = $principalId
    'scope' = $scope
}

New-AzResourceGroupDeployment -Name  "RoleAssignmentForResourceGroup$suffix" -ResourceGroupName $resourceGroupName  -TemplateFile $templateFile -TemplateParameterObject $paramObject  

New-AzStorageAccount -ResourceGroupName $resourceGroupName -Location "westus" -SkuName Standard_GRS -EnableHttpsTrafficOnly $true -Name "stwusjdklafix35"

$scope = ((Get-AzResource -Name "stwusjdklafix35").ResourceId)

$paramObject = @{
    'roleDefinitionID'  = $roleDefinitionId
    'principalId' = $principalId
    'scope' = $scope
}

## THIS LINE FAILS WITH THE ERROR 
## {"code":"DeploymentFailed","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/DeployOperations for usage details.","details":[{"code":"BadRequest","message":"{\r\n \"error\": {\r\n \"code\": \"InvalidCreateRoleAssignmentRequest\",\r\n \"message\": \"The request to create role assignment '136aaba4-9407-5493-838e-6524f8f5c530' is not valid. Role assignment scope '/subscriptions/9f241d6e-16e2-4b2b-a485-cc546f04799b/resourceGroups/rg-wus-sampleproject-01/providers/Microsoft.Storage/storageAccounts/stwusjdklafix35' must match the scope specified on the URI '/subscriptions/9f241d6e-16e2-4b2b-a485-cc546f04799b/resourcegroups/rg-wus-sampleproject-01'.\"\r\n }\r\n}"}]}
New-AzResourceGroupDeployment -Name  "RoleAssignmentForResourceGroup$suffix" -ResourceGroupName $resourceGroupName  -TemplateFile $templateFile -TemplateParameterObject $paramObject 
## HOW TO DEPLOY WITH A SCOPE OF A RESOURCE ???
