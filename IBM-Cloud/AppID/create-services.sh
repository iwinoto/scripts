#!/bin/bash

if [[ -z "${APPID_INSTANCE_NAME}" ]]; then
    APPID_INSTANCE_NAME=appid-test-domain01
fi
if [[ -z "${LOCATION}" ]]; then
    LOCATION=au-syd
fi
if [[ -z "${GROUP}" ]]; then
    GROUP=default
fi

# Create appid service instance
# Search market place for appid using `ibmcloud catalog marketplace | grep -i appid`
# Get the available plans and locations from the service description using `ibmcloud catalog service appid`

ibmcloud resource service-instance-create $APPID_INSTANCE_NAME appid graduated-tier $LOCATION -g $GROUP

# Create service credential service key with `Reader` role name
ibmcloud resource service-key-create $APPID_INSTANCE_NAME-key Reader --instance-name $APPID_INSTANCE_NAME
