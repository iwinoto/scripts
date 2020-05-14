#!/bin/sh

COS_SERVICE_NAME="Cloud Object Storage-prjlygon"
COS_RESOURCE_GROUP="Project-bgx"
# VERTICAL_NAME needs to be updated when the api keys for the COS instance are updated
# Try to align the vertical name and the api key name
#VERTICAL_NAME="admin-core-setup"
VERTICAL_NAME="cassie-debug-bucket"

# To get the GUID for Cloud Object Storage, service-name is the name of COS service
echo "target COS service resource group"
ibmcloud target -g $COS_RESOURCE_GROUP
echo "Grabbing the COS GUID and API key"
COS_SERVICE_GUID=$(ibmcloud resource service-instance "$COS_SERVICE_NAME" -g "$COS_RESOURCE_GROUP" | sed -n 's/.*GUID://p' | xargs)

# Find the appropriate API key for the lygon vertical from the COS service Service Crendentials tab
# Requires JQUERY

#COS_API_KEY="$(ibmcloud resource service-keys --output JSON --instance-name "$COS_SERVICE_NAME" -g "$COS_RESOURCE_GROUP" | jq '.[ ] | select(.name == "'$VERTICAL_NAME'") | .credentials' | jq -r .apikey)"

COS_API_KEY=$(ibmcloud resource service-keys --instance-id "$COS_SERVICE_GUID" -g "$COS_RESOURCE_GROUP" --output json | jq -r '.[] | select(.name == "'$VERTICAL_NAME'") | .credentials.apikey')

echo "Re-target IKS service resource group"
ibmcloud target -g $IKS_RESOURCE_GROUP
# Set the user ID
USER_ID=casstait@au1.ibm.com
