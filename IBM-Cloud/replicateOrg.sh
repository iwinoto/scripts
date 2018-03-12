#!/bin/bash

ORG=
USERS=

SPACE=dev
# First 3 lines of 'bx regions' is informational.
# 'NR>3' tells 'awk' to only process rows after row 3.
REGIONS=$(bx regions | awk 'NR>3 {print $1}' -)
#SPACE_ROLES='SpaceManager SpaceDeveloper SpaceAuditor'
# Dynamically get roles from command line help
# RULE 1: Look for first row starting with ROLES:, flag it and get the row number
# RULE 2: If we've hit ROLES:, print first col of remaining rows
SPACE_ROLES=$(bx account space-role-set -h | \
  awk ' \
    /^ *ROLES:/ { rolesFound=1; roleRow=NR}; \
    (rolesFound && NR>roleRow) {print $1}' - )

print_help()
{
  # Using 'printf' to allow formatting with ''\t', etc.
  echo
  echo "Replice an IBM Cloud Organisation to other regions."
  echo "Pre-requisite: You MUST be logged in to IBM Cloud with 'bx login'."
  echo
  echo "Usage:"
  echo "$0 [-u <Users> -s <Default Org space> -r <IBM Cloud region>] ORG-NAME"
  echo
  echo "Arguments:"
  echo "ORG-NAME  IBM Cloud Organisation (Org) to replicate."
  echo
  echo "Options are:"
  echo "-u  [OPTIONAL]  Space separated list of users in Org to provide"
  echo "                space roles to."
  echo "                Defaults to ALL users in the Org."
  echo "                The following space roles will be provided:"
  for ROLE in $SPACE_ROLES
  do
    printf '%b' "\t\t\t$ROLE\n"
  done
  echo "-s  [OPTIONAL]  Default space to add to replicated Org."
  echo "                Defaults to 'dev'"
  echo "-r  [OPTIONAL]  Space separated list of IBM Cloud regions to"
  echo "                replicate Org to."
  echo "                Defaults to all regions."
  echo "                Must be at least one of:"
  for REGION in $REGIONS
  do
    printf '%b' "\t\t\t$REGION\n"
  done
  echo "-h  Print this message."
  echo
}

while getopts "u:s:r:h" optname
do
    case "$optname" in
      "u")
        USERS=$OPTARG
        ;;
      "s")
        SPACE=$OPTARG
        ;;
      "r")
        REGIONS=$OPTARG
        ;;
      "h")
        print_help
        exit 0
        ;;
      "?")
        echo "Unknown option $OPTARG"
        print_help
        exit 1
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        print_help
        exit 1
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        print_help
        exit $?
        ;;
    esac
done

shift $(($OPTIND -1))
if [ -n "$1" ]; then
  ORG=$1
else
  echo "Argument ORG-NAME missing."
  print_help
  exit 1
fi

if [ -z "$USERS" ]; then
  echo "No users provided. Getting all users for Org $ORG."
  # First 2 lines of 'bx account -a' is informational.
  # 'NR>2' tells 'awk' to only process rows after row 2.
  USERS=$(bx account org-users $ORG -a | awk 'NR>2 {print $1}' -)

  for USER in $USERS
  do
    echo "    $USER"
  done
fi

for REGION in $REGIONS
do
  echo replicating org $ORG to region $REGION

  bx account org-replicate $ORG $REGION

  if [ -n "$SPACE" ]; then
    echo "Adding space $SPACE to Org $ORG in region $REGION"
    bx target -r $REGION -o $ORG
    bx account space-create $SPACE

    for USER in $USERS
    do
      echo Setting space roles for user $USER
      for ROLE in $SPACE_ROLES
      do
        bx account space-role-set $USER $ORG $SPACE $ROLE
      done
    done
  fi
done
