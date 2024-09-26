# Introduction to Azure

In this tutorial you will learn how to install a sample resource in Azure. It introduces the 300-level concepts in Azure, such as how to deploy resources, how resources are governed, how access is controlled to resources.

The purpose is to help the reader understand how ARM deploys and manages your resources.

## Prerequisites

Assumes you have seen how to deploy resource groups and resources in Azure portal. 
Understand basics of role based access control.

You will need:

- Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

```sh
brew update && brew install azure-cli
az login
```

## Definitions

- **Resource** A manageable item that is available through Azure. Virtual machines, storage accounts, web apps, databases, and virtual networks are examples of resources.
- **Resource Group** a group of resources. (in practice, you group resources as lifecycle by region.)
- **Subcription** A way to bill for Azure. 

## Demo on using the portal

1. Stand up a storage account using the portal. 
2. Demonstrate the ARM template and parameter template that is created.
3. Demonstrate role based access control for the resource group.

You can do the same thing using the CLI. 

## Deploy an Azure resource

Ways to deploy Azure resources:

- **Azure Portal** the way to get started to deploy your first resources in Azure.
- **CLI** or **PowerShell** interfaces.
- Templates:
    - **ARM Template** a description of resources as a repeatable JSON template.
    - **Bicep template** is similar to ARM template but uses a DSL that translates your calls into ARM template. Bicep is less typing.
    - **Terraform** templates (requires Terraform).
    - **SDK** that makes REST commands to Azure.
- **REST Interface to ARM**. The portal and cli talk to the REST Interface by making calls to the REST interface. Yes, you can run it from Postman.

For more information, see [What is Resource Manager?](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview)

![management layer](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/media/overview/consistent-management-layer.png)

Identities are managed through *Azure Active Directory (AAD)*. The instance of identities to mange Azure (or Microsoft 365) is called a **tenant**. For IBM, you will see this domain as `ibm.onmicrosoft.com`. NOTE: you and the permissions you exercise must be added into the AAD domain. To log into Azure, you will probably use your IBM credentials. On a customer site, they may add you to their tenant and grant some permissions using your IBMid.

## Deploy storage account using the CLI

Recommend doing this in the following steps:

1. Start your shell or command line, then log in
2. Create environment variables
3. Create the resource group
3. Create the resource(s)

```sh
az login

RESOURCE_GROUP_NAME="rg-wus2-storageproject"
STORAGE_ACCOUNT_NAME="stproject567343d6"
LOCATION="West US 2"

az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION

az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location $LOCATION \
    --sku Standard_LRS \
    --encryption-services blob
```

