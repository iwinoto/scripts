#!/bin/bash

# For infrastructure permissions required to create & manage clusters
# Refer to: https-//cloud.ibm.com/docs/containers?topic=containers-access_reference#infra

# List of Infrastructure permissions grouped by user.

for ID in $(ibmcloud sl user list --output json | jq '.[] | .id'); do
    echo
    echo ID = $ID
    USER_DETAILS=$(ibmcloud sl user detail $ID)
    echo $(echo $USER_DETAILS | awk '$0 ~ /Name/ {print $0}' -)
    echo $(echo $USER_DETAILS | awk '$0 ~ /Email/ {print $0}' -)
    # echo User ID = $USER_EMAIL
    ibmcloud sl user permissions $ID | awk '$0 ~ /true/ {print $0}' -
done

