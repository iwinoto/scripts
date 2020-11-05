#!/bin/bash

NAMESPACE=$1
TIMESTAMP=$(date '+%Y-%-m-%d-T%H:%M:%S')
COS_ACCESS_KEY_ID="<access_key_id>"
COS_ACCESS_KEY="<access_key>"
COS_BUCKET="<bucket>"
COS_ENDPOINT="<cos_endpoint>"
BACKUP_TYPE="<backup_type>"
SCHEDULE_TYPE="<schedula_type>"
SCHEDULE_INFO="<schedule_info>"

ALL_PVCS=$(kubectl get pvc -n $NAMESPACE -o json | jq -r '.items[].metadata.name')
echo ALL_PVCS = $ALL_PVCS'\n'
CA_PVCS=$(kubectl get pvc -n $NAMESPACE -o json | jq -r '.items[].metadata.name' | awk '/.*ca-pvc$/ {print $0}' -)
echo CA_PVCS = $CA_PVCS'\n'
PEER_PVCS=$(kubectl get pvc -n $NAMESPACE -o json | jq -r '.items[].metadata.name' | awk '/.*peer[0-9]{1,2}-pvc$/ {print $0}' -)
echo PEER_PVCS = $PEER_PVCS'\n'
STATEDB_PVCS=$(kubectl get pvc -n $NAMESPACE -o json | jq -r '.items[].metadata.name' | awk '/.*peer[0-9]{1,2}-statedb-pvc$/ {print $0}' -)
echo STATEDB_PVCS = $STATEDB_PVCS'\n'
ORDERER_PVCS=$(kubectl get pvc -n $NAMESPACE -o json | jq -r '.items[].metadata.name'  | awk '/.*ordererservicenode[0-9]{1,2}-pvc$/ {print $0}' -)
echo ORDERER_PVCS = $ORDERER_PVCS'\n'

for pvc in $CA_PVCS; do
    echo "Deploying backup for PVC: $pvc"
    BACKUP_NAME=$pvc-$TIMESTAMP
    H_REL_NAME=backup-$BACKUP_NAME
    echo "backup name $BACKUP_NAME"
    echo "helm -n $NAMESPACE install $H_REL_NAME --set \
        --set ACCESS_KEY_ID=$COS_ACCESS_KEY \
        --set SECRET_ACCESS_KEY=$COS_ACCESS_KEY \
        --set ENDPOINT=$COS_ENDPOINT --set BUCKET_NAME=$COS_BUCKET \
        --set BACKUP_NAME=$BACKUP_NAME --set PVC_NAMES[0]=$pvc \
        --set CHART_TYPE=backup \
        --set BACKUP_TYPE=$BACKUP_TYPE --set SCHEDULE_TYPE=$SCHEDULE_TYPE \
        --set SCHEDULE_INFO=$SCHEDULE_INFO ./ibmcloud-backup-restore"
done

# Wait here for backup completion

for pvc in $PEER_PVCS; do
    echo "Deploying backup for PVC: $pvc"
    BACKUP_NAME=$pvc-$TIMESTAMP
    H_REL_NAME=backup-$BACKUP_NAME
    echo "backup name $BACKUP_NAME"
    echo "helm -n $NAMESPACE install $H_REL_NAME --set \
        --set ACCESS_KEY_ID=$COS_ACCESS_KEY \
        --set SECRET_ACCESS_KEY=$COS_ACCESS_KEY \
        --set ENDPOINT=$COS_ENDPOINT --set BUCKET_NAME=$COS_BUCKET \
        --set BACKUP_NAME=$BACKUP_NAME --set PVC_NAMES[0]=$pvc \
        --set CHART_TYPE=backup \
        --set BACKUP_TYPE=$BACKUP_TYPE --set SCHEDULE_TYPE=$SCHEDULE_TYPE \
        --set SCHEDULE_INFO=$SCHEDULE_INFO ./ibmcloud-backup-restore"
done

# Wait here for backup completion

for pvc in $STATEDB_PVCS; do
    echo "Deploying backup for PVC: $pvc"
    BACKUP_NAME=$pvc-$TIMESTAMP
    H_REL_NAME=backup-$BACKUP_NAME
    echo "backup name $BACKUP_NAME"
    echo "helm -n $NAMESPACE install $H_REL_NAME --set \
        --set ACCESS_KEY_ID=$COS_ACCESS_KEY \
        --set SECRET_ACCESS_KEY=$COS_ACCESS_KEY \
        --set ENDPOINT=$COS_ENDPOINT --set BUCKET_NAME=$COS_BUCKET \
        --set BACKUP_NAME=$BACKUP_NAME --set PVC_NAMES[0]=$pvc \
        --set CHART_TYPE=backup \
        --set BACKUP_TYPE=$BACKUP_TYPE --set SCHEDULE_TYPE=$SCHEDULE_TYPE \
        --set SCHEDULE_INFO=$SCHEDULE_INFO ./ibmcloud-backup-restore"
done

# Wait here for backup completion

for pvc in $ORDERER_PVCS; do
    echo "Deploying backup for PVC: $pvc"
    BACKUP_NAME=$pvc-$TIMESTAMP
    H_REL_NAME=backup-$BACKUP_NAME
    echo "backup name $BACKUP_NAME"
    echo "helm -n $NAMESPACE install $H_REL_NAME --set \
        --set ACCESS_KEY_ID=$COS_ACCESS_KEY \
        --set SECRET_ACCESS_KEY=$COS_ACCESS_KEY \
        --set ENDPOINT=$COS_ENDPOINT --set BUCKET_NAME=$COS_BUCKET \
        --set BACKUP_NAME=$BACKUP_NAME --set PVC_NAMES[0]=$pvc \
        --set CHART_TYPE=backup \
        --set BACKUP_TYPE=$BACKUP_TYPE --set SCHEDULE_TYPE=$SCHEDULE_TYPE \
        --set SCHEDULE_INFO=$SCHEDULE_INFO ./ibmcloud-backup-restore"
done

echo Installed charts:
helm -n $NAMESPACE list



