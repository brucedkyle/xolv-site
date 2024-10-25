Generic cognitive services template that needs to be adapted to the particular uses.

Our team seems to use LUIS, LUIS.Authoring, TextAnalytics, which is not implemented.

This provides the resources for cognitive resources.
The [template format](https://docs.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts) supports some additonal properties not yet implemented:

- customSubDomain
- ipRules
- virtualNetworkRules
- encryption connected to keyVault properties
- userOwnedStorage that points to a resourceid
- privateEndpointConnections
- apiProperties

## Kind
The template param file has the kind of service. 
