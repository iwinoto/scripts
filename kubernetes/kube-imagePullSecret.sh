# Ref: https://console.bluemix.net/docs/containers
# $1 = namespace
# $2 = Docker key
# $3 = email address
kubectl --namespace $1 create secret docker-registry registry-ng-funfactory --docker-server=registry.ng.bluemix.net --docker-username=token --docker-password=$2 --docker-email=

