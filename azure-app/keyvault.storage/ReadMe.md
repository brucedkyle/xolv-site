# Key vault storage

This template retrieves the storage connection string and key and puts them into keyvault secret.

## Important

This is not the recommended way to access connection from your code. 

> It is best practice to use managed identities. See:
> - [How can I use managed identities for Azure resources?](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview#how-can-i-use-managed-identities-for-azure-resources)
> - [How to use managed identities for App Service and Azure Functions](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?context=azure%2Factive-directory%2Fmanaged-identities-azure-resources%2Fcontext%2Fmsi-context&tabs=dotnet)

## Sync keys

If you do not use managed identities to get your access keys, then you must update your keys in key vault. In other words:

> The ARM template will not automatically update the keys when the keys are changed. When you do key rotation in storage account, you will need to update the keys in key vault. So far, that would be manually. 

OR you can set up storage account to automatically update key vault using the following PowerShell command

First enable the storage account access to key vault

```powershell
# Assign Azure role "Storage Account Key Operator Service Role" to Key Vault, limiting the access scope to your storage account. For a classic storage account, use "Classic Storage Account Key Operator Service Role." 
New-AzRoleAssignment -ApplicationId $keyVaultSpAppId -RoleDefinitionName 'Storage Account Key Operator Service Role' -Scope $storageAccount.Id

# Give your user principal access to all storage account permissions, on your Key Vault instance
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -UserPrincipalName $userId -PermissionsToStorage get, list, delete, set, update, regeneratekey, getsas, listsas, deletesas, setsas, recover, backup, restore, purge
```

Then

```powershell
$regenPeriod = [System.Timespan]::FromDays(3)

Add-AzKeyVaultManagedStorageAccount -VaultName $keyVaultName -AccountName $storageAccountName -AccountResourceId $storageAccount.Id -ActiveKeyName $storageAccountKey -RegenerationPeriod $regenPeriod
```

See [Enable key regeneration](https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys-powershell#enable-key-regeneration)
NOTE: I checked with Tech Support.. this is not supported in the ARM Template
But if you use managed identities, you do not need to sync your keys.

## Prerequisites

- Key Vault must exist
- Storage account must exist
- The service running the template must have permissions on the data plane: set permissions on the secret
- The service running the template may need management plane access to update key vault (probably Key Vault Contributor)

## Parameters

- Pass in the name of the keyvault
- Pass in the name of the storge account
- Pass in the name of the secret
- Pass in index of the access key. There can be three of them.

## References

[Manage storage account keys with Key Vault and Azure PowerShell](https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys-powershell)
[Retrieve Azure Storage access keys in ARM template](https://blog.eldert.net/retrieve-azure-storage-access-keys-in-arm-template/)
