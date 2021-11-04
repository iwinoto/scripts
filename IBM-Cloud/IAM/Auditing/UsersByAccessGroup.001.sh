#!/bin/bash

# Export JSON of all access groups, access policies for the group
# and member users for the group.
# JSON format is:
# [
#    "access_group": {
#        "id": "AccessGroupId-50944ee2-9d83-4523-bc83-0477c3bb0c4f",
#        "name": "View cases",
#        "description": "DO NOT DELETE.  This Access Group is used for classic infrastructure permission migration.",
#        "created_at": "2018-12-04T23:52:24Z",
#        "created_by_id": "iam-ServiceId-0aec4d99-f049-44f2-8b1f-04a378800d9d",
#        "last_modified_at": "2019-02-07T17:08:32Z",
#        "last_modified_by_id": "iam-ServiceId-0aec4d99-f049-44f2-8b1f-04a378800d9d",
#        "href": "https://iam.cloud.ibm.com/v2/groups/AccessGroupId-50944ee2-9d83-4523-bc83-0477c3bb0c4f",
#        "is_federated": false,
#        "policies": [
#            {
#                "id": "0b32985c-954b-431f-9264-916b30976fcf",
#                "type": "access",
#                "subjects": [
#                    {
#                        "attributes": [
#                            {
#                                "name": "access_group_id",
#                                "value": "AccessGroupId-9cd1d868-d437-4ca3-83e2-18fd18e48f22"
#                            }
#                        ]
#                    }
#               ],
#                "roles": [
#                    {
#                        "role_id": "crn:v1:bluemix:public:iam::::role:Viewer",
#                        "display_name": "Viewer",
#                        "description": "As a viewer, you can view service instances, but you can't modify them."
#                    },
#                    {
#                       "role_id": "crn:v1:bluemix:public:iam::::role:Operator",
#                        "display_name": "Operator",
#                        "description": "As an operator, you can perform platform actions required to configure and operate service instances, such as viewing a service's dashboard."
#                    },
#                    {
#                       "role_id": "crn:v1:bluemix:public:iam::::role:Editor",
#                       "display_name": "Editor",
#                        "description": "As an editor, you can perform all platform actions except for managing the account and assigning access policies."
#                    },
#                    {
#                       "role_id": "crn:v1:bluemix:public:iam::::role:Administrator",
#                       "display_name": "Administrator",
#                        "description": "As an administrator, you can perform all platform actions based on the resource this role is being assigned, including assigning access policies to other users."
#                    },
#                    {
#                        "role_id": "crn:v1:bluemix:public:iam::::serviceRole:Reader",
#                        "display_name": "Reader",
#                        "description": "As a reader, you can perform read-only actions within a service such as viewing service-specific resources."
#                    },
#                    {
#                        "role_id": "crn:v1:bluemix:public:iam::::serviceRole:Writer",
#                        "display_name": "Writer",
#                       "description": "As a writer, you have permissions beyond the reader role, including creating and editing service-specific resources."
#                    },
#                    {
#                       "role_id": "crn:v1:bluemix:public:iam::::serviceRole:Manager",
#                       "display_name": "Manager",
#                       "description": "As a manager, you have permissions beyond the writer role to complete privileged actions as defined by the service. In addition, you can create and edit service-specific resources."
#                   }
#               ],
#               "resources": [
#                   {
#                       "attributes": [
#                           {
#                                "name": "accountId",
#                               "operator": "stringEquals",
#                               "value": "c15ecdd5890bdc705dd4e448a0a4b68d"
#                            },
#                            {
#                                "name": "resourceGroupId",
#                               "operator": "stringEquals",
#                               "value": "bada6c7c5d0a448bb4865a4e2b5e2ae9"
#                           },
#                           {
#                                "name": "serviceName",
#                                "operator": "stringEquals",
#                                "value": "containers-kubernetes"
#                            }
#                        ]
#                    }
#                ],
#                "href": "https://iam.cloud.ibm.com/v1/policies/0b32985c-954b-431f-9264-916b30976fcf",
#                "created_at": "2021-09-20T00:40:48.112Z",
#                "created_by_id": "IBMid-550003UCTJ",
#                "last_modified_at": "2021-09-20T00:40:48.112Z",
#                "last_modified_by_id": "IBMid-550003UCTJ"
#            }
#        ],
#        "users":[
#           {
#               "iam_id": "IBMid-662001KTBG",
#               "type": "user",
#               "name": "Ryan Pereira",
#               "email": "Ryan.Pereira@ibm.com",
#               "description": "",
#               "href": "https://iam.cloud.ibm.com/v2/groups/AccessGroupId-719d840f-e0ca-4664-a8c8-ac123cfdbff5/members/IBMid-662001KTBG",
#               "created_at": "2021-10-20T00:30:59Z",
#                "created_by_id": "IBMid-550003UCTJ"
#           }
#       ]
#   } 
# ]

ALL_ACCOUNT_USERS_ACCESS_LIST="["
_group_count=0

# Because group names have spaces that are not handled by Bash 'for',
# the group names need to be base64 encoded and then decoded for processing.
_groups=$(ibmcloud iam access-groups --output json | jq -r '.[].name | @base64')
if [ "$DEBUG" ]; then
    echo "Groups: ${_groups}"
fi

if [ "$TEST" ]; then
    _groups_len=$TEST
else
    _groups_len=${#_groups[@]}
fi

if [ "$DEBUG" ]; then
    echo "Groups len: $_groups_len"
fi

echo "Groups len: $_groups_len" > UsersByAccessGroup-progress.txt

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

    GROUP=$(ibmcloud iam access-group "$_group_name" --output json | jq -r '.[0]')
    POLICIES=$(ibmcloud iam access-group-policies "$_group_name" --output json)
    USERS=$(ibmcloud iam access-group-users "$_group_name" --output json)
    ALL_ACCOUNT_USERS_ACCESS_LIST+="\n{"
    ALL_ACCOUNT_USERS_ACCESS_LIST+="\n\"access_group\":${GROUP}"
    ALL_ACCOUNT_USERS_ACCESS_LIST+=",\n\"policies\":${POLICIES}"
    ALL_ACCOUNT_USERS_ACCESS_LIST+=",\n\"users\":${USERS}"
    ALL_ACCOUNT_USERS_ACCESS_LIST+="\n}"
    if (( $_group_count < $_groups_len )); then
        ALL_ACCOUNT_USERS_ACCESS_LIST+=","
    else
        break
    fi
done
ALL_ACCOUNT_USERS_ACCESS_LIST+="\n]"
echo "${ALL_ACCOUNT_USERS_ACCESS_LIST}"

echo "DONE!" >> UsersByAccessGroup-progress.txt
