#!/bin/bash

# Script to get access policy information for an access group.
# may be used to copy policy to another access group
#
# Example Access Groups for testing:
# 

ACCESS_GROUP_NAME="Group mgmt test"
 
ACCESS_GROUP_ID=$(ibmcloud iam access-groups --output json | \
    jq -r '.[] | select(.name == "'${ACCESS_GROUP_NAME}'")')

ACCESS_GROUP_POLICIES=$(ibmcloud iam access-group-policies ${ACCESS_GROUP_NAME} --output json)

echo "$ACCESS_GROUP_POLICIES"
