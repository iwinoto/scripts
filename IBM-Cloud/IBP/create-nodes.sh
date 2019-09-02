#!/bin/bash
# Create IBP nodes using REST API via curl
# Ref: https://cloud.ibm.com/apidocs/blockchain

API_KEY=$1
API_ENDPOINT=$2
access_token=$3

# Get api-key access token
getAccessToken () {
  #echo "Getting access token."
  ID_TOKEN=$(curl -s -X POST \
    https://iam.cloud.ibm.com/identity/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Accept: application/json" \
    -d "grant_type=urn%3Aibm%3Aparams%3Aoauth%3Agrant-type%3Aapikey&apikey=$API_KEY")
    
  access_token=$(echo $ID_TOKEN | jq -r .access_token)
  #echo
  #echo "Access token:"
  #echo $access_token
}

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

getComponents() {
  #echo "Getting IBP components."
  COMPONENTS=$(curl -s -X GET $API_ENDPOINT/ak/api/v1/components \
    -H "Content-Type: application/json" \
       -H "Authorization: Bearer $access_token")
    
  #$(echo $COMPONENTS | jq -r .)
  #echo
  #echo "IBP Components:"
  echo $COMPONENTS
# Ref: https://stackoverflow.com/questions/26701538/how-to-filter-an-array-of-objects-based-on-values-in-an-inner-array-with-jq
  
}

getComponent() {
  display_name=$1
  id=$($getComponents | jq -r '.[] | select( .display_name | contains("$display_name") ) | .id')
  echo $id
}

# Use API key to get access_token.
getAccessToken

# create Org1 CA
#createNodeCA "Org1 CA" "admin" "adminpw"
# create Ordering Service CA
#createNodeCA "Ordering Service CA" "admin" "adminpw"

getComponent "Org1 CA"

# create peer
