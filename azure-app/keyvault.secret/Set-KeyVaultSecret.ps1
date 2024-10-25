#Requires -Version 5.1
#Requires -Modules Az.Resources
<#
.SYNOPSIS
    Set a key vault secret using azuredeploy.json
.DESCRIPTION
    Sets permissions on key vault.
.PARAMETER SubscriptionID 
    The Azure Subscription ID, such as "9f241d6e-16e2-4b2b-a485-cc546f04799b". Uses the current subscription as the default.
.PARAMETER ResourceGroupName
    Mandatory. Resource group name. The resource group needs to exist, otherwise the script throws an error.
.PARAMETER KeyVault
    Mandatory. 
    Should follow naming convention https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging
    The ARM template appends a unique string to make the storage account name unique
.PARAMETER SecretsPermissions
    A JSON array of the secrets permissions to apply.
.PARAMETER Mode
    Default to Incremental.
    Complete: In complete mode, Resource Manager deletes resources that exist in the resource group but are not specified in the template.
    Incremental: In incremental mode, Resource Manager leaves unchanged resources that exist in the resource group but are not specified in the template.
.PARAMETER Tags
    The tags. If absent, the template will use the default tags.
    $createdData = Get-Date -Format "yyyy-MM-dd"
    $tags = @{"Cost Center"=$costCenter; "Location"=$location; "Environment"= $environment; "Project"=$OrganizationName; "Owner"=$owner; "Created Date"=$createdData; "Tier"="Management"; "Application name"=$appName }
.NOTES
  Version:        1.0.0
  Author:         Bruce Kyle
  Creation Date:  9/4//2020
  Purpose/Change: Initial checkin
  Requires:
    - resource group must exist
    - an objectId. Get some from a group, service principal, or user. Can use the cmdlets in the ..\objectid folder
  Note:
    This template will delete the key vault if used in Complete mode
.EXAMPLE
  $resourceGroupName = "rg-wus2-testme"
  $kvName = 'kv-wus2-testme-testme'
  $tags = @{ "Cost Center" = "DevTest"; "Location"="West US 2" }
  New-AzResourceGroup -Name $resourceGroupName -Location "West US 2" -Tags $tags
  New-AzKeyVault -Name $kvName -ResourceGroupName $resourceGroupName -Location "West US 2"
  .\Set-KeyVaultPermissions.ps1 -SubscriptionID 9f241d6e-16e2-4b2b-a485-cc546f04799b `
        -ResourceGroupName $resourceGroupName `
        -KeyVaultName $kvName `
        -SecretName 'randomsecret45'
        -SecretValue 'rgxKGKYGeandhfnieuDr' `
        -ObjectId "50822806-e55b-4c6d-976b-f512710e29c5" `
        -Verbose
#>

[CmdletBinding(SupportsShouldProcess=$True)]
#--------[Params]---------------
Param(
    [Parameter(Mandatory=$false)] [string] $SubscriptionID,
    [Parameter(Mandatory)] [string] $ResourceGroupName,
    [Parameter(Mandatory)] [string] $KeyVaultName,
    [Parameter(Mandatory)] [string] $SecretsPermissions,
    [Parameter(Mandatory)] [string] $ObjectId
)

#--------[Script]---------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot

try {

    ####
    # Set subscription
    ####
    if ($null -eq $SubscriptionId) {
        $SubscriptionId = (Get-AzContext).Subscription.SubscriptionId
    }

    Set-AzContext -Name "AzureContext" -SubscriptionId $SubscriptionId -Force

    $aNumber = Get-Random -Minimum -1000 -Maximum 10000
    $deploymentName =  $KeyVaultName + "-resource-deployment-" + $aNumber

    $parameters = @{
         'Name'                  = $deploymentName
         'ResourceGroupName'     = $ResourceGroupName
         'TemplateFile'          = 'azuredeploy.json'
         'Mode'                  = $Mode
    }

    Write-Verbose "Deploying resource: $deploymentName"

    $arrayParam = "all"
    New-AzResourceGroupDeployment @parameters -keyVaultName $KeyVaultName -ObjectId $ObjectId -secretsPermissions $arrayParam

    Get-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -Name $deploymentName
}
catch
{
    Write-Output "Deployment failed: $deploymentName " -ForegroundColor Red 
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}
finally
{
   Pop-Location
}