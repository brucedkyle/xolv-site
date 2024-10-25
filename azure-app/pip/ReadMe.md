# Public IP Address

This ReadMe assumes you are connecting up a Public IP to AKS using a static ip address.

## Get IP address 

The following CLI can be used to get the IP address

```cli
az network public-ip show --resource-group myResourceGroup --name myAKSPublicIP --query ipAddress --output tsv
```

## Next steps

Do the following three steps with AKS:

1. Grant AKS Network Contributor permission on the resource group
2. Create a load balancer service
3. Apply a DNS label to the service

### Grant AKS Network Contributor permission on the resource group

Get the system assigned managed identity for AKS or whater and assign the resource group Network Contributor permission.

### Create a load balancer service

Then create a _LoadBalancer_ service. See [Create a service using the static IP address](https://docs.microsoft.com/en-us/azure/aks/static-ip#create-a-service-using-the-static-ip-address)

```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-resource-group: myResourceGroup
  name: azure-load-balancer
spec:
  loadBalancerIP: 40.121.183.52
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-load-balancer
```
Apply the service.

```cli
kubectl apply -f load-balancer-service.yaml
```
### Apply a DNS label to the service

```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/azure-dns-label-name: myserviceuniquelabel
  name: azure-load-balancer
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-load-balancer
```
Then apply the DNS label.

To publish the service on your own domain, see [Azure DNS](https://azure.microsoft.com/services/dns/) and the [external-dns](https://github.com/kubernetes-sigs/external-dns) project.

## References

[Use a static public IP address and DNS label with the Azure Kubernetes Service (AKS) load balancer](https://docs.microsoft.com/en-us/azure/aks/static-ip)