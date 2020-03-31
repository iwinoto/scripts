#!bin/bash

# Delete a service instance
# Will ask for confirmation on key and service instance deletion

SERVICE_NAME=$1

# First find all service keys and delete those
for k in $(ibmcloud resource service-keys --instance-name $1 --output json | jq -r '.[] | .name')
do
    ibmcloud resource service-key-delete $k
done

# Now delete the service
ibmcloud resource service-instance-delete $1