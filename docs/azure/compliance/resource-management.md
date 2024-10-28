# Organize Azure resources using management group, tags, naming convention

![org1](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/org1.png?resize=279%2C251&ssl=1)

Once you have set up your Azure administrators, you can begin to consider how to organize your cloud into management groups, subscriptions, resource groups. You will want to develop a naming standard, and way to tag resources.

Although you may be focused initially on just getting your resources deployed, you will want to be able to manage them. For example, a year from now you may want to know who is responsible for the virtual machine that is no longer doing anything, but is costing money. In other words, you may want lifecycle management.

You may want the ability to charge a set of resources to a cost center and to budget those resources. For example, you may want to receive alerts for both the users and for your administrators when costs are out of line with expectations.

And as we all know, it is easier to organize as you go. In this article, you will learn about some key points in organizing your Azure resources.

In this article, learn about the Azure hierarchy, naming standards, and resource tags.

As you deploy resources, you will want specific standards specified for your cloud admins and users. The payoff is that you will be able to maintain your cloud at scale. You can figure out who or what team is responsible for the resource, determine whether the resource is still needed, and figure out what that resource is costing. And it begins with specific standards for:

*   Management hierarchy
*   Names
*   Tags

Let’s start with management hierarchy.

## Management hierarchy

You can think of Azure in four levels for your management: management group, subscriptions, resource groups, and resources. The following illustration shows a partial management hierarchy for Azure.

![org](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/org.png?resize=748%2C601&ssl=1)

The illustration shows:

*   **Management groups** provide a way to manage access, policies, and compliance across multiple subscriptions. The management groups themselves be have their own heirarchy.
*   **Subscriptions** are Azure’s way to associate user accounts and resources. You an provide subscriptions with policies, limits or quotas on what users can create and use. Subscriptions are how you manage your costs.
*   **Resource groups** is a logical container for a set of resources that you manage together. Typically resources within a resource group have the same lifecycle, meaning they are often created or managed as a single unit.
*   **Resources** are instances of the service, such as storage or a database.In a later post, you will learn how to set up your management group.

## Naming standards

Naming standards help you quickly identify resources for your scripts and in your billing statements.

Resources themselves have different naming characteristics. So your standard may have vary depending on the type of resource. You may want to bookmark this link [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules) and refer back to it often when naming your resources.

Many organizations use the [Azure naming convention](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging) suggested in the Cloud Adoption Framework. It is important to note that many (if not most) of the templates posted follow different naming conventions. That means that you off-the-shelf templates may need to be updated for your own naming convention.

Your resource group and resource names are readable. For example, they might look like:

```text
# sample resource group name
rg-wu2-prod-azdays-01

# sample virtual network  name
vnet-wu2-prod-azdays-01

# sample strorage account name
stwu2prazdays89304
```

You can actually tell a lot just by the name of the resource, such as:

1.  resource group: `rg-`
2.  region: `wu2-`
3.  environment (dev, stag, prod): `prod-`
4.  product name: `azdays-`
5.  iteration number or something a random number: `01`

Not all resources will support that format. Of note:

*   Storage accounts must only have small case letters and no hyphens
*   Virtual machines in Windows must only have 15 characters.
*   You may need to use a random number, particularly for storage accounts or log analytics resources that must be unique across all of azure., to make them unique

You can check the length and resource name restrictions.

When you use Azure Resource Manager templates, they will often copy the tags from the resource group to the resources themselves. Not all do. So be sure to check. You can learn more about ARM templates in later posts here or at

## Tags

Resource groups and resources themselves should be tagged. Tags help you identify resources for queries. Tags help you with metadata for your resources. It will help answer questions like: who requested the resource, how long should it be available, who to contact to remove it, what application do these resources belong to, and which cost center is responsible for this.

Microsoft offers a list of suggested tags. The minimum I suggest is:

*   Cost Center
*   Application
*   Owner
*   Review date
*   Environment

You can update tags using scripts. See [Use tags to organize your Azure resources and management hierarchy](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources) for examples on updating tags using PowerShell or Azure CLI.

