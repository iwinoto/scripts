#!/bin/sh

source k8s-setenv.sh

echo -------
echo bx target
bx target
echo -------
echo KUBECONFIG=$KUBECONFIG

deployed=`kubectl --namespace $KUBE_NAMESPACE get deployments -o jsonpath="{$.items[?(@.metadata.name==\"$APP_NAME\")].metadata.name}"`
echo deployed=$deployed

if [ -z "$deployed" ]; then
  echo App $APP_NAME is not deployed. Creating a new deployment

  echo Create services
  # conversation
  bx cf create-service conversation free my-conversation-service
  # speech-to-text
  bx cf create-service speech_to_text standard speech-to-text-service
  # text-to-speech
  bx cf create-service text_to_speech standard text-to-speech-service

  echo Bind services to the cluster
  bx cs cluster-service-bind $CLUSTER_NAME $KUBE_NAMESPACE my-conversation-service
  bx cs cluster-service-bind $CLUSTER_NAME $KUBE_NAMESPACE speech-to-text-service
  bx cs cluster-service-bind $CLUSTER_NAME $KUBE_NAMESPACE text-to-speech-service

  echo Deploy the service to kubernetes
  echo substitute deployment values from environment variables
  sed -e s/\$TAG/$TAG/g \
  -e s/\$REGISTRY_NAMESPACE/$REGISTRY_NAMESPACE/g \
  -e s/\$REGISTRY/$REGISTRY/g \
  -e s/\$IMAGE_NAME/$IMAGE_NAME/g \
  -e s/\$APP_NAME/$APP_NAME/g \
  k8s-car-dashboard.yml | \
  kubectl --namespace $KUBE_NAMESPACE create -f -

  # Create Ingress
  #kubectl apply -f k8s-car-dashboard-ingress.yml
else
  echo App $APP_NAME is already deployed. Do rolling update of deployment PODS
  kubectl --namespace $KUBE_NAMESPACE set image deployments/$APP_NAME $APP_NAME=$REGISTRY/$REGISTRY_NAMESPACE/$IMAGE_NAME:$TAG
fi

# Echo description
kubectl --namespace $KUBE_NAMESPACE describe deployment car-dashboard
bx cs workers $CLUSTER_NAME
