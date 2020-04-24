#!/bin/sh

source k8s-setenv.sh

# Set the credentials
#ibmcloud ks credentials-set --infrastructure-username $API_USERNAME --infrastructure-api-key $API_KEY

# Create VLANs if they don't already exist
# source k8s-create-vlan.sh

if [ "$CLUSTER_TYPE" = "standard" ]; then
  # Create a standard cluster
  # Create a standard cluster without a config yaml.
  ibmcloud ks cluster create classic \
    --name $CLUSTER_NAME \
    --version $CLUSTER_VERSION \
    --zone $CLUSTER_LOCATION \
    --workers $CLUSTER_WORKERS \
    --flavor $CLUSTER_MC_TYPE \
    --hardware $CLUSTER_HARDWARE \
    --public-vlan $VLAN_PUB \
    --private-vlan $VLAN_PRIV
else
  # Create a lite (free) cluster
  ibmcloud ks cluster create classic --name $CLUSTER_NAME
fi

# Get Kube cluster config
ibmcloud ks cluster config --cluster $CLUSTER_NAME
KUBECONFIG_DIR=~/.bluemix/plugins/container-service/clusters/$CLUSTER_NAME
export KUBECONFIG=$KUBECONFIG_DIR/kube-config-$CLUSTER_LOCATION-$CLUSTER_NAME.yml
