New Revised SCC Multi Tool script

Tested on Ubuntu Linux 18.04 thru 22.04 LTS server versions

Options labeled Contabo ONLY will not work with standard Ubuntu installs

Auto IPV6 should function with standard Ubuntu Server installs without modification

Is NOT designed for Desktop GUI Ubuntu installs (Will not most likely work correctly or at all)

-----------------------------------------------------------------------------------------------

SCC MN install guide

Quick guide
https://stakecube.info/stakecubecoin-dip3-masternode-setup-quick-guide/

Full guide
https://stakecube.info/stakecubecoin-dip3-masternode-setup-full-guide/


-----------------------------------------------------------------------------------------------

Commands to install sccmultitool.sh

```
curl -s https://raw.githubusercontent.com/grigzy28/SCC-multitool/master/new-sccmultitool.sh | bash -
```

```
chmod +x new-sccmultitool.sh
```

To execute type:

```
./new-sccmultitool.sh
```

-----------------------------------------------------------------------------------------------


New server note:

New server and IPv6 setup only needs to be set up once per server.

-----------------------------------------------------------------------------------------------


MultiNode note:

To run multiple MN's on one server you will need to use the IPv6 option when promted in option 7 enter a unique Alias, BLS secret key, and rpc port each time you run the masternode install tool.

-----------------------------------------------------------------------------------------------


Masternode install notes:

Alias = Name of your MN, Must all be in lower case with no spaces or special characters and also include "scc" in the name for multi tools
secret key= get this from your control wallets console using the command `bls generate`

`Please note this info and enter carefully also make sure to keep a copy of this information`

RPCport = Default RPCport is 39999, please make sure to use a unique number for each node instance otherwise nodes will not start
