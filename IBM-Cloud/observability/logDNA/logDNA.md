# LogDNA

Variables for the commands used here:
```
LOGDNA_INSTANCE_NAME=<service instance name>
PLAN=<plan, eg lite> 
LOCATION=<location, eg au-syd>
RESOURCE_GROUP=<resource group>
SERVICE_KEY_NAME=<Service key name. eg logdna-key-admin>
LOGDNA_AGENT_NAMESPACE=<namespace eg ibm-observe, for agent deployment in k8s>
```

## Set up IKS to send logs to LogDNA
ref: https://cloud.ibm.com/docs/Log-Analysis-with-LogDNA/tutorials?topic=LogDNA-kube#kube_objectives

### Create logDNA instance.

```
ibmcloud resource service-instance-create $LOGDNA_INSTANCE_NAME logdna $PLAN $LOCATION -g $RESOURCE_GROUP
```

If required, send Platform service logs to the logDNA instance. Only 1 logDNA instance per region can sink platform service logs
```
PLAN_ID=$(ibmcloud resource service-instances --long --output JSON | jq -r '.[] | select(.name == "'${LOGDNA_INSTANCE_NAME}'").resource_plan_id')

ibmcloud resource service-instance-update $LOGDNA_INSTANCE_NAME --service-plan-id $PLAN_ID -p '{"default_receiver": true}'

```



### Create logDNA service key with `Administrator` role name

```
ibmcloud resource service-key-create $SERVICE_KEY_NAME Administrator --instance-name $LOGDNA_INSTANCE_NAME
```

### get logDNA ingestion key
ref: https://cloud.ibm.com/docs/Log-Analysis-with-LogDNA?topic=LogDNA-ingestion_key#ingestion_key_cli

* use service name to get ingestion key
```
LOGDNA_INGESTION_KEY=ibmcloud resource service-keys --instance-name $LOGDNA_INSTANCE_NAME --output json | jq -r '.[0].credentials.ingestion_key'
```

### Configure IKS cluster
* create secret for logDNA ingestion key
```
 kubectl create secret generic logdna-agent-key --from-literal=logdna-agent-key=$LOGDNA_INGESTION_KEY
 ```

OR get key and create secret in 1 line: 

```
kubectl create secret generic logdna-agent-key --namespace $LOGDNA_AGENT_NAMESPACE \
--from-literal=logdna-agent-key=$(ibmcloud resource service-keys \
--instance-name $LOGDNA_INSTANCE_NAME --output json \
| jq -r '.[0].credentials.ingestion_key')
```

* create agent daemon set
 ```
 kubectl create --namespace $LOGDNA_AGENT_NAMESPACE -f https://assets.au-syd.logging.cloud.ibm.com/clients/logdna-agent-ds.yaml
 ```