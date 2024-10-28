# Walkthrough using Azure Policy to audit and enforce compliance

<img style="float: right; width: 20%; padding-inline: 6px" src="https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/azpolicy.png?resize=218%2C213&ssl=1"> Use [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview) to manage and enforce your standards for governance and compliance and to assess that compliance at scale. When you implement Azure Policy, you are effectively adding guard-rails for your users. But you also have a way to audit your organization compliance against a particular policy.

In this walkthrough, you will learn the implications of using a Policy in Azure. For this walkthrough, you will use Azure CLI to create a storage account that will not be compliant, but allowing its contents to be accessed using HTTP. Then you will add a Policy that requires HTTPS, and see how you can audit existing, non-compliant resource. You will audit the resource using the portal and using PowerShell script. Then you will create another non-compliant resource and see how Azure blocks the resource during creation.

## Prerequisites

*   It is helpful that you understand resource groups and about storage accounts. Although the sample provides code, you will want to know how to upload a small file into Azure blob storage. You can use the [portal](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#upload-a-block-blob) or [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-blobs).
*   The sample shows how to use specific role, but you should understand about role based access control roles.
*   You will need owner or contributor access in your subscription.

## Definitions

First let’s start with some definitions:

**Business rule** is a standard that the business wants to audit or wants to insure is compliance. Often, but not always, business rules follow compliance standards, such as ISO 27001 or NIST.

**Resource Provider** is service that supplies Azure resources. For example, a common resource provider is Microsoft.Storage, which supplies the storage resource. The name of a resource type is in the format: `{resource-provider}/{resource-type}`.

**Resource** is a manageable item that is available through Azure. Virtual machines, storage accounts, web apps, databases, and virtual networks are examples of resources. when the resource is created, it has an id. The id has a field that has a format like `/subscriptions//resourceGroups//providers/Microsoft.Compute/disks/`.

Resources have properties that you set when you create the resource. For example, when you create a storage account, you set its location.

**Azure Policy** examines properties on resources that are represented in Resource Manager and properties of some Resource Providers. For example the location of a resource is a property that a policy can audit.

**Policy definition** is the JSON implementation of a business rule.

Several business rules can be grouped together into a **Policy initiative**.

The policy definition or initiative is assigned to any **scope** that can be a management groups, subscriptions, resource groups, or individual resources.

A **policy assignment** applies the policy to all resources within the scope. For example, if the policy

For more information, see:

*   [What is Azure Resource Manager?](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview)
*   [Azure resource providers and types](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types)
*   What is Azure Policy?

## Identify the business requirements

Let’s begin by defining the compliance requirements.

> The requirements should clearly identify both the “to be” and the “not to be” resource states.

For example in this case:

Compliance Standard

[ISO 27001](https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/iso27001/)

Control

[A.10.1.1 Policy on the use of cryptographic controls](https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/iso27001/control-mapping#a1011-policy-on-the-use-of-cryptographic-controls)

Requirement

ISO requirement: _Audit_ secure transfer to storage accounts  
Our business requirement: _Require_ secure transfer to storage accounts

Rules

*   Each storage account must be enabled for HTTPS
*   Each storage account must be disabled for HTTP

First, let’s figure out the resource property that we want to build our policy on.

## Explore resource properties that might want to check

Each resource in Azure is built on a set of APIs that are defined at the top level as Azure _resource providers_. A resource provider is \[uhm\] a service that provides resources, such as storage.

For the list of the providers, see [Resource providers for Azure services](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers). To get a list of providers and the status of whether they are installed in your subscription, use the following command:

```bash
az provider list --query "[].{Provider:namespace, Status:registrationState}" --out table
```

Let’s start by reviewing the [Microsoft.Storage](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/allversions) resource provider. Resource Manager template reference for the [storage account resource](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts) gives you a (nearly all) the property. In this case, the `supportsHttpsTrafficOnly` will be the one we use.

![supportshttps](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/supportshttps.png?resize=448%2C327&ssl=1)

In the `StorageAccountPropertiesCreateParameters object` is the `supportsHttpsTrafficOnly`.

![httpstraffic](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/httpstraffic.png?resize=479%2C74&ssl=1)

### Another way to explore resources

Once you have created a resource, you can inspect their properties. Use the [Azure Resource Explorer](https://resources.azure.com/) to inspect the context of your subscription. You can browse by providers, subscriptions, resource groups, and resources.

## Find the property alias

We need to map the property we found to it’s _alias_. When you create a policy, it uses aliases to restrict what values or conditions are allowed. Each alias maps to paths in different API versions for a given resource type. During policy evaluation, the policy engine gets the property path for that API version.

Use the following cli to get the alias used by the Azure Policy.

```bash
az provider show --namespace Microsoft.Storage --expand "resourceTypes/aliases" --query "resourceTypes[].aliases[].name"
```

As shown in the following illustration, the results show that `supportsHttpsTrafficOnly` is supported.

![supporthttps](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/supporthttps.png?resize=748%2C121&ssl=1)

This means we can write a policy based on `supportsHttpsTrafficOnly`.

Another way to query the aliases is to use Azure Graph. The following code installs Azure Graph into the CLI and queries the aliases. The results are provided in a heirarchy that may be easier to view.
  
```bash
az extension add --name resource-graph
az graph query -q "Resources | where type=~'microsoft.storage/storageaccounts' | limit 1 | project aliases"
```

Before we go install a custom policy, let’s create a sample resource that will not be compliant.

### Create a non-compliant storage account

Let’s begin by creating a storage account resource that allows applications to access the storage, create a container, and upload a file. Log into Azure using `az login`, then use the following code to create a resource group, storage account, and storage container; grant yourself contributor access to the storage account, create a file and upload it.

```bash
RESOURCE_GROUP_NAME="rg-wus2-storagepolicy"
LOCATION="west us 2"
RANDOM=$$
STORAGE_ACCOUNT_NAME=ststoragepolicy$RANDOM
STORAGE_CONTAINER_NAME=thefolder
COST_CENTER=demo
ENVIRONMENT="testing it"

# create resource group
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location "$LOCATION" 
az group update -n $RESOURCE_GROUP_NAME \
    --set tags.'Cost Center'="$COST_CENTER" tags.'Environment'="$ENVIRONMENT"

# get your sign in name and assign yourself 'Storage Blob Data Contributor' 
# permissions to the resource group. The storage account will inherit your role
USER==$(az ad signed-in-user show --query userPrincipalName -o tsv)
az role assignment create --role "Storage Blob Data Contributor" \
    --assignee $USER --resource-group $RESOURCE_GROUP_NAME
 
# it takes a couple minutes for the role to propogate once it is created
sleep 2m

az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --encryption-services blob \
    --https-only false \
    --tags Cost Center=$COST_CENTER Environment=$ENVIRONMENT

az storage container create \
    --account-name $STORAGE_ACCOUNT_NAME \
    --name $STORAGE_CONTAINER_NAME \
    --auth-mode login

# create a helloworld.html page for storage
cat <<EOF > helloworld.html
<!DOCTYPE html>
<html>
    <head>
        <title>Hello World Page</title>
    </head>
    <body>
Hello World!
    </body>
</html>
EOF

# upload the file
az storage blob upload \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $STORAGE_CONTAINER_NAME \
    --name helloworld.html \
    --file helloworld.html \
    --auth-mode login
    
az storage blob list \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $STORAGE_CONTAINER_NAME \
    --output table \
    --auth-mode login
```

Note: For the demo to work, you will explicitly need to assign the [Storage Blob Data Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor) role to yourself. Even though you are the account owner, you need explicit permissions to perform data operations against the storage account.

The storage account is intentionally created with `--https-only false`.

Next, before we create our custom policy, let’s test to see if there is a voilation of Azure policy from our existing policies.

## Test against current policies

Does the new storage resource already violate one of our policies? Log into the Azure Portal, search in the search bar for **Policy**. And there is an intiative that was installed by Azure Security Center that flags the storage resource as not being compliant, as shown in the following illustration.

![notcompliant](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/notcompliant.png?resize=748%2C69&ssl=1)

Click through the links initiative and you can see resource that we just created and the rule that was violated, as shown in the following illustration.

![resourcecompliance](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/resourcecompliance.png?resize=748%2C345&ssl=1)

Our business requirement is to now allow the creation of storage accounts, not to just audit. In the next step, create a custom policy to stop anyone from creating a storage account that is non-compliant.

## Create custom policy to deny the non-compliant storage creation

It is possible to go into the portal and just change the policy. You could go into the initiative, edit the assignment of the policy, and change the parameter from `Audit` to `Deny`. But in our world where you want to track the changes and to automate your new initiatives, you will want to create a custom policy that denies creation of the non-compliant resource.

The following JSON (from the Microsoft documentation [Tutorial: Create a custom policy definition](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-custom-policy-definition#compose-the-definition)) shows the policy.

```json
{
    "properties": {
        "displayName": "Deny storage accounts not using only HTTPS",
        "description": "Deny storage accounts not using only HTTPS. Checks the supportsHttpsTrafficOnly property on StorageAccounts.",
        "mode": "all",
        "parameters": {
            "effectType": {
                "type": "string",
                "defaultValue": "Deny",
                "allowedValues": [
                    "Deny",
                    "Disabled"
                ],
                "metadata": {
                    "displayName": "Effect",
                    "description": "Enable or disable the execution of the policy"
                }
            }
        },
        "policyRule": {
            "if": {
                "allOf": [
                    {
                        "field": "type",
                        "equals": "Microsoft.Storage/storageAccounts"
                    },
                    {
                        "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
                        "notEquals": "true"
                    }
                ]
            },
            "then": {
                "effect": "[parameters('effectType')]"
            }
        }
    }
}
```

Several items to note from the code:

*   The `displayName` and `description` elements show the intent of the policy.
*   The `effectType` element on lines 7 to 18 defaults to `Deny`, but allows you to set the effect to `Disabled`, which allows you to turn off the rule.
*   The `policyRule` requies both:
    *   The storage account type is `Microsoft.Storage/storageAccounts` and
    *   The storage account `supportsHttpsTrafficOnly` property is not true

Next, let’s split up our policy so we can create the policy definition.

### Create the policy definition

The policy definition consists of rules and parameters for those rules. Both are declared in JSON. The following script uses Bash to create two files, one for the rules and one to define the parameters.

```bash
mkdir requirehttps && cd requirehttps
cat <<EOF > requirehttps.azurepolicy.json
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Storage/storageAccounts"
      },
      {
        "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
        "notEquals": "true"
      }
    ]
  },
  "then": {
    "effect": "[parameters('effectType')]"
  }
}
EOF

RULES_FILE_URL="./requirehttps.azurepolicy.json"

cat <<EOF > requirehttps.azurepolicy.parameters.json
{
  "effectType": {
    "type": "string",
    "defaultValue": "Deny",
    "allowedValues": [
      "Deny",
      "Disabled"
    ],
    "metadata": {
      "displayName": "Effect",
      "description": "Enable or disable the execution of the policy"
    }
  }
}
EOF

PARAMETERS_FILE_URL="./requirehttps.azurepolicy.parameters.json"
```

Use `az policy definition create` to create the policy definition. See [Create a policy definition with Azure CLI](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage#create-a-policy-definition-with-azure-cli). The following code creates a policy definition and saves the policy definition to a subscription. It does not assign the policy to the subscription.

```bash
SUBSCRIPTION_ID=c2b15f36-f522-451c-84e3-a4fc54056617

az policy definition create --name "denyStorageAccountNotUsingHttps" \
  --display-name "Deny storage accounts not using only HTTPS" \
  --description "Deny storage accounts that are not using only HTTPS. Checks the supportsHttpsTrafficOnly property on Microsoft.Storage/storageAccounts provider." \
  --rules $RULES_FILE_URL \
  --params  $PARAMETERS_FILE_URL \
  --subscription $SUBSCRIPTION_ID
```

Once you have defined the policy, you can find it in the portal. Open the portal, search Policy, click Definitions to all the the policies. Search on https. The following illustration shows the definition of the matchint policies.

![denystorage](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/denystorage.png?resize=748%2C258&ssl=1)

Click **Deny storage accounts not using only HTTPS** to see your policy definition.

You may want to consider the following best practices:

> You could have saved the policy to a management group, which is then available as a the policy definition to all of the subscriptions associated with the management group.
> 
> The rule and param URLs can point to your rules in GitHub or Azure DevOps.

Now that we have a definition available in our subsription, you need to apply it.

### Apply the policy to a scope

Now that your policy has been defined and available in your subscription, you need to assign the policy. This step sets the policy to a particular _scope_.

Valid scopes are management group, subscription, resource group, and resource as shown in this table:

Management group

`/providers/Microsoft.Management/managementGroups/MyManagementGroup`

Subscription

`/subscriptions/c2b15f36-f522-451c-84e3-a4fc54056617`

Resource group

`/subscriptions/c2b15f36-f522-451c-84e3-a4fc54056617/resourceGroups/myGroup`

Resource

`/subscriptions/c2b15f36-f522-451c-84e3-a4fc54056617/resourceGroups/myGroup/providers/Microsoft.Compute/virtualMachines/myVM`

You can assign the policy in the portal. See

To automate it, use an Azure CLI script command `az policy assignment create` to assign the policy definition to the scope. The following sample assigns the policy to the subscription scope.

```bash
SCOPE=/subscriptions/$SUBSCRIPTION_ID

az policy assignment create --name "Require https for storage in subscription" --scope $SCOPE \
  --policy "denyStorageAccountNotUsingHttps" \
  --params '{ "effectType" : { "value": "Deny" } }'
```

As it assigns the policy, it also provides the parameters for this particular assignment.

Now that you have the policy assigned, what happened to the non-compliant resource?

### Check compliance

Once you have assigned the policy to your subscription, you will want to check compliance. The resource created in an earlier step still fails based on the Security Center rule. But it also fails based on the new custom rules you added in the previous step.

To view, open Policy blade in the Azure portal. Click **Compliance**.

![policycompliance](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/policycompliance.png?resize=740%2C179&ssl=1)

It takes a few minutes to scan your resources.

> Assigning a policy with a “deny” effect may take up to 30 mins (average case) and 1 hour (worst case) to start denying the creation of non-compliant resources.

You can query for non-compliant resources in PowerShell. The following cmdlet returns the details for all non-compliant storage accounts.

```powershell
Get-AzPolicyState -Filter "ResourceType eq '/Microsoft.Storage/storageAccounts'"
```
### Creation of a non-compliant resource now fails

To test that the policy denies creation of an non-compliant resource, run the script in the previous section to create a non-compliant storage account. The following code tries to create a new storage account in the same resource group.

```bash
RESOURCE_GROUP_NAME="rg-wus2-storagepolicy"
LOCATION="west us 2"
RANDOM=$$
STORAGE_ACCOUNT_NAME=ststoragepolicy$RANDOM
STORAGE_CONTAINER_NAME=thefolder
COST_CENTER=demo
ENVIRONMENT="testing it"

az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --encryption-services blob \
    --https-only false \
    --tags Cost Center=$COST_CENTER Environment=$ENVIRONMENT
```

Once completed, you will see an error message.

![policyerror](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/policyerror.png?resize=748%2C173&ssl=1)

When you go into the portal, click Compliance in the Policy page to see results. Click **Require https for storage in subscription** to see the summary of non-compliance. Notice that the existing resource is audited as not compliant. And the denial for the creating of the non-compliant storage account is shown.

![policycompliance2](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/policycompliance2.png?resize=748%2C655&ssl=1)

### View compliance in Log Analytics

Because you installed a Log Analytics workspace as described in the post [Setting up Log Analytics workspace for production in enterprise](https://azuredays.com/2020/06/15/setting-up-log-analytics-workspace-for-production-in-enterprise/), you can view `AzureActivity` from the [Activity Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log) solution tied to your subscription.

![policyactivitylog](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/07/policyactivitylog.png?resize=748%2C328&ssl=1)

### Apply policy using a ARM template

The documentation Quickstart: Create a policy assignment to identify non-compliant resources by using a Resource Manager template shows how you can deploy a policy to a resource group.

You will need the `policyDefinitionID`. Use the following command to get the properties of the policy you want to apply.

```
az policy definition show --name denyStorageAccountNotUsingHttps
```

Use the properties when you deploy the ARM template.

## Summary

This was a deep-dive walkthrough into how to define and implement your own policies, which build-in governance best practices for your users. You learned the workflow of a custom policy and how to deploy the policy into either a subscription or management group. And you learned how to check your compliance with all your initiatives.

## Next steps

*   Define your own specific bsuiness requirements for your own compliance initiatives. Review the [Azure Policy security baseline for Azure Security Benchmark](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/azure-security-benchmark-baseline).
*   Define tags so you can idenity who ownership of resources. Define business rules, policy definition, and assign policies so you will know who to contact and when to review resources as policies change.
*   Review the [built-in policy definitions and initiatives](https://github.com/Azure/azure-policy/tree/master/built-in-policies) to help you in quickly building your own compliance initiatives. Note how the policies have versions
*   Follow and update [policies that are on GitHub](https://github.com/Azure/azure-policy)
*   [Understand Azure Policy effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects)
*   Learn about Blueprints that can group together your policies, resource groups, and role assignments for automation
*   [Design Policy as Code workflows](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-as-code)
*   Define alerts to watch for non-compliance in Azure Monitor logs.

## Resources

*   [Quickstart: Create, download, and list blobs with Azure CLI](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-cli)
*   [Authorize with Azure AD credentials](https://docs.microsoft.com/en-us/azure/storage/common/authorize-data-operations-cli#authorize-with-azure-ad-credentials)
*   Quickstart: Create a policy assignment to identify non-compliant resources with Azure CLI
*   [Azure resource providers and types](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types)

