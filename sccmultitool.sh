#!/bin/bash
#Coin info
version="3.2.0"
coinname=stakecubecoin
coinnamed=sccd
coinnamecli=scc-cli
ticker=SCC
coindir=scc
binaries='https://github.com/stakecube/StakeCubeCoin/releases/download/v3.2.0/scc-3.2.0-linux-daemon.zip'
snapshot='https://stakecubecoin.net/bootstrap.zip'
port=40000
rpcport=39999
discord='https://discord.gg/xxjZzJE'

#pre-setup checks and dependencies installs
echo -e "Checking/installing other script dependency's"
apt -y -qq install curl zip unzip nano ufw software-properties-common pwgen

#setup variables for passwords
pass=`pwgen 14 1 b`
rpcuser=`pwgen 14 1 b`
rpcpass=`pwgen 36 1 b`

#color variables
readonly GRAY='\e[1;30m'
readonly DARKRED='\e[0;31m'
readonly RED='\e[1;31m'
readonly DARKGREEN='\e[0;32m'
readonly GREEN='\e[1;32m'
readonly DARKYELLOW='\e[0;33m'
readonly YELLOW='\e[1;33m'
readonly DARKBLUE='\e[0;34m'
readonly BLUE='\e[1;34m'
readonly DARKMAGENTA='\e[0;35m'
readonly MAGENTA='\e[1;35m'
readonly DARKCYAN='\e[0;36m'
readonly CYAN='\e[1;36m'
readonly UNDERLINE='\e[1;4m'
readonly NC='\e[0m'


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
echo -e ""
echo -e "${UNDERLINE}${CYAN}Welcome to the StakeCube Multitools ${version}${NC}"

#echo -e '\e[4mWelcome to the StakeCube Multitools '${version}' \e[24m'

echo -e "${YELLOW}Please enter a number from the list and press [ENTER] to start tool"
echo -e "1  - Newserver 2GB swap + IPv6 setup. REQUIRES RESTART"
echo -e "2  - Newserver 8GB swap + IPv6 setup. REQUIRES RESTART"
echo -e "3  - Enable IPv6"
echo -e "4  - Wallet update (all ${ticker} nodes)"
echo -e "5  - Chain/PoSe maintenance tool (single ${ticker} node)"
echo -e "6  - Remove MasterNode"
echo -e "7  - Masternode install"
echo -e "8  - Masternode stop/start/restart (stop/start/restart all ${ticker} nodes)"
echo -e "9  - Check health and repair (all ${ticker} nodes)- COMING SOON!"
echo -e "10 - Download/Update StakeCubeCoin local bootstrap file"
echo -e "11 - Setup 2GB swap space, if newserver setup was not previously run"
echo -e "12 - Setup 8GB swap space, if newserver setup was not previously run"
echo -e "13 - Check block count status against explorer"
echo -e "14 - Check MN health status and optional repair (all ${ticker} nodes)"
echo -e "15 - Check block count and optional chain repair (all ${ticker} nodes)"
echo -e ""
echo -e "0  - Exit"
echo -e "${NC}"
read -p "> " start
echo -e ""


