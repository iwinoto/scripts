# Ref: https://console.bluemix.net/docs/containers/cs_cluster.html#cs_apps_images
# $1 = namespace
# $2 = secret name
# $3 = Docker key
# $4 = email address
kubectl --namespace $1 create secret docker-registry $2 \
  --docker-server=registry.ng.bluemix.net \
  --docker-username=token --docker-password=$3 \
  --docker-email=$4
