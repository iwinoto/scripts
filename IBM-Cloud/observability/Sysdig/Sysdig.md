# Sysdig
Variables for the commands used here:
```
SYSDIG_INSTANCE_NAME=<service instance name>
PLAN=<plan, eg lite> 
LOCATION=<location, eg au-syd>
RESOURCE_GROUP=<resource group>
SERVICE_KEY_NAME=<Service key name. eg sysdig-monitoy-key-admin>
SYSDIG_AGENT_NAMESPACE=<namespace eg ibm-observe, for agent deployment in k8s>
```

## Configure Sysdig Monitoring agent in IKS

* Create service instance

```
ibmcloud resource service-instance-create $SYSDIG_INSTANCE_NAME sysdig-monitor $PLAN $LOCATION -g $RESOURCE_GROUP
```

If required, send Platform service metrics to the Sysdig instance. Only 1 Sysdig instance per region can sink platform service metrics
```
PLAN_ID=$(ibmcloud resource service-instances --long --output JSON | jq -r '.[] | select(.name == "'${SYSDIG_INSTANCE_NAME}'").resource_plan_id')

ibmcloud resource service-instance-update $SYSDIG_INSTANCE_NAME --service-plan-id $PLAN_ID -p '{"default_receiver": true}'

```

* Get service name

```
ibmcloud resource service-instances --output json
```

* Create SysDig service key  with `Administrator` role name

```
ibmcloud resource service-key-create $SERVICE_KEY_NAME Administrator --instance-name $SYSDIG_INSTANCE_NAME
```

* get service api key
```
SYSDIG_ACCESS_KEY=ibmcloud resource service-keys --instance-name $SYSDIG_INSTANCE_NAME --output json | jq -r '.[0].credentials."Sysdig Access Key"'
```

* use access key to deploy agent
```
curl -sL https://ibm.biz/install-sysdig-k8s-agent | bash -s -- -a $SYSDIG_ACCESS_KEY -c ingest.private.au-syd.monitoring.cloud.ibm.com -ac 'sysdig_capture_enabled: false'
```

OR get key and deploy sysdig agent in 1 line: 

```
cat install-sysdig-agent-k8s.sh | bash -s -- -a \
$(ibmcloud resource service-keys --instance-name ${SYSDIG_ACCESS_KEY} --output json \
| jq -r '.[0].credentials."Sysdig Access Key"') \
 -c ingest.au-syd.monitoring.cloud.ibm.com -ac 'sysdig_capture_enabled: false'
```

