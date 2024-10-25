
#Requires -Version 5.1
#Requires -Modules AzureADPreview
# Does NOT run on PowerShell Core (7.0)
<#
.PARAMETER DisplayName
    The first few characters of the display name is used to retrive ObjectIds.
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
.\Get-ObjectIdsByDisplayName -DisplayName "Bruce"
Connect-AzAccount -Subscription $SUBSCRIPTION_ID
.\Get-ObjectIdsByDisplayName -DisplayName "Class"
#>

[CmdletBinding(SupportsShouldProcess = $True)]
#--------[Params]---------------
Param(
    [Parameter(Mandatory = $true)] [string] $DisplayName
)

##################
# Get-AzureADUser 
##################

try { 
    $Users = $(try { Get-AzureADUser -Filter "startswith(DisplayName,'$DisplayName')" -ErrorAction SilentlyContinue }  catch { $null } )
    if ($null -eq $Users) {
        Write-Warning "No matches for users named '$DisplayName'" 
    }
    else {
        Write-Output "########### Users ###############"
        Write-Output $Users
    }
}
catch {
    Write-Error  "Error looking up user '$DisplayName'" 
    $ErrorMessage = $_.Exception.Message
    Write-Error $ErrorMessage
}

##################
# Get-AzureADGroup https://docs.microsoft.com/en-us/powershell/module/azuread/get-azureadgroup?view=azureadps-2.0 Filter on DisplayName  
##################

try {
    
    $Groups = $(try { Get-AzureADGroup -Filter "startswith(DisplayName,'$DisplayName')" -ErrorAction SilentlyContinue }  catch { $null } )
    if ($null -eq $Groups) {
        Write-Warning "No matches for groups named '$DisplayName'" 
    }
    else {
        Write-Output "########### Groups ###############"
        Write-Output $Groups
    }
}
catch {
    Write-Error  "Error looking up groups '$DisplayName'" 
    $ErrorMessage = $_.Exception.Message
    Write-Error $ErrorMessage
}

##################
# Get-AzureADServicePrincipal https://docs.microsoft.com/en-us/powershell/module/azuread/get-azureadserviceprincipal?view=azureadps-2.0
##################

try {
    $ServicePrincipals = $(try { Get-AzureADServicePrincipal -Filter "startswith(DisplayName,'$DisplayName')" -ErrorAction SilentlyContinue }  catch { $null } )
    if ($null -eq $ServicePrincipals) {
        Write-Warning "No matches for service principals named '$DisplayName'" 
    }
    else {
        Write-Output "########### ServicePrincipals ###############"
        Write-Output $ServicePrincipals
    }
}
catch {
    Write-Error  "Error looking up service principals '$DisplayName'" 
    $ErrorMessage = $_.Exception.Message
    Write-Error $ErrorMessage
}

