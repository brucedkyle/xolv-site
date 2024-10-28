# Setting up your enterprise Azure subscription administrators

![azureadministratorpng](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/azureadministratorpng.png?resize=222%2C222&ssl=1)Microsoft makes it easy to get started using Azure — sign up for a free subscription and get started. The tutorial show you how to use the portal to create virtual machines, storage, backups. All good.

And then it comes time to take your applications into production. You may realize that you need to show auditors your security methods. And you want to be sure to protect your customer data. Or you may have cloud sprawl and want to control costs.

And you have had a good conversations about your requirements. What then?

This article shows you how to get your subscription up and running using some important best practices for your administrators. It shows how to set up Security Center and how to set up policies that can be used to help your security team validate that you are using best practices.

This step is part [Ready Phase](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/) of the Cloud Adoption Framework.

## Definitions

Let’s start with some definitions and some links on where to learn more about each.

*   **Tenant**. A tenant represents an organization in Azure Active Directory. It’s a dedicated Azure AD service instance that an organization receives and owns when it signs up for a Microsoft cloud service such as Azure, Microsoft Intune, or Microsoft 365. Each Azure AD tenant is distinct and separate from other Azure AD tenants.
*   **Subscription**. This is essentially a way to manage and bill a set of resources. Permissions are granted at the subscription, resource group and resource levels. Billing is provided as part of signing up for a subscription.
*   **Resource Groups**. A group of resources. A resource is like a storage account. A virtual machine is actually several resources, including the compute and its virtual network.
*   **Policy**. A feature of Azure that helps you enforce organizational standards and to assess compliance at-scale.
*   **Scope**. In this artifcle a scope refers to what level you assign permissions. In this article you can assign permissions at the subscription level, the resource group level and to individual resources.
*   **Multi-factor Authentication (MFA)**. MFA can be implemented in a cloud-only setting, which is what is described in this article. But [MFA can also be set up](https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-getstarted) with hybrid identities using Azure AD Connect, [Azure MFA with RADIUS Authentication](https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-nps-extension).
*   **Administrators**. In this article, the admins refer to the subscription owners who can see everything, create just about anything and add and remove users. There are two kinds of administrators discussed. The first are e_mergency admins,_ sometimes known as _break-glass admins,_ who can log in when MFA fails or some other emergency. The other is the global admin or subscription owner who is required to log in using MFA.

A tenant can have many subscriptions and management groups. A subscription is tied to a single management group. Resources, such as virtual machines and storage accounts, are grouped together in a resource group. A subscription can have many management groups.

## Requirements

In this article, you will be able to meet the following requirements:

*   An Active Directory tenant, that can register and manage apps, have access to Microsoft 365 data, and deploy custom Conditional Access and tenant restrictions.
*   Set up emergency administrators, to provide access to the subscription in break-glass scenarios, such as domain name lost, data center fails, Active Directory no longer syncs, product hosted in subscription sold to another company. These users do not have multifactor authentication.
*   Define users and admin roles suitable in your organization.
*   Set up multifactor authentication for developers, security admins, operations admins, managers — anyone who has access to the subscription itself.

Let’s begin by choosing your Azure Active Directory tenant.

## Choose your tenant

This section applies if you are managing your own subscription. If you are using a Cloud Solution Provider for your subsription, the CSP will control your tenant and has added your users to administer the subscription.

Start at the tenant in Azure Active Directory. Each subscription is tied to a single tenant. And the admins of that tenant control who has access to add/remove users and groups, who can create resources, and the control each user has.

If you have Microsoft 365, you already have a tenant.

![tenant](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/tenant.png?resize=708%2C339&ssl=1)

