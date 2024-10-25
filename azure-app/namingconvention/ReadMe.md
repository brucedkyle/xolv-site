# Azure naming convention

Organize your cloud assets to support governance, operational management, and accounting requirements. Well-defined naming and metadata tagging conventions help to quickly locate and manage resources. These conventions also help associate cloud usage costs with business teams via chargeback and showback accounting mechanisms.

The following diagram shows a sample naming convention.

![naming convention](./naming-convention.png.png)

## PowerShell Script

PowerShell script `Get-ResourceBaseName.ps1` creates a base name based the parameters.

Gets a name for the resource based on the naming convention. 

For storage accounts, the template is responsible for creating a random name to append to the storage account name (and then shortens it to 24 characters)

Sets the the resource base name in lowercase.

The step in your pipeline looks like this:

```yaml
      steps: 
        # GET NAME FOR RESOURCES
        - pwsh: Write-Output 'subscription  ${{ parameters.subscriptionid }} -projectName  ${{ parameters.projectName }} -environment $(environment) -resourceType rg -instanceNumber $(instanceNumber) -resourceLocation ${{ parameters.location }}'
          displayName: "show name convention variables"
        - task: PowerShell@2
          inputs:
            filePath: 'namingconvention/Get-ResourceBaseName.ps1'
            arguments: '-ProjectName $(projectName) -Environment $(environment) -InstanceNumber $(instanceNumber) -Location $(location) -IsStorage $false'
        - pwsh: |
            "write-Output $(resourceName)"
          displayName: 'Get resource base name'
```

## References

- [Develop your naming and tagging strategy for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Abbreviation recommendations for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)