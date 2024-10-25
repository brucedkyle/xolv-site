#Requires -Version 5.1
#Requires -Modules Az.Resources, Az.Storage, Az.KeyVault
<#
.SYNOPSIS
    Sets a storage account access key in keyvault.
.DESCRIPTION
    Sets permissions on key vault.
.PARAMETER SubscriptionID 
    The Azure Subscription ID, such as "9f241d6e-16e2-4b2b-a485-cc546f04799b". Uses the current subscription as the default.
.PARAMETER ResourceGroupName
    Mandatory. Resource group name. The resource group needs to exist, otherwise the script throws an error.
.PARAMETER KeyVaultName
    Mandatory. The KevVault must exist
.PARAMETER StorageAccountName
    Mandatory. The storage account must exist
.PARAMETER SecretName
    Manadator. Name you want to use in keyvault for the connection string
.NOTES
  Version:        1.0.0
  Author:         Bruce Kyle
  Creation Date:  9/11/2020
  Purpose/Change: Initial checkin
  Requires:
    Permissions to set a value in the key vault
.EXAMPLE
    $resourceGroupName = "rg-wus2-testme-99"
    $kvName = 'kv-wus2-testme-testme-99'
    $tags = @{ "Cost Center" = "Throw Away"; "Location"="West US 2" }
    $SubscriptionId = '76d5aee2-6a43-4ec9-8248-77f888fb917c'
    Set-AzContext -Name "AzureContext" -SubscriptionId $SubscriptionId -Force
    New-AzResourceGroup -Name $resourceGroupName -Location "West US 2" -Tags $tags
    $kvName = 'kv-wus2-testme-testme-99'
    New-AzKeyVault -Name $kvName -ResourceGroupName $resourceGroupName -Location "West US 2"
    Set-AzKeyVaultAccessPolicy -VaultName $kvName -UserPrincipalName 'v-brkyl@microsoft.com' -PermissionsToSecrets get,set,delete,list
    $suffix = Get-Random -Minimum 100000 -Maximum 1000000
    $storageAccountName = "stwus2project42$suffix"
    New-AzStorageAccount -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName `
        -Location "West US 2" `
        -SkuName Standard_LRS `
        -Kind StorageV2
    $secretName = 'storageTestMeKey0'
    .\Set-StorageAccountKey.ps1 -SubscriptionID $SubscriptionId `
        -ResourceGroupName $resourceGroupName `
        -KeyVaultName $kvName `
        -StorageAccountName $storageAccountName `
        -SecretName $secretName `
        -Verbose
    Write-Output (Get-AzKeyVaultSecret -vaultName $kvName -name $secretName).SecretValueText
#>

[CmdletBinding(SupportsShouldProcess=$True)]
#--------[Params]---------------
Param(
    [Parameter(Mandatory=$false)] [string] $SubscriptionID,
    [Parameter(Mandatory)] [string] $ResourceGroupName,
    [Parameter(Mandatory)] [string] $KeyVaultName,
    [Parameter(Mandatory)] [string] $StorageAccountName,   
    [Parameter(Mandatory)] [string] $SecretName
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
    $deploymentName =  $KeyVaultName + "cosmosdb-resource-deployment-" + $aNumber

    $parameters = @{
         'Name'                  = $deploymentName
         'ResourceGroupName'     = $ResourceGroupName
         'TemplateFile'          = 'azuredeploy.json'
    }

    Write-Verbose "Deploying resource: $deploymentName"

    New-AzResourceGroupDeployment @parameters -keyVaultName $KeyVaultName -StorageAccountName $StorageAccountName -SecretName $SecretName

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