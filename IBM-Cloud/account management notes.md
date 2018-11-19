# Infrastructure management scripts
## What functionality is needed.
1. Create orgs
1. Replicate org to other regions
1. Create `dev` space in all regions
1. Add user to org
1. Add `user-org` & `user-space` roles
1. Add resource group permissions
1. Create Infrastructure API key

API key
~/dev/apiKey-bmxfunc1-onboarding.json

Use a task based tool like `make` or `gradle`

## Terminal session...
```sh
# Export API key to $BLUEMIX_API_KEY from API key json file
$ export BLUEMIX_API_KEY=$(cat "<API key json file" | jq -r .apiKey)
$ ibmcloud login -a https://api.au-syd.bluemix.net

$ bx account orgs
Getting orgs in region 'au-syd' as bmxfunc1@us.ibm.com...
Retrieving current account...
OK

Name                      Region   Account owner         Account ID                         Status
iwinoto                   au-syd   bmxfunc1@us.ibm.com   27ff418fedd6aedffb8dc6ae4164a1d2   active
IBM Cloud AP Tech Sales   au-syd   bmxfunc1@us.ibm.com   27ff418fedd6aedffb8dc6ae4164a1d2   active
ISA-ICICI-API-C           au-syd   bmxfunc1@us.ibm.com   27ff418fedd6aedffb8dc6ae4164a1d2   active
ISA-ITC-POC               au-syd   bmxfunc1@us.ibm.com   27ff418fedd6aedffb8dc6ae4164a1d2   active
IBM-BT                    au-syd   bmxfunc1@us.ibm.com   27ff418fedd6aedffb8dc6ae4164a1d2   active

$ bx account org-replicate IBM-BT us-south
Replicating organization 'IBM-BT' to region 'us-south'
OK
Organization 'IBM-BT' was replicated to region 'us-south'.

$ bx regions
Listing regions...

Name       Geolocation      Customer   Deployment   Domain                CF API Endpoint                   Type
eu-de      Germany          IBM        Production   eu-de.bluemix.net     https://api.eu-de.bluemix.net     public
au-syd     Sydney           IBM        Production   au-syd.bluemix.net    https://api.au-syd.bluemix.net    public
us-east    US East          IBM        Production   us-east.bluemix.net   https://api.us-east.bluemix.net   public
us-south   US South         IBM        Production   ng.bluemix.net        https://api.ng.bluemix.net        public
eu-gb      United Kingdom   IBM        Production   eu-gb.bluemix.net     https://api.eu-gb.bluemix.net     public

$ bx account org-replicate IBM-BT eu-gb
Replicating organization 'IBM-BT' to region 'eu-gb'
OK
Organization 'IBM-BT' was replicated to region 'eu-gb'.

$ bx account org-replicate IBM-BT us-east
Replicating organization 'IBM-BT' to region 'us-east'
OK
Organization 'IBM-BT' was replicated to region 'us-east'.

$ bx account org-replicate IBM-BT eu-de
Replicating organization 'IBM-BT' to region 'eu-de'
OK
Organization 'IBM-BT' was replicated to region 'eu-de'.

$ bx account org-roles
Retrieving all organization roles of bmxfunc1@us.ibm.com...
OK
Organization              Role
IBM Cloud AP Tech Sales   OrgManager
IBM-BT                    OrgManager
ISA-ICICI-API-C           OrgManager
ISA-ITC-POC               OrgManager
iwinoto                   BillingManager
iwinoto                   OrgManager
iwinoto                   OrgAuditor

$ bx account org-users IBM-BT
Getting users in org 'IBM-BT' as bmxfunc1@us.ibm.com...
MANAGERS
iwinoto@au1.ibm.com
sunibabu@in.ibm.com
bmxfunc1@us.ibm.com

BILLING MANAGERS
iwinoto@au1.ibm.com
sunibabu@in.ibm.com

AUDITORS



$ bx target region eu-gb

API endpoint:     https://api.au-syd.bluemix.net (API version: 2.92.0)
Region:           au-syd
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.


$ bx target

API endpoint:     https://api.au-syd.bluemix.net (API version: 2.92.0)
Region:           au-syd
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx target -r us-south
Switched to region us-south

API endpoint:     https://api.ng.bluemix.net (API version: 2.92.0)
Region:           us-south
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx target -o IBM-BT -r us-south
Switched to region us-south

Targeted org IBM-BT

API endpoint:     https://api.ng.bluemix.net (API version: 2.92.0)
Region:           us-south
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:              IBM-BT
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx account space-create dev
Invoking 'cf create-space dev'...

Creating space dev in org IBM-BT as bmxfunc1@us.ibm.com...
OK
Assigning role RoleSpaceManager to user bmxfunc1@us.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK
Assigning role RoleSpaceDeveloper to user bmxfunc1@us.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK

TIP: Use 'cf target -o "IBM-BT" -s "dev"' to target new space

$ bx target -o IBM-BT -r us-east
Switched to region us-east

Targeted org IBM-BT

API endpoint:     https://api.us-east.bluemix.net (API version: 2.92.0)
Region:           us-east
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:              IBM-BT
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx account space-create dev
Invoking 'cf create-space dev'...

Creating space dev in org IBM-BT as bmxfunc1@us.ibm.com...
OK
Assigning role RoleSpaceManager to user bmxfunc1@us.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK
Assigning role RoleSpaceDeveloper to user bmxfunc1@us.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK

TIP: Use 'cf target -o "IBM-BT" -s "dev"' to target new space

$ bx target -o IBM-BT -r eu-gb
Switched to region eu-gb

Targeted org IBM-BT

API endpoint:     https://api.eu-gb.bluemix.net (API version: 2.92.0)
Region:           eu-gb
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:              IBM-BT
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx account space-create dev
Invoking 'cf create-space dev'...

Creating space dev in org IBM-BT as bmxfunc1@us.ibm.com...
OK
Assigning role RoleSpaceManager to user bmxfunc1@us.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK
Assigning role RoleSpaceDeveloper to user bmxfunc1@us.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK

TIP: Use 'cf target -o "IBM-BT" -s "dev"' to target new space

$ bx target -o IBM-BT -r eu-de
Switched to region eu-de

Targeted org IBM-BT

API endpoint:     https://api.eu-de.bluemix.net (API version: 2.92.0)
Region:           eu-de
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:              IBM-BT
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx account space-create dev
Invoking 'cf create-space dev'...

Creating space dev in org IBM-BT as bmxfunc1@us.ibm.com...
OK
Space dev already exists

$ bx account space-roles IBM-BT
Retrieving all space roles of bmxfunc1@us.ibm.com under organization IBM-BT...
OK
Space   Role
dev     SpaceAuditor
dev     SpaceManager
dev     SpaceDeveloper

$ bx account space-users IBM-BT dev
Getting users in org IBM-BT / space dev as bmxfunc1@us.ibm.com
SPACE MANAGERS
sunibabu@in.ibm.com
bmxfunc1@us.ibm.com

SPACE DEVELOPER
sunibabu@in.ibm.com
bmxfunc1@us.ibm.com

SPACE AUDITORS
bmxfunc1@us.ibm.com

$ bx target -o IBM-BT -r us-south
Switched to region us-south

Targeted org IBM-BT

API endpoint:     https://api.ng.bluemix.net (API version: 2.92.0)
Region:           us-south
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:              IBM-BT
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx account space-users IBM-BT dev
Getting users in org IBM-BT / space dev as bmxfunc1@us.ibm.com
SPACE MANAGERS
bmxfunc1@us.ibm.com

SPACE DEVELOPER
bmxfunc1@us.ibm.com

SPACE AUDITORS

$ bx account space-role-set sunibabu@in.ibm.com IBM-BT dev SpaceManager
Assigning role SpaceManager to user sunibabu@in.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK

$ bx account space-role-set sunibabu@in.ibm.com IBM-BT dev SpaceDeveloper
Assigning role SpaceDeveloper to user sunibabu@in.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK

$ bx target -o IBM-BT -r us-east
Switched to region us-east

Targeted org IBM-BT

API endpoint:     https://api.us-east.bluemix.net (API version: 2.92.0)
Region:           us-east
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:              IBM-BT
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx account space-role-set sunibabu@in.ibm.com IBM-BT dev SpaceManager
Assigning role SpaceManager to user sunibabu@in.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK

$ bx account space-role-set sunibabu@in.ibm.com IBM-BT dev SpaceDeveloper
Assigning role SpaceDeveloper to user sunibabu@in.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK

$ bx target -o IBM-BT -r eu-gb
Switched to region eu-gb

Targeted org IBM-BT

API endpoint:     https://api.eu-gb.bluemix.net (API version: 2.92.0)
Region:           eu-gb
User:             bmxfunc1@us.ibm.com
Account:          IBM (27ff418fedd6aedffb8dc6ae4164a1d2) <-> 1500827
Resource group:   Default
Org:              IBM-BT
Space:

Tip: If you are managing Cloud Foundry applications and services
- Use 'bx target --cf' to target Cloud Foundry org/space interactively, or use 'bx target -o ORG -s SPACE' to target the org/space.
- Use 'bx cf' if you want to run the Cloud Foundry CLI with current Bluemix CLI context.

$ bx account space-role-set sunibabu@in.ibm.com IBM-BT dev SpaceDeveloper
Assigning role SpaceDeveloper to user sunibabu@in.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK

$ bx account space-role-set sunibabu@in.ibm.com IBM-BT dev SpaceManager
Assigning role SpaceManager to user sunibabu@in.ibm.com in org IBM-BT / space dev as bmxfunc1@us.ibm.com...
OK
```