# Notes and instructions to successfully set up IKS with workers on only private VLAN.

## set up IBM Virtual Router Appliance (Vyatta 5600)
To order VRA and associate and route VLANs, follow the (getting started guide)[https://console.bluemix.net/docs/infrastructure/virtual-router-appliance/getting-started.html#getting-started] and (Manage VLANs)[https://console.bluemix.net/docs/infrastructure/virtual-router-appliance/manage-vlans.html#manage-vlans] to associate and route the clluster private VLAN through the VRA.

At this point, the devices on the private VLAN will route through the VRA, but the VRA will not be configured to forward traffic beyond the VRA.

Need to:
1. configure VRA to route private VLAN outbound traffic.
  * Is this firewall configuration?
