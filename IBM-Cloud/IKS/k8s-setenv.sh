#!/bin/sh

APP_NAME=car-dashboard

#CLUSTER_TYPE=free
CLUSTER_TYPE=standard
CLUSTER_NAME=_STD
CLUSTER_LOCATION=syd01
CLUSTER_WORKERS=2
CLUSTER_MC_TYPE=u1c.2x4
CLUSTER_HARDWARE=shared

VLAN_PRIV=priv01
VLAN_PUB=pub01

#KUBE_NAMESPACE=$APP_NAME
DEF_KUBE_NAMESPACE=car-dashboard
KUBECONFIG_DIR=~/.bluemix/plugins/container-service/clusters/$CLUSTER_NAME
KUBECONFIG_FILE=$KUBECONFIG_DIR/kube-config-$CLUSTER_LOCATION-$CLUSTER_NAME.yml

IMAGE_NAME=$APP_NAME
# Default image registry
DEF_REGISTRY=registry.au-syd.bluemix.net
DEF_REGISTRY_NAMESPACE=iwinoto_gmail_funfactory

#bx cr login
bx cs init
bx cs cluster-config $CLUSTER_NAME

if [ -f "$KUBECONFIG_FILE" ]; then
  export KUBECONFIG=$KUBECONFIG_FILE
else
  # HACK: if we get here, then most likely cause is that $CLUSTER_LOCATION is not valid
  # This will happen if the cluster is public, in which case it will be in mel01
  KUBECONFIG_FILE=$KUBECONFIG_DIR/kube-config-mel01-$CLUSTER_NAME.yml
  if [ -f "$KUBECONFIG_FILE" ]; then
    export KUBECONFIG=$KUBECONFIG_FILE
  else
    echo KUBECONFIG file is not found
  fi
fi

if [ -z "$KUBE_NAMESPACE" ]; then
  # kubernetes namespace not set. Use the default
  KUBE_NAMESPACE="$DEF_KUBE_NAMESPACE"
fi

if [ -z "$REGISTRY" ]; then
  # Image registry not set. Use the default
  REGISTRY="$DEF_REGISTRY"
fi

if [ -z "$REGISTRY_NAMESPACE" ]; then
  # Image registry namespace not set. Use the default
  REGISTRY_NAMESPACE=$DEF_REGISTRY_NAMESPACE
fi

if [ -z "$IMAGE_TAG" ]; then
  # IMAGE_TAG not set so get from git
  # git rev-parse --short HEAD
  # git describe --tags --exact-match
  # Get tag or commit from git
  TAG="$(git rev-parse --short HEAD)"
else
  TAG=$IMAGE_TAG
fi

echo KUBE_NAMESPACE=$KUBE_NAMESPACE
echo KUBECONFIG=$KUBECONFIG
echo REGISTRY=$REGISTRY
echo REGISTRY_NAMESPACE=$REGISTRY_NAMESPACE
echo Image tag=$TAG
