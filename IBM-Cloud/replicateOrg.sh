#!/bin/bash

ORG=$1
USERS=$2

echo ORG=$ORG
echo USERS=$USERS

SPACE=dev
REGIONS='au-syd eu-de eu-gb us-east us-south'
SPACE_ROLES='SpaceManager SpaceDeveloper SpaceAuditor'

for REGION in $REGIONS
do
  echo replicating org $ORG to region $REGION

  bx account org-replicate $ORG $REGION
  bx target -r $REGION -o $ORG
  bx account space-create $SPACE

  for USER in $USERS
  do
    echo Setting space roles for user = $USER
    for ROLE in $SPACE_ROLES
    do
      bx account space-role-set $USER $ORG $SPACE $ROLE
    done
  done
done
