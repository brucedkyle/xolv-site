### Requirements, plan for your enterprise Azure Subscription for production

![Cloud Adoption Framework](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/cloudadoptionframework.png?resize=374%2C124&ssl=1)

_Microsoft’s Cloud Adoption Framework_

You can get started in Azure. But soon it becomes time to build your subscriptions for your enterprise. For example, giving unrestricted access to developers can make your devs very agile, but it can also lead to unintended cost consequences. In addition, you will want to have requirements to demonstrate compliance for security, monitoring, and resource access control.

In this article we help organize some thoughts around the strategy and plan for building out your cloud, including a plan that you can put into Azure DevOps.

The [Cloud Adoption Framework](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/) provides guidance for in depth analysis and preparation for your cloud. 

Developing your requirements you will want to recognize that your cloud deployments are ongoing, built around what your business goals. Your requirements should include managing, monitoring, and auditing the use of Azure resources.

## Governance requirements

There are many requirements to meet in setting up your Azure subscriptions:

*   **Resource management**. Define which resources and who may access those resources.
*   **Cost management**. Track cloud usage and expenditures for your Azure resources and assign to cost centers or development teams.
*   **Identity management**. Managing your [identity lifecycles](https://docs.microsoft.com/en-us/azure/active-directory/governance/identity-governance-overview), including role-based-access-control across groups of users, admins, and managing the lifecycle for accessing resources.
*   **Security**. Creating a secure infrastructure, but also being able to show auditor and others the steps you have taken for security.
*   **Deploy applications**. You may migrate existing applications from on premises or other cloud providers. Or you may
*   **Monitor**. Collect and analyze data to audit the performance, health, and availability of your resources.
*   **Protect**. Keep your applications and data available, even with outages that are beyond your control.

## Azure solutions

The Azure documentation describes management as:

> Management refers to the tasks and processes required to maintain your business applications and the resources that support them. Azure has many services and tools that work together to provide complete management.
> 
> [Overview of Management services in Azure](https://docs.microsoft.com/en-us/azure/governance/azure-management)

Azure provides many resources to manage these requirements.

*   **Resource management**. Azure organizes resources in resource groups and resources. Resource groups can be defined in templates, allow access using role-based-access-control (RBAC), and
*   **Management groups** provide a way to manage access, policies, and compliance across multiple subscriptions.
*   **Azure Policy**. Provides the guardrails for your developers, administrators, and users.
*   **Azure Monitor and Log Analytics**. Azure resources for collecting and analyzing data pertaining to the performance, health, and availability of your resources.
*   **Azure cost management** helps you monitor and control Azure spending and optimize resource use.
*   **Azure Security Center** strengthens the security posture of your data centers, and provides advanced threat protection across your hybrid workloads in the cloud.
*   And more.

## Define your requirements

Before deploying your applications at scale, you will want to define your requirements. Those requirements are not set in stone, but will be a touchpoint for your decision making. Here are some topics to be sure to include in your requirements.

*   **Cost**. Cost is the first question I get asked, and it is often last one I can answer. Interestingly, the other requirements will determine cost. And the answer will always be an estimate. Cost is based on consumption. Many decision makers want a single cost for a period of time. Frankly, they are used to that cost structure from their past hardware purchases. But the cloud varies. And it can vary a lot based on your other requirements.
*   **Availability**. How much do you want your application to be available? Are you sure? 99.995% may be attainable, but it will be expensive. It is one thing to backup and restore your cloud application with some downtime. It is another to provide high availability across multiple regions. How long can your enterprise go without access to the cloud? And who and how will you test availability?
*   **Security and compliance**. Which are the compliance standards you want to audit and enforce? What kind of data are you keeping? What are the trade-offs that you are willing to take between availability and confidentiality? Which data will be exposed if a particular resource is breached?
*   **Management**. Who is managing the cloud operations? Who is auditing the cloud security? Who is responsible for mitigating anything that goes wrong?
*   **Identity management**. How are your identities and permissions handled? Who has access to the data? Identity is the new edge for accessing data.
*   **Expertise**. What is the expertise of your teams (development, operations, security)? And how are they keeping up to date on the changes?

Each of these topics has its own lifecycle, meaning there is a starting point, changes made, and retirement. How is your organization managing the lifecycles?

Some places to look for deeper understanding:

*   [**Cloud Adoption Framework**](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/). Provides a roadmap for your cloud setup, migration, development, governance, management. This is proven guidance for your enterprise that helps you create and implement the business and technology strategies. 
*   **[ISO 27001](https://www.iso.org/standard/73906.html)** provides guidance in the form of controls that are designed for any size organization. Azure provides a [blueprint](https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/iso27001/) sample that you can use to look for non-compliance.
*   The **National Institute of Standards and Technology (NIST)**, part of the US Department of Commerce, provides Special Publication 800-144, [Guidelines on Security and Privacy in Public Cloud Computing](http://csrc.nist.gov/publications/nistpubs/800-144/SP800-144.pdf). This 80-page report is comprehensive in both defining cloud computing and providing guidelines for using it in a secure and private manner.
*   A more detailed set of controls is also available from NIST. Azure provides detailed guidance on your responsibilities in implementing [SP 800-53 Rev. 4, Security and Privacy Controls for Federal Information Systems and Organizations](https://csrc.nist.gov/publications/detail/sp/800-53/rev-4/final). It provides a catalog of security and privacy controls for federal information systems and organizations and a process for selecting controls to protect organizational operations.

In future postings in this blog, you learn how to use the Cloud Adoption Framework, the NIST SP 800-53 and ISO 27001 Blueprints to implement the controls in your Azure deployment. And you learn how to adapt each for your cloud.

> Important to remember — the cloud is a journey, not a destination. And your job will be to deploy a new data center. This time, it is in the cloud.

## Define workloads

You may want to run an [digital estate assessment](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/plan/contoso-migration-assessment) to identify workloads that may be a good fit for the cloud. Or you may have already identified cloud-first innovation and development opportunities.

Either way, having a list of applications and a proposed infrastructure is helpful to proceed with your migration and design.

## Design

And I mean “design” as an [imperative verb](https://www.grammarly.com/blog/imperative-verbs/). Initially it is a general design to get an estimate of the ongoing feasibility.

Cloud architecture is about tradeoffs and implementing best practices based on how you work and what you want to accomplish. The cloud comes in lots of sizes, lots of patterns.

![](https://i0.wp.com/azuredays.com/wp-content/uploads/2020/05/image-3.png?resize=618%2C301&ssl=1)

### Cloud design patterns

Azure documentation provides many [patterns for your cloud design](https://docs.microsoft.com/en-us/azure/architecture/patterns/). But you will decide the tradeoffs between availability, data management, messaging, management and monitoring, performance and scale, resiliency, and security.

For example, there are huge tradeoffs between virtual machines and VM sizing, Application Services and Azure Functions, and Kubernetes (AKS). Storage tradeoffs for blobs verses files verses disks attached for VMs, backup storage costs.

## And then … you can estimate a cost

And once those questions are answered, and an architecture designed, then you can estimate a cost.

And that cost varies by how you purchase Azure and your commitment to the cloud. For example, a three-year reserved instance or spot instances may save money.

Once you have the green light, you can create a cloud adoption plan.

## Create a Cloud Adoption Plan

You can create a cloud adoption plan in devops. It is a set of steps that you can deploy into Azure DevOps. 

### Deploy the plan into Azure DevOps

To deploy the cloud adoption plan, open the [Azure DevOps demo generator](https://aka.ms/adopt/plan/generator). This tool will deploy the template to your Azure DevOps tenant. You can then [edit the specifics of your plan in Excel](https://docs.microsoft.com/en-us/azure/devops/boards/backlogs/office/bulk-add-modify-work-items-excel?view=azure-devops).

### Align the plan

Use the [Cloud Adoption Framework strategy and planning template](https://archcenter.blob.core.windows.net/cdn/fusion/readiness/Microsoft-Cloud-Adoption-Framework-Strategy-and-Plan-Template.docx) to organize the your decisions and data points. 

## Next steps

In our next post, get your setting up a your subscription. 

## References

*   [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)
*   [Governance in the Cloud Adoption Framework](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/govern/)
*   [Overview of Management services in Azure](https://docs.microsoft.com/en-us/azure/governance/azure-management)
*   [Monitoring Azure resources](https://docs.microsoft.com/en-us/azure/monitoring/monitoring-overview)
*   [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview)
*   [Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/security-center-intro)
*   [Azure Migrate](https://docs.microsoft.com/en-us/azure/migrate/migrate-overview)
*   [Azure Identity Management and access control security best practices](https://docs.microsoft.com/en-us/azure/security/fundamentals/identity-management-best-practices)
*   [Defining Availability Requirements for Cloud Computing](https://www.petri.com/availability-requirements-for-cloud-computing)
*   Training module for [Microsoft Cloud Adoption Framework for Azure](https://docs.microsoft.com/en-us/learn/modules/microsoft-cloud-adoption-framework-for-azure/)
