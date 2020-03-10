#!/bin/sh

source k8s-setenv.sh

# Delete the namespace
kubectl delete namespace $KUBE_NAMESPACE
kubectl config set-context $(kubectl config current-context) --namespace=default

# If not using namespace, delete objects individually
#kubectl --namespace $KUBE_NAMESPACE delete ingress $APP_NAME-ingress
#kubectl --namespace $KUBE_NAMESPACE delete deployment $APP_NAME
#kubectl --namespace $KUBE_NAMESPACE delete service $APP_NAME
#ibmcloud ks cluster-service-unbind $CLUSTER_NAME $KUBE_NAMESPACE my-conversation-service
#ibmcloud ks cluster-service-unbind $CLUSTER_NAME $KUBE_NAMESPACE speech-to-text-service
#ibmcloud ks cluster-service-unbind $CLUSTER_NAME $KUBE_NAMESPACE text-to-speech-service
#kubectl --namespace $KUBE_NAMESPACE delete secret binding-my-conversation-service
#kubectl --namespace $KUBE_NAMESPACE delete secret binding-speech-to-text-service
#kubectl --namespace $KUBE_NAMESPACE delete secret binding-text-to-speech-service
