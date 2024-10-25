# Add an Azure role assignment using an ARM template

This only works for subscription and resource group scope (for now)

The following provides information on how to use this template.

## Prerequisites

You will need:

- `Microsoft.Authorization/roleAssignments/write` and `Microsoft.Authorization/roleAssignments/delete` permissions, such as User Access Administrator or Owner for the scope you changing
- To add a role assignment, you must specify three elements: 

    - security principal
    - role definition
    - scope

## Get parameters

The roleDefinitionId for some common roles:

| Built-in role	| Description |	ID |
| - | - | - |	
| Contributor	| Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC. |	b24988ac-6180-42a0-ab88-20f7382dd24c |
| Owner	| Grants full access to manage all resources, including the ability to assign roles in Azure RBAC. |	8e3af657-a8ff-443c-a75c-2fe8c4bcb635 |
| Reader |	View all resources, but does not allow you to make any changes.	|acdd72a7-3385-48ef-bd42-f606fba81ae7 |

See [Azure built-in roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles) for the list of build in roles and the guids you will need for the roleDefinitionId.

The following PowerShell code can be used to retrieve the parameters you will need for this template:

```powershell
$roleAssignmentName = New-Guid
$principalId = (Get-AzAdUser -Mail $emailAddress).id
$roleDefinitionId = (Get-AzRoleDefinition -name "Virtual Machine Contributor").id
$scope = ((Get-AzResource -Name 'kv-rg-wus-sampleproject-01').ResourceId) #for keyvault or individual references
# or resource group
$scope = ((Get-AzResourceGroup -Name "rg-wus-sampleproject-01").ResourceId) # for vms
```

## Clean up

```PowerShell
$emailAddress = Read-Host -Prompt "Enter the email address of the user with the role assignment to remove"
$resourceGroupName = Read-Host -Prompt "Enter the resource group name to remove (i.e. rg-wus-sampleproject-01)"

$principalId = (Get-AzAdUser -Mail $emailAddress).id

Remove-AzRoleAssignment -ObjectId $principalId -RoleDefinitionName "Virtual Machine Contributor" -ResourceGroupName $resourceGroupName
Remove-AzResourceGroup -Name $resourceGroupName
```

## References
Templated adapted from https://github.com/Azure/azure-quickstart-templates/tree/master/101-rbac-builtinrole-resourcegroup

https://docs.microsoft.com/en-us/azure/role-based-access-control/quickstart-role-assignments-template

- [Assign a Role at Subscription Scope](https://github.com/Azure/azure-quickstart-templates/tree/master/subscription-deployments/subscription-role-assignment)