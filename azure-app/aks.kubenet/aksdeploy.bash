#!/bin/sh
resourceGroupName="rg-wus2-project42-aks-test"
location="west us 2"
aksClusterName="aks-wus2-project42-test-01"
deploymentName='aks-wus2-project42-test-01-'$RANDOM

az group create --name $resourceGroupName --location $location

az deployment group create --name $deploymentName \
    --resource-group $resourceGroupName --template-file ".\azuredeploy.json" \
    --parameters aksClusterName=$aksClusterName dnsPrefix=aks-wus2-project42-test-01 \
    agentCount=1 

result=az deployment group show \
  -g $resourceGroupName \
  -n $deploymentName \
  --query properties.outputs.controlPlaneFQDN.value

echo result