# Resource group

Creates a resource group with the following parameters:

- **resourceGroupName** name of the resource group
- **resourceGroupLocation** location of the resource group
- **lockResourceGroup** True locks the resource group from deletion; otherwise, false. The default is true
- **principalId** the object ID of the group you want to assign contributor permissions 
- **resourceGroupTags** the tags in the string format: `'"Cost Center" = $(CostCenter) ; "Location"=${{ parameters.location }}'`

NOTE: This is a subscription level deployment

## Prerequisites

To run the test code, you will need to log into your Azure Subscription and set your subscription id:

```
Connect-AzAccount

```