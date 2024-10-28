# Setting up Management Group for production in enterprise

![org1](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/org1.png?resize=294%2C265&ssl=1)Once you have set up your first subscription, you can set up your [Management Group](https://docs.microsoft.com/en-us/azure/governance/management-groups/overview).

In Azure, management groups are a way to group your subscriptions. When you apply policies and governance to your management group, all of the subscriptions within a management group automatically inherit the conditions applied. Enterprises want management groups as a way to scale your operations no matter how many subscriptions you may have.

For example, you may want to restrict the regions available for your resources to those within a particular region. A policy that reflects that can be applied to a management group and will automatically be applied to all management groups, all subscriptions, and all resources under that management group.

> IMPORTANT: All subscriptions within a single management group must trust the same Azure Active Directory tenant.

## Managing Policies and Role Base Access Controls at scale

As an enterprise admin, you will need to manage multiple subscriptions. And you will want to be able to show how each subscription meets the goals of your compliance. There are two tools that help you manage these in Azure.

*   [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview) helps to enforce organizational standards and to assess compliance at-scale. Use Policies to impplement governance for resource consistency, regulatory compliance, security, cost, and management.
*   [Azure role-based access control](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview) is an authorization system built on [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview) that provides fine-grained access management of Azure resources.

Each of these can be deployed in management group and automatically inherited by the subscriptions and resources.

In addition, you can apply resource templates to management groups.

## Architecture considerations

Each Azure Active Directory directory is given a single top-level management group called the “Root” management group. This root management group is built into the hierarchy to have all management groups and subscriptions fold up to it.

You can create a heirarchy that you can apply a policy, for example the regions in available for resources. This policy will inherit onto all the subscriptions that are descendants of that management group and will apply to all VMs under those subscriptions.

You can slso use management groups is to provide user access to multiple subscriptions. By moving multiple subscriptions under that management group, you can create one role-based access control (RBAC) assignment on the management group.

The following illustration shows a simple heirarchy with policies applied to the Root Management Group and others.

![org](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/org.png?resize=748%2C601&ssl=1)

## Create a management group

The [Azure AD Global Administrator needs to elevate themselves](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin) to the User Access Administrator role of this root group initially. After elevating access, the administrator can assign any RBAC role to other directory users or groups to manage the hierarchy. As administrator, you can assign your own account as owner of the root management group.

The [documentation](https://docs.microsoft.com/en-us/azure/governance/management-groups/create) shows how you can set up a Management Group using the portal, PowerShell, and the Azure CLI.

### Sample PowerShell cmdlet to set up your Azure management groups

You may want to use scripts so you can support subscriptions and resources using your management groups at scale that support a consistent naming convention. The following code creates a root management group.

```Powershell
#Requires -Version 7.0
#Requires -Modules PowerShellGet, Az.Resources
<#
.SYNOPSIS
  Creates a management group
.DESCRIPTION
  Creates a management group
.PARAMETER OrganizationName
  Used to create the management group name
.OUTPUTS
  If the creation was successful, it return the management group name; otherwise, null.
.NOTES
  Version:        1.0
  Author:         Bruce Kyle
  Creation Date:  6/25/2020
  Purpose/Change: Initial script development
  Copyright 2020 Stretegic Datatech LLC
  License: MIT https://opensource.org/licenses/MIT

.EXAMPLE
  .\New-ManagementGroup.ps1 -OrganizationName "Strategic Datatech LLC"
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory)] [string] $OrganizationName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $ManagementGroupName = $OrganizationName -replace '\s',''
    $ManagementGroupName = $ManagementGroupName'Root'
    Write-Host "Creating management group for $OrganizationName"
    New-AzManagementGroup -GroupName $ManagementGroupName -DisplayName "$OrganizationName Root Group"
}
catch
{
    Write-Host "An error occurred creating management group:"
    Write-Host $_
    $ManagementGroupName = null;
}

return $ManagementGroupName
```

Next, use the root management group to create a new sub group for developers. The following code shows how you can create a subgroup.

```powershell
#Requires -Version 7.0
#Requires -Modules PowerShellGet, Az.Resources
<#
.SYNOPSIS
  Creates a management group
.DESCRIPTION
  Creates a management group
.PARAMETER OrganizationName
  Used to create the management group name
.OUTPUTS
  If the creation was successful, it return the management group name; otherwise, null.
.NOTES
  Version:        1.0
  Author:         Bruce Kyle
  Creation Date:  6/25/2020
  Purpose/Change: Initial script development
  Copyright 2020 Stretegic Datatech LLC
  License: MIT https://opensource.org/licenses/MIT

.EXAMPLE
  $OrganizationName = "Strategic Datatech LLC"
  $TeamName = "Dev"
  $ParentManagementGroupName = @(.\New-ManagementGroup.ps1 -OrganizationName $OrganizationName)
  .\New-ManagementSubGroup.ps1 -ParentManagementGroup $ParentManagementGroupName `
      -OrganizationName $OrganizationName -TeamName $TeamName
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory)] [string] $ParentManagementGroup,
    [Parameter(Mandatory)] [string] $OrganizationName,
    [Parameter(Mandatory)] [string] $TeamName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    $OrganizationName = $OrganizationName -replace '\s',''
    $TeamName = $TeamName -replace '\s',''
    
    $parentGroup = Get-AzManagementGroup -GroupName $ParentGroupName
    $groupName = ({0}{1} -f  $OrganizationName,$TeamName)
    Write-Host "Creating management group $groupName "
    New-AzManagementGroup -GroupName $groupName -DisplayName "$TeamName Group" `
        -ParentId $parentGroup.id
}
catch
{
    Write-Host "An error occurred creating management group:"
    Write-Host $_
    $ManagementGroupName = null;
}

return $ManagementGroupName
```

