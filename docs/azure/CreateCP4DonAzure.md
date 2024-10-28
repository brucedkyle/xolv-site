# Create Cloud Pak for Data on Azure

Cloud Pak for Data uses Azure services and features, including VNets, Availability Zones, Availability Sets, security groups, Managed Disks, and Azure Load Balancers to build a reliable and scalable cloud platform.

The link in the References section provides a template that deploys an Openshift cluster on Azure with all the required resources, infrastructure and then deploys IBM Cloud Pak for Data along with the add-ons that user chooses.

The [deployment guide](https://learn.microsoft.com/en-us/samples/azure/azure-quickstart-templates/ibm-cloud-pak-for-data/) on GitHub provides step-by-step instructions for deploying IBM Cloud Pak for Data on a Red Hat OpenShift Container Platform 4.8 cluster on Azure. With this template, you can automatically deploy a multi-master, production instance of Cloud Pak for Data.

## Prerequisites

You will need:

- Access to Azure with **Contributor** and **User Access Administrator** permissions to run the template to create a Service Principal on the resource group that you will also need to create.

## Notes

You may add parameters to `azuredeployp.parameters.json` to specify additional parameters. The following are defaults in `azuredeploy.json`are:

| | Default value |
| - | - |
| `masterInstanceCount` | 3 |
| `workerInstanceCount` | 3 |
| `masterVmSize` | `Standard_D8s_v3` |
| `workerVmSize` | `Standard_D16s_v3` |
| `dataDiskSize` | `1024` |

If you choose Portworx as your storage class, see [Portworx documentation](https://github.com/Azure/azure-quickstart-templates/blob/master/application-workloads/ibm-cloud-pak/ibm-cloud-pak-for-data/PORTWORX.md) for generating `portworx spec url`.

## Reference

See [Cloud Pak for Data on Azure](https://github.com/Azure/azure-quickstart-templates/tree/master/application-workloads/ibm-cloud-pak/ibm-cloud-pak-for-data).
