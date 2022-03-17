#!/bin/bash

# Export JSON of all access groups, access policies for the group
# and member users for the group.
# JSON schema is described in : UsersByAccessGroup.schema.json

ALL_ACCOUNT_USERS_ACCESS_LIST="["
_group_count=0

# Because group names have spaces that are not handled by Bash 'for',
# the group names need to be base64 encoded and then decoded for processing.
#_groups=$(ibmcloud iam access-groups --output json | jq -r '.[].name | @base64')
#if [ "$DEBUG" ]; then
#    echo "Groups: ${_groups}"
#fi

#if [ "$TEST" ]; then
#    _groups_len=$TEST
#else
#    _groups_len=${#_groups[@]}
#fi

#if [ "$DEBUG" ]; then
#    echo "Groups len: $_groups_len"
#fi

echo "$(date)\nSTART" > UsersByAccessGroup-progress.txt

for _group_name_encoded in $(ibmcloud iam access-groups --output json | jq -r '.[].name | @base64'); do
    ((_group_count+=1))
    if [ "$DEBUG" ]; then
        echo "Group count: ${_group_count}"
        echo "Group name encoded: ${_group_name_encoded}"
    fi
    _group_name=$(echo $_group_name_encoded | base64 --decode -);
    if [ "$DEBUG" ]; then
        echo "Access group: ${_group_name}"
    fi
    echo "\nGroup count: ${_group_count}" >> UsersByAccessGroup-progress.txt
    echo "Access group: ${_group_name}" >> UsersByAccessGroup-progress.txt

    # Use `sed` to retain escaped newline characters
    GROUP=$(ibmcloud iam access-group "$_group_name" --output json | jq -r '.[0]'  | sed 's/\\n/\\\\n/g')
    POLICIES="$(ibmcloud iam access-group-policies "$_group_name" --output json  | sed 's/\\n/\\\\n/g')"
    USERS=$(ibmcloud iam access-group-users "$_group_name" --output json | sed 's/\\n/\\\\n/g')

    if (( $_group_count > 1 )); then
        ALL_ACCOUNT_USERS_ACCESS_LIST+=","
    fi
    ALL_ACCOUNT_USERS_ACCESS_LIST+="\n{"
    ALL_ACCOUNT_USERS_ACCESS_LIST+="\n\"access_group\":${GROUP}"
    ALL_ACCOUNT_USERS_ACCESS_LIST+=",\n\"policies\":${POLICIES}"
    ALL_ACCOUNT_USERS_ACCESS_LIST+=",\n\"users\":${USERS}"
    ALL_ACCOUNT_USERS_ACCESS_LIST+="\n}"

    if [ $TEST ]; then
        if (( $_group_count == $TEST )); then
            break
        fi
    fi
done

ALL_ACCOUNT_USERS_ACCESS_LIST+="\n]"
echo "${ALL_ACCOUNT_USERS_ACCESS_LIST}"

echo "\nDONE!\n$(date)" >> UsersByAccessGroup-progress.txt

## jq snippets to create CSV files

### Export users with access groups to CSV
# flatten structure to array of users with access group names
# jq '[.[] | .access_group.name as $group_name | .users[] | . += {"access_group_name":$group_name} | {name, email, access_group_name}] | .'

# Now convert to CSV of users and access group names
# jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'

### Export access group policies
