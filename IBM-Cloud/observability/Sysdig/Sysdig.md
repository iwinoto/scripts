## Configure Sysdig Monitoring agent in IKS

* Create service instance

```
ibmcloud resource service-instance-create <service instance name> sysdig-monitor <plan, eg lite> <location, eg au-syd> -g <resource group>
```

* Get service name

```
ibmcloud resource service-instances --output json
```

* Create SysDig service key

```
ibmcloud resource service-key-create <Service key name. eg sysdig-monitoy-key-admin> Administrator --instance-name <service instance name>
```

* get service api key
```
ibmcloud resource service-keys --instance-name <Sysdig instance name>  --output json | jq -r '.[0].credentials."Sysdig Access Key"'
```

* use access key to deploy agent
```
curl -sL https://ibm.biz/install-sysdig-k8s-agent | bash -s -- -a <Sysdig access key> -c ingest.private.au-syd.monitoring.cloud.ibm.com -ac 'sysdig_capture_enabled: false'
```

OR get key and deploy sysdig agent in 1 line: 

```
cat install-sysdig-agent-k8s.sh | bash -s -- -a \
$(ibmcloud resource service-keys --instance-name <Sysdig instance name> --output json \
| jq -r '.[0].credentials."Sysdig Access Key"') \
 -c ingest.au-syd.monitoring.cloud.ibm.com -ac 'sysdig_capture_enabled: false'
```

