# Setting up Log Analytics workspace for production in enterprise

![icon_1.0.1195.1535](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/icon_1.0.1195.1535.png?resize=196%2C196&ssl=1)Operations and security are central in any cloud deployment. It should be top of mind in each of your cloud deployments.

Enabling your operations team to find and fix errors, to build practices around scaling your data are essential to having a successful Azure data center.

_Log Analytics_ provides a unified way to show what is happening across your Azure data center.

In this article learn how to set up Log Analytics to receive data from multiple Azure subscriptions, on premises virtual machines or other clouds. And learn to configure your Log Analytics workspace, set up role-based-access-control, and how to incorporate Log Analytics best practices. In addition, you will also learn how to get started with some important queries.

Before you deploy resource groups and resources, you want to be able to measure and anlayze what is happening in our Azure data center. So before you start your deployments, it is a best practice to do these things:

1.  Deploy your Azure Log Analytics workspace
2.  Configure your Log Analytics workspace
3.  Deploy Security Center and have it send its logs to Azure Log Analytics. Learn about Security Center in the next article.

And then you can deploy your workloads.

In the next article, learn how to associate Azure Log Analytics with Security Center.

## Prerequisites

You should already have:

*   Azure CLI and PowerShell installed.
*   Completed [setting up your administrators](http://azuredays.com/2020/06/04/setting-up-your-enterprise-azure-subscription-administrators/) as shown in our previous post.
*   Some basic understanding of how to [deploy resources using an ARM template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-powershell).

## Definitions

Let’s start with some definitions about the [changing terminology around Azure Monitor and Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/terminology).

*   **Azure Monitor** log data is stored in a **Log Analytics workspace**.
*   The term _Log Analytics_ is changing to be _Azure Monitor logs_.
*   **Log analytics** primarily applies to the page in the Azure portal used to write and run queries and analyze log data.
*   **Log Analytics** and **Application Insights** have been consolidated into **Azure Monitor**.
*   **Log Analytics workspaces** is where you [create new workspaces](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace) and configure data sources.
*   [Management solutions](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/solutions) have been renamed to _monitoring solutions_

## About Log Analytics workspaces

**Azure Log Analytics** is the primary tool in the Microsoft Azure portal for writing log queries and interactively analyzing their results. For those who have been around awhile, it was knows as OMS.

**Azure Monitor** and many resources in Azure stores log data in a **Log Analytics workspace**. The workspace is a central repository for that you can use to collect information from monitors and many other sources.

The following illustration shows how you collect data from multiple data sources and then use Log Analytics for alerts, analysis, and reports.

![collecting-data](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/collecting-data.png?resize=748%2C354&ssl=1)

In this article you set up a shared Log Analytics workspace that is used across multiple applications, multiple subscriptions. You can think of it as a central workspace to monitor your the compute, network, and storage for your production environment.

See [Designing your Azure Monitor Logs deployment](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment) for more information about how to design workspace, where your data is collected and aggregated.

## Set up Log Analytics workspace

Log Analytics can collect data from across multiple Azure Monitors, application, subscriptions, and even on premises or operations information across clouds.

Select a [pricing model](https://azure.microsoft.com/en-us/blog/introducing-a-new-way-to-purchase-azure-monitoring-services/) based on the amount of data brought in, called _per GB_. This pricing model works best for containers and microservices where the definition of a node is less clear. “Per GB” data ingestion is the new basis for pricing across application, infrastructure, and networking monitoring.

In order to strictly control the access to the log analytics data, you may want to create a subscription for your operations team that contains Log Analytics and perhaps other sensitive data, such as Key Vault. When you set up your Log Analytics workspace, you can configure the other data sources to send the data to it — regardless of region to aggregate across subscriptions. The name for the Log Analytics workspace is unique across all of Azure, so it can be used to accept data from all of your resources.

Typically in an enterprise, you will have Azure Monitor data and data from Security Center and other resources providing data to a centralized Log Analytics workspace, as shown in the following illustration.

![asc-sentinel](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/asc-sentinel.png?resize=350%2C181&ssl=1)

Architects will often set up a Log Analytics workspace for developers to monitor applications during development and then have a second one for production.

> You may want to consider putting your production Log Analytics workspace in its own subscription so you can strictly control who has access, who can view data, and who receives alarms. Adding a minimal number of people who have access to the subscription can help guarantee the data in Log Analytics.

You can create the Log Analytics workspace using the [portal](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace), [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace-cli), or [PowerShell](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/powershell-workspace-configuration). In this article, you will set up the Log Analytics workspace using PowerShell.

## Set up Log Analytics workspace using PowerShell and an ARM template

Log into Azure using PowerShell. This can be on your local computer or in [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview).

Then create a resource group to hold the Log Analytics workspace and its long term data. The following example shows how to create such a resource group, using your own SUBSCRIPTION\_ID and the other parameters for your tags.

```powershell
$ORGANIZATION_NAME = "Az Days"
$LOCATION = "Central US"
$LOCATION_ABBR= "cenus"
$SUBSCRIPTION_ID = "7005478c-99cb-4b5d-a56c-d60abc23d6af"
$ENVIRONMENT = "Prod"
$COSTCENTER = "Corporate"
$OWNER = "bruce@azdays.com"

$createdData = Get-Date -Format "yyyy-MM-dd"
$tags = @{"Cost Center"=$COSTCENTER; "Location"=$LOCATION; "Environment"=$ENVIRONMENT; "Project"=$ORGANIZATION_NAME; "Owner"=$OWNER; "Created Date"=$createdData; "Tier"="Management" }

$OrganizationName = $ORGANIZATION_NAME -replace '\s', ''
$OrganizationName = $OrganizationName.ToLower()

if ($SubscriptionId -eq $null) {
    $SubscriptionId = (Get-AzContext).Subscription.SubscriptionId
}
Set-AzContext -Name ($OrganizationName + "Context") -SubscriptionId $subscriptionID -Force

#############
# Create shared resource group for management organization
#############

$resourceGroupName = "rg-$LOCATION_ABBR-$OrganizationName-$ENVIRONMENT-management"

New-AzResourceGroup `
      -Name $resourceGroupName `
      -Location $Location_lc `
      -Tag  $tags

Get-AzResourceGroup -Name $resourceGroupName
Write-Host "Created or updated: " $ResourceGroupName
```

Next, you will use an ARM template to create a Log Analytics workspace, create a storage account to hold the Monitor log data, lock the storage account and the Log Analytics workspace resources from deletion. (You will learn more about ARM templates in later posts.)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "organization": {
      "type": "string",
      "metadata": {
        "description": "Organization name. For example: AzDays"
      }
    },
    "service-tier": {
      "type": "string",
      "defaultValue": "PerNode",
      "allowedValues": [
        "Free",
        "Standalone",
        "PerNode",
        "PerGB2018"
      ],
      "metadata": {
        "description": "Service Tier: Free, Standalone, or PerNode"
      }
    },
    "data-retention": {
      "type": "int",
      "defaultValue": 365,
      "minValue": 0,
      "maxValue": 365,
      "metadata": {
        "description": "Number of days data will be retained for."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "West US 2",
      "allowedValues": [
        "australiacentral",
        "australiaeast",
        "australiasoutheast",
        "brazilsouth",
        "canadacentral",
        "centralindia",
        "centralus",
        "eastasia",
        "eastus",
        "eastus2",
        "francecentral",
        "japaneast",
        "koreacentral",
        "northcentralus",
        "northeurope",
        "southafricanorth",
        "southcentralus",
        "southeastasia",
        "uksouth",
        "ukwest",
        "westcentralus",
        "westeurope",
        "westus",
        "westus2"
      ],
      "metadata": {
        "description": "Region used when establishing the workspace."
      }
    },
    "tags": {
      "type": "object",
      "defaultValue": {
        "Cost Center": "[resourceGroup().tags['Cost Center']]",
        "Location": "[resourceGroup().tags['Location']]",
        "Environment": "[resourceGroup().tags['Environment']]",
        "Owner": "[resourceGroup().tags['Owner']]",
        "Organization": "[parameters('organization')]",
        "Created Date": "[resourceGroup().tags['Created Date']]",
        "Tier": "[resourceGroup().tags['Tier']]"
      }
    },
  },
  "variables": {
    "deployment-prefix": "[concat('workload-', parameters('organization'))]",
    "uniqueString": "[uniqueString(subscription().id, concat(variables('deployment-prefix'), '-log'))]",
    "diagnostic-storageAccount-prefix": "[concat(, 'diag', replace(variables('deployment-prefix'), '-', ''))]",
    "diagnostic-storageAccount-name": "[toLower(substring(replace(concat(variables('diagnostic-storageAccount-prefix'), variables('uniqueString'), variables('uniqueString')), '-', ''), 0, 23) )]",
    "oms-workspace-name": "[concat('log-', variables('deployment-prefix'))]"
  },
  "resources": [
    {
      "comments": "----DIAGNOSTICS STORAGE ACCOUNT-----",
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('diagnostic-storageAccount-name')]",
      "apiVersion": "2019-06-01",
      "location": "[resourceGroup().location]",
      "kind": "StorageV2",
      "sku": {
        "name": "Standard_LRS",
        "tier": "Standard"
      },
      "tags": "[parameters('tags')]",
      "properties": {
        "supportsHttpsTrafficOnly": true,
        "networkAcls": {
          "bypass": "AzureServices",
          "defaultAction": "Deny"
        }
      }
    },
    {
      "type": "Microsoft.Storage/storageAccounts/providers/locks",
      "apiVersion": "2016-09-01",
      "name": "[concat(variables('diagnostic-storageAccount-name'), '/Microsoft.Authorization/storageDoNotDelete')]",
      "dependsOn": [
        "[concat('Microsoft.Storage/storageAccounts/', variables('diagnostic-storageAccount-name'))]"
      ],
      "comments": "Resource lock on diagnostic storage account",
      "properties": {
        "level": "CannotDelete"
      }
    },
    {
      "apiVersion": "2015-11-01-preview",
      "location": "[parameters('location')]",
      "name": "[variables('oms-workspace-name')]",
      "properties": {
        "sku": {
          "Name": "[parameters('service-tier')]"
        },
        "retention": "[parameters('data-retention')]"
      },
      "tags": {},
      "type": "Microsoft.OperationalInsights/workspaces"
    },
    {
      "type": "Microsoft.OperationalInsights/workspaces/providers/locks",
      "apiVersion": "2016-09-01",
      "name": "[concat(variables('oms-workspace-name'), '/Microsoft.Authorization/logAnalyticsDoNotDelete')]",
      "dependsOn": [
        "[variables('oms-workspace-name')]"
      ],
      "comments": "Resource lock on Log Analytics",
      "properties": {
        "level": "CannotDelete"
      }
    }
  ],
  "outputs": {
    "resourceID": {
      "type": "string",
      "value": "[resourceId('Microsoft.OperationalInsights/workspaces/', variables('oms-workspace-name'))]"
    },
    "workspaceName":{
        "type": "string",
        "value": "[variables('omsWorkspaceName')]"
    },
    "workspaceId":{
        "type": "string",
        "value": "[reference(resourceId('Microsoft.OperationalInsights/workspaces/', variables('omsWorkspaceName')), '2017-04-26-preview').customerId]"
    },
    "workspaceKey":{
        "type": "string",
        "value": "[listKeys(resourceId('Microsoft.OperationalInsights/workspaces/', variables('omsWorkspaceName')), '2017-04-26-preview').primarySharedKey]"
    }
  }
}
```

To deploy, you can either set up a parameters file, or deploy with a script similar to the following:

```powershell
#Requires -Version 7.0
#Requires -Modules PowerShellGet, Az, Az.Storage, , Az.Resources
<#
.SYNOPSIS
  Add-LogAnalytics adds resource group, log analytics workspace as a shared resource, using loganalytics.deploy.json file in the same directory.
.DESCRIPTION
  Creates a shared resource group, a storage account attached and a new log analytics workspace resource.
.PARAMETER SubscriptionID 
    Mandatory. The Azure Subscription ID, such as "9f241d6e-16e2-4b2b-a485-cc546f04799b"
.PARAMETER OrganizationName
    Mandatory. Name of organization. (used to create the resource group and the common resources.
.PARAMETER CostCenter
    Optional. Cost center for this resource. Used for tags. Default is "Administration"
.PARAMETER Environment
    One for each region. So the default is 'mgmt' for the Environment for tags 
.PARAMETER Location
    You will need to specify the location for regions other than West US 2
.PARAMETER LocationAbbr
    You will need to specify the location for regions other than West US 2
.PARAMETER Owner
    The owner is tagged in the resource group and resource
.RETURN
    The name of the resource group created
.NOTES
  Version:        1.0.1
  Author:         Bruce Kyle
  Creation Date:  6/5/2020
  Purpose/Change: Update example
  Requires:
  - Connection to Azure
  Copyright 2020 Stretegic Datatech LLC
  License: MIT https://opensource.org/licenses/MIT
  
.EXAMPLE
    $ORGANIZATION_NAME = "AzDays"
    $LOCATION = "Central US"
    .\Add-LogAnalytics.ps1 -SubscriptionID 9f241d6e-16e2-4b2b-a485-cc546f04799b `
        -OrganizationName $ORGANIZATION_NAME -Location $LOCATION -LocationAbbr 'cus'
#>
[CmdletBinding()]
#--------[Params]---------------
Param(
    [Parameter(Mandatory=$false)] [string] $SubscriptionID,
    [Parameter(Mandatory)] [string] $OrganizationName,
    [Parameter(Mandatory=$false)] [string] $CostCenter = "Administration",
    [Parameter(Mandatory=$false)] [string] $Environment='mgmt',
    [Parameter(Mandatory=$false)] [string] $Location="West US 2",
    [Parameter(Mandatory=$false)] [string] $LocationAbbr='wus2',
    [Parameter(Mandatory=$false)] [string] $Owner = $env:UserName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try
{

  Set-AzContext -Name ($OrganizationName + "Context") -SubscriptionId $subscriptionID -Force

  $Location_lc = $LOCATION -replace '\s', ''
  $Location_lc = $Location_lc.ToLower()

    #############
    # Deploy log analytics with storage account
    #############

    $deploymentName = $ResourceGroupName.substring(3) + "-management-deployment"
    Write-Host "Deployment name: " $deploymentName

    # accepting the defaults for the other items
    $paramObject = @{
         'organization' = $OrganizationName
    }
    $parameters = @{
         'Name'                  = $deploymentName
         'ResourceGroupName'     = $ResourceGroupName
         'TemplateFile'          = '.\loganalytics-deploy.json'
         'TemplateParameterObject'    = $paramObject
         'Verbose'               = $true
    }

    New-AzResourceGroupDeployment @parameters

    $loganalyticsResourceID = @(Get-AzResourceGroupDeployment `
        -ResourceGroupName  $ResourceGroupName `
        -Name  $ResourceGroupName).Outputs.resourceID.value
}
catch
{
    $loganalyticsResourceID = $null;
     echo "Completed Log analytics failed"
}
finally
{
    echo "Completed Log analytics creation: $loganalyticsResourceID"
}
        
return $loganalyticsResourceID
```

Note that Log Analytics workspace is not available in every region, and Log Analytics does not not need to be colocated in any particular region with your resources. It may be a good idea to have your analytics in a separate region to help query and mitigate during outages.

Run the PowerShell script in this section to deploy the template. The template returns the workspace name that you will need in the next section.

## Configure workspace

Next, to configure workspace, you connect log analytics to the resources you want to track.

In the portal, navigate to the Overview page of your newly created Log Analytics workspace as shown in the following illustration.

![configure-logs](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/configure-logs.png?resize=442%2C344&ssl=1)

Azure provides out of the box Activity Logs. To add Activity Logs to Log Analytics, click the Azure Activity Logs link and select the subscriptions you want to analyze.

### Platform logs and Platform metrics

[_Platform logs_](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/platform-logs-overview) provide detailed diagnostic and auditing information for Azure resources and the Azure platform they depend on. They are automatically generated although you need to configure some of the platform logs to be forwarded to Log Analytics. [_Platform metrics_](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-platform-metrics) are collected by default and typically stored in the Azure Monitor metrics database.

Each Azure resource requires its own diagnostic setting. The available categories will vary for different resource types.

You can send [these data to Log Analytics, Event Hubs, or Storage Account or any combination](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings#destinations).

> This means that you will need to configure your resources to send their performance data and logs to Log Analytics as you build them.

You can set logs at different layers of Azure:

*   **Resource logs**. Operations within an Azure resource (the _data plane_), for example getting a secret from a Key Vault or making a request to a database. _Resource logs were previously referred to as diagnostic logs._
*   **Activity log**. Operations on each Azure resource in the subscription from the outside (_the management plane_) in addition to updates on Service Health events.
*   **Azure Active Directory logs**. History of sign-in activity and audit trail of changes made in the Azure Active Directory.

To analyze these logs in Log Analytics, you need [send platform logs to your Log Analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings).

You can use PowerShell to create the diagnostics settings. For example, the following PowerShell code will send Key Vault diagnostics data to the Log Analytics workspace.

```powershell
$LOG_ANALYTICS_RESOURCE_ID = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/oi-default-east-us/providers/microsoft.operationalinsights/workspaces/myworkspace"
$KEY_VAULE_RESOURCE_ID = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myresourcegroup/providers/Microsoft.KeyVault/vaults/mykeyvault"
Set-AzDiagnosticSetting -Name KeyVault-Diagnostics -ResourceId  $KEY_VAULE_RESOURCE_ID `
  -Category AuditEvent -MetricCategory AllMetrics -Enabled $true `
  -WorkspaceId $LOG_ANALYTICS_RESOURCE_ID
```

Or you can configure your workspace using an ARM template.

### Configure your workspace using ARM Template.

You may want to connect your workspace to one or more of the following.

1.  Add solutions to the workspace
2.  Create saved searches. To ensure that deployments don’t override saved searches accidentally, an eTag property should be added in the “savedSearches” resource to override and maintain the idempotency of saved searches.
3.  Create saved function. The eTag should be added to override function and maintain idempotency.
4.  Create a computer group
5.  Enable collection of IIS logs from computers with the Windows agent installed
6.  Collect Logical Disk perf counters from Linux computers (% Used Inodes; Free Megabytes; % Used Space; Disk Transfers/sec; Disk Reads/sec; Disk Writes/sec)
7.  Collect syslog events from Linux computers
8.  Collect Error and Warning events from the Application Event Log from Windows computers
9.  Collect Memory Available Mbytes performance counter from Windows computers
10.  Collect IIS logs and Windows Event logs written by Azure diagnostics to a storage account
11.  Collect custom logs from Windows computer

Azure documentation provides a sample ARM template to deploy that performs each of the steps. The following sample shows how to configure Log Analytics workspace from the documentation to set each of the steps.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "workspaceName": {
      "type": "string",
      "metadata": {
        "description": "Workspace name"
      }
    },
    "sku": {
      "type": "string",
      "allowedValues": [
        "PerGB2018",
        "Free",
        "Standalone",
        "PerNode",
        "Standard",
        "Premium"
      ],
      "defaultValue": "pergb2018",
      "metadata": {
        "description": "Pricing tier: pergb2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium) which are not available to all customers."
      }
    },
    "dataRetention": {
      "type": "int",
      "defaultValue": 30,
      "minValue": 7,
      "maxValue": 730,
      "metadata": {
        "description": "Number of days of retention. Workspaces in the legacy Free pricing tier can only have 7 days."
      }
    },
    "immediatePurgeDataOn30Days": {
      "type": "bool",
      "defaultValue": "[bool('false')]",
      "metadata": {
        "description": "If set to true, changing retention to 30 days will immediately delete older data. Use this with extreme caution. This only applies when retention is being set to 30 days."
      }
    },
    "location": {
      "type": "string",
      "allowedValues": [
        "australiacentral",
        "australiaeast",
        "australiasoutheast",
        "brazilsouth",
        "canadacentral",
        "centralindia",
        "centralus",
        "eastasia",
        "eastus",
        "eastus2",
        "francecentral",
        "japaneast",
        "koreacentral",
        "northcentralus",
        "northeurope",
        "southafricanorth",
        "southcentralus",
        "southeastasia",
        "uksouth",
        "ukwest",
        "westcentralus",
        "westeurope",
        "westus",
        "westus2"
      ],
      "metadata": {
        "description": "Specifies the location in which to create the workspace."
      }
    },
    "applicationDiagnosticsStorageAccountName": {
      "type": "string",
      "metadata": {
        "description": "Name of the storage account with Azure diagnostics output"
      }
    },
    "applicationDiagnosticsStorageAccountResourceGroup": {
      "type": "string",
      "metadata": {
        "description": "The resource group name containing the storage account with Azure diagnostics output"
      }
    },
    "customLogName": {
      "type": "string",
      "metadata": {
        "description": "The custom log name"
      }
    }
  },
  "variables": {
    "Updates": {
      "Name": "[Concat('Updates', '(', parameters('workspaceName'), ')')]",
      "GalleryName": "Updates"
    },
    "AntiMalware": {
      "Name": "[concat('AntiMalware', '(', parameters('workspaceName'), ')')]",
      "GalleryName": "AntiMalware"
    },
    "SQLAssessment": {
      "Name": "[Concat('SQLAssessment', '(', parameters('workspaceName'), ')')]",
      "GalleryName": "SQLAssessment"
    },
    "diagnosticsStorageAccount": "[resourceId(parameters('applicationDiagnosticsStorageAccountResourceGroup'), 'Microsoft.Storage/storageAccounts', parameters('applicationDiagnosticsStorageAccountName'))]"
  },
  "resources": [
    {
      "apiVersion": "2017-03-15-preview",
      "type": "Microsoft.OperationalInsights/workspaces",
      "name": "[parameters('workspaceName')]",
      "location": "[parameters('location')]",
      "properties": {
        "retentionInDays": "[parameters('dataRetention')]",
        "features": {
          "immediatePurgeDataOn30Days": "[parameters('immediatePurgeDataOn30Days')]"
        },
        "sku": {
          "name": "[parameters('sku')]"
        }
      },
      "resources": [
        {
          "apiVersion": "2015-03-20",
          "name": "VMSS Queries2",
          "type": "savedSearches",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "properties": {
            "eTag": "*",
            "category": "VMSS",
            "displayName": "VMSS Instance Count",
            "query": "Event | where Source == \"ServiceFabricNodeBootstrapAgent\" | summarize AggregatedValue = count() by Computer",
            "version": 1
          }
        },
        {
          "apiVersion": "2017-04-26-preview",
          "name": "Cross workspace function",
          "type": "savedSearches",
            "dependsOn": [
             "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
            ],
            "properties": {
              "etag": "*",
              "displayName": "failedLogOnEvents",
              "category": "Security",
              "FunctionAlias": "failedlogonsecurityevents",
              "query": "
                union withsource=SourceWorkspace
                workspace('workspace1').SecurityEvent,
                workspace('workspace2').SecurityEvent,
                workspace('workspace3').SecurityEvent,
                | where EventID == 4625"
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "type": "datasources",
          "name": "sampleWindowsEvent1",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "kind": "WindowsEvent",
          "properties": {
            "eventLogName": "Application",
            "eventTypes": [
              {
                "eventType": "Error"
              },
              {
                "eventType": "Warning"
              }
            ]
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "type": "datasources",
          "name": "sampleWindowsPerfCounter1",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "kind": "WindowsPerformanceCounter",
          "properties": {
            "objectName": "Memory",
            "instanceName": "*",
            "intervalSeconds": 10,
            "counterName": "Available MBytes"
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "type": "datasources",
          "name": "sampleIISLog1",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "kind": "IISLogs",
          "properties": {
            "state": "OnPremiseEnabled"
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "type": "datasources",
          "name": "sampleSyslog1",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "kind": "LinuxSyslog",
          "properties": {
            "syslogName": "kern",
            "syslogSeverities": [
              {
                "severity": "emerg"
              },
              {
                "severity": "alert"
              },
              {
                "severity": "crit"
              },
              {
                "severity": "err"
              },
              {
                "severity": "warning"
              }
            ]
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "type": "datasources",
          "name": "sampleSyslogCollection1",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "kind": "LinuxSyslogCollection",
          "properties": {
            "state": "Enabled"
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "type": "datasources",
          "name": "sampleLinuxPerf1",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "kind": "LinuxPerformanceObject",
          "properties": {
            "performanceCounters": [
              {
                "counterName": "% Used Inodes"
              },
              {
                "counterName": "Free Megabytes"
              },
              {
                "counterName": "% Used Space"
              },
              {
                "counterName": "Disk Transfers/sec"
              },
              {
                "counterName": "Disk Reads/sec"
              },
              {
                "counterName": "Disk Writes/sec"
              }
            ],
            "objectName": "Logical Disk",
            "instanceName": "*",
            "intervalSeconds": 10
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "type": "dataSources",
          "name": "[concat(parameters('workspaceName'), parameters('customLogName'))]",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', '/', parameters('workspaceName'))]"
          ],
          "kind": "CustomLog",
          "properties": {
            "customLogName": "[parameters('customLogName')]",
            "description": "this is a description",
            "extractions": [
              {
                "extractionName": "TimeGenerated",
                "extractionProperties": {
                  "dateTimeExtraction": {
                    "regex": [
                      {
                        "matchIndex": 0,
                        "numberdGroup": null,
                        "pattern": "((\\d{2})|(\\d{4}))-([0-1]\\d)-(([0-3]\\d)|(\\d))\\s((\\d)|([0-1]\\d)|(2[0-4])):[0-5][0-9]:[0-5][0-9]"
                      }
                    ]
                  }
                },
                "extractionType": "DateTime"
              }
            ],
            "inputs": [
              {
                "location": {
                  "fileSystemLocations": {
                    "linuxFileTypeLogPaths": null,
                    "windowsFileTypeLogPaths": [
                      "[concat('c:\\Windows\\Logs\\',parameters('customLogName'))]"
                    ]
                  }
                },
                "recordDelimiter": {
                  "regexDelimiter": {
                    "matchIndex": 0,
                    "numberdGroup": null,
                    "pattern": "(^.*((\\d{2})|(\\d{4}))-([0-1]\\d)-(([0-3]\\d)|(\\d))\\s((\\d)|([0-1]\\d)|(2[0-4])):[0-5][0-9]:[0-5][0-9].*$)"
                  }
                }
              }
            ]
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "type": "datasources",
          "name": "sampleLinuxPerfCollection1",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "kind": "LinuxPerformanceCollection",
          "properties": {
            "state": "Enabled"
          }
        },
        {
          "apiVersion": "2015-03-20",
          "name": "[concat(parameters('applicationDiagnosticsStorageAccountName'),parameters('workspaceName'))]",
          "type": "storageinsightconfigs",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "properties": {
            "containers": [
              "wad-iis-logfiles"
            ],
            "tables": [
              "WADWindowsEventLogsTable"
            ],
            "storageAccount": {
              "id": "[variables('diagnosticsStorageAccount')]",
              "key": "[listKeys(variables('diagnosticsStorageAccount'),'2015-06-15').key1]"
            }
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "location": "[parameters('location')]",
          "name": "[variables('Updates').Name]",
          "type": "Microsoft.OperationsManagement/solutions",
          "id": "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.OperationsManagement/solutions/', variables('Updates').Name)]",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "properties": {
            "workspaceResourceId": "[resourceId('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          },
          "plan": {
            "name": "[variables('Updates').Name]",
            "publisher": "Microsoft",
            "product": "[Concat('OMSGallery/', variables('Updates').GalleryName)]",
            "promotionCode": ""
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "location": "[parameters('location')]",
          "name": "[variables('AntiMalware').Name]",
          "type": "Microsoft.OperationsManagement/solutions",
          "id": "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.OperationsManagement/solutions/', variables('AntiMalware').Name)]",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "properties": {
            "workspaceResourceId": "[resourceId('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          },
          "plan": {
            "name": "[variables('AntiMalware').Name]",
            "publisher": "Microsoft",
            "product": "[Concat('OMSGallery/', variables('AntiMalware').GalleryName)]",
            "promotionCode": ""
          }
        },
        {
          "apiVersion": "2015-11-01-preview",
          "location": "[parameters('location')]",
          "name": "[variables('SQLAssessment').Name]",
          "type": "Microsoft.OperationsManagement/solutions",
          "id": "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.OperationsManagement/solutions/', variables('SQLAssessment').Name)]",
          "dependsOn": [
            "[concat('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          ],
          "properties": {
            "workspaceResourceId": "[resourceId('Microsoft.OperationalInsights/workspaces/', parameters('workspaceName'))]"
          },
          "plan": {
            "name": "[variables('SQLAssessment').Name]",
            "publisher": "Microsoft",
            "product": "[Concat('OMSGallery/', variables('SQLAssessment').GalleryName)]",
            "promotionCode": ""
          }
        }
      ]
    }
  ],
  "outputs": {
    "workspaceName": {
      "type": "string",
      "value": "[parameters('workspaceName')]"
    },
    "provisioningState": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceName')), '2015-11-01-preview').provisioningState]"
    },
    "source": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceName')), '2015-11-01-preview').source]"
    },
    "customerId": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceName')), '2015-11-01-preview').customerId]"
    },
    "sku": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceName')), '2015-11-01-preview').sku.name]"
    },
    "retentionInDays": {
      "type": "int",
      "value": "[reference(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceName')), '2015-11-01-preview').retentionInDays]"
    },
    "immediatePurgeDataOn30Days": {
      "type": "bool",
      "value": "[reference(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceName')), '2015-11-01-preview').features.immediatePurgeDataOn30Days]"
    },
    "portalUrl": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceName')), '2015-11-01-preview').portalUrl]"
    }
  }
}
```

As owner of the workspace, you can soon tell whether you are able to see or manage sensitive data. If so, you can set up access control.

## Set up access control

Not everyone should have access to the logs and be able to build queries. You can control access assigning groups to build in roles or use configure custom role based on your particular needs.

### Using built-in roles for Log Analytics workspaces

Azure has two built-in user roles for Log Analytics workspaces:

*   Log Analytics Reader
*   Log Analytics Contributor

Members of the _Log Analytics Reader_ role can:

*   View and search all monitoring data.
*   View monitoring settings, including viewing the configuration of Azure diagnostics on all Azure resources.

Members of the _Log Analytics Contributor_ role can:

*   Includes all the privileges of the _Log Analytics Reader role_, allowing the user to read all monitoring data
*   Create and configure Automation accounts (permission must be granted at the resource group or subscription scope)
*   Add and remove management solutions (permission must be granted at the resource group or subscription scope)
*   Read storage account keys
*   Configure the collection of logs from Azure Storage
*   Edit monitoring settings for Azure resources, including
    *   Adding the VM extension to VMs
    *   Configuring Azure diagnostics on all Azure resources

The following PowerShell commmand shows how you can set up a group named _Log Analytics Reader Group_.

```powershell
Install-Module azuread
New-AzureADGroup -Description "Log Analytics Reader Group" -DisplayName "Log Analytics Reader Group" -MailEnabled $false -SecurityEnabled $true -MailNickName "LogAnalyticsReaderGroup"
```
You can then assign users to the group to managed the access.

### Using custom roles for Log Analytics workspaces

You may want to set up a [custom role that combines permissions](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/manage-access#custom-role-examples). This provides more granular control of who accesses data in Log analytics workspace. You can fine tune who has permissions to the data in workspace using [workspace permissions](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/manage-access#manage-access-using-workspace-permissions), which you can can combine into custom roles. See [Azure custom roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles).

### Role based access control best practices

Assign roles to security groups instead of individual users to reduce the number of assignments.

The following script sets a group named **Log Analytics Reader Group** to the resource group.

```powershell
Install-Module azuread
New-AzureADGroup -Description "Log Analytics Reader Group" -DisplayName "Log Analytics Reader Group" -MailEnabled $false -SecurityEnabled $true -MailNickName "LogAnalyticsReaderGroup"
```

Users assigned to the **Log Analytics Reader Group** in Azure Active Directory would have Log Analytics Reader permissions in the resources within the resource group.

## Set up your queries

Once you have data coming into Log Analytics, you will want to set up your queries. The art for Cloud Engineers is to build queries that provide visibility into your own cloud operations.

To get started, Azure provides some samples. To find the samples, navigate to your Log Analytics workspace. Click **Logs** in the **General** panel. You can find some example queries as shown in the following illustration.

![loganalyticsexamplequeries](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/loganalyticsexamplequeries.png?resize=585%2C408&ssl=1)

### Building queries in Log Analytics workspace

When you examine the queries, you can see they are very SQL-like. You can use [Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer) to explore the tables and columns available to you.

Azure Monitor Logs is based on >Azure Data Explorer, and log queries are written using the same Kusto query language (KQL). If you are familiar with SQL, Kusto queriers will be similar (see [SQL to Kusto query translation](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/sqlcheatsheet) for more details).

As an example, the following query counts how many rows in the Logs table have the value of the Level column equals the string Critical:

```text
Logs
| where Level == "Critical"
| count
```

## Next steps

In this article, you learned how to set up Log Analytics Workspace and how to retrieve the workspace.

> As you build each resource, you will want to consider how you will monitor and then send data to Log Analytics for your Cloud Engineers to analyze. You will want to associate your resources to Log Analytics as you deploy each resource.

Next steps:

*   Set up Security Center, as described in our next blog post.
*   Learn about how to [Collect Azure platform logs in Log Analytics workspace in Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/resource-logs-collect-workspace)
*   Use a [resource manager template to enable log alert rules](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/resource-manager-alerts-log)
*   Use a [resource manager template to enable your virtual machines to work with the workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/resource-manager-vminsights)
*   Use a resource manager template to enable Azure Monitor to work with the workspace
*   Use a [resource manager template to enable your AKS cluster to work with the workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/resource-manager-container-insights)
*   Explore [Azure Policy definitiona for Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/policy-samples)
*   Explore [Azure Monitor for containers overview](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-overview)

## Resources

*   [Overview of log queries in Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/log-query/log-query-overview#what-is-log-analytics).
*   [Manage access to log data and workspaces in Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/manage-access#custom-role-examples).
*   [Manage app and resource access using Azure Active Directory groups](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-manage-groups).
*   [Using Azure Monitor Logs with Azure Kubernetes Service (AKS)](https://blog.coffeeapplied.com/using-azure-monitor-logs-with-azure-kubernetes-service-aks-c0b0625295d1).
*   [Getting started with Kusto](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/concepts/).

