#!/bin/bash
# source this so the export will work in the calling process

echo Exporting API key from file: $1
export IBMCLOUD_API_KEY=$(cat "$1" | jq -r .apikey)

#echo IBMCLOUD_API_KEY=$IBMCLOUD_API_KEY
