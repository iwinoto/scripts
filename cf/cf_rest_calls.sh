# Login to CF
# returns a JSON object which contains the token at "access_token"

curl -v -X POST -H "content-type: application/x-www-form-encoded;charset=utf-8" -H "accept: application/json;charset=utf-8" -H "authorization: Basic Y2Y6" --data-urlencode "grant_type=password&username=$CF_USER&password=$CF_PASSWD" "https://api.ng.bluemix.net/uaa/oauth/token"

# store the token to make subsequent calls
auth="Authorization: bearer $token"

# list all organisations
curl -v -X GET -H "$auth" "https://api.ng.bluemix.net/v2/organizations"

# from the list of orgs, select one and use its guid to make org related calls.

# Get a list of all the services for an org
curl -v -X GET -H "$auth" "https://api.ng.bluemix.net/v2/organizations/6b08bf7f-79f2-42c2-ba26-56d92c274098/services"
