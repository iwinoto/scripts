#!/bin/bash

# export appid credential to json
_CREDS=$(ibmcloud resource service-keys \
             --instance-name $APPID_INSTANCE_NAME --output json | \
             jq -c '.[] | select(.name == "'$APPID_INSTANCE_NAME-key'") | .credentials')
#echo '{"'$APPID_INSTANCE_NAME-creds'": '$_CREDS'}'

# create a kubernetes secret for the appid instance using stringData
# note that `sed` substitution pattern is using '~' as the delimiter to avoid collision
# with '/' _CREDS values - prominent in endpoint URLs
sed -e 's~{{secret-name}}~'${APPID_INSTANCE_NAME}'-secret~g' \
    -e 's~{{secret-json}}~'"${_CREDS}"'~g' \
    appid-secret.yaml \
| kubectl apply -f -
