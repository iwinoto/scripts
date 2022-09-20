#!/usr/bin/env python3

import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.realpath(sys.argv[0])), '..'))
from sdcclient import IbmAuthHelper, SdMonitorClient

# Parse arguments.
def usage():
    print('usage: %s <endpoint-url> <oauth_token> <instance_guid>' % sys.argv[0])
    print('endpoint-url: The endpoint URL that should point to IBM Cloud')
    print('oauth_token: Access token. To manage team resources, the token must be for the Sysdig team.')
    print('instance-guid: GUID of an IBM Cloud Monitoring with monitoring instance')
    sys.exit(1)

if len(sys.argv) != 4:
   print("arguments: ", sys.argv)
   usage()


def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file))


def cleanup_dir(path):
    if os.path.exists(path) == False:
        return
    if os.path.isdir(path) == False:
        print('Provided path is not a directory')
        sys.exit(-1)

    for file in os.listdir(path):
        file_path = os.path.join(path, file)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
            else:
                print('Cannot clean the provided directory due to delete failure on %s' % file_path)
        except Exception as e:
            print(e)
    os.rmdir(path)

sysdig_dashboard_dir = 'sysdig-dashboard-dir'

URL = sys.argv[1]
TOKEN = sys.argv[2]
GUID = sys.argv[3]

# Instantiate the client
# ibm_headers is only required when user passes in API key.
#ibm_headers = IbmAuthHelper.get_headers(URL, APIKEY, GUID)
sdclient = SdMonitorClient(token=TOKEN, sdc_url=URL)

print("requesting dashboards")
ok, res = sdclient.get_dashboards()
print("received response")

if not ok:
    print("Resposne is not OK!")
    print(res)
    print("Exiting")
    sys.exit(1)

# Creating sysdig dashboard directory to store dashboards
if not os.path.exists(sysdig_dashboard_dir):
    os.makedirs(sysdig_dashboard_dir)

for db in res['dashboards']:
    sdclient.save_dashboard_to_file(db, os.path.join(sysdig_dashboard_dir, str(db['id'])))

    print("Name: %s, # Charts: %d" % (db['name'], len(db['widgets'])))