SCC Multi Node Tools script

Tested on Ubuntu Linux 18.04 thru 22.04 LTS server versions

Options labeled Contabo ONLY will not work with standard Ubuntu installs

Auto assigning IPV6 should function with standard Ubuntu Server installs without modification

It is NOT designed for Desktop GUI Ubuntu installs (Will most likely not work correctly or at all)

-----------------------------------------------------------------------------------------------

SCC MN install guide

Quick guide
https://stakecube.info/stakecubecoin-dip3-masternode-setup-quick-guide/

Full guide
https://stakecube.info/stakecubecoin-dip3-masternode-setup-full-guide/


-----------------------------------------------------------------------------------------------

Commands to install sccmultitool.sh

```
curl -s https://raw.githubusercontent.com/stakecube/SCC-multitool/master/sccmultitool.sh | bash -
```

To execute type:

```
./sccmultitool.sh
```

-----------------------------------------------------------------------------------------------


New server note:

New server and IPv6 setup only needs to be set up once per server.

-----------------------------------------------------------------------------------------------


MultiNode note:

To run multiple MN's on one server you will need to use the IPv6 option when prompted in the install masternode option

Enter a unique Alias, BLS secret key, and rpc port each time you run the masternode install tool.

-----------------------------------------------------------------------------------------------


Masternode install notes:

Alias = Name of your MN, Must all be in lower case with no spaces or special characters and also include "scc" in the name for the multi tools to function
BLS secret key - get this from your control wallets console using the command `bls generate`

`Please note this info and enter carefully also make sure to keep a copy of this information as you will need it later for maintenance`

RPCport = Default RPCport is 39999, please make sure to use a unique number for each node instance otherwise nodes will not start