_(Illustration from [Sign up for an Azure subscription with your Office 365 account)](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/office-365-account-for-azure-subscription#more-about-azure-and-office-365-subscriptions)_

Your tenant is important. The documents describes how tightly a tenant is tied to the subscription:

> An Azure subscription has a trust relationship with Azure Active Directory (Azure AD). A subscription trusts Azure AD to authenticate users, services, and devices.
> 
> Multiple subscriptions can trust the same Azure AD directory. Each subscription can only trust a single directory.
> 
> If your subscription expires, you lose access to all the other resources associated with the subscription. However, the Azure AD directory remains in Azure. You can associate and manage the directory using a different Azure subscription.
> 
> All of your users have a single _home_ directory for authentication. Your users can also be guests in other directories. You can see both the home and guest directories for each user in Azure AD.
> 
> _(See [Associate or add an Azure subscription to your Azure Active Directory tenant](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory))_

If you start out with a subscription tied to a tenant and then change your mind about who the owners of the subscription should be (in other words, set the subscription to a new tenant) here’s a list of what breaks:

*   Users that have been assigned roles using RBAC will lose their access
*   Service Administrator and Co-Administrators will lose access
*   If you have any key vaults, they’ll be inaccessible and you’ll have to fix them after association
*   If you have any managed identities for resources such as Virtual Machines or Logic Apps, you must re-enable or recreate them after the association
*   If you have a registered Azure Stack, you’ll have to re-register it after association
*   In particular, moving your Azure Kubernetes Service (AKS) cluster to a different subscription, or moving the cluster-owning subscription to a new tenant, causes the cluster to lose functionality due to lost role assignments and service principal’s rights.

So the first steps are to create a new subscription:

**Step 1**. Create a subscription using one of these techniques:

*   [Create your first subscription](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/initial-subscriptions).
*   You can get one through a [Cloud Solution Provider](https://azure.microsoft.com/en-us/overview/what-is-a-cloud-provider/), who provisions your subscription.
*   See [Create an additional Azure subscription](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/create-subscription) if you have an Enterprise Agreement (EA), Microsoft Customer Agreement (MCA), Microsoft Partner Agreement (MPA). You can even set up your subscription using scripts.

**Step 2**. [Associate that subscription with your tenant](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory).

The admin of the new tenant will control who the subscription owners and admins are, who can add and remove users and groups, who can associate another tenant, who must use multifactor authentication and who the emergency admins are. And who can associate the subscription to a management group.

## Set up your admins

At the heart of the tenant are the emergency admins. These credentials are the ones you lock in a safe somewhere. They are the only ones who have access to the subscription without multifactor authentication.

Here’s the steps to set up your admins. You will create three accounts: two without multi-factor authentication and one with MFA.

1.  Create [two user accounts](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/add-users-azure-active-directory) perhaps named something like emergencyadministrator1@yourtenantname.onmicrosoft.com and emergencyadministrator2@yourtenantname.onmicrosoft.com. These users are your [emergency access account admins](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-emergency-access). Use a password that is unreasonably long and complex, such as two [Guid](https://guidgenerator.com/). These two accounts will NOT require multifactor authentication and you will not be using them to log in once you have set up the subscription owner.
2.  Log in using emergencyadministrator1@yourtenantname.onmicrosoft.com
3.  Create a new user account and assign that user to the Global owner role.
4.  Log out of emergencyadministrator1.
5.  From the new global owner account, sign up for Azure AD Priveleged Identity Management account for [Azure AD Premium P2](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-get-started-premium) and assign the global owner to Priveleged Identity Management. Assign the global owner actual user account to Azure AD Premium.
6.  Take the emergency admin user names and passwords and put them in a physical safe somewhere, hopefully never to be used again.
7.  Create [a group](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal) of users named **Subscription Owners**. Add the emergency users to the group and grant the group Owner permissions to the subscription. In a following step, you will add [Require all users to have MFA except for the emergency owners.](https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-userstates)

### Some notes on setting up the admin

There will be an additional cost per user for the Azure AD Priveleged Identity Management. Can be purchased based on how many users have Priveleged Identity Management. For more information, see [Critical items to do right now](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-admin-roles-secure#stage-1-critical-items-to-do-right-now).

It is a best practice for a password for an emergency access account to be separated into two or three parts, written on separate pieces of paper, and stored in secure, fireproof safes that are in secure, separate locations.

Note that you will want to set up to monitor sign-in and audit logs of the emergency accounts once you have set up log analytics. For more details, see Monitor sign-in and audit logs.

Only Global administrators and Privileged Role administrators can delegate administrator roles. To reduce risk to your business, assign this role to the fewest possible people in your organization. You should have _three_ Global administrators.

Your two break-glass admins user names and passwords should be locked in a safe. And one who is assigned _Azure AD Premium P2_. This aligns with the policy, [A maximum of 3 owners should be designated for your subscription](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F4f11b553-d42e-4e3a-89be-32ca364cad4c).

The person who signs up for the Azure AD organization becomes a global administrator. There can be more than one global administrator at your company. Global admins can reset the password for any user and all other administrators.

## Set up Multi-factor Authentication Policy

Next the global administrator owenr should set up the multi-factor authentication policy and assign additional subscription owners or assign other admin roles that are described in a following section.

Create a Conditional Access policy for MFA. Include all users, except for the two emergency admins. See [Create a Conditional Access Policy](https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-all-users-mfa#create-a-conditional-access-policy) in the Azure Active Directory documentation for details.

Follow the steps in the documentation for setting up conditional access in MFA. As you set up the policy, take special note to:

1.  Include all users
2.  Exclude your organization’s emergency access or break-glass accounts.
3.  Under Access controls grant, require multi-factor authentication.

Now that everyone must use MFA (except for your break-glass admins), from now on you will want to grant least permissions for your adminstrators.

## Set additional administrators with limited permissions

Rather than give your admins owner access to the subacription, you can limit their roles.

As best practice, you will want to limit the administrator powers to access data and apps. See [Administrator role permissions in Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles).

Azure provides many out-of-the-box administrator roles. You can assign individual to built in administrator roles that may apply to Azure such as:

*   [Application Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#application-administrator-permissions)
*   [Application Developer](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#application-developer-permissions)
*   [Authentication Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#authentication-administrator-permissions)
*   [Azure DevOps Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#azure-devops-administrator-permissions)
*   [Azure Information Protection Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#azure-information-protection-administrator-permissions)
*   [B2C IEF Keyset Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#b2c-ief-keyset-administrator-permissions)
*   [B2C IEF Policy Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#b2c-ief-policy-administrator-permissions)
*   [Billing Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#billing-administrator-permissions)
*   [Cloud Application Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#cloud-application-administrator-permissions)
*   [Cloud Device Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#cloud-device-administrator-permissions)
*   [Compliance Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#compliance-administrator-permissions)
*   [Compliance Data Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#compliance-data-administrator-permissions)
*   [Conditional Access Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#conditional-access-administrator-permissions)
*   [Customer Lockbox access approver](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#customer-lockbox-access-approver-permissions)
*   [Device Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#device-administrators-permissions)
*   [Directory Readers](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#directory-readers-permissions)
*   [External Id User Flow Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#external-id-user-flow-administrator-permissions)
*   [External Id User Flow Attribute Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#external-id-user-flow-attribute-administrator-permissions)
*   [External Identity Provider Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#external-identity-provider-administrator-permissions)
*   [Global Administrator / Company Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#company-administrator-permissions)
*   [Global Reader](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#global-reader-permissions)
*   [Groups Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#groups-administrator-permissions)
*   [Guest Inviter](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#guest-inviter-permissions)
*   [Helpdesk Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#helpdesk-administrator-permissions)
*   [Hybrid Identity Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#hybrid-identity-administrator-permissions)
*   [Message Center Privacy Reader](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#message-center-privacy-reader-permissions)
*   [Message Center Reader](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#message-center-reader-permissions)
*   [Modern Commerce Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#modern-commerce-administrator-permissions)
*   [Network Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#network-administrator-permissions)
*   [Office Apps Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#office-apps-administrator-permissions)
*   [Password Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#password-administrator-permissions)
*   [Power BI Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#power-bi-service-administrator-permissions)
*   [Power Platform Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#power-platform-administrator-permissions)
*   [Privileged Authentication Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#privileged-authentication-administrator-permissions)
*   [Privileged Role Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#privileged-role-administrator-permissions)
*   [Reports Reader](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#reports-reader-permissions)
*   [Search Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#search-administrator-permissions)
*   [Search Editor](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#search-editor-permissions)
*   [Security Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#security-administrator-permissions)
*   [Security operator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#security-operator-permissions)
*   [Security Reader](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#security-reader-permissions)
*   [Service Support Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#service-support-administrator-permissions)
*   [User Administrator](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles#user-administrator-permissions)

Many of these roles access to view, create, or manage support tickets.

When you assign a role, it is a best practice to set up a group and assign the group to a scope, such as the subscription, resource group, or individual resources. That way, when a person can be added and removed from the group to set of resources is not changed.

Depending on how your enterprise is organizes, you might have groups similar to these:

*   Global administrators
*   Operations admistrators
*   Security administrators
*   Network administrators
*   Developers
*   Developer leads
*   Production developers

You can assign a user to a group and a group to a scope. Users have access to resources based on their group.

For example, you might [manage a group](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-manage-groups?context=azure/active-directory/users-groups-roles/context/ugr-context) by setting up a _Network Admin Group_ that has a set of users. And you might grant Network Administrator to a resource group that includes virtual networks.

Now let’s set up Log Analytics and Security Center, as you learn in our next post.

## Conclusion

In this article, you learned how to:

1.  Create or add an Azure subscription
2.  Understand how user identities are related to Microsoft 365
3.  Set up your owners, including your emergency (break-glass) subscription owners
4.  Set up multi-factor authentication for all the subscription users

## References

*   [Manage emergency access accounts in Azure AD](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-emergency-access)
*   [Administrator role permissions in Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles)
*   [Plan an Azure Multi-Factor Authentication deployment](https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-getstarted)
*   [Conditional Access: Require MFA for all users](https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-all-users-mfa)
*   [What is Azure Security Center?](https://docs.microsoft.com/en-us/azure/security-center/security-center-intro)
