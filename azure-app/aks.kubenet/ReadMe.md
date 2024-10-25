# Deploy AKS using Kubenet

This template deploys a managed Azure hosted Kubernetes cluster via Azure Kubernetes Service (AKS) with Virtual Machine Scale Sets Agent Pool and System-assigned managed identity.

It uses RBAC.

It uses [Kubenet (basic) networking](https://docs.microsoft.com/en-us/azure/aks/concepts-network#kubenet-basic-networking). The limitations of kubenet are described in this document.

VMSS based agent pools gives AKS cluster auto-scaling capabilities. See https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#about-the-cluster-autoscaler for detailed information about cluster auto-scaler. 

## when to choose this architecture for AKS

The [choice of which network plugin to use for your AKS cluster](https://docs.microsoft.com/en-us/azure/aks/configure-kubenet#choose-a-network-model-to-use) is usually a balance between flexibility and advanced configuration needs. 

Use kubenet when:

- You have limited IP address space.
- Most of the pod communication is within the cluster.
- You don't need advanced AKS features such as virtual nodes or Azure Network Policy. Use Calico network policies.

Use Azure CNI when:

- You have available IP address space.
- Most of the pod communication is to resources outside of the cluster.
- You don't want to manage user defined routes for pod connectivity.
- You need AKS advanced features such as virtual nodes or Azure Network Policy. Use Calico network policies. 

For more information to help you decide which network model to use, see [Compare network models and their support scope](https://docs.microsoft.com/en-us/azure/aks/concepts-network#compare-network-models).

### Application Gateway

The architectures where you use [Application Gateway requires Azure CNI](https://azure.microsoft.com/en-us/blog/application-gateway-ingress-controller-for-azure-kubernetes-service/). Ingress Controller leverages the AKS’ advanced networking, which allocates an IP address for each pod from the subnet shared with Application Gateway. Application Gateway has direct access to all Kubernetes pods. This eliminates the need for data to pass through kubenet. 

## How to connect to the solution

The template deployment will output controlPlaneFQDN value while will be the Kubernetes API endpoint for the cluster.

Sample Output:

Outputs:

```text
Name                Type                       Value
==================  =========================  ==========
controlPlaneFQDN    String                     #{Your DNS Prefix}#-a38a5fa0.hcp.#{AksResourceLocation}#.azmk8s.io
Management
```

## How to manage the solution

To get your credentials for your kubectl-cli you can use the Azure CLI command:

```cli
az aks get-credentials --name MyManagedCluster --resource-group MyResourceGroup
```

## Next steps

Here are the next steps after you stand up AKS.

1. [Grant the AKS managed identity 'Network Contributor' access to the resource group](https://docs.microsoft.com/en-us/azure/aks/static-ip#create-a-service-using-the-static-ip-address). You will need this to connect up your public ip.
2. [Create an Azure key vault and set your secrets](https://docs.microsoft.com/en-us/azure/key-vault/general/key-vault-integrate-kubernetes#create-an-azure-key-vault-and-set-your-secrets) then [Create your own SecretProviderClass object](https://docs.microsoft.com/en-us/azure/key-vault/general/key-vault-integrate-kubernetes#create-your-own-secretproviderclass-object)
3. [Create an ingress controller with a static public IP address in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-static-ip)
4. [Create an HTTPS ingress controller and use your own TLS certificates on Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-own-tls)

## References

- [Azure Kubernetes Service (AKS) template](https://github.com/Azure/azure-quickstart-templates/tree/master/101-aks-vmss-systemassigned-identity)
- [Network concepts for applications in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/concepts-network)
- [ARM Template – Deploy an AKS cluster using managed identity and managed Azure AD integration](https://www.danielstechblog.io/arm-template-deploy-an-aks-cluster-using-managed-identity-and-managed-azure-ad-integration/)

## Alternative architectures

- [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)
- [Application Gateway Ingress Controller](https://azure.github.io/application-gateway-kubernetes-ingress/)