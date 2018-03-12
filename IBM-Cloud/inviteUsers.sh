#!/bin/bash

USERS=
ORG=
SPACE=dev
REGION="au-syd"
ORG_ROLES="OrgManager BillingManager OrgAuditor"
SPACE_ROLES='SpaceManager SpaceDeveloper SpaceAuditor'

print_help()
{
  echo
  echo "Invite users to an IBM Cloud Organisation"
  echo "Pre-requisite: You MUST be logged in to IBM Cloud with 'bx login'."
  echo
  echo "Usage:"
  echo "$0 [-s <Default Org space> -r <IBM Cloud region>] ORG-NAME USERS"
  echo
  echo "Arguments:"
  echo "ORG-NAME  IBM Cloud Organisation (Org) to replicate."
  echo "Users     Space separated list of users to invite to Org."
  echo "          Users will be provided with the following roles:"
  echo "          ORG ROLES:"
  for ROLE in $ORG_ROLES
  do
    printf '%b' "\t\t$ROLE\n"
  done
  echo "          SPACE ROLES:"
  for ROLE in $SPACE_ROLES
  do
    printf '%b' "\t\t$ROLE\n"
  done
  echo
  echo "Options are:"
  echo "-u  [REQUIRED]  Space separated list of users to invite to Org."
  echo "                Users will be provided with the following roles:"
  for ROLE in $SPACE_ROLES
  do
    printf '%b' "\t\t\t$ROLE\n"
  done
  echo "-o  [REQUIRED]  IBM Cloud Organisation (Org) to invite users to."
  echo "-s  [OPTIONAL]  Default space to add to replicated Org."
  echo "                Defaults to 'dev'"
  echo "-r  [OPTIONAL]  IBM Cloud region of Org to invite users to."
  echo "                Defaults to currently logged in region."
  echo "                Must be one of:"
  printf '%b' "`(bx regions | awk ''/.-./' {print "\t\t\t",$1}' -)`\n"
  echo "-h  Print this message."
  echo
  exit 0
}

while getopts "s:r:h" optname
do
    case "$optname" in
      "s")
        SPACE=$OPTARG
        ;;
      "r")
        REGION=$OPTARG
        ;;
      "h")
        print_help
        exit $?
        ;;
      "?")
        echo "Unknown option $OPTARG"
        print_help
        exit $?
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        print_help
        exit $?
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        print_help
        exit $?
        ;;
    esac
done

shift $((OPTIND -1))

if [ -n "$1" ]; then
  ORG="$1"
else
  echo "Incorrect number of arguments."
  echo "You must provide ORG-NAME and USERS."
  print_help
  exit 1
fi
if [ -n "$2" ]; then
  USERS="$2"
else
  echo "Incorrect number of arguments."
  echo "You must provide ORG-NAME and USERS."
  print_help
  exit 1
fi

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
