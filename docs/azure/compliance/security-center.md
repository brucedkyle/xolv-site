# Setting up Security Center for production in enterprise

<img style="float: right; width: 20%; padding-inline: 6px" src="https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/icon-security-241-security-center.png?resize=166%2C166&ssl=1">Security Center provides out of the box policies and a dashboard to identify possible security issues with your subscription.

To start with Security Center has a good set of policies that will help you do basic audits and provide security alerts.

## Use Security Center to meet your cloud requirements

In this article, you will be able to meet the following requirements:

*   Set up ways for your security team, developers, and operations to quickly audit subscriptions.
*   Mitigate security issues

In a later post, you will learn how to add additional policies, set up a management group as a way to manage policies across multiple subscriptions.

## Definitions

First some definitions.

*   **Management Group**. This is a logical container that allow Azure administrators to manage access, policy, and compliance across multiple Azure Subscriptions.
*   **Security Center.** A unified infrastructure security management system that strengthens the security posture of your data centers. And it provides advanced threat protection across your hybrid workloads in the cloud – whether they’re in Azure or not.
*   **Policy**. A feature of Azure that helps you enforce organizational standards and to assess compliance at-scale.
*   **Scope**. In this article a scope refers to what level you assign permissions. In this article you can assign permissions at the subscription level, the resource group level and to individual resources.
*   **Log Analytics.** The repository that receives the data from Security Center for alerting and analysis.

## About Security Center

Security Center sets up Azure Policies that provide guardrails for your subscription. Security Center comes with a set of default policies. At a high level, the policies check:

*   Failure to deploy system updates on virtual machines (VMs).
*   Unnecessary exposure to the Internet through public-facing endpoints.
*   Unencrypted data in transit or storage.

You can customize your security policy to focus your own areas of emphasis. For example:

*   Add check for web application firewalls
*   Add storage encryption
*   Apply your policy to multiple Azure subscriptions.

And then, it provides a dashboard that gives you visibility into your security posturea at a glance. The following illustration shows a Security Center dashboard.

![securitycenterdashboard](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/securitycenterdashboard.png?resize=748%2C396&ssl=1)

Gain visibility across your environment to verify compliance with regulatory requirements, such as CIS, PCI DSS, SOC, and ISO.

It also provides for suggestions and in many cases, provides a way to immediately remedy the issue.

Use the dashboard to drill into specific requirements. In many cases, Security Center provides a single click solution to remediate the issue. For others, you will need deeper solution. The following illustration shows an example summary of the solutions to make a virtual machine more secure.

![vmsecurity](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/vmsecurity.png?resize=748%2C577&ssl=1)

Many of the resources were misconfigured when they were built, often using the defaults in the Azure portal. This means that is it easy for your users and cloud administrators to create resoources that may not be as protected as you want.

> The default configurations of many resources provided in the portal will not pass a rigorous security audit. As enterprise administrators you will need to provide other ways for your users to create those resources, such as through deployment in Azure DevOps of sets of resources that will pass your audits.

This blog will highlight ways to provide your users with compliant resources and ways for you to build an approval process within your organization. But for now, you can look to:

*   Deployment of compliant ARM templates (or Terraform templates) through Azure DevOps
*   Deployment of resources, policies, and using Azure Blueprints

But first, you will need to set up Security Center Standard.

## Upgrade Security Center to Standard

