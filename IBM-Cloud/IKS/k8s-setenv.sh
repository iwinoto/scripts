#!/bin/sh

APP_NAME=sec-controls-test

#CLUSTER_TYPE=free
CLUSTER_TYPE=standard
CLUSTER_NAME=ANB-Kub
CLUSTER_LOCATION=syd01
# get available versions with `ibmcloud ks versions`
# for IBP, check the supported k8s version. Sometimes default is not supported.
CLUSTER_VERSION=1.15
CLUSTER_WORKERS=3
CLUSTER_MC_TYPE=b3c.4x16
CLUSTER_HARDWARE=shared
# User VLAN IDs. Names no longer work.
VLAN_PRIV=2821470
VLAN_PUB=2821472

#KUBE_NAMESPACE=$APP_NAME
DEF_KUBE_NAMESPACE=sec-controls-test
KUBECONFIG_DIR=~/.bluemix/plugins/container-service/clusters/$CLUSTER_NAME
KUBECONFIG_FILE=$KUBECONFIG_DIR/kube-config-$CLUSTER_LOCATION-$CLUSTER_NAME.yml

IMAGE_NAME=$APP_NAME
# Default image registry
DEF_REGISTRY=registry.au-syd.bluemix.net
DEF_REGISTRY_NAMESPACE=iwinoto_gmail_funfactory

#ibmcloud cr login
ibmcloud ks init
ibmcloud ks cluster config $CLUSTER_NAME

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
