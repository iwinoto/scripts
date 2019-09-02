#!/bin/sh

source k8s-setenv.sh

kubectl create namespace $KUBE_NAMESPACE

# Private image registry auth key for image pull secret
KUBE_NAMESPACE=$KUBE_NAMESPACE source ~/dev/bluemix/kube-imagePullSecret.sh
kubectl config set-context $(kubectl config current-context) --namespace=car-dashboard
