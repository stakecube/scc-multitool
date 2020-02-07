#!/bin/bash
#Coin info #update here#
version='1.0.4.0'
coinname=stakecube
coinnamed=stakecubed
coinnamecli=stakecube-cli
ticker=SCC
coindir=StakeCubeCore
binaries='https://github.com/stakecube/SCC-multitool/releases/download/1.0.0/stakecube-daemon-U16-U18.zip'
snapshot='https://github.com/stakecube/SCC-multitool/releases/download/1.0.0/bootstrap.zip'
port=40000
rpcport=39999
currentVersion=1000002
currentProto=70812
discord='https://discord.gg/xxjZzJE'

apt-get install pwgen -y &>/dev/null
pass=`pwgen 14 1 b`
rpcuser=`pwgen 14 1 b`
rpcpass=`pwgen 36 1 b`

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

clear
cat << "EOF" 
   _____ _        _         _____      _          
  / ____| |      | |       / ____|    | |         
 | (___ | |_ __ _| | _____| |    _   _| |__   ___ 
  \___ \| __/ _` | |/ / _ \ |   | | | | '_ \ / _ \
  ____) | || (_| |   <  __/ |___| |_| | |_) |  __/
 |_____/ \__\__,_|_|\_\___|\_____\__,_|_.__/ \___|


EOF

#Tool menu
echo -e '\e[4mWelcome to the StakeCube Multitools\e[24m'
echo "Please enter a number from the list and press [ENTER] to start tool"
echo "1  - Newserver 2GB swap. REQUIRES RESTART"
echo "2  - Newserver 8GB swap with Contabo support. REQUIRES RESTART"
echo "3  - Wallet update (single ${ticker} node / installed with multitool)"
echo "31 - Wallet update (all ${ticker} nodes / universal)"
echo "4  - Chain repair"
echo "41 - Chain repair (all ${ticker} nodes)"
echo "5  - Remove MasterNode"
echo "6  - Masternode install"
echo "7  - Masternode restart (restarts all ${ticker} nodes)"
echo "8  - Check health (all ${ticker} nodes)"
echo "9  - Add seed-nodes (to alias)"
echo "99 - Show multitool version"
echo "0  - Exit"
echo ""
read -p "> " start
case $start in
#Tools
    0) echo "Stopping script..."
    exit
    ;;
    1) echo "Starting 2GB swap space setup"
    cd /root
    #Create swap file
    dd if=/dev/zero of=/var/swapfile bs=2048 count=1048576
    mkswap /var/swapfile
    swapon /var/swapfile
    chmod 0600 /var/swapfile
    chown root:root /var/swapfile
    echo "/var/swapfile none swap sw 0 0" >> /etc/fstab
    #Update linux
    apt-get update && apt-get -y upgrade
    apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt -y install
    #Allow SSH and enable firewall
    ufw allow 22/tcp comment "SSH"
    echo "y" | ufw enable
    #Install zip and unzip tools
    apt install zip unzip
    #Get check.sh
    wget https://github.com/stakecube/SCC-multitool/blob/master/check.sh -O check.sh
    chmod +x check.sh
    #Finish
    echo "New server setup complete"
    echo "Please reboot before installing any nodes!"
    exit
    ;;
    2) echo "Starting 8GB swap space setup with added Contabo dependancies"
    cd /root
    #Install Contabo dependancies
    apt -y install ufw
    apt -y install software-properties-common
    apt -y install nano
    #Create swap file
    dd if=/dev/zero of=/var/swapfile bs=2048 count=4194304
    mkswap /var/swapfile
    swapon /var/swapfile
    chmod 0600 /var/swapfile
    chown root:root /var/swapfile
    echo "/var/swapfile none swap sw 0 0" >> /etc/fstab
    #Update linux
    apt-get update && apt-get -y upgrade
    apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt -y install
    #Allow SSH and enable firewall
    ufw allow 22/tcp comment "SSH"
    echo "y" | ufw enable
    #Install zip and unzip tools
    apt install zip unzip
    #Get check.sh
    wget https://github.com/stakecube/SCC-multitool/blob/master/check.sh -O check.sh
    chmod +x check.sh
    #Finish
    echo "New server setup complete"
    echo "Please reboot before installing any nodes!"
    exit
    ;;
    3) echo "Starting single node update tool..."
    echo "Checking home directory (~/home) for MN alias's..."        
    echo "Following installed MN's found:"
    echo -e ${GREEN}
    ls /home
    echo -e ${NC}
    echo "Please enter masternode alias name you want to update and press [ENTER]:"
    read -p "> " alias
    echo "Checking if wallet is already updated..."
    i="$($alias getinfo | sed -n 2p)"
    v="${i:16:7}"
    echo "Latest version: ${currentVersion}"
    echo "Wallet version: ${v}"
    if [ "$currentVersion" -eq "$v" ];then
        echo "MN is up to date, no update needed";
        echo "Stopping script...";
        exit
    fi
    echo "Checking for zip tool..."
    apt install zip unzip -y
    echo "Stopping $alias..."
    systemctl stop $alias
    echo "Pausing script to ensure $alias has stopped..."
    sleep 15
    cd /usr/local/bin
    wget $binaries -O ${coinname}.zip
    unzip -o ${coinname}.zip
    rm ${coinname}.zip
    chmod +x ${coinnamecli} ${coinnamed}
    systemctl start $alias
    echo "============================================"
    echo -e "${GREEN}Wallet updated for: $alias${NC}"
    echo "============================================"
    echo ""
    echo "1. Please wait a moment and then check version number and block height with:"
    echo -e "${GREEN}$alias getinfo"
    echo -e "${NC}"
    echo -e "${RED}2. Please restart now your MN from your controller wallet!!!"
    echo -e "${NC}"
    echo "3. When done and protocol ${currentProto} is displayed, restart the masternode here with:"
    echo -e "${GREEN}systemctl restart $alias"
    echo -e "${NC}"
    echo "4. Wait for 5 minutes and check the status of your masternode with:"
    echo -e "${GREEN}$alias masternode status"
    echo -e "${NC}"
    echo "----------------"
    echo "If you are running multiple $ticker MNs you will need to update the other nodes too!"    
    echo "----------------"
    exit
    ;;
    31) echo "Starting multi node update tool..."
    apt-get install locate -y &>/dev/null
    #replace with new version
    echo "Starting to search for ${coinname} deamon (${coinnamed})..."
    updatedb
    n=$(locate -c -r /${coinnamed}$)
    if [ $n -eq 0 ];then
        echo -e "${RED}No ${coinname} deamon found...${NC}";
        echo "Stopping script...";
        exit
    fi
    if [ $n -gt 1 ];then
        echo -e "${RED}More then one ${ticker} deamon found... please delete duplicates before we can continue${NC}";
        echo "Deamon locations:"
        echo "$(dirname $(locate -e -r /${coinnamed}$))"
        echo "Stopping script...";
        exit
    fi
    daemonDir=$(dirname $(locate -e -r /${coinnamed}$))
    daemonDir+="/"
    echo -e "Found ${GREEN}$(locate -c -r /${coinnamed}$)${NC} ${coinnamed} in the following directory: $daemonDir"
    echo "Checking for zip tool..."
    apt install zip unzip -y &>/dev/null
    echo "Ok..."
    echo "Start downloading latest deamon..."
    cd $daemonDir
    wget $binaries -O ${coinname}.zip &>/dev/null
    unzip -o ${coinname}.zip &>/dev/null
    rm ${coinname}.zip &>/dev/null    
    echo -e "${GREEN}Deamon replaced...${NC}"
    echo "Starting to search for ${coinname} cli (${coinnamecli})..."  
    n=$(locate -c -r /${coinnamecli}$)
    if [ $n -eq 0 ];then
        echo -e "${RED}No ${coinname} cli found...${NC}";
        echo "Stopping script...";
        exit
    fi
    if [ $n -gt 1 ];then
        echo -e "${RED}More then one ${ticker} cli found... please delete duplicates before we can continue${NC}";
        echo "CLI locations:"
        echo "$(dirname $(locate -e -r /${coinnamecli}$))"
        echo "Stopping script...";
        exit
    fi
    cliDir=$(dirname $(locate -e -r /${coinnamecli}$))
    cliDir+="/"
    echo -e "Found ${GREEN}$(locate -c -r /${coinnamecli}$)${NC} ${coinnamecli} in the following directory: $cliDir"    
    echo "Start downloading latest cli..."
    cd $cliDir   
    wget $binaries -O ${coinname}.zip &>/dev/null
    unzip -o ${coinname}.zip &>/dev/null
    rm ${coinname}.zip &>/dev/null    
    echo -e "${GREEN}CLI replaced...${NC}"
    chmod +x $daemonDir${coinnamed} $cliDir${coinnamecli} &>/dev/null
    echo "Start to search for all instances and restarting deamons..."
    for i in $(find / -xdev 2>/dev/null -name ".${coindir}"); do
        echo -e "${GREEN}- Found $i${NC}"
        echo "Stopping node..."
        cd $cliDir && ./${coinnamecli} -datadir=$i stop &>/dev/null
        sleep 1m
        echo "Ok..."           
        echo "Starting node again..."
        cd $daemonDir && ./${coinnamed} -datadir=$i &
        sleep 1m
        echo "Ok..."
    done
    echo "============================================"
    echo -e "${GREEN}DONE${NC}"
    echo "============================================"
    echo ""
    echo -e "${RED}Please restart now your MN(s) from your controller wallet!!!${NC}"
    echo -e "When done and protocol ${currentProto} is displayed, restart the masternode with tool ${GREEN}7 - Masternode restart${NC}"
    exit
    ;;
    4) echo "Starting chain repair tool"
    echo "Checking home directory (~/home) for MN alias's..."        
    echo "Following installed MN's found:"
    echo -e ${GREEN}
    ls /home
    echo -e ${NC}
    echo "Please enter MN alias name and press [ENTER]:"
    read -p "> " alias
    echo "Start repair process..."
    echo "Using: ${snapshot}"
    echo "Checking for zip tool"
    apt install zip unzip -y -y
    echo "Stopping $alias"
    systemctl stop $alias
    echo "Pausing script to ensure $alias has stopped"
    sleep 15
    cd /home/$alias
    wget $snapshot -O ${coindir}.zip
    find /home/$alias/.${coindir}/* ! -name "wallet.dat" ! -name "*.conf" -delete
    unzip ${coindir}.zip
    rm ${coindir}.zip
    cd /home
    chown -R $alias $alias
    systemctl start $alias
    echo "Snapshot updated for $alias"
    echo "Please wait for a while.. and then use $alias getinfo to check block height against explorer"
    exit
    ;;
    41) echo "Starting chain repair all tool"
    echo "Checking home directory (~/home) for MN alias's..."
    n=$(ls /home -lR | grep ^d | wc -l)
    if [ $n -eq 0 ];then
        echo -e "${RED}No MNs found in home directory...${NC}";
        echo "Stopping script...";
        exit
    fi 
    echo "Following installed MN's found:"
    echo -e ${GREEN}
    ls /home
    echo -e ${NC}    
    echo "Start repair process for all MNs..."
    echo "Using: ${snapshot}"
    echo "Checking for zip tool"
    apt install zip unzip -y &>/dev/null
    for i in $(ls /home/); do
        echo "Stopping $i..."
        systemctl stop $i
        echo "Pausing script to ensure $i has stopped..."
        sleep 15
        cd /home/$i
        echo "Start repair for $i..."
        wget $snapshot -O ${coindir}.zip &>/dev/null
        find /home/$i/.${coindir}/* ! -name "wallet.dat" ! -name "*.conf" -delete
        unzip ${coindir}.zip &>/dev/null
        rm ${coindir}.zip
        cd /home
        chown -R $i $i
        echo "Chain repaired for $i..."
        echo "Starting node again..."
        systemctl start $i
    done
    echo "============================================"
    echo -e "${GREEN}DONE${NC}"
    echo "============================================"    
    exit
    ;;
    5) echo "Starting Removal tool"
    echo "Checking home directory for MN alias's"
    ls /home
    echo "Above are the alias names for installed MN's"
    echo "please enter MN alias name"
    read alias
    echo "Stopping $alias"
    systemctl stop $alias
    echo "Pausing script to ensure $alias has stopped"
    sleep 15
    systemctl disable $alias
    rm /usr/local/bin/$alias
    rm /etc/systemd/system/$alias.service
    deluser $alias
    rm -r /home/$alias
    echo "$alias removed"
    exit
    ;;
    6) echo "Starting $ticker MasterNode install"
    ;;
    7) echo "Starting restart tool..."
    apt-get install locate -y &>/dev/null
    daemonDir=$(dirname $(locate -e -r /${coinnamed}$))
    daemonDir+="/"
    cliDir=$(dirname $(locate -e -r /${coinnamecli}$))
    cliDir+="/"
    echo "Start to search for all instances and restarting deamons..."
    for i in $(find / -xdev 2>/dev/null -name ".${coindir}"); do
        echo -e "${GREEN}- Found $i${NC}"
        echo "Stopping node..."
        cd $cliDir && ./${coinnamecli} -datadir=$i stop &>/dev/null
        sleep 1m
        echo "Ok..."           
        echo "Starting node again..."
        cd $daemonDir && ./${coinnamed} -datadir=$i &
        sleep 1m
        echo "Ok..."
    done
    echo "============================================"
    echo -e "${GREEN}DONE${NC}"
    echo "============================================"
    exit
    ;;
    8) echo "Starting health check tool"
    echo "Enter current block from explorer and press [ENTER]:"
    read -p "> " b
    echo "Checking home directory (~/home) for MN alias's..."
    n=$(ls /home -lR | grep ^d | wc -l)
    if [ $n -eq 0 ];then
        echo -e "${RED}No MNs found in home directory...${NC}";
        echo "Stopping script...";
        exit
    fi 
    echo "Following installed MN's found:"
    echo -e ${GREEN}
    ls /home
    echo -e ${NC}    
    echo "Start check for all MNs..."
    for i in $(ls /home/); do
        echo -e "${GREEN}$i${NC}"
        echo "MN status: $($i getmasternodestatus)"
        bc=$($i getblockcount)
        if [ $b -eq $bc ];then
            echo -e "Blocks: ${GREEN}$bc${NC}"
        else 
            echo -e "Blocks: ${RED}$bc${NC}"
        fi
        cc=$($i getconnectioncount)
        if [ $cc -eq 0 ];then
            echo -e "Connections: ${RED}$cc${NC}"
        else 
            echo -e "Connections: ${GREEN}$cc${NC}"
        fi
    done
    echo "============================================"
    echo -e "${GREEN}DONE${NC}"
    echo "============================================"    
    exit
    ;;
    9) echo "Starting add seednodes tool"
    echo "Checking home directory (~/home) for MN alias's..."        
    echo "Following installed MN's found:"
    echo -e ${GREEN}
    ls /home
    echo -e ${NC}
    echo "Please enter MN alias name and press [ENTER]:"
    read -p "> " alias
    echo "Start add nodes..."
    $alias addnode 95.179.165.19 add
    $alias addnode 209.250.224.166 add
    $alias addnode 108.61.212.198 add
    $alias addnode 78.141.211.79 add
    $alias addnode 95.179.209.111 add
    exit
    ;;
    99) echo ${version}
    exit
    ;;
    esac
#get user input alias and bind set varible#
echo "Checking home directory for MN alias's"
ls /home
echo "Above are the alias names for installed MN's"
echo -e '\e[4mPlease enter MN alias. Example mn3\e[24m'
read alias
echo -e '\e[4mEnter masternode key\e[24m'
read key
echo -e '\e[4mPlease enter a port number. Default is '$port' for MultiNode use unique\e[24m'
read port
echo -e '\e[4mPlease enter a RPC port number. Default is '$rpcport' for MultiNode use unique\e[24m'
read rpcport
#script dependency's #do not remove#
echo "Installing install script dependency's"
apt install zip unzip -y -y
apt install nano
apt install curl
apt -y install ufw
ufw allow ssh
echo "Making sure your VPS is up to date"
apt update -y
echo "Installed script dependency's"
echo "Setting needed variables for script"
#checks IP against site and set IP/bind variable#
echo "Finding IP address"
ipadd=$(curl http://ifconfig.me/ip)
echo "your ip is $ipadd"
echo "Auto variables set"
#setup user#
echo "Setting up user $alias"
adduser "$alias" <<EOF
echo ${pass}
echo ${pass}
/
/
/
/
/
/
/
EOF
echo "User $alias setup"
#Install node binaries#
echo "Installing node binaries for $alias"
cd /usr/local/bin
wget ${binaries} -O ${coinname}.zip
echo -e '\e[4mFor MultiNodes use option N below\e[24m'
unzip ${coinname}.zip
chmod +x ${coinnamecli} ${coinnamed}
rm ${coinanme}.zip
echo "$alias node binaries installed"
#Node intergration#
echo "Node Intergration"
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir \$@" >> $alias
chmod +x $alias
cd /etc/systemd/system
echo "Node Intergration done"
#Setup service#
echo "Setting up service"
echo "[Unit]" >> $alias.service
echo "Description=$ticker service" >> $alias.service
echo "After=network.target" >> $alias.service
echo "" >> $alias.service
echo "[Service]" >> $alias.service
echo "User=$alias" >> $alias.service
echo "Group=root" >> $alias.service
echo "" >> $alias.service
echo "Type=forking" >> $alias.service
echo "#PIDFile=/home/$alias/.$coindir/.$coinname.pid" >> $alias.service
echo "ExecStart=/usr/local/bin/$coinnamed -daemon -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir">> $alias.service
echo "ExecStop=-/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir stop" >> $alias.service
echo "" >> $alias.service
echo "Restart=always" >> $alias.service
echo "PrivateTmp=true" >> $alias.service
echo "TimeoutStopSec=60s" >> $alias.service
echo "TimeoutStartSec=10s" >> $alias.service
echo "StartLimitInterval=120s" >> $alias.service
echo "StartLimitBurst=5" >> $alias.service
echo "" >> $alias.service
echo "[Install]" >> $alias.service
echo "WantedBy=multi-user.target" >> $alias.service
systemctl enable $alias
echo "Service setup and enabled"
#update chain files get snapshot#
echo "Downloading $coinname snapshot"
cd /home/$alias
wget ${snapshot} -O ${coindir}.zip
unzip ${coindir}.zip
rm ${coindir}.zip
echo "$coinname snapshot downloaded and unpacked"
#make conf file#
echo "Creating $coinname conf file"
cd .$coindir
echo "rpcuser="$rpcuser"" >> $coinname.conf
echo "rpcpassword="$rpcpass"" >> $coinname.conf
echo "rpcport=$rpcport" >> $coinname.conf
echo "rpcallowip=127.0.0.1" >> $coinname.conf
echo "port=$port" >> $coinname.conf
echo "listen=1" >> $coinname.conf
echo "server=1" >> $coinname.conf
echo "daemon=0" >> $coinname.conf
echo "txindex=1" >> $coinname.conf
echo "maxconnections=64" >> $coinname.conf
echo "bind=$ipadd" >> $coinname.conf
echo "masternode=1" >> $coinname.conf
echo "masternodeaddr=$ipadd:$port" >> $coinname.conf
echo "masternodeprivkey=$key" >> $coinname.conf
echo "$coinname conf file created"
#Set permisions and firewall rules#
echo "Setting permissions and firewall rules"
cd /home
chown -R $alias $alias
ufw allow $port/tcp comment "$alias port"
ufw allow $rpcport/tcp comment "$alias RPC port"
systemctl start $alias
echo "Permissions and firewall rules set"
echo "Please wait a moment and then read the following information"
sleep 15
echo "$ticker MN setup completed"
#Closeing/finish text#
echo -e '\e[4mMasternode setup complete for '$alias'\e[24m'
echo ""
echo "Alias name = $alias"
echo "IP/Bind = $ipadd"
echo "Port = $port"
echo "rpcport = $rpcport"
echo "MN key = $key"
echo "alias password = $pass"
echo ""
echo -e '\e[4mPlease note that if you are installing multiple MNs you will need to setup swap space\e[24m'
echo "Wait for sync and then use $alias getinfo or $alias getmasternodestatus to check node"
echo -e '\e[4mEnter the information below into your masternode.conf file in control wallet with the addition of the collateral_output_txid and TX index\e[24m'
echo "$alias $ipadd:40000 $key"
echo -e '\e[4mYou must use the default port with your control/desktop wallets masternode.conf file'
echo -e '\e[4mThen save masternode.conf, restart your control wallet and start your new '$ticker' MasterNode\e[24m'
echo ""
echo "For more information or support please visit the $ticker masternode-support channel on Discord"
echo "$discord"
exit
