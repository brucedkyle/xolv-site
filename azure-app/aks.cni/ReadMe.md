# Azure Kubernetes Service (AKS) with an Ingress Controller

This document outlines a checklist to stand up a [AKS cluster with Azure CNI networking](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni) connected to an Application Gateway.

The configuration requires CNI networking so the gateway can be automatically configured with pod getting an IP address from the subnet. The ingress controller then can accessed each pod directly. These IP addresses must be unique across your network space, and must be planned in advance. 

Review the architecture [Azure Kubernetes Service (AKS) Production Baseline](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks?toc=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Faks%2Ftoc.json)

# Why CNI

Kubernetes default networking provider, kubenet, is a simple network plugin that works with various cloud providers. Kubenet is a very basic network provider, and basic is good, but does not have very many features. Moreover, kubenet has many limitations. 

_Azure Container Networking Interface (CNI) networking_ - The AKS cluster is connected to existing virtual network resources and configurations. So we can get all the goodness of running inside a virtual network.

With kubenet, nodes get an IP address from a virtual network subnet. Network address translation (NAT) is then configured on the nodes, and pods receive an IP address "hidden" behind the node IP. This approach reduces the number of IP addresses that you need to reserve in your network space for pods to use.

The Container Networking Interface (CNI) is a vendor-neutral protocol that lets the container runtime make requests to a network provider. The Azure CNI assigns IP addresses to pods and nodes, and provides IP address management (IPAM) features as you connect to existing Azure virtual networks. Each node and pod resource receives an IP address in the Azure virtual network, and no additional routing is needed to communicate with other resources or services.

See [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)

## Considerations

The network must be planned in advance. he size of your virtual network and its subnet must accommodate the number of pods you plan to run and the number of nodes for the cluster.
 Some key considerations:

- [Plan IP addressing for your cluster](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#plan-ip-addressing-for-your-cluster)
- [Maximum pods per node](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#maximum-pods-per-node)
- [Deployment parameters](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#deployment-parameters)
  - Virtual Network
  - Subnet

IP addresses must be unique across your network space, and must be planned in advance. Each node has a configuration parameter for the maximum number of pods that it supports. The equivalent number of IP addresses per node are then reserved up front for that node. This approach requires more planning, and often leads to IP address exhaustion or the need to rebuild clusters in a larger subnet as your application demands grow.

## Secure web traffic with a WAF

To scan incoming traffic for potential attacks, use a web application firewall (WAF) such as Barracuda WAF for Azure or Azure Application Gateway. See [Secure traffic with a web application firewall (WAF)](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-network#secure-traffic-with-a-web-application-firewall-waf)

## Integration with Azure AD

This best practices article focuses on how a cluster operator can manage access and identity for AKS clusters. In this article, you learn how to:

- Authenticate AKS cluster users with Azure Active Directory
- Control access to resources with Kubernetes role-based access control (RBAC)
- Use Azure RBAC to granularly control access to the AKS resource and the Kubernetes API at scale, as well as to the kubeconfig.
- Use a managed identity to authenticate pods themselves with other services

Use [pod managed identities](https://docs.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security)

Use managed identity to create the cluster. See [Create an AKS cluster with managed identities](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity#create-an-aks-cluster-with-managed-identities)

## Connecting to AKS

See [Securely connect to nodes through a bastion host](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-network#securely-connect-to-nodes-through-a-bastion-host)

## Steps

1. Create a virtual network (and peer networks)
    - AKS
    - Bastion
    - Application Gateway with WAF
2. Create Azure Bastion
3. Create the AKS cluster with:
    - az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --network-plugin azure \
    --vnet-subnet-id <subnet-id> \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.2.0.10 \
    --service-cidr 10.2.0.0/24 \
    --generate-ssh-keys
4. Set up ingress controller, using either:
    - [Basic controller](https://docs.microsoft.com/en-us/azure/aks/ingress-basic)
    - **[Application Gateway Ingress Controller in a separate virtual network](https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing)**
    - **[Create an HTTPS ingress controller and use your own TLS certificates on Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-own-tls)**
    - [Create a controller with dynamic IP address using Let's Encrpyt](https://docs.microsoft.com/en-us/azure/aks/ingress-tls)
    - [Create a controller with static IP address using Let's Encrpyt](https://docs.microsoft.com/en-us/azure/aks/ingress-static-ip)
5. Integrate Key Vault with Kubernetes
    - [Tutorial: Configure and run the Azure Key Vault provider for the Secrets Store CSI driver on Kubernetes](https://docs.microsoft.com/en-us/azure/key-vault/general/key-vault-integrate-kubernetes) **NOTE: Use managed identities**
    - [Secrets Store CSI driver](https://docs.microsoft.com/en-us/azure/key-vault/general/key-vault-integrate-kubernetes#install-helm-and-the-secrets-store-csi-driver)
6. Sign into _kubectl__ and deploy services and apps


## TODO

[Deploy ASP.NET Core apps to Azure Kubernetes Service with Azure DevOps Starter](https://docs.microsoft.com/en-us/azure/devops-project/azure-devops-project-aks)
[Automate deployment using Azure DevOps Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/kubernetes/aks-template?view=azure-devops)
[App Armor](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-cluster-security#app-armor)
[Dynamically provision volumes](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-storage#dynamically-provision-volumes)
You can put the etcd database in CosmosDB for resiliancy
[Azure Policy Regulatory Compliance controls for Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/security-controls-policy)

# References

- [Azure Kubernetes Service (AKS) Production Baseline](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks)
- [Best practices for authentication and authorization in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-identity)