The CLI is documented. For the storage account, see [`az storage`](https://docs.microsoft.com/en-us/cli/azure/storage?view=azure-cli-latest)

Not all resources can be named in a similar way. See [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules). A storage account must be gloabally unique and be between 3 and 24 lowercase characters and numbers.

IMPORTANT: Your resource group location should be the same as the location of your resources.

## Deploy storage account using a template

You can deploy a resource from a template file. The template can be local or in storage. The following example, uses the current environment variables and uses a sample storage template from GitHub, using inline parameters into the template. 

```
az deployment group create \
  --name $RESOURCE_GROUP_NAME$(date +"%d-%b-%Y") \
  --resource-group  $RESOURCE_GROUP_NAME \
  --template-uri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.storage/storage-account-create/azuredeploy.json" \
  --parameters storageAccountType=Standard_LRS
```

Typically, you will use a parameters file with values.

## Subscription management

In enterprises, a subscription is managed by a higher organization called a **Management Group**. Your subscription ID is accessed as a GUID or by name.
- **Management Group** A group of subscriptions or other management groups that provide governance.

The following diagram shows an example organization using Management Groups to manage subscriptions.

![management groups](https://docs.microsoft.com/en-us/azure/governance/management-groups/media/tree.png)

Resources are managed through **ARM**, the Azure Resource Manager, that provides REST commands for Azure to actions on the resources.

## Resource provider

**Resource provider** is a type of resource. 

The resource provider is `Microsoft.Storage` for the storageAccounts https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?tabs=json 

Not all resource providers are available in the default subscription. Typically when you want to use a resouce intensive (read as costly) or third party resources (non Microsoft), you will need to add the resource provider.

To view resource providers in the portal or CLI, see [Azure resource providers and types](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types)

IMPORTANT: To maintain least privileges in your subscription, only register those resource providers that you're ready to use. The following code shows how to register the Azure Batch resource provider and retrieve information about the provider:

```sh
az provider register --namespace Microsoft.Batch
az provider show --namespace Microsoft.Batch
```

## High level of role based access control

- **Security Principal**. A security principal is an object that represents a user, group, service principal, or managed identity that is requesting access to Azure resources. 

The following diagram shows the combination of security principal:

![security principal](https://docs.microsoft.com/en-us/azure/role-based-access-control/media/shared/rbac-security-principal.png)

### Role

**Role definition** is a collection of permissions. It's typically just called a role. A role definition lists the operations that can be performed, such as read, write, and delete.

Typically you will see:

- Owner
- Contributor
- Reader

These are actually aggregations of permissions for underlying resources.

The following illustration shows the Contributor role definition for a virtual machine.

![role definition](https://docs.microsoft.com/en-us/azure/role-based-access-control/media/shared/rbac-role-definition.png)

For an exercise, see [Quickstart: Check access for a user to Azure resources](https://docs.microsoft.com/en-us/azure/role-based-access-control/check-access).

See [Azure built in roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles).

(300 LEVEL NOTE: Roles are actually aggregation of permissions of particular RBAC calls made on the resource. For example, see [Build in role: Classic Storage Account Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#classic-storage-account-contributor)

### Scope

**Scope** is the set of resources that the access applies to. 

Specify a scope at four levels: management group, subscription, resource group, or resource. Scopes are structured in a parent-child relationship. 

![scope](https://docs.microsoft.com/en-us/azure/role-based-access-control/media/shared/rbac-scope.png)

### Role Assignment

You combine the User (or Service prinicpal) with the Role and Scope to create a **Role Assignment**.

![role assignment](https://docs.microsoft.com/en-us/azure/role-based-access-control/media/overview/rbac-overview.png)

For more information, see [What is Azure role-based access control (Azure RBAC)?](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview).

## Service principal

When applications, hosted services, or automated tools needs to access or modify resources, you can create an identity for the app. This identity is known as a **Service principal**.

There is no way to directly create a service principal using the Azure portal itself. You will need access to the **Azure AD portal** or **Office 365 portal**. When you register an application through the Azure portal, an application object and service principal are automatically created in your home directory or tenant. Instead, you need access to the Tenant.

NOTE: As applications modernize, the service principal is being replaced with a **managed identity**. Managed identities provide an identity for applications to use when connecting to resources that support Azure Active Directory (Azure AD) authentication. 
In this case, the identity is resource created by the application itself. For more information, see [What are managed identities for Azure resources?](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview).

IMPORTANT: See [Securing service principals](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/service-accounts-principal).

### Tenant

A **tenant** provides identity and access management (IAM) capabilities to applications and resources used by your organization. An identity is a directory object that can be authenticated and authorized for access to a resource. Identity objects exist for human identities such as students and teachers, and non-human identities like classroom and student devices, applications, and service principles.

The Azure AD tenant is an identity security boundary that is under the control of your organization’s IT department. Within this security boundary, administration of objects (such as user objects) and configuration of tenant-wide settings are controlled by your IT administrators.

![Azure AD tenant](https://docs.microsoft.com/en-us/microsoft-365/education/deploy/images/intro-to-azure-ad-1.png)

Organizations can be connected in a tenant. In the following illustration, Woodgrove Bank allows external users as Users its Azure AD tenant by connecting the tenants.

![connected organizations](https://docs.microsoft.com/en-us/azure/active-directory/governance/media/entitlement-management-organization/connected-organization-example.png)

In this scenario, the client could allow you to log into the client Azure subscription using your IBMid.

The authentication types for connected organizations are:

- Azure AD
- Direct federation
- One-time passcode (domain)

(Note. It is possible to require MFA on your Azure resources through your Azure AD, even if the connected company does not require MFA.)

### Create a service principal

Very few resources will need you to create a service principal. You will need a service principal when you want to give prermissions to your script to call into the Azure Resource Manager. In other words, when you want the script to act on its own behalf, rather than using your user credentials.

IMPORTANT: You will need permissions to access Azure Active Directory tenant to create a Service Principal. This is not the same as subscription permissions. Only users with an administrator role in the tenant may register a service principal. If you created the subscription, you have access to the tenant.

Service principals can be created through the AD portal. See [Use the portal to create an Azure AD application and service principal that can access resources](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#configure-access-policies-on-resources)

## Demo on providing roles to a resource

When you make a call to ARM (with the portal, CLI, Terraform), the REST command will determine if you have permissions. 

## Show OpenShift and Cloud Pak resources

For more information, see [Deployment reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.redhatopenshift/openshiftclusters?tabs=json&pivots=deployment-language-terraform).

You must add the `Microsoft.RedHatOpenShift` resource provider to access OpenShift template.

## Best Practices

- [Naming convention](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging) for resources and resource groups


