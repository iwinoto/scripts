# LogDNA

## Set up IKS to send logs to LogDNA
ref: https://cloud.ibm.com/docs/Log-Analysis-with-LogDNA/tutorials?topic=LogDNA-kube#kube_objectives

### Create logDNA instance.

```
ibmcloud resource service-instance-create <service instance name> logdna <plan, eg lite> <location, eg au-syd> -g <resource group>
```

### Create logDNA service key

```
ibmcloud resource service-key-create <Service key name. eg logdna-key-admin Administrator --instance-name <service instance name>
```

### get logDNA ingestion key
ref: https://cloud.ibm.com/docs/Log-Analysis-with-LogDNA?topic=LogDNA-ingestion_key#ingestion_key_cli

* use service name to get ingestion key
```
ibmcloud resource service-keys --instance-name <service instance name> --output json | jq -r '.[0].credentials.ingestion_key'
```

### Configure IKS cluster
* create secret for logDNA ingestion key
```
 kubectl create secret generic logdna-agent-key --from-literal=logdna-agent-key=<logDNA_ingestion_key>
 ```

OR get key and create secret in 1 line: 

```
kubectl create secret generic logdna-agent-key --namespace <namespace eg ibm-observe> \
--from-literal=logdna-agent-key=$(ibmcloud resource service-keys \
--instance-name <logDNA service name> --output json \
| jq -r '.[0].credentials.ingestion_key')
```

* create agent daemon set
 ```
 kubectl create --namespace <namespace, eg ibm-observe> -f https://assets.au-syd.logging.cloud.ibm.com/clients/logdna-agent-ds.yaml
 ```