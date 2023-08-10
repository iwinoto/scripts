#!/bin/bash

# Example service IDs for testing:
# ServiceId-46d2c761-9453-4d0e-9648-a2bf2fd95705 - for AppID management
# iam-ServiceId-56b72d76-6d01-4057-818c-ba789e8ea58b - DevSecOps automation


unset ORPHAN_SVC_ID

# ibmcloud iam service-ids --output JSON | jq -r '.[] | select(.name=="'${1}'")'
for id in $(ibmcloud iam service-ids --output JSON | jq -r '.[] | .id'); do
    unset GROUPS
    echo Testing Service ID = $id;
# Because group names have spaces that are not handled by Bash 'for',
# the group names need to be base64 encoded and then decoded for processing.
# this call only returns policies relating to cloud object storage
# ibmcloud iam service-policies $id --output json | jq -r '.[].resources[].attributes[] | select(.value=="cloud-object-storage") | @base64'
    for policy in $(ibmcloud iam service-policies $id --output json | jq -r '.[].resources[].attributes[] | select(.value=="cloud-object-storage") | @base64'); do
        current=$(echo $policy | base64 --decode -i -);
        # echo Testing AG = $current;
        SVC=$(ibmcloud iam access-group-service-ids "$current" --output JSON | \
            jq -r '.[] | select (.id | contains("'${id}'"))');
            if [ -n "$SVC" ]; then
                GROUPS+="${current}"$'\n'
            else
                echo "Access Group ${current} does not contain any service ids"
            fi
    done

    if [ -n "$GROUPS" ]; then
        echo "Service ID ${id} exists in groups"
        echo ${GROUPS}
    else
        echo "Service ID ${id} in NOT a group"
        ORPHAN_SVC_ID+="${id}"$'\n'
    fi
done

echo "Service IDs NOT in a group:"
echo "${ORPHAN_SVC_ID}"
echo "${ORPHAN_SVC_ID}" > orphan_svc_ids.txt