function chain_repair() {

	bootstrapchoice=$2

	if [[ $1 == "" ]]
		then
			echo -e ""
			echo -e "Checking home directory for masternode alias's"
			echo -e ""
			ls /home
			echo -e ""
			echo -e "${YELLOW}Above are the alias names for the installed masternodes${NC}"
			echo -e "${CYAN}Please enter the masternode alias name to repair${NC}"
			echo -e ""
			read alias
		else
			alias=$1
	fi	

	echo -e ""
	echo -e "Stopping ${MAGENTA}$alias${NC}"
	systemctl stop $alias
	sleep 10


	if [[ $2 != "yes" ]]
		then
			echo -e ""
			echo -e "${YELLOW}Use offline bootstrap?${NC}"
			echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
			read bootstrapchoice
		else
			echo -e "${YELLOW}Using offline bootstrap file${NC}"
	fi

	echo -e ""
	cd /home/$alias
	find /home/$alias/.${coindir}/ -name ".lock" -delete
	find /home/$alias/.${coindir}/ -name ".walletlock" -delete
	find /home/$alias/.${coindir}/* ! -name "wallet.dat" ! -name "*.conf" -delete
	echo -e "${YELLOW}Downloading/Copying and replacing chain files for ${MAGENTA}$alias${NC}"

	if [[ $bootstrapchoice == yes ]]
		then
			sccfile=~/${coinname}.zip
			if test -e "$sccfile"
				then 
					#rsync -adm --info=progress2 /root/${coinname}.zip /home/$alias
					unzip ~/${coinname}.zip
					echo -e "${YELLOW}$coinname local bootstrap directory updated${NC}"
					#echo -e "${YELLOW}Removing copied temp file${NC}"
					#rm /home/${alias}/${coinname}.zip
				else
					echo -e "${RED}File doesn't exist${NC}, ${YELLOW}downloading chain${NC}"
					wget -nv --show-progress ${snapshot} -O ${coinname}.zip
					unzip ${coinname}.zip
					echo -e "${YELLOW}$coinname chain directory updated${NC}"
					echo -e "${YELLOW}Removing downloaded temp file${NC}"
					rm /home/${alias}/${coinname}.zip
			fi	
		else
			wget -nv --show-progress ${snapshot} -O ${coinname}.zip
			unzip ${coinname}.zip
			echo -e ""
			echo -e "${YELLOW}$coinname chain directory setup${NC}"
			echo -e "${YELLOW}Removing downloaded temp file${NC}"
			rm /home/${alias}/${coinname}.zip
	fi

	chown -R $alias /home/${alias}
	echo -e "${CYAN}Starting $alias after repair${NC}"
	systemctl start ${alias}.service
	sleep 10
	echo -e ""
	echo -e "${YELLOW}Please wait for a moment.. and use ${CYAN}$alias masternode status${YELLOW} to check if $alais is ready for POSE unban or still showing READY${NC}"
	echo -e "${YELLOW}If $alias showing POSE banned you will need to run the protx update command to unban${NC}"
	echo -e "${YELLOW}Below is an example of the protx update command to use in your main wallets debug console${NC}"
	echo -e "${YELLOW}protx update_service proTxHash ipAndPort operatorKey (operatorPayoutAddress feeSourceAddress)${NC}"
	echo -e "${CYAN}Chain repair tool finished${NC}"

}

function install_mn() {

	#get user input alias and bind set varible#
	echo -e ""
	echo -e "${YELLOW}Checking home directory for masternode alias's${NC}"
	echo -e ""
	ls /home
	echo -e ""
	echo -e "${YELLOW}Above are the alias names for the installed masternodes${NC}"
	echo -e "${YELLOW}Please enter MN alias. Example: ${CYAN}sccmn001${NC}"
	echo -e "${YELLOW}To use other tools you must include ${CYAN}$ticker${YELLOW} in alias${NC}"
	read alias
	echo -e ""
	echo -e "${YELLOW}${UNDERLINE}Enter BLS secret key${NC}"
	read key
	echo -e ""
	echo -e "${YELLOW}${UNDERLINE}Please enter a unique RPC port number. Default is ${CYAN}$rpcport${NC}"
	read rpcport

	#IPv4/v6 choice and setup
	echo -e ""
	echo -e "${YELLOW}Would you like to setup with an IPv6 address?{$NC}"
	echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
	read ipchoice

	
	#script dependency
	echo -e "Checking/installing dependency for auto IP setup"

	if [[ $ipchoice == yes ]]
		then
			#set default IPv6
			sed -i '1{/^$/d}' /etc/netplan/01-netcfg.yaml
			dipv6=$(sed -n '10p' /etc/netplan/01-netcfg.yaml)
			echo -e " 2 $dipv6"
			netconfcount=$(grep -c :0000:0000:0000: /etc/netplan/01-netcfg.yaml)
			echo -e "$netconfcount"
			cipv6=$(( $netconfcount+51 ))
			ipv6="$(echo $dipv6 | sed "s/:0001/:$cipv6/g")"
			echo -e "New IPv6 is $ipv6"
			#Add IPv6 address to /etc/netplan/01-netcfg.yaml
			sed -i "/gateway6/i \ \ \ \ \ \ \ \ ${ipv6}" /etc/netplan/01-netcfg.yaml
			netplan apply
			#tidy IP input for conf
			ipv6conf="$(echo $ipv6 | sed 's/.\{3\}$//')"
			ipv6conf="$(echo $ipv6conf | sed "s/- //g")"
		else
			#check ip set IP/bind variable
			echo -e "Finding IPv4 address"
			ipadd=$(curl http://ifconfig.me/ip)
			echo -e "Your IPv4 is $ipadd"
			echo -e "Auto IPv4 set"
	fi

	echo -e ""
	echo -e "${YELLOW}Use offline bootstrap?${NC}"
	echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
	read bootstrapchoice
	
	echo -e ""
	ufw allow ssh
	
	echo -e "${CYAN}Making sure your VPS is up to date before continuing install${NC}"
	apt update -y

	#setup user
	echo -e ""
	echo -e "${YELLOW}Setting up user ${RED}$alias${NC}"

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

	echo -e ""
	echo -e "${CYAN}User ${RED}$alias${CYAN} setup${NC}"
	echo -e ""
	
	#Node binaries check and install if needed
	cd /usr/local/bin
	binfile=/usr/local/bin/${coinnamecli}
	if test -e "$binfile"
		then
			echo -e "${CYAN}Node binaries already downloaded and setup${NC}"
			echo -e ""
		else
			echo -e "${YELLOW}Installing node binaries for ${MAGENTA}$alias{$NC}"
			cd /usr/local/bin
			wget ${binaries} -O ${coinname}.zip
			unzip ${coinname}.zip
			chmod +x ${coinnamecli} ${coinnamed}
			rm ${coinname}.zip
			echo -e "${CYAN}$alias node binaries downloaded and installed${NC}"
			echo -e ""
	fi

	#Node intergration - creation of alias in /usr/local/bin for executing commands to users daemon
	echo -e "${YELLOW}Node Intergration${NC}"
	echo -e "#!/bin/bash" >> $alias
	echo -e "/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir \$@" >> $alias
	chmod +x $alias
	cd /etc/systemd/system
	echo -e "${CYAN}Node Intergration done${NC}"
	echo -e ""

	#Setup system service
	echo -e "${YELLOW}Setting up system service${NC}"
	echo -e "[Unit]" >> $alias.service
	echo -e "Description=$ticker service" >> $alias.service
	echo -e "After=network.target" >> $alias.service
	echo -e "" >> $alias.service
	echo -e "[Service]" >> $alias.service
	echo -e "User=$alias" >> $alias.service
	echo -e "Group=root" >> $alias.service
	echo -e "" >> $alias.service
	echo -e "Type=forking" >> $alias.service
	echo -e "ExecStart=/usr/local/bin/$coinnamed -daemon -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir">> $alias.service
	echo -e "ExecStop=-/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir stop" >> $alias.service
	echo -e "" >> $alias.service
	echo -e "Restart=always" >> $alias.service
	echo -e "PrivateTmp=true" >> $alias.service
	echo -e "TimeoutStopSec=60s" >> $alias.service
	echo -e "TimeoutStartSec=10s" >> $alias.service
	echo -e "StartLimitInterval=120s" >> $alias.service
	echo -e "StartLimitBurst=5" >> $alias.service
	echo -e "" >> $alias.service
	echo -e "[Install]" >> $alias.service
	echo -e "WantedBy=multi-user.target" >> $alias.service
	systemctl enable $alias
	echo -e "${CYAN}System service setup and enabled${NC}"


	#update/copy chain files or get snapshot# from web
	echo -e ""
	cd /home/$alias
	find /home/$alias/.${coindir}/* ! -name "wallet.dat" ! -name "*.conf" -delete
	echo -e "${YELLOW}Downloading/Copying and installing chain files for ${MAGENTA}$alias${NC}"

	if [[ $bootstrapchoice == yes ]]
		then
			sccfile=~/${coinname}.zip
			if test -e "$sccfile"
				then 
					#rsync -adm --info=progress2 /root/${coinname}.zip /home/$alias
					unzip ~/${coinname}.zip
					echo -e "${YELLOW}$coinname local bootstrap directory updated${NC}"
					echo -e "${YELLOW}Removing copied temp file${NC}"
					#rm /home/${alias}/${coinname}.zip
				else
					echo -e "${RED}File doesn't exist${NC}, ${YELLOW}downloading chain${NC}"
					wget -nv --show-progress ${snapshot} -O ${coinname}.zip
					unzip ${coinname}.zip
					echo -e "${YELLOW}$coinname chain directory updated${NC}"
					echo -e "${YELLOW}Removing downloaded temp file${NC}"
					rm /home/${alias}/${coinname}.zip
			fi	
		else
			wget -nv --show-progress ${snapshot} -O ${coinname}.zip
			unzip ${coinname}.zip
			echo -e "${YELLOW}$coinname chain directory setup${NC}"
			echo -e "${YELLOW}Removing downloaded temp file${NC}"
			rm /home/${alias}/${coinname}.zip
	fi
	
	#make conf file
	echo -e ""
	echo -e "${YELLOW}Creating $coinname conf file${NC}"
	cd .$coindir
	echo -e "rpcuser="$rpcuser"" >> $coinname.conf
	echo -e "rpcpassword="$rpcpass"" >> $coinname.conf
	echo -e "rpcport=$rpcport" >> $coinname.conf
	echo -e "rpcallowip=127.0.0.1" >> $coinname.conf
	echo -e "port=$port" >> $coinname.conf
	echo -e "listen=1" >> $coinname.conf
	echo -e "server=1" >> $coinname.conf
	echo -e "daemon=0" >> $coinname.conf
	echo -e "txindex=1" >> $coinname.conf
	echo -e "maxconnections=125" >> $coinname.conf

	#IPv6 check and edit
	if [[ $ipchoice == yes ]]
		then
			ipadd=$ipv6conf
			echo -e "bind=[$ipadd]" >> $coinname.conf
			echo -e "externalip=[$ipadd]:$port" >> $coinname.conf
		else
			echo -e "bind=$ipadd" >> $coinname.conf
			echo -e "externalip=$ipadd:$port" >> $coinname.conf
	fi

	echo -e "masternodeblsprivkey=$key" >> $coinname.conf
	echo -e "addnode=173.249.9.78" >> $coinname.conf
	echo -e "addnode=173.249.9.77" >> $coinname.conf

	echo -e "${CYAN}$coinname conf file created${NC}"
	echo -e ""

	#Set permisions and firewall rules
	echo -e "${YELLOW}Setting permissions and firewall rules${NC}"
	cd /home
	chown -R $alias $alias
	ufw allow $port/tcp comment "$alias port"
	ufw allow $rpcport/tcp comment "$alias RPC port"
	systemctl start $alias
	echo -e "${YELLOW}Permissions and firewall rules set${NC}"
	echo -e ""
	echo -e "${YELLOW}Please wait a moment and then read the following information${NC}"
	sleep 15
	echo -e "${CYAN}$ticker MN setup completed${NC}"
	echo -e ""

	#Closeing/finish text
	echo -e "${UNDERLINE}Masternode setup complete for ${CYAN}$alias${NC}"
	echo -e ""
	echo -e "Alias name = $alias"
	echo -e "IP/Bind = $ipadd"
	echo -e "Port = $port"
	echo -e "rpcport = $rpcport"
	echo -e "BLS secret key = $key"
	echo -e "alias password = $pass"
	echo -e ""
	echo -e "${YELLOW}Please note that if you are installing multiple MNs you will need to setup swap space${NC}"
	echo -e "${YELLOW}Wait for sync and then use $alias -getinfo or $alias masternode status to check node${NC}"
	echo -e ""
	echo -e "For more information or support please visit the ${CYAN}$ticker${NC} Discord server"
	echo -e "$discord"
	echo -e ""

}


function ipv6_setup() {

	#Enable IPv6
	sleep 2
	sed -i "/net.ipv6.conf.all.disable_ipv6.*/d" /etc/sysctl.conf
	sysctl -q -p
	echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6
	sed -i "s/#//" /etc/netplan/01-netcfg.yaml
	sed -i '1{/^$/d}' /etc/netplan/01-netcfg.yaml
	netplan generate
	netplan apply
	sleep 5

}


