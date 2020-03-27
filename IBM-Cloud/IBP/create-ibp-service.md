* create IKS cluster - check the supported k8s version in IBP docs and set cluster version accordingly
* [Install logDNA agent](../observability/logDNA/logDNA.md)
* [Install Sysdig Monitor agent](../observability/SysDig/Sysdig.md)
* [Install falco probe](../observability/falco/installing-falco.md)
* create IBP service instance
```
ibmcloud resource service-instance-create <service instance name> blockchain standard <location, eg au-syd> -g <resource group>
```
* provide cluster to blockchain service
  * In cloud console, navigate to blockchain service instance
  * from Manage tab, select step to *Link an IBM Cloud Kubernetes Service Cluster*
  * Select the cluster
  * click next
* create service credentials key to access the service

```
ibmcloud resource service-key-create <Service key name. eg blockchain-key-admin> Administrator --instance-name <service instance name>
```
 