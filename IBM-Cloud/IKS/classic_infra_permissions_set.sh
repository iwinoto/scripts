#!/bin/bash

# Ref- https-//cloud.ibm.com/docs/containers?topic=containers-access_reference#infra

# For editing permissions from CLI, first get user ID from classic infrastructure

EMAIL=$1
ID=$(ibmcloud sl user list --output json | jq '.[] | select(.email=="'${EMAIL}'") | .id ')

#PERMISSIONS=(
#    "Device IPMI Remote management:REMOTE_MANAGEMENT"
#    "Account Add server:SERVER_ADD")
#PERMISSIONS+=(("Device Add compute with Public Network port" "PUBLIC_NETWORK_COMPUTE"))
#PERMISSIONS+=(("Device Cancel server" "SERVER_CANCEL"))
#PERMISSIONS+=(("Device OS reloads and rescue kernel" "SERVER_RELOAD"))
#PERMISSIONS+=(("Device View virtual server details" "VIRTUAL_GUEST_VIEW"))
#PERMISSIONS+=(("Device View hardware details" "HARDWARE_VIEW"))
#PERMISSIONS+=(("Account Add support tickets" "TICKET_ADD"))
#PERMISSIONS+=(("Account Edit support tickets" "TICKET_EDIT"))

#echo Number of permissions: ${PERMISSIONS[*]}
#for p in "${PERMISSIONS[@]}"; do
#    echo "in the loop"
#    echo $p
#    IFS=":" read arr <<< $p
#    echo $arr
#    echo "${arr[0]}"
#    echo ibmcloud sl user permission-edit ${ID} --permission ${arr[1]} --enable true
#done

echo Device IPMI Remote management
ibmcloud sl user permission-edit ${ID} --permission REMOTE_MANAGEMENT --enable true

echo Add server to account
ibmcloud sl user permission-edit ${ID} --permission SERVER_ADD --enable true

echo Add compute with Public Network port
ibmcloud sl user permission-edit ${ID} --permission PUBLIC_NETWORK_COMPUTE --enable true

echo Cancel server
ibmcloud sl user permission-edit ${ID} --permission SERVER_CANCEL --enable true

echo Device OS reloads and rescue kernel
ibmcloud sl user permission-edit ${ID} --permission SERVER_RELOAD --enable true

echo Device View virtual server details
ibmcloud sl user permission-edit ${ID} --permission VIRTUAL_GUEST_VIEW --enable true

echo Device View hardware details
ibmcloud sl user permission-edit ${ID} --permission HARDWARE_VIEW --enable true

echo Add support tickets
ibmcloud sl user permission-edit ${ID} --permission TICKET_ADD --enable true

echo Edit support tickets
echo ibmcloud sl user permission-edit ${ID} --permission TICKET_EDIT --enable true

