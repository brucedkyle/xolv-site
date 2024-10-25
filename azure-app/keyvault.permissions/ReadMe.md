Use this implementation to take an objectId and set its the _data plane permissions permissions_ in Key Vault.
This template sets the permissions on the _data plane_ only

This is an ARM template implementation of:

```bash
az keyvault set-policy -n <your-unique-keyvault-name> --spn <ApplicationID-of-your-service-principal> --secret-permissions get list set delete --key-permissions create decrypt delete encrypt get list unwrapKey wrapKey`
``` 
or

```powershell
Set-AzKeyVaultAccessPolicy -VaultName <your-key-vault-name> -PermissionsToKeys create,decrypt,delete,encrypt,get,list,unwrapKey,wrapKey -PermissionsToSecrets get,list,set,delete -ObjectId <Id>
```

> IMPORTANT: Best practice to user groups and service principals rather than user ids.

The parameter files provide some samples for quick implemention of common scenarios.

## Prerequisites

You will need:

- ObjectId
- Key vault name which as `enabledForTemplateDeployment` set to `true`

If a user has Contributor permissions to a key vault management plane, the user can grant themselves access to the data plane by setting a Key Vault access policy. You should tightly control who has Contributor role access to your key vaults. Ensure that only those with a need for access authorized persons can access and manage your vaults. You can read [Secure access to a key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/secure-your-key-vault) )

This implementation does not implement (preview) **'Azure role-based access control' permission model**.

- Optional. You may need an ApplicationId to [deploy using Ev2](https://ev2docs.azure.net/getting-started/environments/test.html#onboard-to-azure-key-vault). See the following section on _compound identity_.

## Keys vs Secrets

See [About keys, secrets, and certificates](https://docs.microsoft.com/en-us/azure/key-vault/general/about-keys-secrets-certificates)

- **Cryptographic keys**: Supports multiple key types and algorithms, and enables the use of Hardware Security Modules (HSM) for high value keys. For more information, see About keys.
- **Secrets**: Provides secure storage of secrets, such as passwords and database connection strings. For more information, see About secrets.
- **Certificates**: Supports certificates, which are built on top of keys and secrets and add an automated renewal feature. For more information, see About certificates.
- **Azure Storage**: Can manage keys of an Azure Storage account for you using Powershell. Internally, Key Vault can list (sync) keys with an Azure Storage Account, and regenerate (rotate) the keys periodically. For more information, see [Manage storage account keys with Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys-powershell).

## Sample permissions

The following example is implemented from [](https://docs.microsoft.com/en-us/azure/key-vault/general/secure-your-key-vault)
| App/Group | Management plane permissions(*) | Data plane permissions | Azure Deploy Parameter filename |
| - | - | - | - |
| Security team | Key Vault Contributor | Keys: backup, create, delete, get, import, list, restore<br />Secrets: all operations | `securityteam.azuredeploy.parameters.json` |
| Developers and operators | Key Vault deploy (AFAIK this is the `enabledForDeployment` property set on Key Vault) <br /> Note: This permission allows deployed VMs to fetch secrets from a key vault. | none | `devoperator.azuredeploy.parameters.json` |
| Auditors | None | Keys: list <br />
Secrets: list <br />
Note: This permission enables auditors to inspect attributes (tags, activation dates, expiration dates) for keys and secrets not emitted in the logs. | `azuredeploy.parameters.json` |
| Application	| None	| Keys: sign<br />Secrets: get | `app.azuredeploy.parameters.json` |
| Reader | Reader | Secrets: get | `reader.azuredeploy.parameters.json` |

> (*) NOTE: This does not set the Management plane permissions

## Built in Key Vault roles

|Role name | Description | ID |
| - | - | - |
| Reader | For existing service principals that need to read keys.<br>Keys: get<br>Secrets: get<br>Certificates: get<br> See [secrets-store-csi-driver-provider-azure service principal](https://github.com/Azure/secrets-store-csi-driver-provider-azure/blob/master/docs/service-principal-mode.md) | acdd72a7-3385-48ef-bd42-f606fba81ae7 |
| Contributor | Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC.<br>NOTE: Limit role of Contributors | b24988ac-6180-42a0-ab88-20f7382dd24c |
| Key Vault Contributor	| Manage key vaults, but does not allow you to assign roles in Azure RBAC, and does not allow you to access secrets, keys, or certificates.	|f25e0fa2-a7c8-4377-a976-54943a77a395 |

For more information, see [Azure built-in roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)

## List of available permissions

```json
"permissions": {
              "keys": [
                "Get",
                "List",
                "Update",
                "Create",
                "Import",
                "Delete",
                "Recover",
                "Backup",
                "Restore"
              ],
              "secrets": [
                "Get",
                "List",
                "Set",
                "Delete",
                "Recover",
                "Backup",
                "Restore"
              ],
              "certificates": [
                "Get",
                "List",
                "Update",
                "Create",
                "Import",
                "Delete",
                "Recover",
                "Backup",
                "Restore",
                "ManageContacts",
                "ManageIssuers",
                "GetIssuers",
                "ListIssuers",
                "SetIssuers",
                "DeleteIssuers"
              ]
            }
          }
```

## Compound identity

[Compound identity](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-secure-your-key-vault#active-directory-authentication) ensures that secrets requires authentication by a specific application (in the case of an Ev2 this is the rollout context) and the user. 

The user is required to access the key vault from a specific application and the application must use the on-behalf-of authentication (OBO) flow to impersonate the user. For this scenario to work, both applicationId and objectId must be specified in the access policy. The applicationId identifies the required application and the objectId identifies the user. Currently, this option isn't available for data plane Azure RBAC (preview).

## References

See:

- [Security Baseline](https://docs.microsoft.com/en-us/azure/key-vault/general/security-baseline)
- [Tutorial: Integrate Azure Key Vault in your ARM template deployment](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-tutorial-use-key-vault)
- [Tutorial: Configure and run the Azure Key Vault provider for the Secrets Store CSI driver on Kubernetes](https://docs.microsoft.com/en-us/azure/key-vault/general/key-vault-integrate-kubernetes)

