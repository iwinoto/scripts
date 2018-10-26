#!/bin/bash

# Get IBM Cloud IAM token for subsequent API calls.
# Token is exported to BEARER_TOKEN
# Use 'source' to execute this script

export BEARER_TOKEN=$(curl -X POST 'https://iam.ng.bluemix.net/identity/token' -d "apikey=$BLUEMIX_API_KEY&grant_type=urn%3Aibm%3Aparams%3Aoauth%3Agrant-type%3Aapikey" -H "Content-Type: application/x-www-form-urlencoded" | jq -r .access_token)

echo BEARER_TOKEN set
