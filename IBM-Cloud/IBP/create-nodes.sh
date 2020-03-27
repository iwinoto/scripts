#!/bin/bash
# Create IBP nodes using REST API via curl
# Ref: https://cloud.ibm.com/apidocs/blockchain
# Ref: https://stackoverflow.com/questions/26701538/how-to-filter-an-array-of-objects-based-on-values-in-an-inner-array-with-jq

SERVICE_NAME=$1
KEY_NAME=$2

getPayload_CA () {
  cat <<EOF
{
  "display_name": "$1",
  "enroll_id": "$2",
  "enroll_secret": "$3"
}
EOF
}

getNodeConfig() {
  cat <<EOF
{
  "enrollment": {
      "component": {
          "cahost": "",
          "caport": "",
          "caname": "",
          "catls": {
              "cacert": ""
          },
          "enrollid": "",
          "enrollsecret": "",
          "admincerts": [""]
      },
      "tls": {
          "cahost": "",
          "caport": "",
          "caname": "",
          "catls": {
              "cacert": ""
          },
          "enrollid": "",
          "enrollsecret": "",
          "csr": {
              "hosts": [""]
          }
      }
  }
}
EOF
}

getPayload_Peer () {
  cat <<EOF
{
  "msp_id": "$1",
  "config": "$2",
  "display_name": "$3",
  "type": "$4"
}
EOF
}

# get API endpoint and key from service key credentials
getAPICreds () {
    _CREDS=$(ibmcloud resource service-keys \
             --instance-name $SERVICE_NAME --output json | \
             jq '.[] | select(.name == "'$KEY_NAME'") | .credentials')
    #echo "credentials for $KEY_NAME: $_CREDS"

    _API_KEY=$(echo $_CREDS | jq -r '.apikey')
    _API_ENDPOINT=$(echo $_CREDS | jq -r '.api_endpoint')
    #echo "endpoint: $_API_ENDPOINT"
    #echo "key: $_API_KEY"
}

# Get api-key access token
getAccessToken () {
  getAPICreds
  #echo "Getting access token."
  _TOKEN=$(curl -s -X POST \
    https://iam.cloud.ibm.com/identity/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Accept: application/json" \
    -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$_API_KEY")
    
  _ACCESS_TOKEN=$(echo $_TOKEN | jq -r .access_token)
}

getComponents() {
  #echo "Getting IBP components."
  _COMPONENTS=$(curl -s -X GET $_API_ENDPOINT/ak/api/v1/components \
    -H "Content-Type: application/json" \
       -H "Authorization: Bearer $_ACCESS_TOKEN")
    
  #echo $_COMPONENTS
}


# Create CA node
createNodeCA () {
  #echo
  #echo "Creating CA node with display name $1."

#  payload=$(jq -n --arg name "$1" --arg id "$2" --arg secret "$3" '
#  {
#    display_name: $name,
#    enroll_id: $id,
#    enroll_secret: $secret
#  }')
  # Using arrays to construct command because of bash string variable expansion.
  curl_args=( -s -X POST "$API_ENDPOINT/ak/api/v1/kubernetes/components/ca" \
       -H "Content-Type: application/json" \
       -H "Authorization: Bearer $access_token" \
       -d "$(getPayload_CA "$1" "$2" "$3")" )

  #printf "<%s>\n" curl "${curl_args[@]}"
  curl "${curl_args[@]}"
}

getComponent() {
  display_name=$1
  getComponents
#  id=$($getComponents | jq -r '.[] | select(.display_name == "'"$display_name"'") | .id')
#  id=$($getComponents | jq -r '.')
  id=$(echo ${_COMPONENTS} | jq -r '.[] | select(.display_name == "'"$display_name"'") | .id')
  echo $id
}

# Use API key to get access_token.
getAccessToken

# create Org1 CA
#createNodeCA "Org1 CA" "admin" "adminpw"
# create Ordering Service CA
#createNodeCA "Ordering Service CA" "admin" "adminpw"


#getComponents
echo Component ID for Law Firm 1 MSP: 
getComponent "Law Firm 1 MSP"

# create peer
