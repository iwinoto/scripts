A set of scripts to create IKS clusters.

To set cluster options, edit the `k8s-setenv.sh` file and set the environment variable appropriately. Then login with `ibmcloud` and set the resource goup as required with
```
ibmcloud target -g <resource group name>
```

Then run the `k8s-create-cluster.sh` script.

## Important environment variables
These environment variables are key in defining the cluster that is created
* CLUSTER_TYPE
  * [free | standard]
  * set the type of cluster. if `free`, then all other settings except for `CLUSTER_NAME` are ignored
* CLUSTER_NAME
  * specify the cluster name
* CLUSTER_LOCATION
  * set the location for the cluster. For example `syd01`.
  * To find available locations run `ibmcloud ks zones`
* CLUSTER_VERSION=1.15
  * get available versions with `ibmcloud ks versions`
  * for IBP, check the supported k8s version. Sometimes default is not supported.
* CLUSTER_WORKERS
  * Number of worker nodes
* CLUSTER_MC_TYPE
  * Machine type of worker nodes. For example `b3c.4x16`.
  * To get a list of machine types and their descriptions, use `ibmcloud ks flavors --zone <target zone>`
* CLUSTER_HARDWARE
  * [shared | dedicated]
* VLAN_PRIV
  * User VLAN ID for private network. Names no longer work.
  * To get a list of available VLANs, use `ibmcloud ks vlans --zone <target zone>`
  * You may need to create a VLAN using `ibmcloud sl vlan create`
* VLAN_PUB
  * User VLAN ID for public facing network. Names no longer work.
  * To get a list of available VLANs, use `ibmcloud ks vlans --zone <target zone>`
  * You may need to create a VLAN using `ibmcloud sl vlan create`

## Account access set up.

strategy is to create a resource group and an access group for admin access to the resource group.

Access group must have Administrator access to the resource group