* create service instance
```
ibmcloud resource service-instance-create <service instance name> blockchain <plan, eg lite> <location, eg au-syd> -g <resource group>
```
* create service credentials key to access the service

```
ibmcloud resource service-key-create <Service key name. eg blockchain-key-admin> Administrator --instance-name <service instance name>
```