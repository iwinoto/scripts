#!/bin/bash

_API_KEY=$1

_ACCOUNT_ID=<Account ID>

# Access group = Security controls research
_ACCESS_GROUP_ID=<Access Group ID>

#Aharon Rossano
_USER_EMAIL=<email address>

# Get api-key access token
getAccessToken () {
  #getAPICreds
  #echo "Getting access token."
  _TOKEN=$(curl -s -X POST \
    "https://iam.cloud.ibm.com/identity/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Accept: application/json" \
    -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$_API_KEY")
    
  _ACCESS_TOKEN=$(echo $_TOKEN | jq -r .access_token)
}

# List access groups available to $_ACCESS_TOKEN
getAccessGroups () {
    curl -s -X GET \
    "https://iam.cloud.ibm.com/v2/groups?account_id=$_ACCOUNT_ID" \
    -H "Authorization: Bearer $_ACCESS_TOKEN" \
    -H "Content-Type: application/json"
}

# List access group members
getAccessGroupMembers () {
    _GROUP_MEMBERS=$(curl -s -X GET \
    "https://iam.cloud.ibm.com/v2/groups/$_ACCESS_GROUP_ID/members?verbose=true" \
    -H "Authorization: Bearer $_ACCESS_TOKEN" \
    -H "Content-Type: application/json")
}

getUserId () {
    _MEMBER_IAMID=$(curl -s -X GET "https://user-management.cloud.ibm.com/v2/accounts/$_ACCOUNT_ID/users" \
    -H "Authorization: Bearer $_ACCESS_TOKEN" \
    -H "Content-Type: application/json" | \
    jq -r '.resources[] | select (.email=="'${_USER_EMAIL}'") | .iam_id')
}

# Add member to access group
addGroupMember () {
    curl -s -X PUT \
    "https://iam.cloud.ibm.com/v2/groups/$_ACCESS_GROUP_ID/members" \
    -H "Authorization: Bearer $_ACCESS_TOKEN" \
    -H "Content-Type: application /json" \
    -d '{"members":[{"iam_id": "'$_MEMBER_IAMID'","type": "user"}]}'

}

# Delete member from access group
deleteGroupMember () {
    curl -s -X DELETE \
    "https://iam.cloud.ibm.com/v2/groups/$_ACCESS_GROUP_ID/members/$_MEMBER_IAMID" \
    -H "Authorization: Bearer $_ACCESS_TOKEN" \
    -H "Content-Type: application /json" \
}

# Test case

getAccessToken

getAccessGroupMembers
echo "Members of Access Group '${_ACCESS_GROUP_ID}':"
echo $_GROUP_MEMBERS | jq -r '.members[] | .name + " (" + .iam_id + ")"'

getUserId

echo "\nAdding member ${_MEMBER_IAMID} to group ID ${_ACCESS_GROUP_ID}"
addGroupMember
getAccessGroupMembers
echo "\nMembers of Access Group '${_ACCESS_GROUP_ID}':"
echo $_GROUP_MEMBERS | jq -r '.members[] | .name + " (" + .iam_id + ")"'

echo "\nDeleting member ${_MEMBER_IAMID} from group ID ${_ACCESS_GROUP_ID}"
deleteGroupMember
getAccessGroupMembers
echo "Members of Access Group '${_ACCESS_GROUP_ID}':"
echo $_GROUP_MEMBERS | jq -r '.members[] | .name + " (" + .iam_id + ")"'

