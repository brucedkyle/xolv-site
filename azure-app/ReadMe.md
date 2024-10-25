# Sample Azure infrastructure deployment

This example shows a sample architecture deployment for an application that can run in either AKS or Azure Web Service.

Each resource includes a pipeline and sample PowerShell code to test the installation.

## Prerequisites

You will need:
- An Azure account with an active subscription. 
- An Azure DevOps organization and project. 
- An ability to run pipelines on Microsoft-hosted agents. You can either purchase a parallel job or you can request a free tier.
- [Azure Resource Manager service connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops)

  - If you have Owner role for your Azure subscription, you can use [Azure Resource Manager app registration with workload identity federation](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops#create-an-azure-resource-manager-app-registration-with-workload-identity-federation-automatic)

## Assign permissions to a group or user

You can assign permissions to the Resource Group during creation. You can optionally provide the ID of an individual or group in Entra for you to grant Contributor access. 

To create a user or group using the Entra UI, see [Assign Microsoft Entra roles to groups](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/groups-assign-role?tabs=ms-powershell#microsoft-entra-admin-center)

## References

See:

- [Tutorial: Create a multistage pipeline with Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/create-multistage-pipeline?view=azure-devops)
- [Create an Azure Resource Manager service connection with an existing service principal](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops#create-an-azure-resource-manager-service-connection-with-an-existing-service-principal)