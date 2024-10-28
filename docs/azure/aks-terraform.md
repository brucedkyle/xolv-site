# Walkthrough: Create Azure Kubernetes Service (AKS) using Terraform

![](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/e0dfb-terraform.png?resize=300%2C150&ssl=1)When you are building your cloud infrastructure, you can think of it as code. _Infrastructure as code_ means that the virtual machines, networking, and storage can all be thought of as code. On Azure, you can build your infrastructure using Azure Resource Manager (ARM) templates and deploy using PowerShell. You could also use PowerShell or Azure CLI to express your infrastructure. Many enterprises use [Terraform](https://www.terraform.io/), an open source infrastructure as code provider by [HashiCorp](https://www.hashicorp.com/), to build, change, version cloud infrastructure.

You can use Terraform across multiple platforms, including Amazon Web Services, IBM Cloud (formerly Bluemix), Google Cloud Platform, DigitalOcean, Linode, Microsoft Azure, Oracle Cloud Infrastructure, OVH, Scaleway VMware vSphere or Open Telekom Cloud, OpenNebula and OpenStack. In this article, we’ll explore Azure. At a high level, you write the configuration of your infrastructure in Terraform files that can describe the infrastructure of a single application or of your entire data center, and then apply it to the target cloud (in this case Azure).

In this article, you install Terraform and configure it, create the Terraform configuration _plans_ for two resource groups an AKS cluster and Azure Log Analytics workspace, and _apply_ the plans into Azure.

When you deploy the infrastructure, Terraform figures out the what changes changes to reach the desired state and then executes your configuration to build your cloud in its desired state.

In this article you will use a new JSON-like [syntax](https://www.terraform.io/docs/configuration/syntax.html) of HCL to describe your infrastructure, then use the Terraform command line tool to build an _execution plan_, create a resource graph of your resources. You apply the plan for Terraform tp figure out what to change and in what order, and then will execute those changes.

## Prerequisites

You will need:

*   An Azure subscription and general understanding of Azure resource groups and resources.
*   Contributor role access on the subscription.
*   This demo uses Ubuntu 18.04 LTS on Linux on WSL on Windows or an similar Bash shell.
*   [The Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
*   Azure CLI for AKS so you can use kubectl. To install, use: `az aks install-cli`.
*   [Visual Studio Code](https://code.visualstudio.com/) or another editor.
*   The lightweight and flexible command-line JSON processor, [jq](https://stedolan.github.io/jq/download/).
*   To use the graphics, install [GraphViz](https://graphviz.gitlab.io/_pages/Download/Download_windows.html).

For many of the requirements, you could use [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview). Azure CLI, Terraform, and jq are already installed in Cloud Shell. If you are using Visual Studio Code, optionally install the Azure Terraform extension from Microsoft, [`ms-azuretools.vscode-azureterraform`](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform). The extension lets you run Terraform commands from inside VS Code, such as : `init`, `plan`, `apply`, `validate`, `refresh` and `destroy`. It also includes a visualizer.

## Core Terraform workflow

The core Terraform workflow has three steps:

1.  **Write**. Author infrastructure as code.
2.  **Plan**. Preview changes before applying.
3.  **Apply**. Provision reproducible infrastructure.

In this article you will repeat the pattern to install the Resource group, the Log Analytics workspace, and AKS. But first, let’s set up Terraform and configure Terraform for Azure.

## Install Terraform

Use these steps to install Terraform:

1.  [Download Terraform](https://www.terraform.io/downloads.html) for your platform.
2.  Unzip the file
3.  Either moving it to a directory included in your system’s [`PATH`](https://superuser.com/questions/284342/what-are-path-and-other-environment-variables-and-how-can-i-set-or-use-them) or add the location where you unzipped Terraform to your `PATH`.
4.  Verify Terraform is running using `terraform --version`.

```sh
terraform –version
```

### Configure Terraform for Azure

To create resources in Azure, Terraform will need permissions. In this Terraform walkthrough, use a [_service principle_](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals). The security principal defines the access policy and permissions for the user or application in the Azure AD tenant.

To configure Terraform you will need to:

1.  Create a service principal for Terraform [to access Azure](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli).
2.  Set the service principal to environment variables that Terraform uses.

The following sample creates your service principal using [`az ad sp create-for-rbac`](https://docs.microsoft.com/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac).

```sh
## Requires jq .. to install see: https://stedolan.github.io/jq/download/

# set some environment variables to use to create the service principal
export SUBSCRIPTION_ID=3464892e-e827-4752-bad5-b4f93c00dbbe
export PROJECT_NAME="wus2-azure-aks-terraform-demo"

az account set --subscription="${SUBSCRIPTION_ID}"

# create the service principal to the subscription scope and save it to an auth file
TF_SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --skip-assignment --role 'Contributor' --name rbac-tf-$PROJECT_NAME --output json --scopes="/subscriptions/${SUBSCRIPTION_ID}")

export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export ARM_CLIENT_ID=$(echo $TF_SERVICE_PRINCIPAL | jq '.appId')
export ARM_CLIENT_SECRET=$(echo $TF_SERVICE_PRINCIPAL | jq '.password')
export ARM_TENANT_ID=$(echo $TF_SERVICE_PRINCIPAL | jq '.tenant')

# Not needed for public, required for usgovernment, german, china
export ARM_ENVIRONMENT=public
```

It uses a name for you to identify it within Azure Active Directory. The service principal must have contributor permission in the subscription in order to create resource groups. `--skip-assignment` allows the service principal to access resources under the current subscription.

Next, the sample sets the environment variables that Terraform uses. The [Azure Terraform modules](https://registry.terraform.io/modules/Azure) uses the following environment variables.

*   `ARM_SUBSCRIPTION_ID`
*   `ARM_CLIENT_ID`
*   `ARM_CLIENT_SECRET`
*   `ARM_TENANT_ID`
*   `ARM_ENVIRONMENT`

Use `ARM_ENVIROMENT` to specify the cloud, such as China, Germany, or GovCloud.

Next although not required for the resource group, you will soon need to create an SSH key. You will use when you create your Kubernetes cluster.

```sh
ssh-keygen -t rsa -b 4096 -m PEM

# display the public key
cat $HOME/.ssh/id_rsa.pub
```

The public key is put into your home directory `~/.ssh/id_rsa.pub`.

## Create a resource group using HCL

In this step, you will use _HashiCorp Configuration Language (HCL)_ to define a resource group and then use Terraform to deploy the resource group to Azure. The syntax of HCL is similar to JSON, but adds the idea of providing names to the object. The steps to create a resource group are:

1.  Define the Azure provider in a file named `main.tf`
2.  Create the resource group in a file named `resourcegroup.tf`
3.  Define the variables used by the resource group definition in a file named `variables.tf`
4.  Create a Terraform plan
5.  Apply the Terraform plan into Azure

### Create main.tf

Let’s first create a directory and use your editor to create a file named `main.tf` Start by creating the directory and opening your editor. [https://gist.github.com/brucedkyle/121d11c763b5182cdaaa82b6b1b08ec8#file-create-main-bash](https://gist.github.com/brucedkyle/121d11c763b5182cdaaa82b6b1b08ec8#file-create-main-bash) In main.tf, define the Terraform version and that you are targeting Azure.

```yaml
provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using Terraform version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
}
```

Save the file and exit the editor.

### Create resourcegroup.tf

Next, create `resourcegroup.tf` in the same directory.

```sh
code resourcegroup.tf
```

Use the following HCL in resouregroup.tf:


```yaml
# Defines the main resource group

resource "azurerm_resource_group" "rg" {
  name = "${var.resource_group_prefix}${var.project_name}-${var.environment}"
  location = var.project_location
  tags = {
        "Cost Center" = var.project_name
        Environment = var.environment
        Team = "infrastructure"
        Project = var.project_name
    }
}
```

Save the file. Notice that Terraform uses its own format where `resource "azurerm_resource_group"` provides Terraform with kind of resource to create and `"rg"` is a name you can use later to reference this particular resource group.

### Create variables.tf

Next, create a new file for the variables named `variables.tf`.

```sh
code variables.tf
```


Use the following content to set the default values of the variables. There are more variables that you need to create a resource group.. There are more variables that you need to create a resource group.

```
variable resource_group_prefix {
  default = "rg-"
}

variable project_name {
  default = "wus2-aksdemo"
}

variable project_location {
  default = "West US 2"
}

variable environment {
  default = "devtest"
}

variable company_name {
  default = "azuredays"
}
```

Use a project name based on your naming conventions. In this case, the name includes the region, project name, and environment. Use your own company name without spaces.

Save the file.

## Create a Terraform plan

Next, we will take several steps to first initialize Terraform, then have Terraform figure out the dependencies and the differences between what exists in Azure. create a plan, then apply the plan into Azure. Here are the steps:

1.  Initiate Terraform plan using `terraform init`
2.  Use Terraform to create a plan for creating the resource groups by using `terraform plan`
3.  Apply the plan to Azure by using `terraform apply`
4.  Query Azure to see that the resource group was created

To initialize Terraform to be sure you have all of the requirements in place.

```sh
terraform init
```

You will see this response.

![terraforminit](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/b7702-terraforminit.png?resize=512%2C194&ssl=1)

When you are building larger infrastructure, you may want to check for typos and be sure you have all your variables. You can validate using:

```sh
terraform validate
```

### Create a Terraform plan

Terraform compares the requested resources to the state information saved by Terraform and then outputs the planned execution. You have not yet created your Azure resources.

```sh
terraform plan -var project_name=$PROJECT_NAME -out out.plan
```

Note that in this command, you change the `project_name` variable from the command line. And you send the output to an `out.plan` file.

Once you run the command, you should see the result of the plan, shown in the following illustration.

![](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/ed7f9-terraformplan.png?resize=512%2C393&ssl=1)

### Apply the Terraform plan

Once the plan is created, you can then apply the plan.

```sh
terraform apply "out.plan"
```


Terraform will ask to confirm that you want to make the changes.

You have now deployed your resource groups. you can test that the resource group was created. Use `terraform show` to see the state of your Terraform deployment.

```sh
terraform show
```


Terraform will show the resource it has created.

![terraform apply](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/c140a-terraformapply.png?resize=512%2C102&ssl=1)

And you can check it in Azure. The following code returns a list of resource groups with the `Project` tag set to the project name.

```sh
az group list --subscription $SUBSCRIPTION_ID --tag "Project=$PROJECT_NAME"
```

The result displays the resource group properties from the Azure CLI.

![Terraform deploy response](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/3dae9-terraformdeploy.png?resize=512%2C160&ssl=1)

In this step, you defined the resources, created a plan, and applied the plan into Azure. Next, let’s add resources to create the Log Analytics workspace to monitor the Azure Kubernetes Service (AKS) cluster.

## Create Log Analytics workspace using HCL

It a best practice to provide log analytics for your container. To give you visibility into the performance of your cluster, [Azure Monitor for containers](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-overview) collects memory and processor metrics from controllers, nodes, and containers that are available in Kubernetes. Container logs are also collected.

This following chart from the Azure documentation shows the various ways metrics and logs are gathered.

![](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/200bf-azmon-containers-architecture-01.png?resize=512%2C236&ssl=1)

To create log analytics resources, use your text editor to add a new HCL file named `loganalytics.tf` in the same directory.

```yaml
### For Log Analytics Workspace
variable log_analytics_workspace_prefix {
    default = "workspace-"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "Central US"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}
```

Save the file. Note that in this configuration file, you create a shared resource group and create log analytics workspace and logs for multiple applications to use.

As the final step in this section, validate, create a plan into an file named `out.plan`, and then apply that plan.

```sh
# init
terraform init

# verify
terraform validate

# plan and send the plan to an out.plan file
terraform plan -var project_name=$PROJECT_NAME -out out.plan

# apply the plan from the out.plan file
terraform apply out.plan

terraform show
```

The result is that two resources are created in the shared resource group. You can find yours in the Azure portal.

![](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/11/ee57f-loganalyticsworkspace.png?w=512&ssl=1)

In this step, you created and HCL file configuring the Log Analytics resources, created an out plan, and then applied the plans.

Next, let’s create the Kubernetes cluster.

## Create Kubernetes cluster using HCL

You are now ready to create the cluster. This will be take a few steps:

1.  Create a service principal for Azure to use to create the cluster
2.  Add a HCL file to configure the AKS resources
3.  Add a HCL file to define the output from Terraform
4.  Add a HCL variables file for AKS parameters
5.  Validate, plan, and apply the resources

Let’s complete each step.

**Step 1.** Create the service principal and assign to environment variables. You will send those environment variables into the Terraform plan.

```sh
#create service principal for AKS to use
az ad sp create-for-rbac --name "rbac-$PROJECT_NAME" --skip-assignment

# retrieve the appId and the password 
AKS_SERVICE_PRINCIPAL=$(az ad sp list --display-name "rbac-$PROJECT_NAME" --query "[].{id:appId, id.password}" --output json)
export TF_VAR_client_id=$(echo $AKS_SERVICE_PRINCIPAL | jq '.appId')
export TF_VAR_client_secret=$(echo $AKS_SERVICE_PRINCIPAL | jq '.password')

export TF_VAR_client_id=$(echo $TF_SERVICEPRINCIPAL | jq '.appId')
export TF_VAR_client_secret=$(echo $TF_SERVICEPRINCIPAL | jq '.password')

# get the public key file location
export TF_VAR_ssh_public_key=$HOME/.ssh/id_rsa.pub
```

This is a different service principal from the one used in a previous section. The service principal in the previous section gave Terraform permissions to interact with Azure Resource Manager. This one gives the AKS service permission to create resources.

**Step 2.** To create the cluster add a file named `aks.tf` in the same folder that contains the Terraform configuration for the cluster. The file provides the configuration for the cluster. Use the following code.

```yaml
resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = azurerm_resource_group.rg_aks.location
    resource_group_name = azurerm_resource_group.rg_aks.name
    dns_prefix          = var.dns_prefix

    linux_profile {
        admin_username = var.admin_name

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_F1"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
        }
    }

    tags = {
        Environment = var.environment
    }
}
```


**Step 3.** Next, provide a file that describes the output. The file, `output.tf` tells Terraform the values to return. It will provide the information you will need to log into the cluster.

```yaml
output "client_key" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
}

output "client_certificate" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
}

output "cluster_password" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.password
}

output "kube_config" {
    value = azurerm_kubernetes_cluster.k8s.kube_config_raw
}

output "host" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}
```

The output keyword in HCL specifies the output attributes. The values can be traced from the resource `azurerm_kubernetes_cluster.k8s` that you created in your resource. The attributes are exported by Terraform. In this case, the values export [attributes of the Kubernetes cluster resource](https://www.terraform.io/docs/providers/azurerm/d/kubernetes_cluster.html#attributes-reference). In particular, the values are found in the the `kube_config` and the `kube_config_raw` attributes.

**Step 4.** Next you will want a file that provides the variables. Create a file named `var-aks.tf` with the following content.

```yaml
variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "aksdemo"
}

variable cluster_name {
    default = "aksdemo"
}
```

**Step 5.** Validate, plan, and apply the resources. You can either provide the variables for which there is no defined default value, or provide them on the command line when you construction the plan. One of the important variables is the SSH key file location. Let’s set those variables using the environment variables that you created in the first steps. In this case, read in the public ssh key locally.

```sh
terraform plan -var project_name=$PROJECT_NAME -var 'client_id=$TF_VAR_client_id' -var 'client_secret=$TF_VAR_client_secret' -var 'ssh_public_key=$TF_VAR_ssh_public_key' -out out.plan
```

## Log into the cluster


Now that we’ve stood up the cluster, let’s log in. The values you need to log in was generated by Step 5 in the previous section where you applied the Terraform configuration to Azure. You need to extract the values that Terraform generated as output and use those data to log in to the cluster.

The following code shows how to get the output using `terraform output kube_config`, which extracts the value of an output variable from the state file. Next, set the values inside `kube_config` into a file named `azurek8s`. Then you can then set an environment variable, `KUBECONFIG` that `kubectl` recognizes as containing the secrets needed to log into the cluster.

```
# extracts the value of an output variable kube_config from the state file
echo "$(terraform output kube_config)" > ./azurek8s

# set the KUBECONFIG to that file
export KUBECONFIG=./azurek8s

# Log into the cluster using the KUBECONFIG data
kubectl get nodes
```

For more information about the `KUBECONFIG` environment variable, see [Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/).

When all goes well, you log into your cluster and see the nodes. At this point you can use `kubedtl` commands to install and operation your Kubernetes Deployments and Services.

## Visualize the dependencies Terraform
------------------------------------

Create an SVG file of the Terraform dependencies. You can view the SVG file in your favorite browser.

```sh
# install GraphViz
sudo apt install graphviz

# creates a dot file that can be translated by GraphViz
terraform graph | dot -Tsvg > graph.svg

# open graph.svg in your favorite browser
```

In this tutorial, you used Terraform created a resource group, log analytics workspace, and Kubernetes cluster, and logged into the cluster to see the nodes.

And you learned that Terraform creates a plan that notifies you of destructive changes before you apply the plan.

## Next steps


*   This sample shows how you can deploy a basic AKS. To use RBAC, you will want to provide additional information. See [](https://github.com/PixelRobots/terraform-aks-rbac-azure-ad#create-a-rbac-azure-kubernetes-services-aks-cluster-with-azure-active-directory-using-terraform)Create a [RBAC Azure Kubernetes Services (AKS) cluster with Azure Active Directory using Terraform](https://github.com/PixelRobots/terraform-aks-rbac-azure-ad) on GitHub.
*   If you are working as a team, you will probably want to use Terraform backend to store the state of your Azure deployments. For more information, see [azurerm](https://www.terraform.io/docs/backends/types/azurerm.html) backend.
*   Learn how to [Deploying Terraform Infrastructure using Azure DevOps Pipelines Step by Step (Advanced)](https://medium.com/@gmusumeci/deploying-terraform-infrastructure-using-azure-devops-pipelines-step-by-step-advanced-1281b4ee15d1)
*   Explore the existing Terraform configuration files available on GitHub. See [terraform-provider-azurerm](https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples)

## References

*   [The Core Terraform Workflow](https://www.terraform.io/guides/core-workflow.html)
*   [Terraform on Azure documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/)
*   [Tutorial: Create a Kubernetes cluster with Azure Kubernetes Service using Terraform](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks)
*   [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html) in the Terraform documentation.
