#!/bin/bash

USERS=$1
ORG=$2
SPACE=$3
REGION="au-syd"
ORG_ROLES="OrgManager BillingManager OrgAuditor"
SPACE_ROLES='SpaceManager SpaceDeveloper SpaceAuditor'

bx account org-create $ORG
bx target -o $ORG
bx account space-create $SPACE

for USER in $USERS
do
  bx account user-invite $USER
  bx account org-user-add $USER $ORG
  for ROLE in $ORG_ROLES
  do
    bx account org-role-set $USER $ORG $ROLE
  done

  echo Setting space roles for user = $USER
  for ROLE in $SPACE_ROLES
  do
    bx account space-role-set $USER $ORG $SPACE $ROLE
  done
done