function setup_swap() {

    cd /root
    #Create swap file
    dd if=/dev/zero of=/var/swapfile bs=1024 bs=1M count=$1 status=progress
    mkswap /var/swapfile
    swapon /var/swapfile
    chmod 0600 /var/swapfile
    chown root:root /var/swapfile
    echo -e "/var/swapfile none swap sw 0 0" >> /etc/fstab

}


case $start in
#Tools
    
	0)	echo -e "Stopping and exiting script..."
		exit
    ;;

    1)	echo -e "${YELLOW}Starting 2GB swap space setup with added dependencies${NC}"

		setup_swap "2048"

		#Update linux
		apt-get update && apt-get -y upgrade
		apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt -y install

		#Allow SSH and enable firewall
		ufw allow 22/tcp comment "SSH"
		echo -e "y" | ufw enable

   		#Get check.sh
    	#wget https://raw.githubusercontent.com/stakecube/SCC-multitool/master/check.sh -O check.sh
    	#chmod +x check.sh

		ipv6_setup

		#Finish
		echo -e "${CYAN}New server setup complete${NC}"
		echo -e ""
		echo -e "${YELLOW}Please ${RED}reboot${YELLOW} before installing any nodes!${NC}"
		echo -e ""
		exit

    ;;

    2)	echo -e "${YELLOW}Starting 8GB swap space setup with added dependencies${NC}"

		setup_swap "8192"

		#Update linux
		apt-get update && apt-get -y upgrade
		apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt -y install

		#Allow SSH and enable firewall
		ufw allow 22/tcp comment "SSH"
		echo -e "y" | ufw enable

		#Get check.sh
    	#wget -q https://raw.githubusercontent.com/stakecube/SCC-multitool/master/check.sh -O check.sh
    	#chmod +x check.sh

		ipv6_setup

		#Finish
		echo -e "${CYAN}New server setup complete${NC}"
		echo -e ""
		echo -e "${YELLOW}Please ${RED}reboot${YELLOW} before installing any nodes!${NC}"
		echo -e ""
		exit

    ;;

	3)	echo -e "Starting IPv6 setup tool..."

		ipv6_setup

		#Finish
		echo -e "IPv6 setup complete"
		exit

	;;

    4)	echo -e "${YELLOW}Starting Wallet update tool ${CYAN}(All ${ticker}${YELLOW} node${NC}"
		echo -e ""
		cd /usr/local/bin
		rm $coinnamecli $coinnamed
		wget ${binaries} -O ${coinname}.zip
		unzip -o ${coinname}.zip
		chmod +x ${coinnamecli} ${coinnamed}
		rm ${coinname}.zip
		cd /root
		sleep 15

		for i in $(ls /home/); do
			echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN's${NC}"
			echo -e "${YELLOW}found ${CYAN}$i${NC}..."
			echo -e ""

			if [[ $i == *scc* ]]
				then
					echo -e "${YELLOW}Restarting ${CYAN}$i${YELLOW}..${NC}"
					systemctl restart $i
					echo -e "${CYAN}$i${YELLOW} updated and restarted${NC}"
					echo -e ""
					echo -e "${YELLOW}Pausing for 2 minutes to let ${CYAN}$i${YELLOW} settle${NC}"
					sleep 120
				else
					echo -e "${YELLOW}No ${CYAN}$ticker${YELLOW} MN's found to update${NC}"
			fi

		done

		echo -e "${CYAN}Wallet update tool finished${NC}"
		exit

	;;

	5)	echo -e "${YELLOW}Starting chain repair/PoSe maintenance tool${NC}"

		chain_repair ""

		exit

	;;

	6)	echo -e "${YELLOW}Starting Removal tool${NC}"
		echo -e ""
		echo -e "Checking home directory for MN alias's"
		ls /home
		echo -e ""
		echo -e "${YELLOW}Above are the alias names for installed MN's${NC}"
		echo -e "${CYAN}Please enter MN alias name{NC}"
		echo -e ""
		read alias
		echo -e ""
		echo -e "${YELLOW}Stopping ${MAGENTA}$alias${NC}"
		systemctl stop $alias
		echo -e ""
		echo -e "${YELLOW}Pausing script to ensure ${MAGENTA}$alias${YELLOW} has stopped${NC}"
		sleep 30
		systemctl disable $alias
		rm /usr/local/bin/$alias
		rm /etc/systemd/system/$alias.service
		deluser $alias
		rm -r /home/$alias
		echo -e ""
		echo -e "${CYAN}$alias removed${NC}"
		exit

	;;

	7)	echo -e "${YELLOW}Starting $ticker MasterNode install${NC}"
		
		install_mn
		
		exit

	;;

	8)	echo -e "Starting stop/start tool..."
		echo -e "Please enter ${CYAN}<stop>${NC} to stop all ${ticker} nodes"
		echo -e "Please enter ${CYAN}<start>${NC} to start all ${ticker} nodes"
		echo -e "Please enter ${CYAN}<restart>${NC} to restart all ${ticker} nodes"
		read stopstart
		echo -e ""
		
		if [[ $stopstart == stop ]] || [[ $stopstart == start ]] || [[ $stopstart == restart ]]
			then
				echo -e "Starting ${CYAN}$stopstart${NC} tool"
				
				for i in $(ls /home/)
					do
						echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN's"
						echo -e "${YELLOW}found ${CYAN}$i${YELLOW}...${NC}"
						if [[ $i == *scc* ]]
							then
								echo -e "${MAGENTA}${stopstart}ing ${CYAN}$i${MAGENTA}..${NC}"
								systemctl $stopstart $i
								echo -e "Pausing for 2 minutes to let ${CYAN}$i${NC} settle"
								sleep 120
								echo -e ""
							else
								echo -e "${CYAN}${ticker}${NC} node not found"
						fi
					done
			else
				echo -e "${RED}Invalid entry${NC}"
		fi
		echo -e "Wallet tool finished"
		exit

	;;

	9)	echo -e "Starting health check and repair tool"
		echo -e "Tool coming soon! Now closing.."
		exit

	;;

	10)	echo -e "${CYAN}Downloading updated bootstrap for offline install/repair${NC}"
		cd /root
		wget -nv --show-progress ${snapshot} -O ${coinname}.zip
		exit

	;;

	11)	echo "Setting up 2GB test swap file"
		setup_swap "2048"
		exit
	;;

	12)	echo "Setting up 8GB test swap file"
		setup_swap "8192"
		exit
	;;

	13)	echo -e "Beginning Explorer comparison tool"

		for i in $(ls /home/); do

			echo -e "${YELLOW}Checking for $ticker MN's${NC}"
			echo -e "found ${CYAN}$i${NC}..."
