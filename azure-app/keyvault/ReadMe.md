This folder contains a set of templates to deploy Azure Key Vault to Azure.

There are several templates:

- `azuredeploy.json` includes parameters for keyVaultName, location, enabledForDeployment, enabledForTemplateDeployment, tenantId, keysPermissions, skuName, secretName, secretValue
- `keyvault.permissions\azuredeploy.json` to change the access policies for secrets.  Valid values are a list of: all, get, list, set, delete, backup, restore, recover, and purge
- `keyvault.secret\azuredeploy.json` is a template to quickly edit to change policies for secrets, keys, or certificates

To connect secrets with AKS https://docs.microsoft.com/en-us/azure/key-vault/general/key-vault-integrate-kubernetes

So far, to deploy using the pipeline, you will need to get your objectid from PowerShell and then copy it into a parameter
(from https://4bes.nl/2020/06/14/step-by-step-setup-a-cicd-pipeline-in-azure-devops-for-arm-templates/)
[you can use the service principal object id from the service object that runs the pipeline. But in the template, it has 'list' permissions only.]

(To provide permissions, you will need to run one of the access policies with the user id .. and provide list and get using -secretPermissions @("list", "get") )

NOTE: enabledForTemplateDeployment is set to true as default, so you can use it to pull secrets for subsequent ARM template deployments (such as retrieve a connection string)