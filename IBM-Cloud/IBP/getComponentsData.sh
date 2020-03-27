#!/bin/bash
# Ref: https://cloud.ibm.com/apidocs/blockchain

# Get data about all components in an IBP network for back up and restore
# restore process is to import the component data into a new network.

SERVICE_NAME=$1
KEY_NAME=$2

# get API endpoint and key from service key credentials
getAPICreds () {
    _CREDS=$(ibmcloud resource service-keys \
             --instance-name $SERVICE_NAME --output json | \
             jq '.[] | select(.name == "'$KEY_NAME'") | .credentials')
    _API_KEY=$(echo $_CREDS | jq -r '.apikey')
    _API_ENDPOINT=$(echo $_CREDS | jq -r '.api_endpoint')
    #echo "credentials for $KEY_NAME: $_CREDS"
    #echo "endpoint: $_API_ENDPOINT"
    #echo "key: $_API_KEY"
}

# Get api-key access token
getAccessToken () {
  #echo "Getting access token."
  _ID_TOKEN=$(curl -s -X POST \
    https://iam.cloud.ibm.com/identity/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Accept: application/json" \
    -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$_API_KEY")
    
  _TOKEN=$(echo $_ID_TOKEN | jq -r .access_token)
  #echo "Access token: $_TOKEN"
}


getComponents() {
  #echo "Getting IBP components."
  _COMPONENTS=$(curl -s -X GET $_API_ENDPOINT/ak/api/v1/components \
    -H "Content-Type: application/json" \
       -H "Authorization: Bearer $_TOKEN")
    
  #$(echo $COMPONENTS | jq -r .)
  #echo
  echo $_COMPONENTS
# Ref: https://stackoverflow.com/questions/26701538/how-to-filter-an-array-of-objects-based-on-values-in-an-inner-array-with-jq
  
}

getAPICreds
getAccessToken
getComponents