This template retrieves the cosmosdb connection string and key and puts them into keyvault secret.

## Important

This is not the recommended way to access connection from your code. 

> It is best practice to use managed identities. See:
> - [How can I use managed identities for Azure resources?](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview#how-can-i-use-managed-identities-for-azure-resources)
> - [How to use managed identities for App Service and Azure Functions](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?context=azure%2Factive-directory%2Fmanaged-identities-azure-resources%2Fcontext%2Fmsi-context&tabs=dotnet)

## Prerequisites

Key Vault must exist
CosmosDB must exist
The service running the template must have permissions on the data plane: set permissions on the secret
The service running the template may need management plane access to update key vault (probably Key Vault Contributor)

## Parameters

Pass in the name of the keyvault
Pass in thema of the cosmosDB
Pass in the name of the secrets
Pass in index of the connection string. There can be three of them.

## References

[Get CosmosDb Primary Connection String in ARM template](https://stackoverflow.com/questions/55108333/get-cosmosdb-primary-connection-string-in-arm-template)