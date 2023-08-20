SCC Multi Tool script tested on Linux 18.04 - 22.04
(Automatic IPv6 configuration is valid only for Contabo servers)



SCC MN install guide

Quick guide
https://stakecube.info/stakecubecoin-dip3-masternode-setup-quick-guide/

Full guide
https://stakecube.info/stakecubecoin-dip3-masternode-setup-full-guide/





Commands to install sccmultitool.sh

wget https://raw.githubusercontent.com/grigzy28/SCC-multitool/master/new-sccmultitool.sh

chmod +x new-sccmultitool.sh

./new-sccmultitool.sh




New server note
New server and IPv6 setup only needs to be set up once per server.




MultiNode note
To run multiple MN's on one server you will need to use the IPv6 option when promted in option 6 enter a unique Alias, BLS secret key, and rpc port each time you run masternode install tool.





Masternode install note

Alias = Name of your MN, Must all be in lower case with no spaces or special characters and also include "scc" in the name for multi tools

secret key= get this from your control wallets console using the command

bls generate

note this info and enter carefully

Port = Default port is 40000 and is set for you

RPCport = Default RPCport is 39999 use unique for multinode
