# Install instructions for operations team for OpenShift on Azure in restricted client environment for an MVP

This documents the steps to stand up Red Hat OpenShift 4.8 in Azure in a restrictive environment, including

- Prerequisites
- Preparation for the environment by the Ops team

The document follows these general steps:

- Access to [OpenShift Container Platform](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-customizations.html#cluster-entitlements_installing-azure-customizations). 
- Set [Account Limits](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-account.html#installation-azure-limits_installing-azure-account), specifically set the number of vCPU set to 60 plus the number already needed in the subscription.
- Configure a [public DNS zone](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-account.html#installation-azure-network-config_installing-azure-account)
- A [service principal with both Contributor and User Access Administrator](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-account.html#installation-azure-service-principal_installing-azure-account). (This step requires Owner permission to create the service principal). NOTE: We will need to securely copy the service principal.
- User access for anyone working on the installation for Contributor.

## Prerequisites

You will need:

- Azure subscription
- Azure CLI installed
- Approval of CoreOS for the operating system of the Control Plane nodes that is part of OpenShift 4.8
- Access to the mirrored/approved Red Hat OpenShift 4.8 images for the worker nodes

The admin Azure account subscription must have the following roles to create the service principal:

- User Access Administrator
- Owner

Know how to log into Azure using:

```bash
az login
az account show
# validate you are in the right subscription
```

| Save the values of the `tenantId` and `id` from the previous output. You need these values during OpenShift Container Platform installation.

## Configure your firewall

The following assumes a cluster name of `watsonaiopsmvp` and a base domain name of `costcowaiopsmvp.com`.

### Allowlist the following registry URLs

| URL	| Port	| Function |
|-|-|-|
| `registry.redhat.io` | 443, 80 | Provides core container images |
| `quay.io` | 443, 80 | Provides core container images |
| `*.quay.io` | 443, 80 | Provides core container images |
| `sso.redhat.com` | 443, 80 | The https://console.redhat.com/openshift site uses authentication from sso.redhat.com |
| `*.openshiftapps.com` | 443, 80 | Provides Red Hat Enterprise Linux CoreOS (RHCOS) images |

> When you add a site, such as `quay.io`, to your allowlist, do not add a wildcard entry, such as *.quay.io, to your denylist. In most cases, image registries use a content delivery network (CDN) to serve images. If a firewall blocks access, then image downloads are denied when the initial download request is redirected to a hostname such as cdn01.quay.io.

CDN hostnames, such as cdn01.quay.io, are covered when you add a wildcard entry, such as *.quay.io, in your allowlist.

### Allow access for Watson AI Ops

Inbound ports that WAIOPs exposes (for ingress communication):

- Generally, WAIOPs pods use only standard ports (80/443) defined by OCP routes for HTTP/HTTPs inbound connections coming from external clients such as the browser (for accessing the WAIOps console), an external Kafka client that needs to place data on a Kafka topic, Slack inbound data, etc.

In our case, we will need standard ports (80/443) to the Instana instance.

Outbound ports that WAIOPs needs access to (for egress communication):

- Generally, these types of connectors (e.g. ELK, Splunk, Humio, LogDNA, SNOW topology observers, etc.), WAIOps uses a PULL model. Therefore, the endpoint exposed by those external products specifies the port and connection parameters that WAIOPs should used for pulling the data (event, log, etc.) from those external systems. The port number used by that external system is totally dependent on how that external tool was configured. WAIOps does not dictate what that value should be.

Not to be implemented in this MVP.

Internal communication within the OCP cluster where WAIOPs is installed

- WAIOps internally uses other ports as well (e.g. 8080; 8383; 8686, etc.) for communication between its own pods (ClusterIP type) running on the same OCP cluster. Hence, these are not exposed as OCP routes.

### Allow access for Red Hat Insights

| URL | Port | Function |
|-|-|-|
| `cert-api.access.redhat.com` | 443, 80 | Required for Telemetry |
| `api.access.redhat.com` | 443, 80 | Required for Telemetry |
| `infogw.api.openshift.com` | 443, 80 | Required for Telemetry |
| `console.redhat.com/api/ingress`, `cloud.redhat.com/api/ingress` |  443, 80 | Required for Telemetry and for insights-operator |

### Allow access to Azure resources

| URL | Port | Function |
|-|-|-|
| `management.azure.com` | 443, 80 | Required to access Azure services and resources. Review the Azure REST API reference in the Azure documentation to determine the endpoints to allow for your APIs. |
| `*.blob.core.windows.net` | 443, 80 | Required to download Ignition files. |
| `login.microsoftonline.com` | 443, 80 | Required to access Azure services and resources. Review the Azure REST API reference in the Azure documentation to determine the endpoints to allow for your APIs.|

### Allow list for the following URLs

| URL | Port | Function |
|-|-|-|
| `mirror.openshift.com` | 443, 80 | Required to access mirrored installation content and images. This site is also a source of release image signatures, although the Cluster Version Operator needs only a single functioning source. |
| `storage.googleapis.com/openshift-release` | 443, 80 | A source of release image signatures, although the Cluster Version Operator needs only a single functioning source. |
| `*.apps.<cluster_name>.<base_domain>` in our case use `*.apps.watsonaiopsmvp.costcowaiopsmvp.com` | 443, 80 | Required to access the default cluster routes unless you set an ingress wildcard during installation. |
| `quayio-production-s3.s3.amazonaws.com` | 443, 80 | Required to access Quay image content in AWS. |
| `api.openshift.com` | 443, 80 | Required both for your cluster token and to check if updates are available for the cluster. |
| `art-rhcos-ci.s3.amazonaws.com` | 443, 80 | Required to download Red Hat Enterprise Linux CoreOS (RHCOS) images. |
| `console.redhat.com/openshift` | 443, 80 | Required for your cluster token. |
| `registry.access.redhat.com` | 443, 80 | Required for odo CLI. |

### Time controller

If you use a default Red Hat Network Time Protocol (NTP) server allow the following URLs:

1. `rhel.pool.ntp.org`
2. `rhel.pool.ntp.org`
3. `rhel.pool.ntp.org`

> If you do not use a default Red Hat NTP server, verify the NTP server for your platform and allow it in your firewall.

For more information, see [Configuring your firewall](https://docs.openshift.com/container-platform/4.8/installing/install_config/configuring-firewall.html#configuring-firewall)

## Configure subscription limit

For [IBM Cloud Pak for Watson AIOps AI Manager](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=requirements-ai-manager) Small without high availability.

The default Azure subscription will not have service limited needed. The system administration will need to update the subscription:

| Component | Number of components required | Description |
|-|-|-|
| vCPU for AIOps (Small) | 60 + the number already allocated for other services on the subscription| Hardware requirement totals for AI Manager and OpenShift control plane |

To [set the required number of vCPUs](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-account.html#installation-azure-increasing-limits_installing-azure-account):

1. From the Azure portal, click **Help + support** in the lower left corner.

2. Click **New support request** and then select the required values:

    a. From the **Issue type** list, select **Service and subscription limits (quotas)**.

    b. From the **Subscription** list, select the subscription to modify.

    c. From the **Quota type** list, select the quota to increase. For example, select **Compute-VM (cores-vCPUs)** subscription limit increases to increase the number of vCPUs, which is required to install a cluster.

    d. Click **Next: Solutions**.

3. On the **Problem Details** page, provide the required information for your quota increase:

    a Click **Provide details** and provide the required details in the **Quota details** window.

    b. In the SUPPORT METHOD and CONTACT INFO sections, provide the issue severity and your contact details.

4. Click **Next: Review + create** and then click **Create**.

The complete list of requirements is [here](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-account.html#installation-azure-limits_installing-azure-account)

## Configure new DNS zone

To install OpenShift Container Platform, the Microsoft Azure account you use must have a dedicated public hosted DNS zone in your account. This zone must be authoritative for the domain. 

1. Identify your domain, such as `costcowaiopsmvp.com`
2. Create resource group `rg-wus2-waiopsmvp-01` using:

```bash
az group create --name rg-wus2-waiopsmvp-01 --location "westus2"
```

3. Create a DNS Zone

```bash
az network dns zone create -g rg-wus2-waiopsmvp-01 -n costcowaiopsmvp.com
```

4. Create a DNS Record

The following creates a record with the relative name "demo" in the DNS Zone "costcowaiopsmvp.com" in the resource group "MyResourceGroup". The fully-qualified name of the record set is "costcowaiopsmvp.com". The record type is "A", with IP address "10.10.10.10", and a default TTL of 3600 seconds (1 hour).

```bash
az network dns record-set a add-record -g rg-wus2-waiopsmvp-01 -z costcowaiopsmvp.com -n demo -a 10.10.10.10
```

5. View the records

```bash
az network dns record-set list -g rg-wus2-waiopsmvp-01 -z costcowaiopsmvp.com
```

For more information, see [Quickstart: Create an Azure DNS zone and record using Azure CLI](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-cli)

## Create a service principal

Because OpenShift Container Platform and its installation program must create Microsoft Azure resources through Azure Resource Manager, you must create a service principal to represent it.

```bash
az ad sp create-for-rbac --role Contributor --name costcowaiopsmvp-01
```

Record the values of the `appId` and `password` from the output. You need these values during OpenShift Container Platform installation. Set the `appId` to an environment variable where `<appid>` is the value from the output of the previous command.

```bash
APP_ID=<appid>
```

> IMPORTANT: You must always add the **Contributor** and **User Access Administrator** roles to the app registration service principal so the cluster can assign credentials for its components.

Next, assign the User Access Administrator role and the Azure Active Directory Graph permission:

```bash
az role assignment create --role "User Access Administrator" --assignee-object-id $(az ad sp list --filter "appId eq '$APP_ID'" | jq '.[0].objectId' -r)
az ad app permission add --id $APP_ID --api 00000002-0000-0000-c000-000000000000 --api-permissions 824c81eb-e3f8-4ee6-8f6d-de7f50d565b7=Role
```

Approve the permissions request. If your account does not have the Azure Active Directory tenant administrator role, follow the guidelines for your organization to request that the tenant administrator approve your permissions request.

```bash
az ad app permission grant --id $APP_ID --api 00000002-0000-0000-c000-000000000000
```

For more information, see [Creating a service principal](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-account.html#installation-azure-service-principal_installing-azure-account)

## Port access

Inbound ports that WAIOPs exposes (for ingress communication):

- WAIOPs pods use only standard ports (80/443) defined by OCP routes for HTTP/HTTPs inbound connections coming from external clients such as the browser (for accessing the WAIOps console), an external Kafka client that needs to place data on a Kafka topic, Slack inbound data, etc.

Outbound ports that WAIOPs needs access to (for egress communication):

- For these types of connectors (e.g. ELK, Splunk, Humio, LogDNA, SNOW topology observers, etc.), WAIOps uses a PULL model. Therefore, the endpoint exposed by those external products specifies the port and connection parameters that WAIOPs should used for pulling the data (event, log, etc.) from those external systems. The port number used by that external system is totally dependent on how that external tool was configured. WAIOps does not dictate what that value should be.

Internal communication within the OCP cluster where WAIOPs is installed

- WAIOps internally uses other ports as well (e.g. 8080; 8383; 8686, etc.) for communication between its own pods (ClusterIP type) running on the same OCP cluster. Hence, these are not exposed as OCP routes.

## Next steps

1. Define the config for [Installing a cluster on Azure with customizations](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-customizations.html#installing-azure-customizations)
2. Install [ODF](https://access.redhat.com/documentation/en-us/red_hat_openshift_data_foundation/4.9/html/deploying_openshift_data_foundation_using_microsoft_azure_and_azure_red_hat_openshift/index) for 601 Gi of persistent storage
3. Install [Watson AI Ops](https://ibmdocs-test.mybluemix.net/docs/en/cloud-paks/cloud-pak-watson-aiops/3.3.0?topic=manager-starter-installation-cli) or other Cloud Pak.

## References

Red Hat documentation: [Configuring an Azure account](https://docs.openshift.com/container-platform/4.8/installing/installing_azure/installing-azure-account.html)
[Hardware requirements for IBM Cloud Pak for Watson AIOps AI Manager](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=requirements-ai-manager)
[Azure Account Set Up](https://github.com/openshift/installer/blob/master/docs/user/azure/README.md). This document is a guide for preparing a new Azure account for use with OpenShift. It will help prepare an account to create a single cluster and provide insight for adjustments which may be needed for additional clusters.
[Watson AI Ops 3.3 pre-prod doc](https://ibmdocs-test.mybluemix.net/docs/en/cloud-paks/cloud-pak-watson-aiops/3.3.0?topic=manager-starter-installation-cli) for hardware, OCP version and necessary setup on that page to ensure the configured OCP should be maximally compatible. 

## Contributors

- Bruce Kyle
- Volodymyr Rozdolsky
- Hamza Elgindy

March 22, 2022