#			echo -e ""

			if [[ $i == *scc* ]]
				then
					currentblock=$(curl -s http://79.143.186.234/api/getblockcount)
					nodeblock=0
					nodeblock=$($i getblockcount)
					nodestatus=$?

					if [[ $nodestatus == 0 ]]
						then

							if [[ $currentblock == $nodeblock ]]
								then
									echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${CYAN}Same as explorer${NC}"
								else
									echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${RED}Different block count from explorer${NC}"
							fi
						else
							echo -e "${RED}Something is wrong with ${CYAN}$i${NC}"
					fi

				else
					echo -e "${RED}No $ticker MN's found to check${NC}"
			fi

			echo -e ""

		done

		exit
	;;

	14)	echo -e "Beginning Status Checks of Nodes"

		for i in $(ls /home/); do

			echo -e "${YELLOW}Checking for ${CYAN}$ticker ${YELLOW}MN's${NC}"
			echo -e ""
			echo -e "found ${CYAN}$i${NC}..."
			echo -e ""

			if [[ $i == *scc* ]]
				then
					mn_status=0
					mn_status=$($i masternode status)
					mn_status_exitcode=$?

					if [ $mn_status_exitcode != 0 ]
						then
							echo -e "${RED}Something appears to be wrong with node ${CYAN}$i${NC}"
						else

