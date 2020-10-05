#!/bin/bash
#Coin info
version="3.0"
coinname=stakecubecoin
coinnamed=sccd
coinnamecli=scc-cli
ticker=SCC
coindir=scc
binaries='https://github.com/stakecube/StakeCubeCoin/releases/tag/v3.0.0/scc-3.0.0-linux-daemon.zip'
snapshot='https://github.com/stakecube/StakeCubeCoin/releases/tag/v3.0.0/bootstrap.zip'
port=40000
rpcport=39999
discord='https://discord.gg/xxjZzJE'
apt-get install pwgen -y &>/dev/null
pass=`pwgen 14 1 b`
rpcuser=`pwgen 14 1 b`
rpcpass=`pwgen 36 1 b`

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
echo -e '\e[4mWelcome to the StakeCube Multitools '${version}' \e[24m'
echo "Please enter a number from the list and press [ENTER] to start tool"
echo "1  - Newserver 2GB swap + IPv6 setup. REQUIRES RESTART"
echo "2  - Newserver 8GB swap + IPv6 setup. REQUIRES RESTART"
echo "3  - Enable IPv6"
echo "4  - Wallet update (all ${ticker} nodes)"
echo "5  - Remove MasterNode"
echo "6  - Masternode install"
echo "7  - Masternode stop/start/restart (stop/start/restart all ${ticker} nodes)"
echo "8  - Check health and repair (all ${ticker} nodes)- COMING SOON!"
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
	#Enable IPv6
	sleep 2
	sed -i "/net.ipv6.conf.all.disable_ipv6.*/d" /etc/sysctl.conf
	sysctl -q -p
	echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6
	sed -i "s/#//" /etc/netplan/01-netcfg.yaml
	netplan generate
	netplan apply
	sleep 5
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
	#Enable IPv6
	sleep 2
	sed -i "/net.ipv6.conf.all.disable_ipv6.*/d" /etc/sysctl.conf
	sysctl -q -p
	echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6
	sed -i "s/#//" /etc/netplan/01-netcfg.yaml
	netplan generate
	netplan apply
	sleep 5
    #Finish
    echo "New server setup complete"
    echo "Please reboot before installing any nodes!"
    exit
    ;;
	3) echo "Starting IPv6 setup tool..."
	#Enable IPv6
	sleep 2
	sed -i "/net.ipv6.conf.all.disable_ipv6.*/d" /etc/sysctl.conf
	sysctl -q -p
	echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6
	sed -i "s/#//" /etc/netplan/01-netcfg.yaml
	netplan generate
	netplan apply
	sleep 5
    #Finish
    echo "IPv6 setup complete"
	exit
	;;
    4) echo "Starting Wallet update tool (All ${ticker} node"
	cd /usr/local/bin
	rm $coinnamecli $coinnamed
	wget ${binaries} -O ${coinname}.zip
	unzip -o ${coinname}.zip
	chmod +x ${coinnamecli} ${coinnamed}
	rm ${coinname}.zip
	cd /root
	sleep 15
	for i in $(ls /home/); do
	echo "Checking for $ticker MN's"
	echo "found $i..."
	if [[ $i == *scc* ]]
	then
	echo "Restarting $i.."
	systemctl restart $i
	echo "$i updated and restarted"
	echo "Pausing to let $i settle"
	sleep 120
	else
	echo "No $ticker MN's found to update"
	fi
	done
	echo "Wallet update tool finished"
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
	#ipv6check and remove
	confip=$(sed -n '11p' /home/${alias}/.${coindir}/${coinname}.conf)
	if [[ ${confip} = bind=[*** ]]
	then
		confip=$(echo $confip | sed "s/bind=//g")
		confip=$(echo $confip | sed 's/\[//')
		confip=$(echo $confip | sed 's/\]//')
		echo "confip is $confip"
		echo "removing $confip from 01-netcfg.yaml"
		sed -i "/${confip}/d" /etc/netplan/01-netcfg.yaml
		netplan apply
	else
		echo "$alias.conf file showing $confip"
		echo "IPv6 not found skipping removal of IP from netplan"
	fi
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
    7) echo "Starting stop/start tool..."
	echo "Please enter <stop> to stop all ${ticker} nodes"
	echo "Please enter <start> to start all ${ticker} nodes"
	echo "Please enter <restart> to restart all ${ticker} nodes"
	read stopstart
	if [[ $stopstart == stop ]] || [[ $stopstart == start ]] || [[ $stopstart == restart ]]
	then
		echo "Starting $stopstart tool"
		for i in $(ls /home/)
			do
			echo "Checking for $ticker MN's"
			echo "found $i..."
			if [[ $i == *scc* ]]
			then
				echo "${stopstart}ing $i.."
				systemctl $stopstart $i
				echo "Pausing to let $i settle"
				sleep 120
			else
				echo "${ticker} node not found"
			fi
		done
	fi
	echo "Wallet update tool finished"
	exit
    ;;
	8) echo "Starting health check and repair tool"
	echo "Tool coming soon! Now closing.."
	exit
    ;;
    esac
