# Deploy Cloud Native PostgreSQL

In this tutorial, you will deploy Cloud Native PostgreSQL directly using the Operator manifest using `kubectl`. 

> NOTE: This Operator will not show up in **Installed Operators** in OpenShift control panel. It needs the _OperatorGroup_.

The operator can be installed like any other resource in Kubernetes, through a YAML manifest applied via kubectl.

You can install the latest operator manifest as follows:

```sh
kubectl apply -f \
  https://get.enterprisedb.io/cnp/postgresql-operator-1.8.0.yaml
```

Once you have run the kubectl command, Cloud Native PostgreSQL will be installed in your Kubernetes cluster.

You can verify that with:

```
kubectl get deploy -n postgresql-operator-system postgresql-operator-controller-manager
```

For more information, see [EDB docs Cloud Native PostgreSQL](https://www.enterprisedb.com/docs/kubernetes/cloud_native_postgresql/installation_upgrade/)