Finally, use the following code to set the subscription to your subgroup.

```powershell
#Requires -Version 7.0
#Requires -Modules PowerShellGet, Az.Resources
<#
.SYNOPSIS
    Sets the subscription to a management group 
.DESCRIPTION
    Sets the subscription to a management group 
.PARAMETER ManagementGroupName
    Used to create the management group name
.PARAMETER SubscriptionID
    The subscription id
.NOTES
  Version:        1.0
  Author:         Bruce Kyle
  Creation Date:  6/25/2020
  Purpose/Change: Initial script development
  Copyright 2020 Stretegic Datatech LLC
  License: MIT https://opensource.org/licenses/MIT

.EXAMPLE
  .\Set-ManagementGroup.ps1 -ManagementGroupName $ManagementGroupName `
    -SubscriptionId 9f241d6e-16e2-4b2b-a485-cc546f04799b
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory)] [string] $ManagementGroupName,
    [Parameter(Mandatory=$false)] [string] $SubscriptionId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    if ($SubscriptionId -eq $null) {
        $SubscriptionId = (Get-AzContext).Subscription.SubscriptionId
    }
    Write-Host "Assigning subscription '$SubscriptionId' to management group '$ManagementGroupName'"
    New-AzManagementGroupSubscription -GroupName $ManagementGroupName -SubscriptionId $SubscriptionId
}
catch
{
    Write-Host "An error occurred assigning management group:"
    Write-Host $_
    $OrganizationName = null;
}
```

You have now created a management group, a sub-management group and and assigned the subscription to the sub-management group.

In our next post, you will learn how to create policies that you want to apply to all the subscriptions in your management group using Azure Blueprints.

## Next steps

You will want to learn more about:

*   [Azure Policy built-in policy](https://docs.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies) that you can apply to your management group
*   Azure built-in roles that provide a good starting point to assign to users, groups, service principals, and managed identities.
*   [Azure Blueprints](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview) that provide sets of pre-built policies, role based access controls, and Rsource Manager templates that you can apply to a management group to support specific compliance initiatives, such as ISO, PCI, NIST and many others.

## References

*   [Organize your resources with Azure management groups](https://docs.microsoft.com/en-us/azure/governance/management-groups/overview)

### Share this:

*   [Twitter](https://azuredays.com/2020/06/29/setting-up-management-group-for-production-in-enterprise/?share=twitter&nb=1 "Click to share on Twitter")
*   [Facebook](https://azuredays.com/2020/06/29/setting-up-management-group-for-production-in-enterprise/?share=facebook&nb=1 "Click to share on Facebook")


[Setting up your enterprise Azure subscription administrators](/2020/06/04/setting-up-your-enterprise-azure-subscription-administrators/?relatedposts_hit=1&relatedposts_origin=2309&relatedposts_position=1&relatedposts_hit=1&relatedposts_origin=2309&relatedposts_position=1 "Setting up your enterprise Azure subscription administrators")June 4, 2020In "Azure"

[Setting up Security Center for production in enterprise](/2020/06/18/setting-up-security-center-for-production-in-enterprise/?relatedposts_hit=1&relatedposts_origin=2309&relatedposts_position=2&relatedposts_hit=1&relatedposts_origin=2309&relatedposts_position=2 "Setting up Security Center for production in enterprise")June 18, 2020In "Azure"
