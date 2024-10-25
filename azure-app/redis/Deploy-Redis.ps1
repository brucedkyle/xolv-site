#Requires -Version 5.1
#Requires -Modules Az.Resources
<#
.SYNOPSIS
    Deploys Redis using azuredeploy.json
.DESCRIPTION
    Deploys a Redis to the resource group.
.PARAMETER SubscriptionID 
    The Azure Subscription ID, such as "9f241d6e-16e2-4b2b-a485-cc546f04799b". Uses the current subscription as the default.
.PARAMETER ResourceGroupName
    Mandatory. Resource group name. The resource group needs to exist, otherwise the script throws an error.
.PARAMETER ResourceName
    Mandatory. 
    Should follow naming convention https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging
    The ARM template appends a unique string to make the storage account name unique
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
  Creation Date:  8/20/2020
  Purpose/Change: Initial checkin
  Requires:
    - resource group must exist
.EXAMPLE
$resourceGroupName = "rg-wus2-testme"
$tags = @{ "Cost Center" = "TestMe"; "Location"="West US 2" }
New-AzResourceGroup -Name $resourceGroupName -Location "West US 2" -Tags $tags
.\Deploy-Redis.ps1  `
    -SubscriptionID 76d5aee2-6a43-4ec9-8248-77f888fb917c `
    -ResourceGroupName $resourceGroupName -ResourceName "cache-wus2-testme" `
    -Tags $tags -Verbose -Mode "Complete" 
#>

[CmdletBinding(SupportsShouldProcess=$True)]
#--------[Params]---------------
Param(
    [Parameter(Mandatory=$false)] [string] $SubscriptionID,
    [Parameter(Mandatory=$true)] [string] $ResourceGroupName, 
    [Parameter(Mandatory=$false)] [string] $Mode = "Incremental",
    [Parameter(Mandatory=$false)] [object] $Tags = $null,
    [Parameter(Mandatory=$false)] [string] $ResourceName = "cache-wus2-test-99"
)

#--------[Script]---------------
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot
Write-Host "Deploying Redis"

try {
    ####
    # Set subscription
    ####
    if ($null -eq $SubscriptionId) {
        $SubscriptionId = (Get-AzContext).Subscription.SubscriptionId
    }

    Set-AzContext -Name "AzureContext" -SubscriptionId $SubscriptionId -Force

    ####
    # Basic error checking for the resource group and resource group name
    ####
    if ( $ResourceGroupName.Length -gt 90 ) {
        $deploymentError =  "Resource group name '$ResourceGroupName' is too long. Must be fewer than 90 characters."
        Write-Output $deploymentError
        throw $deploymentError
    } 
    Get-AzResourceGroup -Name $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent)
    {
        # ResourceGroup doesn't exist
        $deploymentError = "Resource group '$ResourceGroupName' does not exist. Create resource group before calling this Cmdlet"
        Write-Output $deploymentError
        throw $deploymentError    
    }

    ####
    # Prepare to add resource
    ####

    $paramObject = @{
        redisCacheName = $ResourceName
    }

    If ($PSBoundParameters.ContainsKey('Tags')) {
        $paramObject += @{'resourceTags' = $Tags}
    }

    $deploymentName =  $ResourceName + "-resource-deployment"

    $parameters = @{
         'Name'                  = $deploymentName
         'ResourceGroupName'     = $ResourceGroupName
         'TemplateFile'          = 'azuredeploy.json'
         'TemplateParameterObject'    = $paramObject
         'Mode'                  = $Mode
    }

    Write-Verbose "Deploying resource: $ResourceName"

    New-AzResourceGroupDeployment @parameters 

    $resourceName = (Get-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -Name $deploymentName).Outputs.cacheName.value

    Write-Verbose "Resource deployment successful: $resourceName"
}
catch
{
    Write-Host "Deployment failed: $ResourceName" -ForegroundColor Red 
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
}
finally
{
   Pop-Location
}