
#Requires -Version 5.1
#Requires -Modules AzureADPreview
# Does NOT run on PowerShell Core (7.0)
<#
.NOTES
The Azure Active Directory PowerShell for Graph module can be downloaded and installed from the PowerShell Gallery, www.powershellgallery.com. 
Contributor at the subscription level
  Version:        1.0
  Author:         Bruce Kyle
  Creation Date:  9/2/2020
  Requires:
  - you will probably need to update every few weeks:
Uninstall-Module AzureAD 
Uninstall-Module AzureADPreview
Install-Module AzureADPreview
  - You may get an error an error `PackageManagement\Uninstall-Package : No match was found for the specified search criteria and module names 'AzureAD'.` which is Okay.
    It just means the module is not installed.
  - AzureADPreview gives you the Azure Graph Module
  - 
.EXAMPLE
$TENANT_DOMAIN_NAME = "strategicdatatech.com"
$SUBSCRIPTION_ID = "9f241d6e-16e2-4b2b-a485-cc546f04799b"
Connect-AzureAD -TenantDomain $TENANT_DOMAIN_NAME
Connect-AzAccount -Subscription $SUBSCRIPTION_ID
.\Get-ObjectIds -UserPrincipalName brucedkyle@strategicdatatech.com
#>

[CmdletBinding(SupportsShouldProcess = $True)]
#--------[Params]---------------
Param(
    [Parameter(Mandatory = $true)] [string] $UserPrincipalName
)
try {
    $Users = $(try { Get-AzureADUser -Filter "userPrincipalName eq '$userPrincipalName'" -ErrorAction SilentlyContinue }  catch { $null } )
    if ($null -eq $Users) {
        Write-Warning "Failed retrieving $userPrincipalName" -WarningAction Inquire
    }
    else {
        Write-Output $Users
    }
}
catch {
    Write-Error  "Error looking up '$userPrincipalName'" 
    $ErrorMessage = $_.Exception.Message
    Write-Error $ErrorMessage
}

# Get-AzureADUser

# Get-AzureADGroup https://docs.microsoft.com/en-us/powershell/module/azuread/get-azureadgroup?view=azureadps-2.0 Filter on DisplayName 

# Get-AzureADServicePrincipal https://docs.microsoft.com/en-us/powershell/module/azuread/get-azureadserviceprincipal?view=azureadps-2.0
