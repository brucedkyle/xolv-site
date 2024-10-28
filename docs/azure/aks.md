# Walkthrough: Create Azure Kubernetes Service (AKS) using ARM template

<img style="float: right; width: 20%; padding-inline: 6px" src="https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/9fde8-azure-container-service_color.png?resize=190%2C158&ssl=1">[Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/) provides a hosted Kubernetes service where Azure handles critical tasks like health monitoring and maintenance for you. AKS reduces the complexity and operational overhead of managing Kubernetes by offloading much of that responsibility to Azure. When you create AKS, Azure provides the Kubernetes control plane. You need manage only the agent nodes within your clusters.

There are several ways to deploy to Azure, including using the [portal](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal), [Azure CLI](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough), [Azure PowerShell](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-powershell), and [Terraform](https://learn.hashicorp.com/tutorials/terraform/aks).

In this walkthrough, you will create an AKS cluster using an ARM template and then use Azure CLI to deploy a simple application to the cluster. You will review the design decisions made for the walkthrough, see how the template supports Kubenet for Kubernetes networking, role-based-access-control (RBAC) and how it supports managed identities to communicate with other Azure resources. Finally, you will use a Kubernetes manifest file to define the desired state of the cluster, and test the application.

An ARM template sets you up to being able to deploy AKS clusters and your applications into Pods in your Azure DevOps pipeline or using GitHub actions. You can set the parameters to define the characteristics of the cluster at deployment time.

## Prerequisites

To run this walkthrough, you will need:

*   Azure Account.
*   Have basic understanding of Azure resource groups and ARM templates
*   Understand how to [navigate the Azure portal](https://docs.microsoft.com/en-us/azure/azure-portal/azure-portal-overview).
*   To have completed [Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using an ARM template](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-rm-template). The quickstart provides a quick introduction to the concepts in this article.
*   To run locally, you will need:
    *   Azure CLI, version 2.8.0 or later.
    *   Bash. For Windows, Windows Services for Liniux (WSL) or GitBash.
*   To run in Azure Portal, start [Azure Cloud Shell](https://azure.microsoft.com/en-us/features/cloud-shell) and run in the CLI
*   A high level understanding of [Azure Role Based Access Control (RBAC)](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview), the concept of a built-in role, what an objectId is.


## Design considerations

This walkthrough implements the following design considerations:

*   **Kubenet**. In the example, use Kubenet networking where Azure manages the virtual network resources as the cluster is being deployed. The alternative is Azure Container Networking Interface (CNI) plugin. With CNI pods receive individual IP addresses that can route to other network services. For more information, see [Choose the appropriate network model](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-network#choose-the-appropriate-network-model).
*   **Managed identities**. AKS requires additional resources like load balancers and managed disks in Azure. To create these resources, Azure uses either a _service principal_ or a _managed identity_. If you use managed identity, you do no need to manage a [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals). For more information, see [Use managed identities in Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity).
*   **Kubernetes Role-based-access-control (RBAC)**. Kubernetes provides its own role-based-access control when enabled. It is the way you can dynamically configure policies that regulating access to computer or network resources based on the roles of individual users within your organization. For more information, see [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) in the Kubernetes documentation.
*   **Linux nodes**. You can run [Windows nodes](https://docs.microsoft.com/en-us/azure/aks/windows-container-cli#create-an-aks-cluster) in your AKS cluster that uses CNI, but in this walkthrough we will use Linux.
*   **Virtual machine scale set**. Because we are deploying a single node, you may need to adjust the number of nodes that run your workloads. The cluster autoscaler component can watch for Pods in your cluster that can’t be scheduled because of resource constraints. For more information, see [Automatically scale a cluster to meet application demands on Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler).

In a future blog post, you will learn now to assign an admin group to manage Kubernetes using Azure Active Directory.

Let’s first look at the steps in the walkthrough.


## Steps in the walkthrough

You will take the following steps to deploy:

1.  Start your command prompt
2.  Set environment variables, log in to Azure, and create a resource group
3.  Review the ARM template
4.  Deploy the ARM template
5.  Review what was deployed
6.  Log in to the cluster
7.  Connect to the cluster
8.  Run an application

### Start your command prompt

Open your command prompt on your local machine or start [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview).  
On Windows you can use [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10) or Bash.

Let’s begin by creating an SSH key pair.

### Set environment variables, log in, create resource group

Next, use the following code to log in, set environment variables, and create the resource group:

```sh
SUBSCRIPTION_ID=<your subscription id>
RESOURCE_GROUP_NAME="aks-eus2-aksdays-demo-01"
AKS_NAME="aks-eus2-aksdays-demo-01"
LOCATION="east us 2"
NODE_SIZE="Standard_B2s"
DEPLOYMENT_NAME=$AKS_NAME-$RANDOM

az account set --subscription $SUBSCRIPTION_ID
az group create --name $RESOURCE_GROUP_NAME --location "$LOCATION"
```

### Review the ARM Template
-----------------------

Next copy the ARM template into your directory. In Cloud Shell, you can upload the file.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "aksClusterName": {
            "type": "string",
            "defaultValue": "aks101cluster-vmss",
            "metadata": {
                "description": "The name of the Managed Cluster resource."
            }
        },
        "location": {
            "defaultValue": "[resourceGroup().location]",
            "type": "string",
            "metadata": {
                "description": "The location of AKS resource."
            }
        },
        "dnsPrefix": {
            "type": "string",
            "metadata": {
                "description": "Optional DNS prefix to use with hosted Kubernetes API server FQDN."
            }
        },
        "osDiskSizeGB": {
            "type": "int",
            "defaultValue": 0,
            "metadata": {
                "description": "Disk size (in GiB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize."
            },
            "minValue": 0,
            "maxValue": 1023
        },
        "agentCount": {
            "type": "int",
            "defaultValue": 3,
            "metadata": {
                "description": "The number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production"
            },
            "minValue": 1,
            "maxValue": 100
        },
        "agentVMSize": {
            "type": "string",
            "defaultValue": "Standard_DS2_v2",
            "metadata": {
                "description": "The size of the Virtual Machine."
            }
        },
        "osType": {
            "type": "string",
            "defaultValue": "Linux",
            "allowedValues": [
                "Linux",
                "Windows"
            ],
            "metadata": {
                "description": "The type of operating system."
            }
        }
    },
    "resources": [
        {
            "apiVersion": "2020-09-01",
            "type": "Microsoft.ContainerService/managedClusters",
            "location": "[parameters('location')]",
            "name": "[parameters('aksClusterName')]",
            "tags": {
                "displayname": "AKS Cluster"
            },
            "identity": {
                "type": "SystemAssigned"
            },
            "properties": {
                "kubernetesVersion": "1.18.8",
                "enableRBAC": true,
                "dnsPrefix": "[parameters('dnsPrefix')]",
                "agentPoolProfiles": [
                    {
                        "name": "agentpool",
                        "osDiskSizeGB": "[parameters('osDiskSizeGB')]",
                        "count": "[parameters('agentCount')]",
                        "vmSize": "[parameters('agentVMSize')]",
                        "osType": "[parameters('osType')]",
                        "storageProfile": "ManagedDisks",
                        "type": "VirtualMachineScaleSets",
                        "mode": "System"
                    }
                ]
            }
        }
    ],
    "outputs": {
        "controlPlaneFQDN": {
            "type": "string",
            "value": "[reference(resourceId('Microsoft.ContainerService/managedClusters/', parameters('aksClusterName'))).fqdn]"
        }
    }
}
```

Let’s review some key lines in the ARM template. You will need to pass in:

*   `aksClusterName`. The name of the managed cluster resource. The name is used to create the resource group containing the nodes.
*   `dnsPrefix`. DNS prefix specified when creating the managed cluster.

In the template itself, the following properties are set in the `Microsoft.ContainerService/managedClusters` resource:

*   `identity`. The identity is [system assigned managed identity](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity). Credential rotation for managed identity happens automatically every 46 days according to Azure Active Directory default. For more information how managed identities are used in AKS including the permissions granted to the managed identity, see [Summary of managed identities](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity#summary-of-managed-identities) for Kubernetes.
*   `kubernetesVersion`. The version number needs to include `[major].[minor].[patch]`. To check for supported versions use `az aks get-versions --location $LOCATION --output table`
*   `enableRBAC` Whether to enable [Kubernetes internal Role-Based Access Control](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) to grant users, groups, and service accounts access to only the resources they need. Note that this parameter does not provide for Azure Active Directory RBAC.
*   `agentPoolProfiles.type`. This is set to virtual machine scale sets.

You can review the various properties available for the [latest ARM Template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters).

### Deploy the cluster

Run the following code to deploy the cluster.

```sh
az deployment group create --name $DEPLOYMENT_NAME \
    --resource-group $RESOURCE_GROUP_NAME --template-file "./azuredeploy.json" \
    --parameters aksClusterName=$AKS_NAME dnsPrefix=aks-eus2-aksdays-demo-01 \
    agentCount=1 agentVMSize=$NODE_SIZE
```


The script show how to use `az deployment group create` to deploy the ARM template and uses `--parameters` to provide the deployment parameter values, such as `aksClusterName`, `dnsPrefix`, and a small `agentVMSize`. Note: The The system node pool must use VM sku with more than 2 cores and 4GB memory.

The script then retrieves the output and displays the `controlPlaneFQDN`.

## Review what is deployed


The AKS template deploys the following resources:

*   A resource group that contains:
    *   The nodes
    *   A load balancer
    *   Public IP
    *   Network Security Group (NSG)
    *   Managed identity
    *   Virtual network
    *   Route table
*   A resource group that contains:
    *   The Kubernetes service
    *   The node pools
    *   Kubernet Networking

You can view the deployment in the portal. First, go to the resource group and view the resources deployed as shown in the following illustration.

![](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/ce512-aks-deployment.png?resize=512%2C372&ssl=1)

Go to the resource group that was created for your cluster. It will have a name similar to `MC_aks-eus2-aksdays-demo-01_aks-eus2-aksdays-demo-01_eastus2`. Here you will see the various resources deployed to support Kubernetes service.

![](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/a5eac-aks-resources.png?resize=748%2C217&ssl=1)

In this example, Azure resources are created using [managed identity](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity), which allows Azure to create additional resources such as a load balancer and managed disks.

Let’s log into the cluster.

## Connect to the cluster


Next, install the Kubernetes tools that you will need, and then use AKS to get your credentials

```sh
az aks install-cli
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $AKS_NAME
```

The code installs the tools you will need to interact with Kubernetes, including **kubectl**. And then it downloads credentials and configures the Kubernetes CLI to use them.

To verify the connection to your cluster, use the `kubectl get` to return a list of the cluster nodes.

![kubectl-get-nodes](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/b758d-aksclusterup.png?resize=514%2C51&ssl=1)

```sh
kubectl get nodes
```

## Run an application


Next, let’s use a Kubernetes manifest file defines a desired state for the cluster. In this case, let’s use the example in the Azure quickstart documentation.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
        env:
        - name: ALLOW_EMPTY_PASSWORD
          value: "yes"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
```

Save this file locally as `azure-vote.yaml`.

Let’s do a quick code review before you apply the manifest into Kubernetes. The manifest has four parts separated by `--`. The manifest could have been deployed as [four separate files](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/). But for simplicity in the walkthrough it is a single file here. The file includes two deployments and two services.

*   A [_deployment_](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) is a declarative way to update a Pod and ReplicaSet. The Pod has one or more containers. You describe a desired state in a Deployment, and the Kubernetes Deployment Controller changes the actual state to the desired state at a controlled rate.
*   A [_service_](https://kubernetes.io/docs/concepts/services-networking/service/) is an abstraction which defines a logical set of Pods and a policy by which to access them (sometimes this pattern is called a micro-service).

The **deployment** of `azure-vote-back` has a single container that pulls the `mcr.microsoft.com/oss/bitnami/redis:6.0.8` image and sets its resource sizes. It also defines a _label_ `app: azure-vote-back`.

The **service** of `azure-vote-back` specification creates a new Service object named “azure-vote-back”, which targets TCP port 6379 on any Pod with the `app=azure-vote-back` label.

The labels connect Services to Deployments. Deployments define the Pods.

Next, let’s apply the manifest using `kubectl apply` as in the code sample:

```sh
kubectl apply -f azure-vote.yaml
```

The Pod does not come up right away. To monitor the progress, use:

```sh
kubectl get service azure-vote-front –watch
```

Kubernetes will report back the status of the service. Watch the EXTERNAL-IP column.  Type `ctrl+c` to exit watch.

![kubectl-get-service-watch](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/f1da6-akscluster.png?resize=608%2C51&ssl=1)

When it changes to an public IP address, you can use the external IP address in your browser to go to the application.

![](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/d2f6e-votapp.png?resize=300%2C194&ssl=1)

## Summary


In this walkthrough, you reviewed the design decisions and deployed a Kubernetes cluster. Then you used a manifest to deploy an image into Kubernetes.

## References

*   [Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using an ARM template](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-rm-template)
*   [Use managed identities in Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity)
