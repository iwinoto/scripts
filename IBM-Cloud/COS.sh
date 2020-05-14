#!/bin/sh
COS_SERVICE_NAME="Cloud Object Storage-prjlygon"
COS_RESOURCE_GROUP="Project-bgx"
# VERTICAL_NAME needs to be updated when the api keys for the COS instance are updated
# Try to align the vertical name and the api key name
VERTICAL_NAME="admin-core-setup"
# To get the GUID for Cloud Object Storage, service-name is the name of COS service
# run `ibmcloud resource service-instance <service_name> | grep GUID`
COS_SERVICE_GUID=$(ibmcloud resource service-instance $COS_SERVICE_NAME -g $COS_RESOURCE_GROUP | sed -n 's/.*GUID://p' | xargs)
# Find the appropriate API key for the lygon vertical from the COS service Service Crendentials tab
# Requires JQUERY
COS_API_KEY="$(ibmcloud resource service-keys --output JSON --instance-name $COS_SERVICE_NAME -g $COS_RESOURCE_GROUP | jq '.[ ] | select(.name == "'$VERTICAL_NAME'") | .credentials' | jq -r '.apikey')"