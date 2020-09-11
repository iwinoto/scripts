# Installing Falco

## Falco overview

## Using Helm
With default chart values

```
$ helm install  falco stable/falco
```



On IKS free cluster the helm charts installs successfully, but the pod does not get to `running` state.

```
$  git kubectl get pod
NAME          READY   STATUS             RESTARTS   AGE
falco-cwmmn   0/1     CrashLoopBackOff   126        10h
```

On inspection of the log, we see the kernel module `falco-probe` did not install. The log showed it could not find the pre-built module in the Falco online repository.

```
$  git kubectl logs falco-cwmmn -p
ln: failed to create symbolic link '/usr/src//host/usr/src/linux-headers-4.4.0-174': No such file or directory
* Setting up /usr/src links from host
ln: failed to create symbolic link '/usr/src//host/usr/src/linux-headers-4.4.0-174-generic': No such file or directory
* Unloading falco-probe, if present
* Running dkms install for falco
Error! echo
Your kernel headers for kernel 4.4.0-174-generic cannot be found at
/lib/modules/4.4.0-174-generic/build or /lib/modules/4.4.0-174-generic/source.
* Running dkms build failed, couldn't find /var/lib/dkms/falco/0.20.0+d77080a/build/make.log
* Trying to load a system falco-probe, if present
* Trying to find precompiled falco-probe for 4.4.0-174-generic
Found kernel config at /host/boot/config-4.4.0-174-generic
* Trying to download precompiled module from https://s3.amazonaws.com/download.draios.com/stable/sysdig-probe-binaries/falco-probe-0.20.0%2Bd77080a-x86_64-4.4.0-174-generic-e0f19d41ef2b9b69d98779c4b5489657.ko
curl: (22) The requested URL returned error: 404 Not Found
Download failed, consider compiling your own falco-probe and loading it or getting in touch with the Falco community
Wed Mar  4 22:51:47 2020: Falco initialized with configuration file /etc/falco/falco.yaml
Wed Mar  4 22:51:47 2020: Loading rules from file /etc/falco/falco_rules.yaml:
Wed Mar  4 22:51:48 2020: Loading rules from file /etc/falco/falco_rules.local.yaml:
Wed Mar  4 22:51:49 2020: Unable to load the driver. Exiting.
Wed Mar  4 22:51:49 2020: Runtime error: error opening device /dev/falco0. Make sure you have root credentials and that the falco-probe module is loaded.. Exiting.
```

Created a standard cluster in Lygon account under `Security controls research` resource group.

```
$ ibmcloud ks cluster get sec-controls-research
Retrieving cluster sec-controls-research...
OK

Name:                           sec-controls-research
ID:                             bpg7msss03vit83ssa80
State:                          normal
Created:                        2020-03-05T04:09:23+0000
Location:                       syd01
Master URL:                     https://c1.au-syd.containers.cloud.ibm.com:21875
Public Service Endpoint URL:    https://c1.au-syd.containers.cloud.ibm.com:21875
Private Service Endpoint URL:   -
Master Location:                Sydney
Master Status:                  Ready (2 hours ago)
Master State:                   deployed
Master Health:                  normal
Ingress Subdomain:              sec-controls-research-e5fbe70a16444e53a79426b94254b29a-0000.au-syd.containers.appdomain.cloud
Ingress Secret:                 sec-controls-research-e5fbe70a16444e53a79426b94254b29a-0000
Workers:                        1
Worker Zones:                   syd01
Version:                        1.15.10_1531
Creator:                        -
Monitoring Dashboard:           -
Resource Group ID:              23a1d538607c487b96691cacf42371ae
Resource Group Name:            Security controls research
```

Followed instructions in Spence Krum's dev works article and [gitlab repo](https://gitlab.com/nibalizer/falco-iks).

Still getting same error of DKMS not being able to build probe and not fining pre-built probe on Falco storage.

## 6/3/2020
Solution might be to install kernel headers so that probe can be build. Since we have a standard cluster with worker nodes in the account, this can be accomplished with user access to the worker node device and installing linux headers.

First create a [VPN connection](https://cloud.ibm.com/docs/iaas-vpn?topic=iaas-vpn-getting-started) to the IBM Cloud IaaS network.

Ensure user has VPN access to the device subnet.
* User / `user ID` / Classic infrastructure / VPN Subnets
The user sets the VPN password in User / `user ID` / User detailse

Follow instructions to connect to [KVM console](https://www.ibm.com/support/pages/how-connect-kvm-console-ibm-cloud-virtual-servers) via MacOS finder (*Connect to server*). Firewall needs to be amended to allow access.

On kube worker node device:
```
apt-get install linux-headers-generic
```

Still did not make a difference. getting 

```
kubectl logs falco-twmmz -p
* Setting up /usr/src links from host
ln: failed to create symbolic link '/usr/src//host/usr/src/linux-headers-4.15.0-88': No such file or directory
ln: failed to create symbolic link '/usr/src//host/usr/src/linux-headers-4.15.0-88-generic': No such file or directory
* Unloading falco-probe, if present
* Running dkms install for falco
Error! echo
Your kernel headers for kernel 4.15.0-88-generic cannot be found at
/lib/modules/4.15.0-88-generic/build or /lib/modules/4.15.0-88-generic/source.
* Running dkms build failed, couldn't find /var/lib/dkms/falco/0.20.0+d77080a/build/make.log
```

Even though `/usr/src/linux-headers-4.15.0-88` and `/lib/modules/4.15.0-88-generic/build` both exist on host.

Reached out to Spencer Krum via slack for help.

## 7/3/2020
Reponse from Spencer to try version downgrade. Both v0.18.0 and v0.19.0 worked with the community helm chart.

```
helm install falco --namespace <namespace eg ibm-observe> --values falco-values.yaml stable/falco
```

Installed successfully and tested via the little test scenario from [Spencer's article](https://gitlab.com/nibalizer/falco-iks).

