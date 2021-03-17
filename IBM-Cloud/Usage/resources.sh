#!/bin/bash

for g in $(ibmcloud resource groups --output JSON | jq -r '.[] | .name | @base64'); do
    group=$(echo $g | base64 --decode -)
    ibmcloud target -q -g "$group" > /dev/null
    instances=$(ibmcloud resource service-instances --output JSON | \
        jq -r '.[].id' | awk '{ FS = ":" }; {print $5}')
    echo "Resources in Group '${group}':"
    echo $instances
    echo
done
