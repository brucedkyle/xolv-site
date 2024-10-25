subscriptionId=76d5aee2-6a43-4ec9-8248-77f888fb917c
az account set --subscription $subscriptionId
resourceGroupName="rg-wus2-project42-akscni-test-01"
location="westus2"

az account set -subscription $subscriptionId

# Create an Azure resource group
az group create --name $resourceGroupName --location $location

templateFile="./azuredeploy.json"
deploymentName='deploy-akscni-test-01-'$RANDOM

virtualNetworkName=vnet-wus2-project42-testaks-01
subnetName=snet-wus2-project42-testaks-01
addressPrefix='10.0.0.0/16'
subnetPrefix='10.0.0.0/24'

az network vnet create \
  --name $virtualNetworkName \
  --resource-group $resourceGroupName \
  --subnet-name $subnetName \
  --address-prefix $addressPrefix \
  --subnet-prefix $subnetPrefix

aksName=aks-wus2-project42-testaks-01

az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file $templateFile \
  --parameters resourceName=$aksName existingVirtualNetworkName=$virtualNetworkName \
    existingSubnetName=$subnetName serviceCidr=$addressPrefix dnsServiceIP=10.0.0.10 \
    dnsPrefix=project42 builtInRoleType=Owner existingVirtualNetworkResourceGroup=$resourceGroupName
