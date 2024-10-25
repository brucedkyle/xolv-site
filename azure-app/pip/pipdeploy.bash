subscriptionId=76d5aee2-6a43-4ec9-8248-77f888fb917c
az account set --subscription $subscriptionId
resourceGroupName="rg-wus2-project42-aks-test-01"
location="westus2"
resourceName="pip-wus2-project42-pip-test-01"

az account set --subscription $subscriptionId

# Create an Azure resource group
az group create --name $resourceGroupName --location $location

templateFile="./azuredeploy.json"
deploymentName='deploy-pip-test-01-'$RANDOM

az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file $templateFile \
  --parameters publicIPResourceName=$resourceName

az network public-ip show --resource-group $resourceGroupName --name $resourceName --query ipAddress --output tsv