Security Center provides a good set of policies and dashboards through the free portal. But for enterprise and for production, you will want the [standard version](https://docs.microsoft.com/en-us/azure/security-center/security-center-pricing).

As explained in the documentation: “The standard tier also adds threat protection capabilities, which use built-in behavioral analytics and machine learning to identify attacks and zero-day exploits, access and application controls to reduce exposure to network attacks and malware, and more. In addition, standard tier adds vulnerability scanning for your virtual machines. You can try the standard tier for free. Security Center standard supports Azure resources including VMs, Virtual machine scale sets, App Service, SQL servers, and Storage accounts. If you have Azure Security Center standard, you can opt out of support based on resource type.”

Review [Security Center pricing](https://azure.microsoft.com/en-us/pricing/details/security-center/). When you upgrade to the Standard tier of Azure Security Center, you are automatically enrolled and Security Center by default protects all your resources unless you explicitly decide to opt-out.

Some of the most important features provided by Security Center standard, are:

*   [**Just in Time VM access**](https://docs.microsoft.com/en-us/azure/security-center/security-center-just-in-time) to virtual machines. Your admins and users will occasionally need to access a VM inside the virtual network. JIT closes down the RDP and SSH ports and opens them only to the users who are authorized.
*   [Adaptive application controls](https://docs.microsoft.com/en-us/azure/security-center/security-center-adaptive-application) is an intelligent, automated, end-to-end solution from Azure Security Center which helps you white-list which applications can run on your Azure and non-Azure machines (Windows and Linux).
*   [Adaptive Network Hardening](https://docs.microsoft.com/en-us/azure/security-center/security-center-adaptive-network-hardening) improves your security posture by hardening the network security group (NSG) rules, based on the actual traffic patterns
*   [**Security alerts**](https://docs.microsoft.com/en-us/azure/security-center/security-center-alerts-overview) are the notifications that Security Center generates when it detects threats on your resources.
*   [**Threat protection**](https://docs.microsoft.com/en-us/azure/security-center/threat-protection). You can enable threat protection for **Azure Storage accounts** at either the subscription level or resource level. You can enable threat protection for **Azure SQL Database SQL servers** at either the subscription level or resource level. You can enable threat protection for **Azure Database for MariaDB/ MySQL/ PostgreSQL** at the resource level only.
*   Microsoft Defender ATP

Security Center comes with a set of [built in policy definitions](https://docs.microsoft.com/en-us/azure/security-center/policy-samples) that are discussed in a following section in more detail.

But first, you should follow the documentation to learn how to [upgrade to Security Center Standard](http://Quickstart: Onboard your Azure subscription to Security Center Standard) in the portal. Or you can automate the process to onboard new subscriptions to use Security Center standard as explained in the next section.

## Onboard Security Center using PowerShell

In the previous article, you learned how to [set up Log Analytics](https://azuredays.com/2020/06/15/setting-up-log-analytics-workspace-for-production-in-enterprise/). Log Analytics can act as a central repository for your Security Center data and is a prerequisite for this step.

Get the log analytics workspace ID from the PowerShell cmdlet that you used to set up the workspace, or you can get it from the portal.

To find your workspace, open the portal and in the search bar at the top of the page, type Log Analytics to see the list of your workspaces as shown in the following illustration.

![workspace](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/workspace.png?resize=748%2C210&ssl=1)

Then click on the workspace that you want Security Center to conntect to. The workspace ID is shown in the Overview section.

![workspaceid](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/workspaceid.png?resize=748%2C170&ssl=1)

Next, use the following cmdlet to set your subscription to use Security Center standard, sets up your security administrator to receive email and phone for security alerts, and attaches the policy to your Log Analytics workspace.

```powershell
#Requires -Version 7.0
#Requires -Modules PowerShellGet, Az.Resources, Az.Security
<#
.SYNOPSIS
  Sets up Security Center and the admin alerts for the subscription
.DESCRIPTION
  Automatically sets Security Center standard tier to the subscription.
.PARAMETER OrganizationName
    Used to create the management group name
.PARAMETER LogAnalyticsWorkplaceId
    The resource ID for the Log Analytics workplace
.PARAMETER SecurityAdminEmail  
    The email for security notifications
.PARAMETER SecurityAdminPhone
    The phone number to send security notifications
.OUTPUTS
  If the creation was successful, it return the management group name; otherwise, null.
.NOTES
  Version:        1.0
  Author:         Bruce Kyle
  Creation Date:  6/18/2020
  Purpose/Change: Initial script development
  Copyright 2020 Stretegic Datatech LLC
  License: MIT https://opensource.org/licenses/MIT

.EXAMPLE
  .\New-ManagementGroup.ps1 "Strategic Datatech LLC"
.EXAMPLE
$SubscriptiondID = 9f241d6e-16e2-4b2b-a485-cc546f04799b
$OrganizationName = "Strategic Datatech LLC"
$SecurityAdminEmail = "security@strategicdatatech.com"
$SecurityAdminPhone = 2065557878
$workspaceID = @(.\Add-LogAnalytics.ps1 -SubscriptionID $SubscriptionID -OrganizationName $OrganizationName)
.\Set-SubscriptionSecurity.ps1 SubscriptionID $SubscriptionID `
    -LogAnalyticsWorkplaceId $workspaceID `
    -SecurityAdminEmail $SecurityAdminEmail `
    -SecurityAdminPhone $SecurityAdminPhone
#>

## Run as Admin
[CmdletBinding()]
Param(
    [Parameter(Mandatory)] [string] $SubscriptionID,
    [Parameter(Mandatory)] [string] $LogAnalyticsWorkplaceId,
    [Parameter(Mandatory)] [string] $SecurityAdminEmail,
    [Parameter(Mandatory)] [string] $SecurityAdminPhone
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Set-AzContext -Subscription $SubscriptionID
Register-AzResourceProvider -ProviderNamespace 'Microsoft.Security'

Set-AzSecurityPricing -Name "default" -PricingTier "Standard"

echo "Subscriptions has workspace id: $workspaceID"

Set-AzSecurityWorkspaceSetting -Name "default" `
    -Scope "/subscriptions/$SubscriptionID" `
    -WorkspaceId $LogAnalyticsWorkplaceId

Set-AzSecurityAutoProvisioningSetting -Name "default" -EnableAutoProvision

Set-AzSecurityContact -Name "default1" -Email $SecurityAdminEmail -Phone $SecurityAdminPhone -AlertAdmin -NotifyOnAlert

Register-AzResourceProvider -ProviderNamespace 'Microsoft.PolicyInsights'
$Policy = Get-AzPolicySetDefinition | where {$_.Properties.displayName -EQ '[Preview]: Enable Monitoring in Azure Security Center'}
New-AzPolicyAssignment -Name 'ASC Default <d07c0080-170c-4c24-861d-9c817742786c>' -DisplayName 'Security Center Default $SubscriptionID ' -PolicySetDefinition $Policy -Scope '/subscriptions/$SubscriptionID '
```

### Review the Security Center built-in policies

Security Center comes with a set of built in [Policies for Security Center](https://docs.microsoft.com/en-us/azure/security-center/policy-samples). Most of the policies are instantly recongizable. For example:

*   [System updates should be installed on your machines](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F86b3d65f-7626-441e-b690-81a8b71cff60)
*   [Role-Based Access Control (RBAC) should be used on Kubernetes Services](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Fac4a19c2-fa67-49b4-8ae5-0b2e78c49457)
*   [Security Center standard pricing tier should be selected](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Fa1181c5f-672a-477a-979a-7d58aa086233)
*   [Subnets should be associated with a Network Security Group](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Fe71308d3-144b-4262-b144-efdc3cc90517)
*   [There should be more than one owner assigned to your subscription](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F09024ccc-0c5f-475e-9457-b7c0d9ed487b)
*   [Vulnerabilities in container security configurations should be remediated](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Fe8cbc669-f12d-49eb-93e7-9273119e9933)
*   [Vulnerabilities in security configuration on your machines should be remediated](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Fe1e5fd5d-3e4c-4ce1-8661-7d1873ae6b15)
*   [External accounts with owner permissions should be removed from your subscription](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Ff8456c1c-aa66-4dfb-861a-25d127b775c9)

Many of the policies can be used out of the box. But a few will need to be updated based on your own compliance needs. It is a best practice to use your infrastructure as code practices (checking the changes in policies as code into Azure DevOps and deploying them through DevOps.)

For example, as you learned in the previous blog post, [Setting up your enterprise Azure subscription administrators](https://azuredays.com/2020/06/04/setting-up-your-enterprise-azure-subscription-administrators/), multifactor authentication should be required on all users, except for two emergency owners. Yet the default policy applied by Security Center provides [MFA should be enabled on accounts with owner permissions on your subscription](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Faa633080-8b72-40c4-a2d7-d00c03e80bed). In this rare case, this means you need to [create a custom policy in Security Center](https://docs.microsoft.com/en-us/azure/security-center/custom-security-policies).

Also, you will want to be aware of the following:

> NOTE: When you deploy new resources, the Security Center dashboard will not update immediately. You will need to wait a few minutes (20 minutes to an hour) to receive reports on the new resources. Also, some resources that have been deleted may continue to impact your score. So review the dashboard information closely to determine the actual impact on your systems.

## Next steps

In this article, you learned the basics of Security Center, its features, the importance of using Security Center standard in production environments, and how you can connect it to Log Analytics.

Next, you will want to dive deper to:

*   [Strengthen security posture](https://docs.microsoft.com/en-us/azure/security-center/security-center-intro#strengthen-security-posture)
*   [Remediate recommendations in Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/security-center-remediate-recommendations)
*   See more about [Working with security policies](https://docs.microsoft.com/en-us/azure/security-center/tutorial-security-policy)
*   Download and review [Security best practices for Azure solutions](https://azure.microsoft.com/en-us/resources/security-best-practices-for-azure-solutions/)

If you want to do fine-grained selection of the tiers available for each of the service, you can [adapt an Azure ARM template to deploy and update Security Center tiers](https://github.com/azsec/scaf-azure-arm-templates/tree/master/AzureSecurityCenter).

## References

*   [Security Center pricing](https://azure.microsoft.com/en-us/pricing/details/security-center/)
*   [Azure Security Center documentation](https://docs.microsoft.com/en-us/azure/security-center/)
