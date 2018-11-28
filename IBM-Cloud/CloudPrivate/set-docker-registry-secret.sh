#!/bin/bash

# Create Docker config registry Secret
kubectl -n iwinoto create secret docker-registry docker-admin.registrykey \
  --docker-server=https://icpcluster.icp:8500 \
  --docker-username=admin --docker-password=passw0rd \
  --docker-email=null

# Add image registry secret as ImagePullSecret in default service account
kubectl -n iwinoto get serviceaccounts default -o yaml \
  | \
  sed -e "/resourceVersion.*/d"\
    -e "$ a imagePullSecrets:\n- name: docker-admin.registrykey" - \
  | \
  kubectl -n iwinoto replace serviceaccount default -f -