#							echo -e "$mn_status"
#							echo -e ""
#							echo -e "${CYAN}$i${NC}"
							grep -e 'state' <<< $mn_status
							grep -e 'status' <<< $mn_status
							grep -e 'POSE' <<< $mn_status > /dev/null
#							grep -e 'ERROR' <<< $mn_status > /dev/null
							mn_status_exitcode=$?

							if [ $mn_status_exitcode -eq 0 ]
								then
									echo -e "${RED}POSE_BANNED{$NC}"
									echo -e ""
									echo -e "${YELLOW}Do you wish to initiate repair of this node${NC}"
									echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
									read repairnode

									if [[ $repairnode == yes ]]
										then
											chain_repair "$i"
										else
											echo -e "${RED}Not repairing node at this time${NC}"
									fi 
								else
									echo -e "${YELLOW}Appears to be in good shape${NC}"
							fi
					fi
				else
					echo -e "${RED}No $ticker MN's found to check${NC}"
			fi

			echo -e ""

		done
	;;

	15)	echo -e "Beginning Explorer comparison tool with optional repair"

		updatechainfile=0
		offlinerepairall=0
		updateallnodes=0
		blockcompare=0
		
		for i in $(ls /home/); do

			echo -e "${YELLOW}Checking for $ticker MN's${NC}"
			echo -e "found ${CYAN}$i${NC}..."
