#Requires -Version 5.1
<#
.SYNOPSIS
    Gets a naming convention compliant base name of the resource.
.DESCRIPTION
    Gets a name for the resource based on the naming convention:  (locationAbbr-ProjectName-Environment-InstanceNumber)
    An example of the value set by this script: "wus2-projectName-dev-02"
    It sets a value in Azure DevOps Pipeline named resourceName. 
    The name is in lowercase. You will prepend the resource name, such as "st" for a storage account or "kv-" for key vault.
.PARAMETER ProjectName 
    A short project name. Should be less than 10 characters to allow for short storage account names.
.PARAMETER Location 
    Uses the Location to look up the location abbreviation used to create the resource name
.PARAMETER Environment 
    Expecting up to four characters for the dev, stage, and prod environments
.PARAMETER InstanceNumber 
    Optional. An integer between 1 and 99 that can be appended to the name
.PARAMETER IsStorage
    True to create a resource name without hyphens and limited to 20 characters, otherwise hyphers are used
.NOTES
  Version:        1.0.1
  Author:         Bruce Kyle
  Creation Date:  8/1/2020
  See: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging
  CAUTION: You are responsible for the length of the resource name.  See https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
  For example, Windows VM names are shorter than this naming comvention provides
#>

[CmdletBinding(SupportsShouldProcess=$True)]
param(
   [Parameter(Mandatory)] [string] $Location,
   [Parameter(Mandatory)] [string] $ProjectName,
   [Parameter(Mandatory)] [string] $Environment,
   [Parameter(Mandatory)] [string] $ResourcePrefix,
   [Parameter(Mandatory=$false)] [string] $InstanceNumber = "00",
   [Parameter(Mandatory=$false)] [bool] $IsStorage = $false
)

#--------[Script]---------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

## Set up lookup table for Location

$locationAbbrLoopup = @{}
$locationAbbrLoopup.Add("eastasia", "eaa")
$locationAbbrLoopup.Add("southeastasia", "sea")
$locationAbbrLoopup.Add("centralus", "cus")
$locationAbbrLoopup.Add("eastus", "eus")
$locationAbbrLoopup.Add("eastus2", "eus2")
$locationAbbrLoopup.Add("westus", "wus")
$locationAbbrLoopup.Add("northcentralus", "ncus")
$locationAbbrLoopup.Add("southcentralus", "scus")
$locationAbbrLoopup.Add("northeurope", "neu")
$locationAbbrLoopup.Add("westeurope", "weu")
$locationAbbrLoopup.Add("japanwest", "jaw")
$locationAbbrLoopup.Add("japaneast", "jae")
$locationAbbrLoopup.Add("brazilsouth", "brs")
$locationAbbrLoopup.Add("australiaeast", "aue")
$locationAbbrLoopup.Add("australiasoutheast", "ause")
$locationAbbrLoopup.Add("southindia", "sind")
$locationAbbrLoopup.Add("centralindia", "cind")
$locationAbbrLoopup.Add("westindia", "wind")
$locationAbbrLoopup.Add("canadacentral", "canc")
$locationAbbrLoopup.Add("canadaeast", "cane")
$locationAbbrLoopup.Add("uksouth", "uks")
$locationAbbrLoopup.Add("ukwest", "ukw")
$locationAbbrLoopup.Add("westcentralus", "wcus")
$locationAbbrLoopup.Add("westus2", "wus2")
$locationAbbrLoopup.Add("koreacentral", "korc")
$locationAbbrLoopup.Add("koreasouth", "kors")
$locationAbbrLoopup.Add("francecentral", "frc")
$locationAbbrLoopup.Add("francesouth", "frs")
$locationAbbrLoopup.Add("australiacentral", "auc")
$locationAbbrLoopup.Add("australiacentral2", "auc2")
$locationAbbrLoopup.Add("uaecentral", "uaec")
$locationAbbrLoopup.Add("uaenorth", "uaen")
$locationAbbrLoopup.Add("southafricanorth", "sfn")
$locationAbbrLoopup.Add("southafricawest", "sfw")
$locationAbbrLoopup.Add("switzerlandnorth", "swn")
$locationAbbrLoopup.Add("switzerlandwest", "sww")
$locationAbbrLoopup.Add("germanynorth", "den")
$locationAbbrLoopup.Add("germanywestcentral", "dew")
$locationAbbrLoopup.Add("norwaywest", "now")
$locationAbbrLoopup.Add("norwayeast", "noe")

$Location = $Location.ToLower().Replace(' ','')
$locationAbbr = $locationAbbrLoopup[$Location] # this just fails if you give is a name not on the list

$instNumber = $InstanceNumber.ToInt16($null)
$paddedInstanceNumber = "{0:d2}" -f $instNumber

If ($IsStorage)
{
    $resourceName = '{0}{1}{2}{3}' -f $ResourcePrefix, $ProjectName, $Environment, $locationAbbr

    if($instNumber -gt 0) {
        $resourceName = '{0}{1}' -f  $resourceName, $paddedInstanceNumber
    }
    #Add a random string to the base name
    #$resourceName = '{0}{1}' -f $resourceName,  (-join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}))
    #$resourceName = $resourceName.Substring(0, [Math]::Min($resourceName.Length, 20))
    
    # storage resourceName must be shorter than 24 characters
    if($resourceName.Length > 24){
        throw "Storage resource name '$resourceName' cannot be greater than 24 characters. Shorten $ProjectName."
    }
}
Else {
    $resourceName = '{0}-{1}-{2}-{3}' -f $ResourcePrefix, $ProjectName, $Environment, $locationAbbr

    if($instNumber -gt 0) {
        $resourceName = '{0}-{1}' -f $resourceName, $paddedInstanceNumber
    }
}

$resourceName =  $resourceName.ToLower()

Write-Host "##vso[task.setvariable variable=resourceName;]$resourceName"