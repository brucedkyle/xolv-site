# Understanding Azure Policy for regulatory compliance

![azpolicy](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/azpolicy.png?resize=218%2C213&ssl=1)Use [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview) to manage and enforce your standards for governance and compliance and to assess that compliance at scale. The idea is to set standards and to be able to demonstrated your organization is meeting your regularoty compliance goals.

In previous blog posts, you learned about setting up [Management Groups](http://azuredays.com/2020/06/29/setting-up-management-group-for-production-in-enterprise/) and [Security Center](http://azuredays.com/2020/06/18/setting-up-security-center-for-production-in-enterprise/). For management groups, you learned that policies can be applied  across multiple subscriptions. You noticed that Security Center provides a set of policies (an an policy initiative) for your subscription.

In this post, learn the basics of Azure Policy for you to manage resource consistency, regulatory compliance, security, and cost. And how Policies can be grouped together as initiatives, and how you can assign initiatives to specific regulatory compliance goals.

## What is an Azure Policy?

You can think of an _Azure Policy_ as a business rule that you want to apply to a resource. _Policy definitions_ are defined in JSON. And rules that are grouped together is called a _policy set_.

Once you have defined your Azure Policy, you apply it to a scope, such as such as [management groups](https://docs.microsoft.com/en-us/azure/governance/management-groups/overview), subscriptions, [resource groups](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview#resource-groups), or individual resources.

Importantly, when you signed up for Azure Security Center standard, you added many out of the box policies to your subscription.

But first, let’s check the policies deployed as part of Security Center.

## Explore Policies deployed by Security Center

When you installed Security Center, you installed the Security Center dashboard, andyou also added a set of Azure Policies. To view the policies, open your browser and log into Azure. Next, type **Policy** in the search bar.

![searchazurepolicy](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/searchazurepolicy.png?resize=455%2C97&ssl=1)

The Policy dashboard appears. To view the list of policy initiatives that have been added to your subscription, click **ASC Default (subscription: ).**

![policypanel](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/policypanel.png?resize=496%2C332&ssl=1)

Once you click on the **ASC Default**, view the list of policies that have been added for the ASC (Azure Security Center) initiative. Click **View definition**, as shown in the illustration.

![policyviewdefinition](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/policyviewdefinition.png?resize=429%2C156&ssl=1)

You can view each of the policies defined in the ASC initiative, which consists of a the list of Policies. Click on one that you are interested in and you can see the policy as defined in JSON. The following illustration shows the policy titled S_torage accounts should restrict network access._

![policyjson](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/policyjson.png?resize=357%2C448&ssl=1)

Click **Assign** to see how you might assign the polilcy to a scope (subscription, resource group, or resource.  Unter the tabs on the Assign policy page, you can also set whether the policy is to be enforced, which parameters to apply, and how to run a rediation step. The following illustration shows how to set **Policy enforcement** on the Basics tab.

![policyenforcement](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/06/policyenforcement.png?resize=191%2C72&ssl=1)

In this section, you learned about policies set up by Security Center, how to view the policy, and where to find the definition of the policy in JSON. In the next section, you will learn the effects of policies.

## Policy as rules

Business rules for handling non-compliant resources vary widely between organizations. Examples of how an organization wants the platform to respond to a non-complaint resource include:

*   Deny the resource change
*   Log the change to the resource
*   Alter the resource before the change
*   Alter the resource after the change
*   Deploy related compliant resources

### Kinds of policy definitions

As an administrator, you control and audit using policies that written using JSON, and are created from one of two kinds of definition:

*   **Built-in**: A set of policies that are supplied automatically by Microsoft
*   **Custom**: Policies that you can write and store in Azure

There are some interesting examples in the selection of built-in policies:

*   **Enforce tag and its value**: Enforce a tag that might be used for cross-charging consumption of a single Azure subscription.
*   Allowed regions. Enforce deployment of resources to particular regions, such as those in Europe, India, or United States.
*   **Not allowed resource types**: Restrict access to certain kinds of Azure resources.
*   **Allowed virtual machine SKUs**: Limit the series and size of virtual machines that delegated administrators can deploy.

The [Azure Policy definition structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure) contains elements in JSON for:

*   Display name
*   Description
*   Mode
*   Metadata
*   Parameters
*   Policy rule
    *   Logical evaluation
    *   Effect

### Apply a Policy effect

When you apply the policy, you apply the _Policy effect_. The effect determines what happens when the policy rule matches the resource. So, when you review an existing resource or create a resource or view, the policy is reviewed in the following order:

1.  [Disabled](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#disabled). Should the policy even be evaluated (as shown in the previous section)?
2.  [Append](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#append) or [Modify](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#modify). Should the policy add something that you specify in or modify a resource? For example, specifying allowed IPs for a storage resource.
3.  [Deny](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deny). Should the policy block the request?  For example, a rule could be set to deny that storage resource that are not georedundant.
4.  [Audit](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#audit). Create a warning event in the activity log when evaluating a non-compliant resource

When you successfully deploy a resource, you can specify:

*   [AuditIfNotExists](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#auditifnotexists) enables auditing of resources _related_ to the resource. For example, it would evaluate a Virtual Machines to determine if the Antimalware extension exists then audits when missing.
*   [DeployIfNotExists](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deployifnotexists) evaluate to determine if additional compliance logging or action is required. For example, you might evaluates SQL Server databases to determine if transparentDataEncryption is enabled. If not, then a deployment to enable is executed.

For more information, see [Understand Azure Policy effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects).

## Sample built-in policy

The following is an example of a policy provided by Microsoft, “Secure transfer to storage accounts should be enabled”.

```json
{
  "properties": {
    "displayName": "Secure transfer to storage accounts should be enabled",
    "policyType": "BuiltIn",
    "mode": "Indexed",
    "description": "Audit requirement of Secure transfer in your storage account. Secure transfer is an option that forces your storage account to accept requests only from secure connections (HTTPS). Use of HTTPS ensures authentication between the server and the service and protects data in transit from network layer attacks such as man-in-the-middle, eavesdropping, and session-hijacking",
    "metadata": {
      "version": "2.0.0",
      "category": "Storage"
    },
    "parameters": {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "The effect determines what happens when the policy rule is evaluated to match"
        },
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue": "Audit"
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
            "anyOf": [
              {
                "allOf": [
                  {
                    "value": "[requestContext().apiVersion]",
                    "less": "2019-04-01"
                  },
                  {
                    "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
                    "exists": "false"
                  }
                ]
              },
              {
                "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
                "equals": "false"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  },
  "id": "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9",
  "type": "Microsoft.Authorization/policyDefinitions",
  "name": "404c3081-a854-4457-ae30-26a93ef643f9"
}
```

The `policyRule` element says that if the field in the resource `Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly` is `false`, then apply the effect, which is provided as a parameter. The effect defaults to `Audit`.

The policy `id` is `/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9`, which you will use in the next section.

When you apply the policy, you provide it a scope (management group, subscription, or resource) and the effect.

For more information about this particular policy, see [Require secure transfer to ensure secure connections](https://docs.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer).

## Policy initiatives

The policy definitions can be grouped into an initiative. Security Center is an example of several policies tied togeather using an initiative.

Using JSON, you can group your own policies together using the [Azure Policy initiative definition structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/initiative-definition-structure), which contains elements for:

*   display name
*   description
*   metadata
*   parameters
*   policy definitions
*   policy groups (this property is part of [Regulatory Compliance](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/regulatory-compliance), explained in the next section.)

You can assign several of your own policies togeather as an initiative. In the following example, selected portions of the [_NIST SP 800-53 R4_ initiative on GitHub](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Regulatory%20Compliance/NIST80053_audit.json) includes the storage account rule used in the previous section.

```json
{
  "properties": {
      "displayName": "NIST SP 800-53 R4",
      "policyType": "BuiltIn",
      "description": "This initiative includes audit and virtual machine extension deployment policies that address a subset of NIST SP 800-53 R4 controls. Additional policies will be added in upcoming releases. For more information, visit https://aka.ms/nist80053-blueprint.",
      "metadata": {
        "version": "2.0.1",
        "category": "Regulatory Compliance"
      },  
      "policyDefinitions": [
        {
          "policyDefinitionReferenceId": "AuditSecureTransferToStorageAccounts",
          "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9",
          "parameters": {},
          "groupNames": [
            "NIST_SP_800-53_R4_SC-8(1)"
          ]
        }
      ],
      "comment": "policyDefinitionGroups go here"
  },
  "id": "/providers/Microsoft.Authorization/policySetDefinitions/cf25b9c1-bd23-4eb6-bd2c-f4f3ac644a5f",
  "name": "cf25b9c1-bd23-4eb6-bd2c-f4f3ac644a5f"
}
```

Note that `policyDefinitionId` refers to the resource id `/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9` of the storage account policy. The initiative has `displayName` of `NIST_SP_800-53_R4_SC-8(1)`.

## Regulatory Compliance

When you create initiatives, you are creating sets of policies that can be used to valiadate your regulatory compliance. But how can you track the policy initiative back to a specific regulation?

Use the [policy groups](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/initiative-definition-structure#policy-definition-groups) element in the policy initiative JSON to define your own regulatory compliance. In the following example, the name refers to a specific rule in NIST, but is also associated with other policies.

```json
   "policyDefinitionGroups": [
      {
        "name": "NIST_SP_800-53_R4_SC-8(1)",
        "additionalMetadataId": "/providers/Microsoft.PolicyInsights/policyMetadata/NIST_SP_800-53_R4_SC-8(1)"
      }
    ]
```

The schema makes is possible for you to define many policies to a particular regulatory compliance, but also for the regulator compliance to apply to multiple policies.

If using a built-in Regulatory Compliance initiative definition as a reference, it’s recommended to monitor the source of the Regulatory Compliance definitions in the [Azure Policy GitHub repo](https://github.com/Azure/azure-policy/tree/master/built-in-policies/policySetDefinitions/Regulatory%20Compliance).

You can even link your custom Regulatory Compliance initiative to your Azure Security Center dashboard, see [Azure Security Center – Using custom security policies](https://docs.microsoft.com/en-us/azure/security-center/custom-security-policies).

For more information, see [Regulatory Compliance in Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/regulatory-compliance).

## Policy as Code

In the beginning, you will be using the portal to implement your policies. But as time goes on, you will want to lock down the workflow. You will want to demonstrate how and when your policies and how your code demonstrates regulatory compliance.

You will want to put your code into a DevOps workflow. When you make a change, check in the change into a code repository, then deploy it into your environments.

As provided in the guidance, it is best practice:

> By making Azure Policy validation an early component of the build and deployment process the application and operations teams discover if their changes are non-compliant, long before it’s too late and they’re attempting to deploy in production.

For more information, see [Design Policy as Code workflows](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-as-code).

## Policy as Blueprints

Azure Policy and policy intiatives can be automated for deployment. For example, when you create a new subscription, you will want a set of policies in place when the subscription is created.

[Blueprints](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview) are a declarative way to orchestrate the deployment of various resource templates and other artifacts such as:

*   Role Assignments
*   Policy Assignments
*   Azure Resource Manager templates
*   Resource Groups

Blueprints will give you a way to stand up a subscription that meets the compliance for policies and standard resource deployments.

The work you do in creating policies can be leveraged directly into Blueprints.

## Next steps

Learn more about the [built in policy samples](https://docs.microsoft.com/en-us/azure/governance/policy/samples/).

Set up an organizational policy and implementation. See [Policy enforcement decision guide](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/decision-guides/policy-enforcement/#policy-compliance-monitoring) in the Cloud Adoption Framework.

And in next few posts, you will learn how to select and deploy Azure Blueprints. Use Azure Blueprints to deploy groups of policies (and resource templates) across your subscriptions, resource groups, or resources. The power of Azure Blueprints comes in at providing sets of policies that will demonstrate your regulatory compliance, such as

*   [Azure Security Benchmark](https://docs.microsoft.com/en-us/azure/governance/policy/samples/azure-security-benchmark)
*   [CIS Microsoft Azure Foundations Benchmark v1.1.0](https://docs.microsoft.com/en-us/azure/governance/policy/samples/cis-azure-1-1-0)
*   [NIST SP 800-53 R4](https://docs.microsoft.com/en-us/azure/governance/policy/samples/nist-sp-800-53-r4)
*   [NIST SP 800-171 R2](https://docs.microsoft.com/en-us/azure/governance/policy/samples/nist-sp-800-171-r2)

And then, you will be ready to to deploy resources.

## References

*   [Azure Policy documentation](https://docs.microsoft.com/en-us/azure/governance/policy/)
*   [Azure Policy Samples](https://docs.microsoft.com/en-us/azure/governance/policy/samples/)
*   Aiden Finn’s [Azure Policy for Governance Enforcement](https://petri.com/azure-policy-governance-enforcement)