#			echo -e ""

			if [[ $i == *scc* ]]
				then
					currentblock=$(curl -s http://79.143.186.234/api/getblockcount)
					nodeblock=0
					nodeblock=$($i getblockcount)
					nodestatus=$?
					blockcount=($currentblock - $nodeblock)

					if [[ $blockcompare == 0 ]]
						then
							echo -e ""
							echo -e "${YELLOW}Compare how many block difference count, enter a number${NC}"
							read blockcompare
							echo -e ""
					fi


					if [[ $nodestatus == 0 ]]
						then
							if [[ $currentblock == $nodeblock ]]
								then
									echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${CYAN}Same as explorer${NC}"
								else
									if [[ $blockcount -gt $blockcompare ]]
										then
											echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${RED}Different block count from explorer${NC}"
											echo -e ""
											echo -e "${YELLOW}Block count difference is greater than $blockcompare blocks${NC}"
											echo -e ""

											if [[ $updatechainfile == 0 ]]
												then
													echo -e "${YELLOW}Do you wish to update the offline chain file first?"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read updatechainfile

													if [[ $updatechainfile == "yes" ]]
														then
															echo -e "${CYAN}Downloading updated bootstrap for offline install/repair${NC}"
															cd /root
															wget -nv --show-progress ${snapshot} -O ${coinname}.zip
															echo -e ""
													fi
											fi

											if [[ $offlinerepairall == "no" ]] || [[ $offlinerepairall == 0 ]]
												then
													echo -e ""
													echo -e "${YELLOW}Do you wish to use offline bootstrap for all repairs?"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read offlinerepairall
											fi

											if [[ $updateallnodes != "yes" ]]
												then
													echo -e "${YELLOW}Do you wish to chain repair this node?${NC}"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read repairnode
													echo -e ""

													if [[ $repairnode == "yes" ]]
														then
															echo -e "${YELLOW}Do you wish to repair all nodes?${NC}"
															echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
															read updateallnodes
															echo -e ""
													fi
											fi

											if [[ $offlinerepairall == "yes" ]]
												then
													if [[ $repairnode == "no" ]]
														then
															echo -e "${YELLOW}Skipping repair${NC}"
														else
															chain_repair $i "yes"
													fi
												else
													if [[ $repairnode == "yes" ]]
														then
															chain_repair $i "no"
														else
															echo -e "${YELLOW}Skipping repair${NC}"
													fi
											fi

									fi
							fi
						else
							echo -e "${RED}Something is wrong with ${CYAN}$i${NC}"

							if [[ $updatechainfile == 0 ]]
								then
									echo -e "${YELLOW}Do you wish to update the offline chain file first?"
									echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
									read updatechainfile
									
									if [[ $updatechainfile == "yes" ]]
										then
											echo -e "${CYAN}Downloading updated bootstrap for offline install/repair${NC}"
											cd /root
											wget -nv --show-progress ${snapshot} -O ${coinname}.zip
											echo -e ""
											fi
									fi

									if [[ $offlinerepairall == "no" ]] || [[ $offlinerepairall == 0 ]]
										then
											echo -e ""
											echo -e "${YELLOW}Do you wish to use offline bootstrap for all repairs?"
											echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
											read offlinerepairall
									fi

									if [[ $updateallnodes != "yes" ]]
										then
											echo -e "${YELLOW}Do you wish to chain repair this node?${NC}"
											echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
											read repairnode
											echo -e ""

											if [[ $repairnode == "yes" ]]
												then
													echo -e "${YELLOW}Do you wish to repair all nodes?${NC}"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read updateallnodes
													echo -e ""
											fi
									fi

									if [[ $offlinerepairall == "yes" ]]
										then
											if [[ $repairnode == "no" ]]
												then
													echo -e "${YELLOW}Skipping repair${NC}"
												else
													chain_repair $i "yes"
											fi
										else
											if [[ $repairnode == "yes" ]]
												then
													chain_repair $i "no"
												else
													echo -e "${YELLOW}Skipping repair${NC}"
											fi
									fi

							fi
				else
					echo -e "${RED}No $ticker MN's found to check${NC}"
			fi
		
			echo -e ""

		done

		exit

	;;

    esac

