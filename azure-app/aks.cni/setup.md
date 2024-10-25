# Prerequisites

- object id for the whoever is acting in the admin group 
- Virtual Network, including a subnet of sufficient size
- ~~Service Principal~~

The template uses managed identities to create the cluster. Hopefully, we won't need a service principal.

## NOTE

For creating and using your own VNet, static IP address, or attached Azure disk where the resources are outside of the worker node resource group, use the PrincipalID of the cluster System Assigned Managed Identity to perform a role assignment. For more information on role assignment, see Delegate access to other Azure resources.

Permission grants to cluster Managed Identity used by Azure Cloud provider may take up 60 minutes to populate.

## References

ARM Template [101-aks-advanced-networking](https://github.com/Azure/azure-quickstart-templates/tree/master/101-aks-advanced-networking)

