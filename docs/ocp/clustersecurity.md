# Red Hat Advanced Cluster Security for Kubernetes (RHACS)

[Red Hat Advanced Cluster Security (ACS)](https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes) for Kubernetes is the pioneering Kubernetes-native security platform, equipping organizations to more securely build, deploy, and run cloud-native applications. The solution helps protect containerized Kubernetes workloads in all major clouds and hybrid platforms, including:

- Red Hat OpenShift
- Amazon Elastic Kubernetes Service (EKS)
- Microsoft Azure Kubernetes Service (AKS)
- Google Kubernetes Engine (GKE)

## Use cases

Key use cases:

- **Vulnerability management**. Implement risk-based vulnerability management that spans the full application life cycle.
- **Compliance**. Ensure your cloud native environment is compliant with industry standards and best practices such as CIS Benchmarks, NIST, PCI, and HIPAA.
- **Configuration management**.  Automate configuration best practices to help prevent security misconfigurations in the build pipeline and deployments.
- **Threat detection and response**.  Use behavioral analysis, rules, and allow-listing to understand runtime behavior and detect and respond to threats.

## DevSecOps

Red Hat Advanced Cluster Security integrates with DevOps and security tools to help you mitigate threats and enforce security policies that minimize operational risk to your applications within your Kubernetes environment.

Red Hat Advanced Cluster Security reduces the time and effort needed to implement security by acting as a common source of truth, so you can streamline security analysis, investigation, and remediation.

For more information, see [What is DevSecOps?](https://www.redhat.com/en/topics/devops/what-is-devsecops#built-for-containers-and-microservices).

## Features and benefits of Red Hat Advanced Cluster Security for Kubernetes

**Lower operational cost**

- Guide development, operations, and security teams towards using a common language and source of truth—driving down the operational costs of team silos.
- Use Kubernetes-native controls across the build, deploy, and runtime phases of the application for better visibility and management of vulnerabilities, policy and configuration violations, and application runtime behavior.
- Reduce the cost of addressing a security issue by catching and fixing it in the development stage.

**Reduce operational risk**

- Align security and infrastructure to reduce application downtime using built-in Kubernetes capabilities, such as Kubernetes network policies for segmentation and admission controller for security policy enforcement.
- Mitigate threats using Kubernetes-native security controls to enforce security policies, minimizing potential impacts to your applications and infrastructure operations. For example, using controls to contain a successful breach by automatically instructing Kubernetes to scale suspicious pods to zero or kill then restart instances of breached applications.

**Increase developer productivity**

- Take advantage of Kubernetes and existing continuous integration and continuous delivery (CI/CD) tooling to provide integrated security guardrails supporting developer velocity while still maintaining the desired security posture. 
- Accelerate your organization’s pace of innovation and provide developers actionable guidance by standardizing on Kubernetes as the common platform for declarative and continuous security across development, security, and operations.

## Secure the software supply chain

By integrating with your CI/CD pipelines and image registries, Red Hat Advanced Cluster Security provides continuous scanning and assurance. By shifting security left, vulnerable and misconfigured images can be remediated within the same developer environment with real-time feedback and alerts. Integration with Cosign/sigstore delivers security attestation for your assets, including image and deployment signing, for security validation and tamper detection.

## RHACS Operator

A Kubernetes _operator_ is a method of packaging, deploying, and managing a Kubernetes application.

Using the [RHACS](https://www.openshift.com/products/kubernetes-security) operator, you can configure RHACS like an expert operator by taking advantage of the operational knowledge built into the operator and exposed as a custom resource. 

The Red Hat Advanced Cluster Security operator supports the following two custom resources:

- Central custom resource
- SecuredCluster custom resource

### Central custom resource

The **Central custom resource** allows users to configure Central services. Central is the management control plane and user interface for RHACS. Central includes the following services:

- **Central**. Central is the RHACS application management interface and services.
- **Scanner**. Scanner is the StackRox vulnerability scanner, a Red Hat developed and certified scanner for the container images and associated databases.

### SecuredCluster custom resource

The **SecuredCluster custom resource** allows users to configure SecuredCluster services. Secured Cluster Services manages the components of RHACS necessary to secure your OpenShift cluster. SecuredCluster includes the following services:

-- **Sensor**. Sensor is the service responsible for analyzing and monitoring the cluster.
- **Collector**. Collector analyzes and monitors container activity on Kubernetes nodes.
- **Admission Control**. Admission Controller is the validating webhook designed to enforce and monitor events against the OpenShift/Kubernetes API server.

## Configuration options

The operator’s default configuration settings are set to a “monitor” security policy, allowing users time to analyze their typical behavior, set policies and enforce the created rules when comfortable. As you become acquainted with RHACS, it will be essential to understand the configuration options and adjust the settings to fit your requirements.

One of the main benefits of operators is the configuration capabilities that are given to the users. RHACS users can alter a significant amount of Central services and the SecuredCluster service settings. For common settings, see [Useful Configuration Options](https://cloud.redhat.com/blog/the-advanced-cluster-security-operator-is-here.-what-you-need-to-know-and-how-to-get-started).

See [Generating and applying an init bundle for RHACS on Red Hat OpenShift](https://docs.openshift.com/acs/installing/install-ocp-operator.html) for a complete list.

## Next steps

See [A layered approach to container and Kubernetes security](https://www.redhat.com/en/resources/layered-approach-container-kubernetes-security-whitepaper) whitepaper.

## Reference

- [Red Hat Advanced Cluster Security for Kubernetes](https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes)
- Datasheet [Red Hat Advanced Cluster Security for Kubernetes](https://www.redhat.com/en/resources/advanced-cluster-security-for-kubernetes-datasheet)
- [The Advanced Cluster Security Operator Is Here. What You Need to Know and How to Get Started](https://cloud.redhat.com/blog/the-advanced-cluster-security-operator-is-here.-what-you-need-to-know-and-how-to-get-started)

