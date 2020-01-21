#!/bin/bash
#Coin info #update here#
coinname=stakecube
coinnamed=stakecubed
coinnamecli=stakecube-cli
ticker=SCC
coindir=StakeCubeCore
binaries='https://www.dropbox.com/s/nwz925s70uhuie8/stakecubebin.zip'
snapshot='https://www.dropbox.com/s/auuabbr1nuzhn3m/StakeCubeCore.zip'
port=40000
rpcport=39999
discord='https://discord.gg/xxjZzJE'
pass=`pwgen 14 1 b`
rpcuser=`pwgen 14 1 b`
rpcpass=`pwgen 36 1 b`
#Tool menu
echo -e '\e[4mWelcome to the '$coinname' Multitools\e[24m'
echo "Please pick a number from the list to start tool"
echo "1 - Newserver 2GB swap. REQUIRES RESTART"
echo "2 - Newserver 8GB swap with Contabo support. REQUIRES RESTART"
echo "3 - Wallet update"
echo "4 - Chain repair"
echo "5 - Remove MasterNode"
echo "6 - Masternode install"
read start
case $start in
#Tools
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
    dd if=/dev/zero of=/var/swapfile bs=8192 count=1048576
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
    3) echo "Starting MasterNode wallet update tool"
    echo "Checking home directory for MN alias's"
    ls /home
    echo "Above are the alias names for installed MN's"
    echo "please enter masternode alias name"
    read alias
    echo "Please enter updated wallet download zip link in full"
    echo "Here is the wallet link used in this script"
    echo "$binaries"
    read bin
    echo "Checking for zip tool"
    apt install zip unzip -y -y
    echo "Stopping $alias"
    systemctl stop $alias
    echo "Pausing script to ensure $alias has stopped"
    sleep 15
    cd /usr/local/bin
    wget $bin -O ${coinname}.zip
    unzip ${coinname}.zip
    rm ${coinname}.zip
    chmod +x ${coinnamecli} ${coinnamed}
    systemctl start $alias
    echo "Binaries updated for $alias"
    echo "Please wait a moment and then check version number with $alias getinfo"
    echo "If you are running multiple $ticker MNs you will need to restart the other nodes!"
    echo "Example restart command below"
    echo "systemctl restart $alias"
    exit
    ;;
    4) echo "Starting chain repair tool"
    echo "Checking home directory for MN alias's"
    ls /home
    echo "Above are the alias names for installed MN's"
    echo "Please enter MN alias name"
    read alias
    echo "Please enter bootstrap/snapshot zip link in full"
    echo "Here is the snapshot this script uses for MN install"
    echo "$snapshot"
    read snap
    echo "Checking for zip tool"
    apt install zip unzip -y -y
    echo "Stopping $alias"
    systemctl stop $alias
    echo "Pausing script to ensure $alias has stopped"
    sleep 15
    cd /home/$alias
    wget $snap -O ${coindir}.zip
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
    6)  echo "Starting $ticker MasterNode install"
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
apt-get install pwgen -y
apt install zip unzip -y -y
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
