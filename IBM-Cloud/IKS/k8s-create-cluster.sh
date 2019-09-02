#!/bin/sh

source k8s-setenv.sh

# Set the credentials
#bx cs credentials-set --infrastructure-username $API_USERNAME --infrastructure-api-key $API_KEY

# Create VLANs if they don't already exist
#bx sl vlan create --vlan-type private --datacenter $CLUSTER_LOCATION --size 8 --name $VLAN_PRIV
#bx sl vlan create --vlan-type public --datacenter $CLUSTER_LOCATION --size 8 --name $VLAN_PUB

if [ "$CLUSTER_TYPE" = "standard" ]; then
  # Create a standard cluster
  bx cs cluster-create \
    --name $CLUSTER_NAME \
    --location $CLUSTER_LOCATION \
    --workers $CLUSTER_WORKERS \
    --machine-type $CLUSTER_MC_TYPE \
    --hardware $CLUSTER_HARDWARE
  #  --public-vlan $VLAN_PUB \
  #  --private-vlan $VLAN_PRIV
else
  # Create a lite (free) cluster
  bx cs cluster-create --name $CLUSTER_NAME
fi

# Get Kube cluster config
bx cs cluster-config $CLUSTER_NAME
KUBECONFIG_DIR=~/.bluemix/plugins/container-service/clusters/$CLUSTER_NAME
export KUBECONFIG=$KUBECONFIG_DIR/kube-config-$CLUSTER_LOCATION-$CLUSTER_NAME.yml
