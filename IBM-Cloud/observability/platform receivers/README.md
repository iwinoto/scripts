# IBM Cloud Platform log and metrics receivers
## Overview
Logs and metrics from some IBM Cloud platform services instances can be sent to LogDNA and Sysdig instances provisioned to a cloud account. To enable this, the LogDNA and Sysdig service instances must be configured as the `default_receiver`.

IBM Cloud Patform service logs and metrics can be sent to ONE and only ONE instance of LogDNA and Sysdic. Because Platform logs and metrics includes all services in the account regardless of resource group (i.e. which env), we would have to use something like the service instance CRN to filter views for a particular service instances.

Services that are enabled will have documentation describing the data schema that is emitted.

* Log data for Cloudant is [documented here](https://cloud.ibm.com/docs/Cloudant?topic=Cloudant-log-analysis-integration).
* Metrics for Cloudant is [documented here](https://cloud.ibm.com/docs/Cloudant?topic=Cloudant-monitor-sysdig-pm).

Configuring a LogDNA or Sysdig instance as the `default_receiver` can be done from the IBM Cloud web console or from the `ibmcloud` command line interface.

This documentation describe the process using the command line interface.

## Checking `default_receiver` status
Using the command line to set `default_receiver` can lead to a situation where more than one collector (LogDNA or Sysdig instances) is configured as a receiver. This is an unsupported state and must be avoided as results will be unpredictable.

Therefore it is important to check if any collector instances are already set as a default receiver. Unfortunately, this requires checking collectors in all account resource groups.

The following snippet can be used to generate a list of service instances in a resource group have a `default_receiver` parameter set to `true`:

```sh
ibmcloud resource service-instances --long --output json | jq -r '.[] | select(.parameters.default_receiver==true) | .name'
```

## Setting `default_receiver` status
Setting the `default_receiver` parameter is the same command for both LogDNA and Sysdig.

1. First target the resource group containing the service instance to set.
2. Retrieve the `resource_plan_id` for the service instance. The following returns the ID for a LogDNA instance assuming there is only 1 in the resource group
   ```sh
   RESOURCE_PLAN_ID=$(ibmcloud resource service-instances --long --output json | jq -r '.[] | select(.id|test(".*logdna.*")) | .resource_plan_id')
   ```

   To get the resource plan ID for a Sysdig instance, replace `".*logdna.*"` with `".*sysdig.*"'.
3. You will also need the service name
   ```sh
   SERVICE_NAME=$(ibmcloud resource service-instances --long --output json | jq -r '.[] | select(.id|test(".*logdna.*")) | .name')
   ```
4. Use the service instance name and resource plan ID to set the parameters on the service. The `default_receiver` parameter must be set to `true`
   ```sh
   SERVICE_NAME=<service instance name>
   RESOURCE_PLAN_ID=<resource plan id>

   ibmcloud resource service-instance-update $SERVICE_NAME \
        --service-plan-id $RESOURCE_PLAN_ID \
        -p '{"default_receiver": true }
   ```
