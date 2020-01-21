SCC Multi Tool script tested on Linux 16.04

SCC MN install guide

https://stakecube.net/app/download/guides/SCC_node_setup_guide_v2.pdf

Commands to install sccmultitool.sh

wget https://github.com/stakecube/SCC-multitool/raw/master/sccmultitool.sh

chmod +x sccmultitool.sh

./sccmultitool.sh

Alias = Name of your MN, Must all be in lower case with no spaces or special characters

MN key = get this from your control wallets console using the command 
createmasternodekey
note this and enter carefully

Port = Default port is 40000 and must always be set to 40000 in masternode.conf on control side even if different on VPS!

RPCport = Default RPCport is 39999

MultiNode note

Swap space only needs to be set up once per server.
To run multiple MN's on one server sharing the same IP on the VPS side you will need to enter a unique Alias, MN key, port and rpc port each time you run sccmultitool.sh.
When setting up your masternode.conf file in your control wallet you will always need to set the port number to 40000.

Check.sh instructions 

Updated check.sh file for new commands if you are using an older version of this script
wget https://github.com/stakecube/SCC-multitool/raw/master/check.sh

chmod +x check.sh

The new server option will also add a file in root named check.sh
edit this file using 
nano check.sh
add node alias to "node="
example "node1=alias"
