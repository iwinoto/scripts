
## General rule for IBM Cloud URL to service instance 
**Cloud Object Storage and IKS are exceptions to this pattern**

URL patterns
- [General rule for IBM Cloud URL to service instance](#general-rule-for-ibm-cloud-url-to-service-instance)
  - [URL for plarform services](#url-for-plarform-services)
  - [Cloud Object storage](#cloud-object-storage)
  - [Kubernetes service](#kubernetes-service)

### URL for plarform services

For platform services, service instance URL pattern is:
```
https://cloud.ibm.com/services/<service short name>/<service instance crn>
```

Service instance crn will contain service shortname in the fifth stanza.

Use IBM Cloud CLI to list the services and a `jq` query to transpose the output and optionally select the service.

```
ibmcloud resource service-instances --output json | jq '.[] | select(.name=="DEVD-LYGON-CLOUDANT") | {name, id, dashboard_url, resource_id, resource_plan_id}'
```

From the output, copy the `resource_id` value to the `<service instance crn>` location in the base URL. Replace any `/` characters in the `resource_id` with the uuencoded equivalent `%2F` (the `:` does not need to be encoded).

Replace the `<service shortname>` from the base URL with shortname from the service instance ID.

```
https://cloud.ibm.com/services/cloudantnosqldb/crn:v1:bluemix:public:cloudantnosqldb:au-syd:a%2Fc15ecdd5890bdc705dd4e448a0a4b68d:15d9809e-7e02-4d27-874e-5e2f199a3ce6::
```

### Cloud Object storage
Cloud object storage instance URL pattern is
```
https://cloud.ibm.com/objectstorage/<service instance id>
```

### Kubernetes service

* Template:
```
https://cloud.ibm.com/kubernetes/clusters/
<cluster id>/overview?
region=<region name>
&resourceGroup=<resource group id>
&ace_config={"region":"<region name>","crn":"<cluster crn>","resource_id":"","orgGuid":"","redirect":"https://cloud.ibm.com/resources","bluemixUIVersion":"v6"}
```

Get service instance details
```
ibmcloud ks clusters --output json | jq '.[] | select(.name=="DEVD-LYGON-IKS") | {name, crn, id, region, location, resourceGroup}'
```

Substiture values in the template

Example: DEVD-IKS\
```
https://cloud.ibm.com/kubernetes/clusters/c1eickjs0u9a1ofop690/overview?region=au-syd&resourceGroup=4a1ed070dd344c38848bcf4063b529d9&ace_config=%7B%22region%22%3A%22au-syd%22%2C%22crn%22%3A%22crn%3Av1%3Abluemix%3Apublic%3Acontainers-kubernetes%3Aau-syd%3Aa%2Fc15ecdd5890bdc705dd4e448a0a4b68d%3Ac1eickjs0u9a1ofop690%3A%3A%22%2C%22resource_id%22%3A%22%22%2C%22orgGuid%22%3A%22%22%2C%22redirect%22%3A%22https%3A%2F%2Fcloud.ibm.com%2Fresources%22%2C%22bluemixUIVersion%22%3A%22v6%22%7D
```
