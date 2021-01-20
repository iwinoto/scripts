#!/bin/bash

# For infrastructure permissions required to create & manage clusters
# Refer to: https-//cloud.ibm.com/docs/containers?topic=containers-access_reference#infra

# List of Infrastructure permissions grouped by user.

for ID in $(ibmcloud sl user list --output json | jq '.[] | .id'); do
    echo ID = $ID
    USER_EMAIL=$(ibmcloud sl user detail $ID | awk '$0 ~ /Email/ {print $2}' -)
    echo User ID = $USER_EMAIL
    ibmcloud sl user permissions $ID | awk '$0 ~ /true/ {print $0}' -
done

