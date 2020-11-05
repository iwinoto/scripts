#!/bin/sh

# get IBP namespace
NAMESPACE=$1

DATE=$(date '+%Y-%-m-%d-T%H%M%S')
BACKUP_PATH=./backup

CONFIGMAP_PATH=$BACKUP_PATH/configmaps
SECRETS_PATH=$BACKUP_PATH/secrets
mkdir -p $CONFIGMAP_PATH
mkdir -p $SECRETS_PATH

# get all configmaps in IBP namespace
for cm in $(kubectl -n $NAMESPACE get configmaps -o json | jq -r '.items[] | .metadata.name'); do
    echo backing up config map $cm
    kubectl -n $NAMESPACE get configmap ${cm} -o yaml > $CONFIGMAP_PATH/$DATE-${cm}.yaml
done

# get all secrets in IBP namespace
for secret in $(kubectl -n $NAMESPACE get secrets -o json | jq -r '.items[] | .metadata.name'); do
    echo backing up secret $secret
    kubectl -n $NAMESPACE get secret ${secret} -o yaml > $SECRETS_PATH/$DATE-${secret}.yaml
done
