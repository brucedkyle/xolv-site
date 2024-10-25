#Requires -Version 5.1
#Requires -Modules Az.Resources
<#
.SYNOPSIS
    Tests the azure resource group deployment.
.DESCRIPTION
    Adds two resource groups and sets tabs
#>
$projectName = "TestProject07"
$location = "westus2"
$environment = "dev"

#$SubscriptionId = "76d5aee2-6a43-4ec9-8248-77f888fb917c"
$costCenter = "123 465"

####

$baseName = 'wus2-' + ($ProjectName -replace '-') + "-" + $environment + "01"
$createdDate = Get-Date -Format "yyyy-MM-dd"
$tags = @{ "Cost Center" = $costCenter; "Location"=$location; "Environment"=$environment; "Created Date"= (Get-Date -Format "yyyy-MM-dd").Tostring() }

Set-AzContext -Name "AzureContext" -SubscriptionId $SubscriptionId -Force
#     'resourceGroupTags' = $tags

$paramObject = @{
    'resourceGroupName'  = "rg-" + $baseName
    'resourceGroupLocation'      = $location
}

$deploymentName = "deploy-" + $baseName + "-" + $createdDate
Write-Output ("Deploying" + $deploymentName)

Write-Output ("Creating " + $paramObject['resourceGroupName'])
New-AzSubscriptionDeployment -Name $deploymentName -TemplateFile "azuredeploy.json"  -TemplateParameterObject $paramObject -Location $location # -TemplateParameterFile "azuredeploy.parameters.json"

$baseName = 'wus2-' + ($ProjectName -replace '-') + "-" + $environment + "02"
$createdDate = Get-Date -Format "yyyy-MM-dd"
$tags = @{ "Cost Center" = $costCenter; "Location"=$location; "Environment"=$environment; "Created Date"= (Get-Date -Format "yyyy-MM-dd").Tostring() }

Set-AzContext -Name "AzureContext" -SubscriptionId $SubscriptionId -Force

$paramObject = @{
    'resourceGroupName'  = "rg-" + $baseName
    'resourceGroupLocation'      = $location
    'resourceGroupTags' = $tags
    'lockResourceGroup' = $false
    'principalId' = '17e848dd-23be-4ee4-8090-dc47bd50bfe6'
}

$deploymentName = "deploy-" + $baseName + "-" + $createdDate
Write-Output ("Deploying" + $deploymentName)

Write-Output "Creating $($paramObject['resourceGroupName'])"
New-AzSubscriptionDeployment -Name $deploymentName -TemplateFile "azuredeploy.complete.json"  -TemplateParameterObject $paramObject -Location $location # -TemplateParameterFile "azuredeploy.parameters.json"