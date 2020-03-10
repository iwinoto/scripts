#!/bin/sh

source k8s-setenv.sh

# Set the credentials
#ibmcloud ks credentials-set --infrastructure-username $API_USERNAME --infrastructure-api-key $API_KEY

# Create VLANs if they don't already exist
# use `ibmcloud ks vlan ls` to check if they exist.
# There is no json output for above so need to use `awk` or something to automate the test.
ibmcloud sl vlan create --vlan-type private --datacenter $CLUSTER_LOCATION --name $VLAN_PRIV
ibmcloud sl vlan create --vlan-type public --datacenter $CLUSTER_LOCATION --name $VLAN_PUB

