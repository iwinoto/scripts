// for testing with nodejs. Remove this if using JavaScript.
const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;

const apiKey = process.env._API_KEY;

// Account = GBS c/o Lygon 1B Pty Ltd
const accountId = "c15ecdd5890bdc705dd4e448a0a4b68d";
// Access group = Security controls research
const accessGroupId = "AccessGroupId-6720da8b-df19-4dd1-a5a2-475b789baa00";
// test user
const userEmail = "Aharon.Rossano@ibm.com";

const identityEndpoint = "https://iam.cloud.ibm.com/identity/";
const iamEndpoint = "https://iam.cloud.ibm.com/v2/";
const userEndpoint = "https://user-management.cloud.ibm.com/v2/";

var xhr = new XMLHttpRequest();
xhr.onerror = function () {
    console.log("Request failed");
};
const asynchXHR = false;

var userId;
var groupMembers;
var accessToken;

function getMemberData(memberIAMId) {
    return {
        members: [
            {
                iam_id: memberIAMId,
                type: "user"
            }
        ]
    };
};

// Get api-key access token
function getAccessToken(apiKey) {
    var url = identityEndpoint + "token";
    url += "?grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=" + apiKey;
    xhr = new XMLHttpRequest();
    xhr.open("POST", url, asynchXHR);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.setRequestHeader("Accept", "application/json");
    xhr.onload = function () {
        if (this.status != 200) {
            console.log("Token request fail.\nHTTP error " + this.status + ":" + this.statusText);
        } else {
            console.log("token request success")
            accessToken = JSON.parse(this.responseText).access_token;
        }
    };
    console.log("sending accessToken request");
    xhr.send();
    return accessToken;
    // xhr.send("grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=" + apiKey);
};

// List access groups available to $_ACCESS_TOKEN
function getAccessGroups(accountId, token) {
    var url = iamEndpoint + "token/groups?account_id=" + accountId;
    xhr = new XMLHttpRequest();
    xhr.open("GET", url, asynchXHR);
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Accept", "application/json");

    xhr.onload = function () {
        if (this.status != 200) {
            console.log("Access Group list request fail.\nHTTP error " + this.status + ":" + this.statusText);
        } else {
            console.log("Access Group list success")
            accessGroups = JSON.parse(xhr.responseText);
        }
    }
    xhr.send();
    return accessGroups;
};

// List access group members
function getAccessGroupMembers(accessGroupId, token) {
    var members;
    var url = iamEndpoint + "groups/" + accessGroupId + "/members?verbose=true";
    xhr = new XMLHttpRequest();
    xhr.open("GET", url, asynchXHR);
    if (xhr.getRequestHeader("Authorization") != "Bearer " + token){
        xhr.setRequestHeader("Authorization", "Bearer " + token);
    };
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Accept", "application/json");

    xhr.onload = function () {
        if (this.status != 200) {
            console.log("Access Group member list request fail.\nHTTP error " + this.status + ":" + this.statusText);
        } else {
            console.log("Access Group member list success")
            members = JSON.parse(xhr.responseText).members;
        }
    }
    xhr.send();
    return members;
}

function getUserId(email, account, token) {
    var url = userEndpoint + "accounts/" + account + "/users";
    var userId;
    xhr = new XMLHttpRequest();
    xhr.open("GET", url, asynchXHR);
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Accept", "application/json");
    
    xhr.onload = function () {
        if (this.status != 200) {
            console.log("Get userId fail.\nHTTP error " + this.status + ":" + this.statusText);
            console.log(this.responseText);
        } else {
            var userList = JSON.parse(xhr.responseText).resources;
            for (user of userList) {
                if (user.email == email) {
                    userId = user.iam_id;
                    break;
                }
            }
        }
    };
    xhr.send();
    return userId;
}

// Add member to access group
function addAccessGroupMember(userId, groupId, token) {
    var url = iamEndpoint + "groups/" + groupId + "/members";
    
    xhr = new XMLHttpRequest();
    xhr.open("PUT", url, asynchXHR);
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Accept", "application/json");

    xhr.onload = function () {
        if (this.status != 207) {
            console.log("Add user to group fail.\nHTTP error " + this.status + ":" + this.statusText);
        } else {
            console.log("User " + userId + " added to access group " + groupId);
        }
    };
    xhr.send(JSON.stringify(getMemberData(userId)));
}

// Delete member from access group
function deleteAccessGroupMember(userId, groupId, token) {
    var url = iamEndpoint + "groups/" + groupId + "/members/" + userId;
    xhr = new XMLHttpRequest();
    xhr.open("DELETE", url, asynchXHR);
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("Accept", "application/json");

    xhr.onload = function () {
        if (this.status != 204) {
            console.log("Delete user from group fail.\nHTTP error " + this.status + ":" + this.statusText);
        } else {
            console.log("User " + userId + " deleted from access group " + groupId);
        }
    };
    xhr.send();
}

// Test case
accessToken = getAccessToken(apiKey);

groupMembers = getAccessGroupMembers(accessGroupId, accessToken);
console.log("\nMembers of Access Group " + accessGroupId + " : ");
for (member of groupMembers){
        console.log(member.name + " (" + member.iam_id + ")");
};

userId = getUserId(userEmail, accountId, accessToken);

console.log("\nAdding member " + userId + " to group ID " + accessGroupId);
addAccessGroupMember(userId, accessGroupId, accessToken)
groupMembers = getAccessGroupMembers(accessGroupId, accessToken);
console.log("\nMembers of Access Group " + accessGroupId + " : ");
for (member of groupMembers){
    console.log(member.name + " (" + member.iam_id + ")");
};

console.log("\nDeleting member " + userId + " from group ID " + accessGroupId);
deleteAccessGroupMember(userId, accessGroupId, accessToken);
groupMembers = getAccessGroupMembers(accessGroupId, accessToken);
console.log("\nMembers of Access Group " + accessGroupId + " : ");
for (member of groupMembers){
    console.log(member.name + " (" + member.iam_id + ")");
};
