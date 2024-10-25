$resourceGroupName = "rg-cenus-cogsvc-test-99"
$location = "centralus"
$templateFile = ".\azuredeploy.json"
$SubscriptionId = "76d5aee2-6a43-4ec9-8248-77f888fb917c"
Set-AzContext -Name "AzureContext" -SubscriptionId $SubscriptionId -Force
New-AzResourceGroup -Name $resourceGroupName -Location $location
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -Location $location -sku "F0" -kind LUIS