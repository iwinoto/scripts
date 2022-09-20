#!/bin/bash

SERVICE_NAME=$1
API_KEY_NAME="sysdig-management-key"

# make sure we don't nasty escape characters in ibmcloud output
export IBMCLOUD_COLOR=false

# export the service GUID
export SYSDIG_GUID=$(ibmcloud resource service-instance $SERVICE_NAME --output json | jq -r '.[].guid')

# get the OAuth bearer token
export IBMCLOUD_TOKEN=$(ibmcloud iam oauth-tokens | grep IAM | cut -d \: -f 2 | sed 's/^[ \t]*//')

# export the enpoint
# can be scripted with jq match("regex") from service instance json .[].dashboard_url
export SYSDIG_ENDPOINT="https://au-syd.monitoring.cloud.ibm.com"

