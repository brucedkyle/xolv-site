# Install Elastic Cloud on Kubernetes (Elastic Kubernetes Operator) using the CLI

Elastic Cloud on Kubernetes (ECK) is an official open source operator designed especially for the Elastic Stack (ELK). It lets you automatically deployment, provisioning, management, and orchestration of Elasticsearch, Kibana, APM Server, Beats, Enterprise Search, Elastic Agent and Elastic Maps Server on Kubernetes. ECK provides features like monitoring clusters, automated upgrades, scheduled backups, and dynamic scalability of local storage.

Following the instructions in the Red Hat OpenShift documentation [Install cluster logging using the CLI](https://docs.openshift.com/container-platform/4.6/logging/cluster-logging-deploying.html#cluster-logging-deploy-cli_cluster-logging-deploying)

In this section, you will:

- Create **Namespaces** for the Elasticsearch Operator and for the Cluster Logging Operator
- Install the OpenShift Elasticsearch Operator's
    - Operator Group
    - Subscription
- Install the Cluster Logging Operator's
    - Operator Group
    - Subscription
    - Instance
- Verify the installation by listing the pods

## Definitions

[**Operator Lifecycle Manager (OLM)**](https://docs.openshift.com/container-platform/4.7/operators/understanding/olm/olm-understanding-olm.html) helps users install, update, and manage the lifecycle of Kubernetes native applications (Operators) and their associated services running across their OpenShift Container Platform clusters. 

[**Operator Group**](https://docs.openshift.com/container-platform/4.7/operators/understanding/olm/olm-understanding-operatorgroups.html) provides multitenant configuration to OLM-installed Operators. An Operator group selects target namespaces in which to generate required RBAC access for its member Operators.

[**Subscription**](https://docs.openshift.com/container-platform/4.6/rest_api/operatorhub_apis/subscription-operators-coreos-com-v1alpha1.html) keeps operators up to date by tracking changes to Catalogs. A subscription is optional.

<!--
In the description, it recommends that this operator be installed in the `openshift-operators-redhat` namespace to
properly support the Cluster Logging and Jaeger use cases.

3. Define an Operator group

An Operator group, defined by an `OperatorGroup` object, selects target namespaces in which to generate required RBAC access for all Operators in the same namespace as the Operator group. 

> If the Operator you intend to install uses the `AllNamespaces`, then the openshift-operators namespace already has an appropriate Operator group in place.

In this case, the description shows: 

```text
      Install Modes:
        Supported:  true
        Type:       OwnNamespace
        Supported:  false
        Type:       SingleNamespace
        Supported:  false
        Type:       MultiNamespace
        Supported:  true
        Type:       AllNamespaces
```

> The web console version of this procedure handles the creation of the OperatorGroup and Subscription objects automatically behind the scenes for you when choosing SingleNamespace mode.

If your Operator does not support `AllNamespaces`, see [Installing from OperatorHub using the CLI](https://docs.openshift.com/container-platform/4.6/operators/user/olm-installing-operators-in-namespace.html#olm-installing-operator-from-operatorhub-using-cli_olm-installing-operators-in-namespace)

3. Create a `Subscription` object

```sh
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators 
spec:
  channel: stable 
  name: elasticsearch-operator
  source: redhat-operators 
  sourceNamespace: openshift-marketplace 
EOF
```

If an Operator is available through multiple channels, you can choose which channel you want to subscribe to. For example, to deploy from the `stable` channel, if available, select it from the list.

At this point, OLM is now aware of the selected Operator. A cluster service version (CSV) for the Operator should appear in the target namespace, and APIs provided by the Operator should be available for creation.
-->

## See what is available in the OperatorHub marketplace

Get list from marketplace

```sh
oc get packagemanifests -n openshift-marketplace
```

Returns a long list that includes `elasticsearch-operator`.

2. Inspect the desired Operator

```sh
oc describe packagemanifests elasticsearch-operator -n openshift-marketplace
```

In the description, it recommends that this operator be installed in the `openshift-operators-redhat` namespace to
properly support the Cluster Logging and Jaeger use cases.

## Steps to deploy Elasticsearch from CLI

### 1. Create Namespaces

Create a namespace for the OpenShift Elasticsearch Operator:

```sh
cat <<EOF | oc create -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-operators-redhat 
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
EOF
```

Note: You must specify the `openshift-operators-redhat` namespace. 

Next, create a namespace for the Cluster Logging Operator:

```sh
cat <<EOF | oc create -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-logging
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
EOF
```

### 2. Install the OpenShift Elasticsearch Operator by creating:

- Operator Group object
- Subscription object

An Operator group, defined by an `OperatorGroup` object, selects target namespaces in which to generate required RBAC access for all Operators in the same namespace as the Operator group. 

> If the Operator you intend to install uses the `AllNamespaces`, then the openshift-operators namespace already has an appropriate Operator group in place.

```sh
cat <<EOF | oc create -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-operators-redhat
  namespace: openshift-operators-redhat 
spec: {}
EOF
```

A Subscription object describes the namespace to the OpenShift Elasticsearch Operator.

```sh
cat <<EOF | oc create -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: "elasticsearch-operator"
  namespace: "openshift-operators-redhat" 
spec:
  channel: "4.6" 
  installPlanApproval: "Automatic"
  source: "redhat-operators" 
  sourceNamespace: "openshift-marketplace"
  name: "elasticsearch-operator"
EOF
```

You must specify the `openshift-operators-redhat` namespace.
Specify `4.6` as the channel.

Verify the Operator installation.

```sh
oc get csv --all-namespaces
```

There should be an OpenShift Elasticsearch Operator in each namespace. 

### 3. Install the Cluster Logging Operator

Create a OperatorGroup for the Cluster Logging Operator and subscribe to the namespace using:

```sh
cat <<EOF | oc create -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: cluster-logging
  namespace: openshift-logging 
spec:
  targetNamespaces:
  - openshift-logging 
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cluster-logging
  namespace: openshift-logging 
spec:
  channel: "4.6" 
  name: cluster-logging
  source: redhat-operators 
  sourceNamespace: openshift-marketplace
EOF
```
The Cluster Logging Operator is installed to the openshift-logging namespace.

Verify using:

```sh
oc get csv -n openshift-logging
```

### 4. Create a Cluster Logging instance

Create an instance object for Cluster Logging Operator.

```sh
cat <<EOF | oc create -f -
apiVersion: "logging.openshift.io/v1"
kind: "ClusterLogging"
metadata:
  name: "instance" 
  namespace: "openshift-logging"
spec:
  managementState: "Managed"  
  logStore:
    type: "elasticsearch"  
    retentionPolicy: 
      application:
        maxAge: 1d
      infra:
        maxAge: 7d
      audit:
        maxAge: 7d
    elasticsearch:
      nodeCount: 3 
      storage:
        storageClassName: "<storage-class-name>" 
        size: 200G
      resources: 
        requests:
          memory: "8Gi"
      proxy: 
        resources:
          limits:
            memory: 256Mi
          requests:
             memory: 256Mi
      redundancyPolicy: "SingleRedundancy"
  visualization:
    type: "kibana"  
    kibana:
      replicas: 1
  curation:
    type: "curator"
    curator:
      schedule: "30 3 * * *" 
  collection:
    logs:
      type: "fluentd"  
      fluentd: {}
EOF
```

This creates the Cluster Logging components, the Elasticsearch custom resource and components, and the Kibana interface.

### 5. Verify logging

Verify using:

```sh
oc get pods -n openshift-logging
```

### 6. Post-installation tasks

If you plan to use Kibana, you must [manually create your Kibana index patterns and visualizations](https://docs.openshift.com/container-platform/4.6/logging/cluster-logging-deploying.html#cluster-logging-visualizer-indices_cluster-logging-deploying) to explore and visualize data in Kibana.

If your cluster network provider enforces network isolation, [allow network traffic between the projects that contain the OpenShift Logging operators](https://docs.openshift.com/container-platform/4.6/logging/cluster-logging-deploying.html#cluster-logging-deploy-multitenant_cluster-logging-deploying).
