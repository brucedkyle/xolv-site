The main parameters should be passed in separate azuredeploy.parameters.json file rather than through the command line.

> IMPORTANT: The PrimaryRegion must be in the same region as its ResourceGroup or the deployment may fail.

The template is built with a single database per CosmosDB account.

## Notes for future

Return connection strings
https://stackoverflow.com/questions/55108333/get-cosmosdb-primary-connection-string-in-arm-template

See many of the cosmosdb arm templates at
https://docs.microsoft.com/en-us/azure/cosmos-db/manage-sql-with-resource-manager

This one uses  https://docs.microsoft.com/en-us/azure/cosmos-db/manage-sql-with-resource-manager#azure-cosmos-account-with-autoscale-throughput

To get the connection string in a following template, use:

```
"connectionStrings": [
 {
   "name": "CosmosConnection",
   "connectionString": "[listConnectionStrings(resourceId('Microsoft.DocumentDB/databaseAccounts',parameters('cosmosDbAccountName')), '2019-12-12').connectionStrings[0].connectionString]",
   "type": 3
 }
]
```

and pass in the cosmosDBAccountName as a parameter