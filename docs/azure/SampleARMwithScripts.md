# Sample Azure Resource Manager (ARM) best practice templates

The ARM templates provided as defaults through the Azure portal for various resources are not particularly extensible. And in some few cases, the defaults may not pass security checks and comply with basic policies.

The following links take you to my GitHub site for:

- ARM templates

    - Deployment template
    - Parameter template

- PowerShell script to test the ARM template deployment

    - Including `.EXAMPLE` code that you can copy and paste in PowerShell to test the template deployment

- Azure DevOps pipeline script to deploy a site

## Features

ARM Templates

- Extensible
- Incorporate best practices, such as Role Based Access Control, Private Endpoints, Hub-Spoke network architecture, managed identities, security permissions
- Both template and parameters

PowerShell

- Test individual templates and combination of templates

Azure DevOps Pipeline

- End to end DevOps Pipeline that ties it all together

## Supported Kubernetes architecture

The following diagram illustrates a hybrid deployment where Kubernetes is a central deployment for many services. 

![architecture](./media/hybrid-containers.png)

## Sample templates and scripts

From this GitHub:

- [Naming convention]()
- Create [Resource Group]() with locks and access control
- [Azure Storage account]()
- [Azure Kubernetes Service (AKS) using CNI]() and [Azure Container Registry (ACR)]()
- [CosmosDB]()
- [Key Vault](), [Key Vault for Cosmos](), [Key Vault Permissions](), [Key Vault Secret](), [Key Vault for Storage]()
- ARM template to [Retrieve Object ID]()
- [Role Assignment]() 
- [SignalR]()
- [Virtual Network]()