#get user input alias and bind set varible#
echo "Checking home directory for MN alias's"
ls /home
echo "Above are the alias names for installed MN's"
echo -e '\e[4mPlease enter MN alias. Example sccmn3\e[24m'
echo "To use other tools you must include $ticker in alias"
read alias
echo -e '\e[4mEnter BLS secret key\e[24m'
read key
echo -e '\e[4mPlease enter a unique RPC port number. Default is '$rpcport'\e[24m'
read rpcport
#IPv4/v6 choice and setup
echo "Would you like to setup with an IPv6 address?"
echo "Please enter yes or no"
read ipchoice
#script dependency
echo "Checking/installing dependency for auto IP setup"
apt install curl
if [[ $ipchoice == yes ]]
then
	#set default IPv6
	dipv6=$(sed -n '10p' /etc/netplan/01-netcfg.yaml)
	echo " 2 $dipv6"
	netconfcount=$(grep -c :0000:0000:0000: /etc/netplan/01-netcfg.yaml)
	echo "$netconfcount"
	cipv6=$(( $netconfcount+1 ))
	ipv6="$(echo $dipv6 | sed "s/:0001/:$cipv6/g")"
	echo "New IPv6 is $ipv6"
	#Add IPv6 address to /etc/netplan/01-netcfg.yaml
	sed -i "/gateway6/i \ \ \ \ \ \ \ \ ${ipv6}" /etc/netplan/01-netcfg.yaml
	netplan apply
	#tidy IP input for conf
	ipv6conf="$(echo $ipv6 | sed 's/.\{3\}$//')"
	ipv6conf="$(echo $ipv6conf | sed "s/- //g")"
else
#check ip set IP/bind variable
	echo "Finding IPv4 address"
	ipadd=$(curl http://ifconfig.me/ip)
	echo "Your IPv4 is $ipadd"
	echo "Auto IPv4 set"
fi
echo "Checking/installing other script dependency's"
apt install zip unzip -y -y
apt install nano
apt -y install ufw
ufw allow ssh
echo "Making sure your VPS is up to date before continueing install"
apt update -y
#setup user
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
#Node binaries check
cd /usr/local/bin
binfile=/usr/local/bin/${coinnamecli}
if test -e "$binfile"
then
	echo "Node binaries already downloaded and setup"
else
#Install node binaries
echo "Installing node binaries for $alias"
cd /usr/local/bin
wget ${binaries} -O ${coinname}.zip
unzip ${coinname}.zip
chmod +x ${coinnamecli} ${coinnamed}
rm ${coinanme}.zip
echo "$alias node binaries installed"
fi
#Node intergration
echo "Node Intergration"
echo "#!/bin/bash" >> $alias
echo "/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir \$@" >> $alias
chmod +x $alias
cd /etc/systemd/system
echo "Node Intergration done"
#Setup service
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
#echo "Downloading $coinname snapshot"
cd /home/$alias
wget ${snapshot} -O ${coinname}.zip
unzip ${coinname}.zip
echo "$coinname dir setup"
#make conf file
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
echo "maxconnections=125" >> $coinname.conf
#IPv6 check and edit
if [[ $ipchoice == yes ]]
then
	ipadd=$ipv6conf
	echo "bind=[$ipadd]" >> $coinname.conf
	echo "externalip=[$ipadd]:$port" >> $coinname.conf
else
	echo "bind=$ipadd" >> $coinname.conf
	echo "externalip=$ipadd:$port" >> $coinname.conf
fi
echo "masternodeblsprivkey=$key" >> $coinname.conf
echo "addnode=173.249.9.78" >> $coinname.conf
echo "addnode=173.249.9.77" >> $coinname.conf
echo "$coinname conf file created"
#Set permisions and firewall rules
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
#Closeing/finish text
echo -e '\e[4mMasternode setup complete for '$alias'\e[24m'
echo ""
echo "Alias name = $alias"
echo "IP/Bind = $ipadd"
echo "Port = $port"
echo "rpcport = $rpcport"
echo "BLS secret key = $key"
echo "alias password = $pass"
echo ""
echo -e '\e[4mPlease note that if you are installing multiple MNs you will need to setup swap space\e[24m'
echo "Wait for sync and then use $alias -getinfo or $alias masternode status to check node"
echo ""
echo "For more information or support please visit the $ticker masternode-support channel on Discord"
echo "$discord"
exit