In a later post, you will learn how to require tags in your resources. For now, you can view [Enforce resource tagging with Azure Policy](https://blogs.endjin.com/2019/04/enforce-resource-tagging-with-azure-policy/).

## Use PowerShell scripts to create a resource group

The following script shows an example how how to create a resource group using the suggested naming convention and tags.

```powershell
$REGION_ABBR = "wu2"
$ENVIRONMENT = "dev"
$PROJECT = "azdays"
$ITERATION = "01"
$LOCATION = "West US 2"

$RESOURCE_GROUP_NAME = "rg-" + $REGION_ABBR + "-" + $ENVIRONMENT + "-" + $PROJECT + "-" + $ITERATION
$TAGS = @{ "Cost Center" = "AzDays"; "Location"=$LOCATION }

# new resource group
New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location $LOCATION -Tags $TAGS
```

The following script gets the list of resource groups based on the tag.

```powershell
(Get-AzResourceGroup -Tag @{ "Cost Center"="AzDays" }).ResourceGroupName
```

Next, we’ll do the same with CLI.

## Use Azure CLI (Bash) scripts with a resource group

The following script shows an example how how to create a resource group using the suggested naming convention and tags.

```sh
TAG="Cost Center=AzDays"

# az group list --tag supports a single tag only
az group list --tag "$TAG"
```

The syntax for tags is a bit quirky, perhaps not for Bash users. But take a quick note of the syntax in the previous code. `$LOCATION` has a space and requires quotes to pass into the CLI command. And `$TAGS` is passed in as an array of string. In the example, it also shows no spaces between the tags’ key and value.

### Query resources using tags using CLI

In your Azure CLI scripts, get a list of resource groups or resources by using the the `--tags` parameter. The following shows how to get a list of resource groups and resources by specifying the tag, however the tag cannot have a space.

```sh
# get resource groups with a tag which does not have spaces
az group list --tag Environment=Dev -o json

# get a list of resources with a tag without spaces
az resource list --tag Environment=Dev -o json
```

You can then get a list of resource groups based on a single tag.

```sh
TAG="Cost Center=AzDays"

# az group list --tag supports a single tag only
az group list --tag "$TAG"
```


### Set resource tags using CLI

The following is a full example of how to copy all of tags from the resource group to all of its resources.

```sh
# adapted from https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources#handling-spaces 
RESOURCE_GROUP_NAME='rg-wu2-prod-azdays-01'

jsontags=$(az group show --name $RESOURCE_GROUP_NAME --query tags -o json)
tags=$(echo $jsontags | tr -d '{}"' | sed 's/: /=/g' | sed "s/\"/'/g" | sed 's/, /,/g' | sed 's/ *$//g' | sed 's/^ *//g')
origIFS=$IFS
IFS=','
read -a tagarr <<< "$tags"
resourceids=$(az resource list -g $RESOURCE_GROUP_NAME --query [].id --output tsv)
for id in $resourceids
do
  az resource tag --tags "${tagarr[@]}" --id $id
done
IFS=$origIFS
```
## Use tags and naming convention with ARM templates

In the next few posts, you can learn how to pass tags into deployments scripts. Look for posts that include _Boilerplate_ in the title.

## Query Log Analytics based on tags

Once you get started with Log Analytics, you may want to query resource groups ro resources based on their tags. As of this writing, you will need to use a workaround as the feature in log analytics is not supported. You can upvote the feature at [Log Analytics query with tags](https://feedback.azure.com/forums/267889-azure-monitor-log-analytics/suggestions/33885118-log-analytics-query-with-tags).

You can leverage Azure serverless offerings (including Logic Apps and Functions) to get this data into your Log Analytics workspaces. See [Query Azure VM Tags from Log Analytics](https://mjyeaney.github.io/2018/06/05/omsvmtags/).

## Summary

In this article you identified three ways to help you organize your resources:

*   Management groups
*   Naming convention
*   Tags

In posts coming up, learn how to set up your management group.

## Resources

*   [Organize your Azure resources](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources)
*   [Recommended naming and tagging conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
*   [Use tags to organize your Azure resources and management hierarchy](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources)
*   [Everything you need to know about resource tagging in Azure](https://sharegate.com/blog/everything-you-need-to-know-about-resource-tagging-in-azure)
