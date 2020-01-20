#!/bin/bash
node1=
node2=
node3=
node4=
node5=
 
echo "Starting node check"
echo
 
echo -e "1) $node1 \c"
$node1 getmasternodestatus
echo -e "Blocks: \c"
$node1 getblockcount
echo -e "Connections: \c"
$node1 getconnectioncount
echo
 
echo -e "2) $node2 \c"
$node2 getmasternodestatus
echo -e "Blocks: \c"
$node2 getblockcount
echo -e "Connections: \c"
$node2 getconnectioncount
echo
 
echo -e "3) $node3 \c"
$node3 getmasternodestatus
echo -e "Blocks: \c"
$node3 getblockcount
echo -e "Connections: \c"
$node3 getconnectioncount
echo
 
echo -e "4) $node4 \c"
$node4 getmasternodestatus
echo -e "Blocks: \c"
$node4 getblockcount
echo -e "Connections: \c"
$node4 getconnectioncount
echo
 
echo -e "5) $node5 \c"
$node5 getmasternodestatus
echo -e "Blocks: \c"
$node5 getblockcount
echo -e "Connections: \c"
$node5 getconnectioncount
echo
 
echo
echo "Node check completed"
