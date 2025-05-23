#!/bin/bash
#Coin info
version="3.4.7.1"
coinname=stakecubecoin
coinnamed=sccd
coinnamecli=scc-cli
ticker=SCC
coindir=scc
sleeptimerinsec=120
binaries="https://github.com/stakecube/StakeCubeCoin/releases/download/v3.4.7.1/scc-3.4.7.1-linux-nodes.zip"
prereleasebinaries="https://github.com/stakecube/StakeCubeCoin/releases/download/v3.4.7.1/scc-3.4.7.1-linux-nodes.zip"
snapshot='https://stakecubecoin.net/bootstrap.zip'
port=40000
rpcport=39999
discord='https://discord.gg/xxjZzJE'

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
readonly ERASEBACK='\e[1K'
readonly BEGINLINE='\e[0G'

#############################
### Functions and Methods ###
#############################

# Console message functions
function msg {
  echo -e "${1}${NC}"
}
function msgc {
  echo -e "${2}${1}${NC}"
}

# Gets the platform we are running on.
function getPlt {
  if [ "$(uname)" == "Darwin" ]; then
      echo 1
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      echo 0
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      echo 1
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      echo 1
  elif [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
      echo 1
  else
      echo 1
  fi
}

if [ `getPlt` == 0 ]; then

	msgc "Running on Linux.." $YELLOW

else

	msgc "Not running on Linux..." $RED
	exit

fi

#############################
#############################


#pre-setup checks and dependencies installs
checkforrunningapt=$(ps -e | grep apt)

if [[ $checkforrunningapt == "" ]]
        then
                echo -e "Apt not currently running"
				echo -e ""
        else
                echo -e "${RED}Error:${NC} Apt is already running, aborting script"
                exit
fi

echo -e "Checking/installing/updating other script dependency's"
apt -y -qq install curl zip unzip nano ufw software-properties-common pwgen p7zip-full p7zip-rar

clear

sccmultitool_update=$(curl -s https://raw.githubusercontent.com/stakecube/SCC-Multitool/master/sccmultitool.sh)

if [[ $(cmp <(echo "$sccmultitool_update") ~/sccmultitool.sh) ]] && [[ $(diff <(echo "$sccmultitool_update") ~/sccmultitool.sh) ]]
	then
		updatesccmultitool=$([[ -f ~/sccmultitool.sh ]] && echo "1" || echo "0")
	else
		updatesccmultitool=0
fi

function displayname() {

cat << "EOF"
   _____ _        _         _____      _
  / ____| |      | |       / ____|    | |
 | (___ | |_ __ _| | _____| |    _   _| |__   ___
  \___ \| __/ _` | |/ / _ \ |   | | | | '_ \ / _ \
  ____) | || (_| |   <  __/ |___| |_| | |_) |  __/
 |_____/ \__\__,_|_|\_\___|\_____\__,_|_.__/ \___|
EOF

}

displayname

#Tool menu
echo -e ""
echo -e "${UNDERLINE}${CYAN}Welcome to the StakeCube Multitools ${version}${NC}"

#echo -e '\e[4mWelcome to the StakeCube Multitools '${version}' \e[24m'

echo -e "${YELLOW}Please enter a number from the list and press [ENTER] to start tool"
echo -e "${YELLOW}1  - Newserver 8GB swap + IPv6 setup. REQUIRES RESTART ${MAGENTA}Contabo VPS only${NC}"
echo -e "${YELLOW}2  - Setup/Resize/Delete swap space with X MB swap space"
echo -e "${YELLOW}3  - Wallet update (all ${ticker} nodes)"
echo -e "${YELLOW}4  - Masternode stop/start/restart (stop/start/restart all ${ticker} nodes)"
echo -e "${YELLOW}5  - Remove MasterNode"
echo -e "${YELLOW}6  - Remove Multiple Masternodes"
echo -e "${YELLOW}7  - Masternode install"
echo -e "${YELLOW}8  - Masternode install with optional sleep delay function"
echo -e "${YELLOW}9  - Install New Node with manually specified IPv4/IPv6 Address"
echo -e "${YELLOW}10 - Download/Update StakeCubeCoin local bootstrap file from stakecube"
echo -e "${YELLOW}11 - Make/Update your StakeCubeCoin local bootstrap file from an existing SCC node"
echo -e "${YELLOW}12 - Chain/PoSe maintenance tool (single ${ticker} node)"
echo -e "${YELLOW}13 - Check block count status against explorer (all ${ticker} nodes)"
echo -e "${YELLOW}14 - Check MN health status and optional repair (all ${ticker} nodes)"
echo -e "${YELLOW}15 - Check block count and optional chain repair (all ${ticker} nodes)"
echo -e "${YELLOW}16 - Output some system diagnostic info"
echo -e ""
echo -e "${CYAN}97 - Pre-Release Menu${NC}"
echo -e "${YELLOW}98 - Maintenance Sub-Menu - extra functions"
echo -e "${YELLOW}99 - Check for updated script from GitHub${NC}"
echo -e ""
echo -e "${YELLOW}0  - Exit"
echo -e ""
echo -e "${MAGENTA}This script can now use an optional sleep delay of up to 5 minutes per node on startup${NC}"
echo -e "${MAGENTA}This helps to prevent the VPS from being overloaded upon reboot when there are many nodes installed${NC}"
echo -e "${MAGENTA}This can make the install/start/restart/repair node(s) look like it has stopped working${NC}"
echo -e "${MAGENTA}This is just a side effect of the delay only(if it occurs)${NC}"
echo -e ""
echo -e "${YELLOW}This is an ${RED}OPTIONAL${YELLOW} feature that you can use by selecting appropriate options${NC}"
echo -e "${YELLOW}Please run the check install/update service files before installing nodes${NC}"
echo -e "${RED}only IF${YELLOW} you want to use the sleep delay functionality, it only needs to be ran once${NC}"
echo -e "${NC}"

if [[ $updatesccmultitool == "1" ]]
	then
		echo -e "${CYAN}New version of ${GREEN}SCCMultitool${NC}${CYAN} available${NC}"
		echo -e ""
fi

read -p "> " start
echo -e ""

function displaypause() {

        local delaycount=$1

        echo -e "${YELLOW}Press any key to abort countdown and continue${NC}"

		while [ $delaycount -ge 0 ]
                 do
                        echo -en "${GREEN}Countdown ${NC}$delaycount"
                        sleep 1
                        echo -en "${ERASEBACK}${NC}${BEGINLINE}${NC}"
						read -n 1 -t 0.05 $anykey
						anykeystatus=$?
						if [[ $anykeystatus -le 127 ]]
							then
								echo -en "${ERASEBACK}${NC}${BEGINLINE}${NC}"
								return
						fi

                        delaycount=$(($delaycount - 1))
                done

        echo -e ""

        return

}

function checkprocess() {

	local processname=$1

	processidentoutput=$(ps -U $processname -jh)
	processident=$(echo $processidentoutput | grep -c $processname -)
	processidentstatus=$?

	checkprocessname=$(echo $processidentoutput | grep -c sleep -)
	checkprocessstatus=$?

	if [[ $checkprocessstatus == 0 ]]
		then
			echo -e ""
			echo -e "${YELLOW}Process is in sleep mode waiting to start still${NC}"

			sleepcounter="$(echo $processidentoutput | grep 'sleep[ 0-9]' | awk '{print $NF}')"
			echo -e "${YELLOW}$sleepcounter"
			sleepcounter=$(( $sleepcounter + 15 ))
			echo -e "$sleepcounter"
			displaypause $sleepcounter
	fi

#	echo -e ""
#	echo -e "$processidentoutput"
#	echo -e "$processident"
#	echo -e "$processidentstatus"

	if [[ $processident == 0 ]]
		then
			return 1
		else
			return 0
	fi

	#always return false if it gets this far
	return 1

}

function debugmodeonoffsub() {

		local alias=$1
		local onoff=$2
		local debugcmd=$3
		local debugcount=$4
		local grepcheckstatus=$5

#		echo -e ""
#		echo -e "debugcount=$debugcount"
#		echo -e "debugcmd=$debugcmd"
#		echo -e "grepcheckstatus=$grepcheckstatus"

		if [[ $grepcheckstatus == 1 && $debugcount == 0 && $onoff == 1 ]]
			then
				echo -e ""
				echo -e "${YELLOW}Debug line not found, inserting turned on${NC}"

				echo 'debug=1' >> /home/$alias/.scc/stakecubecoin.conf
				echo -e ""
				echo -e "${YELLOW}Restarting node and pausing $sleeptimerinsec seconds${NC}"
				systemctl restart $alias --no-block
				displaypause $sleeptimerinsec
				return
			else
				if [[ $grepcheckstatus == 1 && $debugcount == 0 && $onoff == 0 ]]
					then
						echo -e ""
						echo -e "${YELLOW}Debug line not found, inserting turned off${NC}"

						echo 'debug=0' >> /home/$alias/.scc/stakecubecoin.conf
						echo -e ""
						echo -e "${YELLOW}Restarting node and pausing $sleeptimerinsec seconds${NC}"
						systemctl restart $alias --no-block
						displaypause $sleeptimerinsec
						return
				fi
		fi

		if [[ ${debugcmd,,} == "debug=0" && $onoff == "0" ]]
			then
				echo -e ""
				echo -e "${YELLOW}Debugging already disabled on node ${CYAN}$i${NC}"
				return
		fi

		if [[ ${debugcmd,,} == "debug=1" && $onoff == "1" ]]
			then
				echo -e ""
				echo -e "${YELLOW}Debugging already enabled on node ${CYAN}$i${NC}"
				return
		fi

		if [[ ${debugcmd,,} == "debug=0" && $onoff == "1" ]]
			then
				echo -e ""
				echo -e "${YELLOW}Enabling debugging on node ${CYAN}$i${NC}"
				sed -i 's/debug=0/debug=1/gi' /home/$alias/.scc/stakecubecoin.conf

				echo -e ""
				echo -e "${YELLOW}Restarting node and pausing $sleeptimerinsec seconds${NC}"
				systemctl restart $alias --no-block
				displaypause $sleeptimerinsec
				return
		fi

		if [[ ${debugcmd,,} == "debug=1" && $onoff == "0" ]]
			then
				echo -e ""
				echo -e "${YELLOW}Disabling debugging on node ${CYAN}$i${NC}"
				sed -i 's/debug=1/debug=0/gi' /home/$alias/.scc/stakecubecoin.conf

				echo -e ""
				echo -e "${YELLOW}Restarting node and pausing $sleeptimerinsec seconds${NC}"
				systemctl restart $alias --no-block
				displaypause $sleeptimerinsec
				return
		fi

		return

}

function checkifstart() {

		local alias=$1
		local yesnostart=""

		echo -e ""
		echo -e "${YELLOW}Do you wish to try and start ${CYAN}$alias${YELLOW}?${NC}"
		echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
		read yesnostart

		checkyesno $yesnostart

		if [[ $yesnostart == "yes" ]]
			then
				echo -e ""
				echo -e "${YELLOW}This will only attempt a start and will not verify it started${NC}"
				systemctl start $alias --no-block
				echo -e "${CYAN}Sent start command${NC}"
			else
				echo -e ""
				echo -e "${YELLOW}Not starting${NC}"
		fi

		return

}

function debugmodeonoff() {

		local alias=$1
		local onoff=$2
		local errorpid=0

		foundone=0

		debugcmd="empty"

		echo -e ""
		echo -e "${YELLOW}Checking for $ticker MN's${NC}"
		echo -e ""

		if [[ $alias != 0 ]]
			then
				if ! checkprocess $alias
					then
						errorpid=1

						echo -e ""
						echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$alias${YELLOW} not found${NC}"

						return
				fi

				debugcmd=$(grep -ix 'debug=[0-1]' /home/$alias/.scc/stakecubecoin.conf)
				grepcheckstatus=$?

				if [[ $debugcmd == "" && $grepcheckstatus == 1 ]]
					then
						debugcmd="empty"
				fi

				debugcount=$(grep -cFi 'debug' /home/$alias/.scc/stakecubecoin.conf)
				debugcountstatus=$?

#echo -e "debugcmd=$debugcmd"
#echo -e "debugcount=$debugcount"
#echo -e "debugcountstatus=$debugcountstatus"

				if [[ $debugcount == 1 && $debugcountstatus == 1 ]]
					then
						debugcount=0
				fi

#echo -e "debugcount=$debugcount"


				echo -e "found ${CYAN}$alias${NC}..."

				debugmodeonoffsub $alias $onoff $debugcmd $debugcount $grepcheckstatus

				return
		fi

		for i in $(ls /home/); do

			echo -e ""

			if [[ $i == *scc* ]]
				then
					foundone=1
					errorpid=0
					grepcheckstatus=""
					debugcmd=""

					echo -e "found ${CYAN}$i${NC}..."

					debugcount=$(grep -cFi 'debug' /home/$i/.scc/stakecubecoin.conf)
					debugcmd=$(grep -ix 'debug=[0-1]' /home/$i/.scc/stakecubecoin.conf)
					grepcheckstatus=$?

#echo -e ""
#echo -e "$debugcount"
#echo -e "$debugcmd"
#echo -e "$grepcheckstatus"

					if ! checkprocess $i
						then
							errorpid=1

							echo -e ""
							echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$i${YELLOW} not found${NC}"
					fi

					if [[ $errorpid == 0 ]]
						then
							if [[ $debugcmd == "" ]]
								then
									debugcmd=1
									debugcount=0
							fi

							debugmodeonoffsub $i $onoff $debugcmd $debugcount $grepcheckstatus

					fi

			fi

			if [[ $foundone == 0 ]]
				then
					echo -e ""
					echo -e "${CYAN}No $ticker nodes found${NC}"
			fi

		done

}

function is_number() {

# Author: neo3587
# Source: https://github.com/neo3587/dupmn

	# <$1 = number>
    [[ "$1" =~ ^[0-9]+$ ]] && echo "1"

}

function pad() {

	[ "$#" -gt 1 ] && [ -n "$2" ] && printf "%$2.${2#-}s" "$1";

}

function checkyesno() {

	local yesno=$1

	if [[ $yesno == "yes" ]] || [[ $yesno == "no" ]]
		then
			return
		else
			echo -e "${YELLOW}Please enter only${MAGENTA} yes${YELLOW} or${MAGENTA} no${NC}"
			echo -e ""
			echo -e "${RED}Aborting script${NC}"
			echo -e ""
			exit

	fi

}

function checknetcfgfile() {

	local netdone=0
	netcfg=/etc/netplan/01-netcfg.yaml

	if [[ $netdone == 0 ]] 
		then
			if [[ -f $netcfg ]] 
				then
					netdone=1
				else
					netcfg=/etc/netplan/00-installer-config.yaml
					netdone=0
			fi
	fi

#echo -e "$netdone"
#echo -e "$netcfg"

	if [[ $netdone == 0 ]] 
		then
			if [[ -f $netcfg ]]
				then
					netdone=1
				else
					netcfg=/etc/netplan/50-cloud-init.yaml
					netdone=0
			fi
	fi

#echo -e "$netdone"
#echo -e "$netcfg"

	if [[ $netdone == 0 ]] 
		then
			if [[ -f $netcfg ]]
				then
					netdone=1
				else
					netdone=0
			fi
	fi

#echo -e "$netdone"
#echo -e "$netcfg"

	if [[ $netdone == 0 ]]
		then
			msg ""
			msgc "Error - network config file not found (01-netcfg.yaml or 00-installer-config.yaml or 50-cloud-init.yaml)" $red
			msg ""
			exit
	fi

}

function checkaliasvalidity() {

	local aliasname=$1

	if [[ ! -f /home/$aliasname/.${coindir}/${coinname}.conf ]]
		then
			echo -e ""
			echo -e "${RED}Error node not found${NC}"
			echo -e ""

			exit
	fi

}

function sleeprandomfilecheck() {

			local sleepnumberfile=/usr/local/bin/sleeprandom

			if test -e "$sleepnumberfile"
				then
					echo -e "${CYAN}Sleep/delay file exists, not creating${NC}"
					echo -e ""
				else
					echo -e "${CYAN}Installing sleep/delay file${NC}"
					cd /usr/local/bin
					echo -e "#!/bin/bash" > $sleepnumberfile
					echo -e "MINWAIT=10" >> $sleepnumberfile
					echo -e "MAXWAIT=310" >> $sleepnumberfile
					echo -e 'sleep $((MINWAIT+RANDOM%(MAXWAIT-MINWAIT)))' >> $sleepnumberfile
					chmod +x $sleepnumberfile
			fi

}

function chain_repair() {

	local alias=$1
	local bootstrapchoice=$2
	local chaindownload=0
	local nodeblock=0

	if [[ $alias == "" ]]
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

			checkaliasvalidity $alias
	fi

	echo -e ""
	echo -e "${YELLOW}Checking ${CYAN}$alias${YELLOW} block count against explorer"
	echo -e ""

	currentblock=$(curl -s https://www.coinexplorer.net/api/v1/SCC/getblockcount)
	nodeblock=$($alias getblockcount)
	nodestatus=$?

	if [[ $nodestatus == 0 ]]
		then
			if [[ $currentblock == $nodeblock ]]
				then
					echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${CYAN}Same as explorer${NC}"
					echo -e ""
					echo -e "${MAGENTA}Chain Repair is not needed for this node"
					echo -e ""
					echo -e "${YELLOW}Do you wish to still do the chain repair?"
					echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
					read forcechainrepair

					checkyesno $forcechainrepair

					if [[ $forcechainrepair == "no" ]]
						then
							return
					fi

				else
					echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${RED}Different block count from explorer${NC}"
					echo -e ""
					echo -e "${CYAN}Continuing with repair of node${NC}"
					echo -e ""
			fi
		else
			echo -e "${RED}Something is wrong with ${CYAN}$alias${NC}"
			echo -e "${YELLOW}Continuing repair${NC}"
			echo -e ""
			if [[ $updateallnodes == "no" ]]
				then
					echo -e "${YELLOW}Do you wish to still chain repair?"
					echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
					read checkchainrepair2

					checkyesno $checkchainrepair2
				else
					checkchainrepair2="yes"
			fi

			if [[ $checkchainrepair2 == "no" ]]
				then
					exit
			fi
	fi

	echo -e ""
	echo -e "Stopping ${MAGENTA}$alias${NC}"
	aliasvalid=$(systemctl stop $alias)
	aliasvalidstatus=$?

	if [[ $aliasvalidstatus != 0 ]]
		then
			echo -e ""
			echo -e "${RED}Error: ${CYAN}$alias ${MAGENTA} does not exist or has other errors${NC}"
			echo -e ""

			exit
	fi

	displaypause 10


	if [[ $bootstrapchoice != "yes" ]]
		then
			echo -e ""
			echo -e "${YELLOW}Use offline bootstrap?${NC}"
			echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
			read bootstrapchoice
			checkyesno $bootstrapchoice
		else
			echo -e "${YELLOW}Using offline bootstrap file${NC}"
	fi

	echo -e ""
	cd /home/$alias
	find /home/$alias/.${coindir}/ -name ".lock" -delete
	find /home/$alias/.${coindir}/ -name ".walletlock" -delete
	find /home/$alias/.${coindir}/* ! -name "wallet.dat" ! -name "*.conf" -delete
	echo -e "${YELLOW}Downloading and/or Unzipping and replacing chain files for ${MAGENTA}$alias${NC}"

	if [[ $bootstrapchoice == yes ]]
		then
			sccfile=~/${coinname}.zip
			if test -e "$sccfile"
				then
					7za x ~/${coinname}.zip
					echo -e "${YELLOW}$coinname local chain directory updated${NC}"
				else
					echo -e ""
					echo -e "${RED}File doesn't exist${NC}, ${YELLOW}downloading chain${NC}"
					wget -nv --show-progress ${snapshot} -O ~/${coinname}.zip
					7za x ~/${coinname}.zip
					echo -e ""
					echo -e "${YELLOW}$coinname chain directory updated${NC}"
			fi
		else
			echo -e ""
			echo -e "${YELLOW}Do you wish to download from the web (${CYAN}yes${YELLOW}) or full chain downlaod (${CYAN}no${YELLOW})${NC}"
			echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
			read chaindownload

			checkyesno $chaindownload
	fi

	if [[ $chaindownload == yes ]]
		then
			echo -e ""
			echo -e "${YELLOW}Downloading bootstrap for offline use as well${NC}"
			echo -e ""
			wget -nv --show-progress ${snapshot} -O ~/${coinname}.zip
			7za x ~/${coinname}.zip
			echo -e ""
			echo -e "${YELLOW}$coinname chain directory updated${NC}"
	fi

	chown -R $alias:$alias /home/${alias}
	echo -e ""
	echo -e "${CYAN}Starting $alias after repair${NC}"
	echo -e ""
	systemctl start --no-block ${alias}.service
	displaypause 10

	echo -e ""
	echo -e "${YELLOW}Please wait for a moment.. and use ${CYAN}$alias masternode status${YELLOW} to check if $alais is ready for POSE unban or still showing READY${NC}"
	echo -e "${YELLOW}If $alias showing POSE banned you will need to run the protx update command to unban${NC}"
	echo -e "${YELLOW}Below is an example of the protx update command to use in your main wallets debug console${NC}"
	echo -e "${YELLOW}protx update_service proTxHash ipAndPort operatorKey (operatorPayoutAddress feeSourceAddress)${NC}"
	echo -e ""
	echo -e "${YELLOW}Example: protx update_service proTxHash (127.0.0.1:40000 or [2001:2000:2000:2000:0000:0000:0000:0052]:40000) (blsprivatekey) '""' (feeSourceAddress)${NC}"
	echo -e "${CYAN}Chain repair tool finished${NC}"

}

function install_mn() {

	local bypassipv6setup=$1
	local bypassipv6addr=$2
	local sleepdelay=$3

	if [[ $bypassipv6setup == yes ]]
		then
#			test=$bypassipv6addr
			echo -e "${MAGENTA}Setting config file for IPV6 address $bypassipv6addr${NC}"
			echo -e ""
			ipchoice=yes
#		else
#			test=0
	fi

	#get user input alias and bind set varible#
	echo -e ""
	echo -e "${YELLOW}Checking home directory for masternode alias's${NC}"
	echo -e ""
	ls /home
	echo -e ""
	echo -e "${YELLOW}Above are the alias names for the installed masternodes${NC}"
	echo -e "${YELLOW}Please enter MN alias. Example: ${CYAN}sccmn001${NC}"
	echo -e "${YELLOW}To use other tools you must include ${CYAN}$ticker${YELLOW} in the alias${NC}"
	read alias

	if [[ -f /home/$alias/.${coindir}/${coinname}.conf ]]
		then
			echo -e ""
			echo -e "${RED}Error duplicate node name${NC}"
			echo -e ""

			exit
	fi

	echo -e ""
	echo -e "${YELLOW}${UNDERLINE}Enter the BLS secret key${NC}"
	read key
	echo -e ""
	echo -e "${YELLOW}${UNDERLINE}Please enter a unique RPC port number. Default is ${CYAN}$rpcport${NC}"
	echo -e "${YELLOW}Examples: for ${CYAN}sccmn001 ${YELLOW}use ${CYAN}40010 ${YELLOW}and so on${NC}"
	echo -e "${YELLOW}So it's 4(node number)0 (40010 for sccmn001)${NC}"
	read rpcport

	if [[ $bypassipv6setup == no ]]
		then

			#IPv4/v6 choice and setup
			echo -e ""
			echo -e "${YELLOW}Would you like to setup with an IPv6 address?{$NC}"
			echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
			read ipchoice

			checkyesno $ipchoice

#			echo -e "Passed yes/no check"

			#script network config dependency
			echo -e ""
			echo -e "Checking/installing dependency for auto IP setup"

			if [[ $ipchoice == yes ]]
				then
					#set default IPv6

					checknetcfgfile

					sed -i '1{/^$/d}' $netcfg
					netconfcount=$(grep -c "/64" $netcfg)
					linenumber1=$((grep -n "/64" $netcfg) | cut -d\: -f1 | head -n 1)
					linenumber2=$(( $linenumber1+$netconfcount ))
#					echo -e "$linenumber1"
#					echo -e "$linenumber2"
					dipv6=$(sed -n "$linenumber1"p $netcfg)
					spaces=$(echo -e "$dipv6" | tr -cd ' \t' | wc -c)
					spaces=$(( $spaces-2 ))
					ipv6test="$(echo $dipv6 | grep -E '.{0,4}\/64')"
					ipv6test2="$(echo $ipv6test | awk 'match($0,"/64"){print substr($0,RSTART-4,4)}')"
					ipv6test2="$(echo $ipv6test2 | cut -d\: -f3)"
					ipv6test2="$(echo $ipv6test2 | tr -d ':')"
					ipv6test3=$(( $ipv6test2 + $netconfcount + 50 ))
#					echo -e "ipv6test $ipv6test"
#					echo -e "ipv6test2 $ipv6test2"
#					echo -e "ipv6test3 $ipv6test3"
#					echo -e " 2 $dipv6"
#					echo -e " 3 $spaces"
#					echo -e "$netconfcount"
					cipv6=$(( $ipv6test3 ))
#					echo -e "$cipv6"
					ipv6="$(echo $dipv6 | sed "s/\:$ipv6test2/\:$cipv6/g")"
					echo -e ""
					echo -e "New IPv6 is $ipv6"
					finalconfigipv6="$(echo -e "$(pad " " $spaces) ${ipv6}")"
#					echo -e "$finalconfigipv6"
#					sed -i "${linenumber2}i\\${finalconfigipv6}" $netcfg


#			sed -i '1{/^$/d}' $netcfg
#			netconfcount=$(grep -c :0000:0000 $netcfg)
#			linenumber1=$((grep -n ":0000:0000" $netcfg) | cut -d\: -f1 | head -n 1)
#			echo -e "$linenumber1"
#			dipv6=$(sed -n "$linenumber1"p $netcfg)
#			echo -e " 2 $dipv6"
#			echo -e "$netconfcount"
#			cipv6=$(( $netconfcount+51 ))
#			echo -e "$cipv6"
#			ipv6="$(echo $dipv6 | sed "s/:0001/:$cipv6/g")"
#			echo -e "New IPv6 is $ipv6"

#			#Add IPv6 address to netcfg file
#			sed -i "/gateway6/i \ \ \ \ \ \ \ \ ${ipv6}" $netcfg

#					netplan apply

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
		else
			ipadd=$bypassipv6addr
	fi


	echo -e ""
	echo -e "${YELLOW}Use offline bootstrap?${NC}"
	echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
	read bootstrapchoice

	checkyesno $bootstrapchoice

	if [[ $bootstrapchoice == no ]]
		then
			echo -e ""
			echo -e "${YELLOW}Do you wish to download from the web (${CYAN}yes${YELLOW}) or full chain downlaod (${CYAN}no${YELLOW})${NC}"
			echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
			read chaindownload

			checkyesno $chaindownload
		else
			chaindownload=0
	fi

	if [[ $ipchoice == yes ]]
		then
			echo -e ""
			echo -e "${CYAN}Applying IP configuration${NC}"

			sed -i "${linenumber2}i\\${finalconfigipv6}" $netcfg

			netplan apply
	fi

	echo -e ""
	ufw allow ssh

	echo -e "${CYAN}Making sure your VPS is up to date before continuing install${NC}"
	apt update -y

	#setup user
	echo -e ""
	echo -e "${YELLOW}Setting up user ${CYAN}$alias${NC}"

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
	echo -e "${CYAN}User ${CYAN}$alias${CYAN} setup${NC}"
	echo -e ""

	#Sleep/Delay check and install

	if [[ $sleepdelay == yes ]]
		then
			sleeprandomfilecheck
	fi


	#Node binaries check and install if needed
	cd /usr/local/bin
	binfile=/usr/local/bin/${coinnamecli}
	if test -e "$binfile"
		then
			echo -e "${CYAN}Node binaries already downloaded and setup${NC}"
			echo -e ""
		else
			echo -e "${YELLOW}Installing node binaries for ${MAGENTA}$alias${NC}"
			cd /usr/local/bin
			wget -nv --show-progress ${binaries} -O ${coinname}.zip
			7za x ${coinname}.zip
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

	if [[ $sleepdelay == yes ]]
		then
			echo -e "ExecStartPre=/usr/local/bin/sleeprandom" >> $alias.service
	fi

	echo -e "ExecStart=/usr/local/bin/$coinnamed -daemon -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir">> $alias.service
	echo -e "ExecStop=-/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir stop" >> $alias.service
	echo -e "" >> $alias.service
	echo -e "Restart=always" >> $alias.service
	echo -e "PrivateTmp=true" >> $alias.service
	echo -e "TimeoutStopSec=6000s" >> $alias.service
	echo -e "TimeoutStartSec=3000s" >> $alias.service
	echo -e "StartLimitInterval=120s" >> $alias.service
	echo -e "StartLimitBurst=5" >> $alias.service
	echo -e "" >> $alias.service
	echo -e "[Install]" >> $alias.service
	echo -e "WantedBy=multi-user.target" >> $alias.service
	systemctl enable $alias
	echo -e "${CYAN}System service setup and enabled${NC}"


	#update/copy chain files or get snapshot# from web or fresh complete chain download
	echo -e ""
	cd /home/$alias
	find /home/$alias/.${coindir}/* ! -name "wallet.dat" ! -name "*.conf" -delete
	echo -e "${YELLOW}Downloading and/or Unzipping chain files for ${MAGENTA}$alias${NC}"
	echo -e ""

	mkdir /home/$alias/.${coindir}
	chown $alias:$alias /home/$alias/.${coindir}

	if [[ $bootstrapchoice == yes ]] && [[ $chaindownload == 0 ]]
		then
			sccfile=~/${coinname}.zip
			if test -e "$sccfile"
				then
					7za x ~/${coinname}.zip
					echo -e "${YELLOW}$coinname local bootstrap directory updated${NC}"
				else
					echo -e "${RED}File doesn't exist${NC}, ${YELLOW}downloading chain${NC}"
					wget -nv --show-progress ${snapshot} -O ${coinname}.zip
					7za x  ${coinname}.zip
					echo -e "${YELLOW}$coinname chain directory updated${NC}"
					echo -e "${YELLOW}Removing downloaded temp file${NC}"
					rm /home/${alias}/${coinname}.zip
			fi
		else
			if [[ $chaindownload == yes ]]
				then
					wget -nv --show-progress ${snapshot} -O ${coinname}.zip
					7za x ${coinname}.zip
					echo -e "${YELLOW}$coinname chain directory setup${NC}"
					echo -e "${YELLOW}Removing downloaded temp file${NC}"
					rm /home/${alias}/${coinname}.zip
			fi
	fi

	echo -e ""

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
			if [[ $bypassipv6setup != yes ]] 
				then
					ipadd=$ipv6conf
			fi
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
	echo -e "${YELLOW}Permissions and firewall rules set${NC}"
	echo -e ""
	echo -e "${YELLOW}Starting Node${NC}"

	systemctl start --no-block $alias

	echo -e ""
	echo -e "${YELLOW}Please wait a moment and then read the following information${NC}"
	displaypause 15
	echo -e ""
	echo -e "${CYAN}$ticker${YELLOW} MN setup completed${NC}"
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
	echo -e "${YELLOW}Please wait for sync and then use ${CYAN}$alias -getinfo${NC} or ${CYAN}$alias masternode status ${YELLOW}to check on the node${NC}"
	echo -e ""
	echo -e ""
	echo -e "For more information or support please visit the ${CYAN}$ticker${NC} Discord server"
	echo -e "Support is provided via email: ${MAGENTA}${UNDERLINE}support@stakecube.zohodesk.com${NC}"
	echo -e ""
	echo -e "${CYAN}$discord${NC}"
	echo -e ""

}

function ipv6_setup() {

	#Enable IPv6
	displaypause 2
	sed -i "/net.ipv6.conf.all.disable_ipv6.*/d" /etc/sysctl.conf
	sysctl -q -p

	filefixed=0
	netcfg=/etc/netplan/50-cloud-init.yaml
	netcfg2=/etc/netplan/01-netcfg.yaml
	cloudinit=/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

	if [[ -f $netcfg ]]
		then
			echo -e "${CYAN}Determined Auto Configuration in place.${NC}"
			echo -e "${CYAN}Do you wish to disable auto and setup static network configuration?${NC}"
			echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
			read autoconfigchoice

			checkyesno $autoconfigchoice

			if [[ $autoconfigchoice == yes ]]
				then
					mv $netcfg $netcfg2
					filefixed=1

					if [[ -f $cloudinit ]]
						then
							netdone=0
						else
							echo "network: {config: disabled}" > $cloudinit
					fi
				else
					echo -e "${RED}Aborting due to configuration error.${NC}"
					exit
			fi
	fi

	checknetcfgfile

	echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6

	if [[ $filefixed == 0 ]]
		then
			sed -i "s/#//" $netcfg
			sed -i '1{/^$/d}' $netcfg
	fi

	netplan generate
	netplan apply
	displaypause 5

}

function setup_swap() {

# Author: neo3587
# Source: https://github.com/neo3587/dupmn
# Adapted for use by Lifenaked(grigzy28)

        # <$1 = size_in_mbytes>

        echo -e ""

		if [[ ! $(is_number $1) ]]; then
                echo -e "${YELLOW}<size_in_mbytes>${NC} must be a number"
                return
        fi

        local avail_mb=$(df / --output=avail -m | grep [0-9])
        local total_mb=$(df / --output=size -m | grep [0-9])

        if [[ $1 -ge $avail_mb ]]; then
                echo -e "There's only $avail_mb MB available in the hard disk"
                return
        fi

        [[ -f /var/swapfile ]] && swapoff /var/swapfile &> /dev/null

        if [[ $1 -eq 0 ]]; then
                rm -rf /var/swapfile
                sed -i "/\/var\/swapfile/d" /etc/fstab
                echo -e "Swapfile deleted"
        else
                echo -e "Generating swapfile, this may take some time depending on the size..."
                echo -e "$(($1 * 1024 * 1024)) bytes swapfile"
                dd if=/dev/zero of=/var/swapfile bs=1024 bs=1M count=$1 status=progress
                chmod 600 /var/swapfile &> /dev/null
                mkswap /var/swapfile &> /dev/null
                swapon /var/swapfile &> /dev/null
                /var/swapfile swap swap defaults 0 0 &> /dev/null
                [[ ! $(cat /etc/fstab | grep "/var/swapfile") ]] && echo "/var/swapfile none swap 0 0" >> /etc/fstab
                echo -e ""
				echo -e "${YELLOW}Swapfile new size = ${GREEN}$1 MB${NC}"
        fi

        echo -e ""
		echo -e "Use ${YELLOW}swapon -s${NC} to see the changes of your swapfile and ${YELLOW}free -m${NC} to see the total available memory"
}


function offlinechainfilebuild() {

		echo -e "${YELLOW}Beginning creation of offline bootstrap file${NC}"
		echo -e ""
		ls /home
		echo -e ""
		echo -e "${YELLOW}Above are the alias names for the installed masternodes that you can create the bootstrap from${NC}"
		echo -e "${YELLOW}Please enter MN alias. Example: ${CYAN}sccmn001${NC}"
		read alias

		checkaliasvalidity $alias

		echo -e ""
		echo -e "${YELLOW}Stopping node ${CYAN}$alias${NC}"
		echo -e ""

		systemctl stop $alias.service
		displaypause 5

		echo -e "${YELLOW}Starting the zip process${NC}"

		rm ~/stakecubecoin.zip

		cd /home/$alias
		7za a -tzip -r '-xr!wallet.dat' '-xr!*.conf' '-xr!debug.log' -- ~/stakecubecoin.zip .scc/*

		echo -e ""
		echo -e "${YELLOW}Done creating offline boostrap file${NC}"
		echo -e ""
		echo -e "${YELLOW}Starting ${CYAN}$alias${NC}"

		systemctl start --no-block $alias.service

		return
}

function mn_uninstall() {

		echo -e ""
		echo -e "${YELLOW}Checking home directory for MN alias's${NC}"
		ls /home
		echo -e ""
		echo -e "${YELLOW}Above are the alias names for installed MN's${NC}"
		echo -e "${CYAN}Please enter MN alias name${NC}"
		echo -e ""
		read alias

		checkaliasvalidity $alias

		echo -e ""
		echo -e "${YELLOW}Stopping ${MAGENTA}$alias${NC}"

		systemctl stop $alias
		echo -e ""
		echo -e "${YELLOW}Pausing script to ensure ${MAGENTA}$alias${YELLOW} has stopped${NC}"
		displaypause 20
		systemctl disable $alias
		rm /usr/local/bin/$alias
		rm /etc/systemd/system/$alias.service
		deluser $alias
		rm -r /home/$alias
		echo -e ""
		echo -e "${CYAN}$alias removed${NC}"

}

function prereleasemenu() {

clear
displayname

#Tool pre-release menu
echo -e ""
echo -e "${UNDERLINE}${CYAN}Welcome to the StakeCube Multitools Pre-Releaes Menu${NC}"
echo -e ""
echo -e "${YELLOW}Please enter a number from the list and press [ENTER] to start maintenance tool"
echo -e ""
echo -e "${YELLOW}991 - Download and Install pre-release version and restart all nodes${NC}"
echo -e ""
echo -e "${YELLOW}0  - Exit"
echo -e ""
echo -e "${NC}"

read -p "> " prerelease
echo -e ""

case $prerelease in

	991)	echo -e "${YELLOW}Starting Wallet update tool for ${CYAN}All ${ticker}${YELLOW} nodes with pre-release software${NC}"
			echo -e ""
			cd /usr/local/bin
			rm $coinnamecli $coinnamed
			wget -nv --show-progress ${prereleasebinaries} -O ${coinname}.zip
			7za x ${coinname}.zip
			chmod +x ${coinnamecli} ${coinnamed}
			rm ${coinname}.zip
			cd /root
			displaypause 15

			echo -e "How long between node (re)starts in seconds?"
			echo -e "Blank/Empty equals 120 seconds"
			read secondsdelay

			if [[ $secondsdelay != "" ]]
				then
					sleeptimerinsec=$secondsdelay
			fi

			for i in $(ls /home/); do
				echo -e ""
				echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN's${NC}"
				echo -e "${YELLOW}found ${CYAN}$i${NC}..."
				echo -e ""

				if [[ $i == *scc* ]]
					then
						echo -e "${YELLOW}Restarting ${CYAN}$i${YELLOW}..${NC}"
						systemctl stop $i
						displaypause 3
						systemctl start --no-block $i
						echo -e "${CYAN}$i${YELLOW} updated and restarted${NC}"
						echo -e ""
						echo -e "${YELLOW}Pausing for $sleeptimerinsec seconds to let ${CYAN}$i${YELLOW} settle${NC}"
						displaypause $sleeptimerinsec
					else
						echo -e "${YELLOW}No ${CYAN}$ticker${YELLOW} MN's found to update${NC}"
				fi

			done

			echo -e "${CYAN}Wallet update tool finished${NC}"
			exit

	;;

esac

}


function maintmenu() {


clear

displayname

#Tool maintenance menu
echo -e ""
echo -e "${UNDERLINE}${CYAN}Welcome to the StakeCube Multitools ${version}${NC}"
echo -e ""
echo -e "${YELLOW}Maintenance menu${NC}"
echo -e ""
echo -e "${YELLOW}Please enter a number from the list and press [ENTER] to start maintenance tool"
echo -e ""
echo -e "${YELLOW}91 - Check and install/update service files for ${MAGENTA}optional${YELLOW} sleep delay${NC}"
echo -e "${YELLOW}92 - Output all ${ticker} nodes IP and Private Keys${NC}"
echo -e "${YELLOW}93 - Change Debug mode for single ${ticker} node${NC}"
echo -e "${YELLOW}94 - Change Debug mode for all ${ticker} nodes${NC}"
echo -e "${YELLOW}95 - Check current debug status for all ${ticker} nodes${NC}"
echo -e "${YELLOW}96 - Collect debug log for a single ${ticker} node${NC}"
echo -e "${YELLOW}97 - Collect debug logs for all ${ticker} nodes${NC}"
echo -e "${YELLOW}98 - Delete debug log and restart node(s), single or all${NC}"
echo -e "${YELLOW}${NC}"
echo -e "${YELLOW}99 - Full chain repair by not using a bootstrap(not recommended)${NC}"
echo -e "${YELLOW}100- Enable IPv6 ${MAGENTA}Contabo VPS ONLY${NC}"
echo -e ""
echo -e "${YELLOW}0  - Exit"
echo -e ""
echo -e "${MAGENTA}This script can now use an optional sleep delay of up to 5 minutes per node on startup${NC}"
echo -e "${MAGENTA}This helps to prevent the VPS from being overloaded upon reboot when there are many nodes installed${NC}"
echo -e "${MAGENTA}This can make the install/start/restart/repair node(s) look like it has stopped working${NC}"
echo -e "${MAGENTA}This is just a side effect of the delay only(if it occurs)${NC}"
echo -e ""
echo -e "${YELLOW}This is an ${RED}OPTIONAL${YELLOW} feature that you can use by selecting appropriate options${NC}"
echo -e "${YELLOW}Please run the check install/update service files before installing nodes${NC}"
echo -e "${RED}only IF${YELLOW} you want to use the sleep delay functionality, it only needs to be ran once${NC}"
echo -e "${NC}"

read -p "> " maintstart
echo -e ""


case $maintstart in

	91)	echo -e "${YELLOW}Beginning Optional Sleep delay install/update tool${NC}"

		sleeprandomfilecheck

		echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN service files${NC}"

		foundone=0

		for i in $(ls /etc/systemd/system/)
			do
				if [[ $i == *scc* ]]
					then
						foundone=1

						echo -e "${YELLOW}found ${CYAN}$i${YELLOW}...${NC}"
						echo -e ""
						echo -e "${CyAN}Checking file ${MAGENTA}$i${NC}"

						grepkcheck=$(grep -Fxq 'ExecStartPre=/usr/local/bin/sleeprandom' /etc/systemd/system/$i)
						grepcheckstatus=$?

						if [[ $grepcheckstatus == 0 ]]
							then
								echo -e "${CYAN}$i already updated${NC}"
							else
								sed -i '/^ExecStart=.*/i ExecStartPre=/usr/local/bin/sleeprandom' /etc/systemd/system/$i
								sed -i 's/TimeoutStartSec=.*/TimeoutStartSec=3000s/g' /etc/systemd/system/$i
								echo -e "${CYAN}Updated ${MAGENTA}$i${NC}"
								echo -e ""
								echo -e "${YELLOW}Reloading system config daemon files${NC}"
								echo -e ""
								systemctl daemon-reload
						fi
				fi
			done

		if [[ $foundone == 0 ]]
			then
				echo -e "${CYAN}Found no SCC nodes${NC}"
		fi

		exit

	;;

	92)	echo -e "${YELLOW}Beginning Private Keys and IP for all nodes${NC}"

		echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} IP/MN private keys${NC}"

		foundone=0

		for i in $(ls /home/)
			do
				if [[ $i == *scc* ]]
					then

						foundone=1

						privkey=$(grep -e 'masternodeblsprivkey' /home/$i/.scc/stakecubecoin.conf | cut -d\= -f2)
						grepcheckstatus=$?
						ip=$(grep -e 'bind' /home/$i/.scc/stakecubecoin.conf | cut -d\= -f2)

						echo -e "${YELLOW}found ${CYAN}$i${YELLOW}...${NC}"
						echo -e "${CYAN}IP: ${GREEN}$ip${NC}"
						echo -e "${CYAN}Private Key:${MAGENTA}$privkey${NC}"
						echo -e ""
				fi
			done

		if [[ $foundone == 0 ]]
			then
				echo -e "${CYAN}Found no SCC nodes${NC}"
		fi

		exit

	;;

	93)	echo -e "${YELLOW}Beginning debug node tool - single node${NC}"

		echo -e ""
		echo -e "${YELLOW}Checking home directory for masternode alias's${NC}"
		echo -e ""
		ls /home
		echo -e ""
		echo -e "${YELLOW}Above are the alias names for the installed masternodes${NC}"
		echo -e "${YELLOW}Please enter MN alias. Example: ${CYAN}sccmn001${NC}"
		echo -e ""
		read alias

		checkaliasvalidity $alias

		echo -e ""
		echo -e "${YELLOW}Enable Debug Mode on Node?${NC}"
		echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
		read onoff
		checkyesno $onoff

		echo -e ""

		if [[ $onoff == "yes" ]]
			then
				onoff=1
			else
				onoff=0
		fi

		debugmodeonoff $alias $onoff

		exit

	;;

	94)	echo -e "${YELLOW}Beginning debug node tool - all nodes${NC}"

		echo -e ""
		echo -e "${YELLOW}Enable Debug Mode on Nodes?${NC}"
		echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
		read onoff
		checkyesno $onoff

		echo -e ""

		if [[ $onoff == "yes" ]]
			then
				onoff=1
			else
				onoff=0
		fi

		alias=0
		debugmodeonoff $alias $onoff

		exit

	;;

	95)	echo -e "${YELLOW}Beginning check debug status tool on all ${ticker} nodes${NC}"

		for i in $(ls /home/); do

			debugcount=""
			debugcmd=""

			echo -e ""

			if [[ $i == *scc* ]]
				then
					foundone=1
					errorpid=0
					grepcheckstatus=2

					echo -e "found ${CYAN}$i${NC}..."

					debugcount=$(grep -cFi 'debug' /home/$i/.scc/stakecubecoin.conf)
					debugcmd=$(grep -ix 'debug=[0-1]' /home/$i/.scc/stakecubecoin.conf)
					grepcheckstatus=$?

#					echo -e ""
#					echo -e "$countdebug"
#					echo -e "$debugcmd"
#					echo -e "$grepcheckstatus"

					if ! checkprocess $i
						then
							errorpid=1

							echo -e ""
							echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$i${YELLOW} not found${NC}"
					fi

					if [[ $errorpid == 0 ]]
						then
							if [[ $debugcmd == "" ]]
								then
									debugcmd=1
									debugcount=0
							fi

					fi
			fi

			if [[ ${debugcmd,,} == "debug=0" ]]
				then
					echo -e ""
					echo -e "${YELLOW}Debugging is disabled on node ${CYAN}$i${NC}"
			fi

			if [[ ${debugcmd,,} == "debug=1" ]]
				then
					echo -e ""
					echo -e "${YELLOW}Debugging is enabled on node ${CYAN}$i${NC}"
			fi

			if [[ ${debugcmd,,} == 1 || $debugcount == 0 ]]
				then
					echo -e ""
					echo -e "${YELLOW}Debugging command not found in config file on node ${CYAN}$i${NC}"
			fi

			if [[ $foundone == 0 ]]
				then
					echo -e ""
					echo -e "${CYAN}No $ticker nodes found${NC}"
			fi

		done

		exit

	;;

	96)	echo -e "${YELLOW}Beginning collect single node debug log tool${NC}"

		echo -e ""
		echo -e "${YELLOW}Checking home directory for masternode alias's${NC}"
		echo -e ""
		ls /home/
		echo -e ""
		echo -e "${YELLOW}Above are the alias names for the installed masternodes${NC}"
		echo -e "${YELLOW}Please enter MN alias. Example: ${CYAN}sccmn001${NC}"
		echo -e ""
		read alias

		checkaliasvalidity $alias

		echo -e ""
		echo -e "${YELLOW}Collecting log for ${CYAN}$alias${NC}"
		echo -e ""

		debugzipfilename="${alias}_debug.zip"

		rm ~/${debugzipfilename}
		7za a -tzip -spf -- ~/${debugzipfilename} /home/$alias/.scc/debug.log 

		echo -e ""
		echo -e "${YELLOW}Completed file name is ${CYAN}${debugzipfilename}${YELLOW} in user roots folder${NC}"
		echo -e ""
		echo -e "${YELLOW}Tool Completed${NC}"

		exit

	;;

	97)	echo -e "${YELLOW}Beginning collection of debug logs on all ${ticker} nodes${NC}"

		debugzipfilename="SCC_nodes_debug_logs.zip"
		debugfilelist=""

		echo -e ""

		for i in $(ls /home/); do

			if [[ $i == *scc* ]]
				then
					foundone=1

					echo -e "found ${CYAN}$i${NC}..."

					if [[ $debugfilelist == "" ]]
						then
							debugfilelist="/home/${i}/.scc/debug.log "
						else
							debugfilelist="${debugfilelist} /home/${i}/.scc/debug.log "
					fi

#					echo -e ""
#					echo -e "${debugfilelist}"
#					echo -e "$debugcmd"
#					echo -e "$grepcheckstatus"

			fi

		done

			if [[ $foundone == 1 ]]
				then
					echo -e ""
					echo -e "${CYAN}Zipping all debug logs${NC}"

					rm ~/${debugzipfilename}
					7za a -tzip -spf -- ~/$debugzipfilename $debugfilelist
			fi

			if [[ $foundone == 0 ]]
				then
					echo -e ""
					echo -e "${CYAN}No $ticker nodes found${NC}"
			fi

		exit

	;;

	98)	echo -e "${YELLOW}Beginning deletion of debug log(s) for ${ticker} node(s)${NC}"

		echo -e ""

		echo -e "${YELLOW}Do you wish to erase all nodes debug logs?${NC}"
		echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
		echo -e ""
		read eraseallnodes

		checkyesno $eraseallnodes

		singlealias=0

		if [[ $eraseallnodes == "no" ]]
			then
				echo -e ""
				echo -e "${YELLOW}Checking home directory for masternode alias's${NC}"
				echo -e ""
				ls /home/
				echo -e ""
				echo -e "${YELLOW}Above are the alias names for the installed masternodes${NC}"
				echo -e "${YELLOW}Please enter MN alias. Example: ${CYAN}sccmn001${NC}"
				echo -e ""
				read singlealias

				checkaliasvalidity $singlealias
		fi

		if [[ $eraseallnodes == "yes" ]]
			then

				for i in $(ls /home/); do

					if [[ $i == *scc* ]]
						then
							echo -e "found ${CYAN}$i${NC}..."
							echo -e ""
							echo -e "${YELLOW}Erasing debug log file and restarting ${CYAN}$i${NC}"

							rm /home/$i/.scc/debug.log
							systemctl restart $i --no-block

							echo -e ""
							echo -e "${YELLOW}Restarted node and pausing $sleeptimerinsec seconds${NC}"
							displaypause $sleeptimerinsec
					fi



#					echo -e ""
#					echo -e "${debugfilelist}"
#					echo -e "$debugcmd"
#					echo -e "$grepcheckstatus"

				done
			else
				echo -e ""
				echo -e "${YELLOW}Erasing debug log file and restarting ${CYAN}$singlealias${NC}"

				rm /home/$singlealias/.scc/debug.log
				systemctl restart $singlealias --no-block

				echo -e ""
				echo -e "${YELLOW}Restarted node and pausing $sleeptimerinsec seconds${NC}"
				displaypause $sleeptimerinsec
		fi

		exit

	;;

	99)	echo -e "${YELLOW}Starting full sync chain download repair tool${NC}"
		echo -e ""
		echo -e "${YELLOW}Checking home directory for masternode alias's${NC}"
		echo -e ""
		ls /home
		echo -e ""
		echo -e "${YELLOW}Above are the alias names for the installed masternodes${NC}"
		echo -e "${YELLOW}Please enter MN alias. Example: ${CYAN}sccmn001${NC}"
		echo -e ""
		read alias

		checkaliasvalidity $alias

		echo -e ""

		echo -e "${YELLOW}Stopping node ${CYAN}$alias${NC}"

		systemctl stop $alias.service

		echo -e ""
		echo -e "${YELLOW}Pausing for 30 seconds${NC}"

		displaypause 30

		cd /home/$alias
		find /home/$alias/.${coindir}/ -name ".lock" -delete
		find /home/$alias/.${coindir}/ -name ".walletlock" -delete
		find /home/$alias/.${coindir}/* ! -name "wallet.dat" ! -name "*.conf" -delete

		echo -e "${RED}Chain files are deleted, restarting node ${CYAN}$alias${NC}"

		systemctl start --no-block $alias.service

		exit

	;;

	100)	echo -e "Starting IPv6 setup tool..."

		ipv6_setup

		#Finish
		echo -e "IPv6 setup complete"
		exit

	;;


esac

}


case $start in
#Tools

	0)	echo -e "Stopping and exiting script..."
		exit
	;;

	1)	echo -e "${YELLOW}Starting 8GB swap space setup with added dependencies${NC}"

		setup_swap "8192"

		#Update linux
		apt-get update && apt-get -y upgrade
		apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt -y install

		#Allow SSH and enable firewall
		ufw allow 22/tcp comment "SSH"
		echo -e "y" | ufw enable

		ipv6_setup

		#Finish
		echo -e "${CYAN}New server setup complete${NC}"
		echo -e ""
		echo -e "${YELLOW}Please ${RED}reboot${YELLOW} before installing any nodes!${NC}"
		echo -e ""

		exit

	;;

	2)	echo -e "${YELLOW}Resizing Swap space to X MB swap size${NC}"
		echo -e ""
		echo -e "${MAGENTA}Make sure all nodes are stopped first${NC}"
		echo -e "${MAGENTA}If not, please press control-c to cancel${NC}"
		echo -e ""
		echo -e "${YELLOW}Enter size of swap file to create in MB (2048 is 2GB, 8192 (8GB), 16384 (16GB), 32768 (32GB), 65536 (64GB))${NC}"
		echo -e "${YELLOW}Enter 0 to delete swapfile${NC}"
		read swapsize

		setup_swap "$swapsize"

		exit
	;;

	3)	echo -e "${YELLOW}Starting Wallet update tool for ${CYAN}All ${ticker}${YELLOW} nodes${NC}"
		echo -e ""
		cd /usr/local/bin
		rm $coinnamecli $coinnamed
		wget -nv --show-progress ${binaries} -O ${coinname}.zip
		7za x ${coinname}.zip
		chmod +x ${coinnamecli} ${coinnamed}
		rm ${coinname}.zip
		cd /root
		displaypause 15

		echo -e "How long between node (re)starts in seconds?"
		echo -e "Blank/Empty equals 120 seconds"
		read secondsdelay

		if [[ $secondsdelay != "" ]]
			then
				sleeptimerinsec=$secondsdelay
		fi

		for i in $(ls /home/); do
			echo -e ""
			echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN's${NC}"
			echo -e "${YELLOW}found ${CYAN}$i${NC}..."
			echo -e ""

			if [[ $i == *scc* ]]
				then
					echo -e "${YELLOW}Restarting ${CYAN}$i${YELLOW}..${NC}"
					systemctl stop $i
					displaypause 3
					systemctl start --no-block $i
					echo -e "${CYAN}$i${YELLOW} updated and restarted${NC}"
					echo -e ""
					echo -e "${YELLOW}Pausing for $sleeptimerinsec seconds to let ${CYAN}$i${YELLOW} settle${NC}"
					displaypause $sleeptimerinsec
				else
					echo -e "${YELLOW}No ${CYAN}$ticker${YELLOW} MN's found to update${NC}"
			fi

		done

		echo -e "${CYAN}Wallet update tool finished${NC}"
		exit

	;;

	4)	echo -e "Starting stop/start tool..."
		echo -e "Please enter ${CYAN}stop${NC} to stop all ${ticker} nodes"
		echo -e "Please enter ${CYAN}start${NC} to start all ${ticker} nodes"
		echo -e "Please enter ${CYAN}restart${NC} to restart all ${ticker} nodes"
		read stopstart
		echo -e ""

		if [[ $stopstart == stop ]] || [[ $stopstart == start ]] || [[ $stopstart == restart ]]
			then
				if [[ $stopstart == restart ]] || [[ $stopstart == start ]]
					then
						echo -e "How long between node (re)starts in seconds?"
						echo -e "Blank/Empty equals 120 seconds"
						read secondsdelay

						if [[ $secondsdelay != "" ]]
							then
								sleeptimerinsec=$secondsdelay
						fi
				fi

				echo -e "Starting ${CYAN}$stopstart${NC} tool"

				for i in $(ls /home/)
					do
						echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN's"
						echo -e "${YELLOW}found ${CYAN}$i${YELLOW}...${NC}"
						if [[ $i == *scc* ]]
							then
								echo -e "${MAGENTA}${stopstart}ing ${CYAN}$i${MAGENTA}..${NC}"

								if [[ $stopstart == "restart" ]]
									then
										systemctl stop $i
										displaypause 5
										systemctl start --no-block $i
									else
										systemctl $stopstart --no-block $i
								fi

								if [[ $stopstart == "stop" ]]
									then
										echo -e "${YELLOW}Pausing for 10 seconds${NC}"
										displaypause 10
										echo -e ""
									else
										echo -e "Pausing for $sleeptimerinsec seconds to let ${CYAN}$i${NC} settle"
										displaypause $sleeptimerinsec
										echo -e ""
								fi
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

	5)	echo -e "${YELLOW}Starting Removal tool${NC}"

		mn_uninstall

		exit

	;;

	6)	echo -e "${YELLOW}Beginning Multiple Nodes Uninstall Tool${NC}"
		echo -e ""
		echo -e "${YELLOW}Press ${CYAN}Control-C${YELLOW} to abort at alias selection to quit${NC}"
		echo -e ""

		for i in $(ls /home/)
			do
				if [[ $i == *scc* ]]
					then
						mn_uninstall
				fi
			done

		echo -e "${CYAN}Found no SCC node nodes${NC}"
		echo -e ""

		exit

	;;

	7)	echo -e "${YELLOW}Starting $ticker MasterNode install${NC}"

		install_mn "no" "" "no"

		exit

	;;

	8)	echo -e "${YELLOW}Starting $ticker MasterNode install with Sleep Delay functionality${NC}"

		install_mn "no" "" "yes"

		exit

	;;

	9) echo -e "${YELLOW}Beginning manual ip node install${NC}"
		echo -e ""
		echo -e "${YELLOW}Please specify a valid IPv4 or IPv6 address${NC}"
		echo -e "${YELLOW}In x.x.x.x or [x:x:x:x:x:x:x:x] format${NC}"
		read manualipv6addr

		echo -e ""
		echo -e "${MAGENTA}Testing ip address${NC}"
		echo -e "${MAGENTA}Pinging Google${NC}"

		testipv6=$(ping google.com -c 5 -W 2 -I $manualipv6addr)
		testipv6status=$?

		if [[ $testipv6status == 0 ]]
			then
				echo -e "${CYAN}Passed${NC}"
				echo -e ""
				echo -e "${YELLOW}Do you wish to enable sleep delay?${NC}"
				echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
				read sleepquestion
				checkyesno $sleepquestion

				if [[ $sleepquestion == "no" ]]
					then
						install_mn "yes" "$manualipv6addr" "no"
					else
						install_mn "yes" "$manualipv6addr" "yes"
				fi
			else
				echo -e "${RED}Error: ${CYAN}IP is invalid${NC}"
		fi

		exit

	;;

	10)	echo -e "${CYAN}Downloading updated bootstrap for offline install/repair from StakeCube${NC}"
		cd /root
		wget -nv --show-progress ${snapshot} -O ${coinname}.zip
		exit

	;;

	11)	offlinechainfilebuild

		exit

	;;


	12)	echo -e "${YELLOW}Starting chain repair/PoSe maintenance tool${NC}"

		chain_repair ""

		exit

	;;

	13)	echo -e "Beginning Explorer comparison tool"

		foundone=0
		currentblock=$(curl -s https://www.coinexplorer.net/api/v1/SCC/getblockcount | tr -dc '0-9' )
		upperlimit=$((currentblock + 5))
		lowerlimit=$((currentblock - 5))

		echo -e ""
		echo -e "${YELLOW}Explorer Block Height: ${CYAN}$currentblock${NC}"
		echo -e "${YELLOW}Lower Block Height: ${CYAN}$lowerlimit${NC}"
		echo -e "${YELLOW}Upper Block Height: ${CYAN}$upperlimit${NC}"
		echo -e ""
		
		for i in $(ls /home/); do

			if [[ $i == *scc* ]]
				then

					echo -e "${YELLOW}Checking for $ticker MN's${NC}"
					echo -e "found ${CYAN}$i${NC}..."
#					echo -e ""

					foundone=1
					runnode=0

					if ! checkprocess $i
						then
							runnode=1
							echo -e ""
							echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$i${YELLOW} not found${NC}"

							checkifstart $i
						else
							runnode=0
					fi

					if [[ $runnode == 0 ]]
						then
							nodeblock=0
							nodeblock=$($i getblockcount)
							nodestatus=$?
						else
							nodestation=1
					fi

					if [[ $nodestatus == 0 ]]  && [[ $runnode == 0 ]]
						then

							if [[ $currentblock == $nodeblock ]]
								then
									echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${CYAN}Same as explorer${NC}"
								else
									if [[ $nodeblock -le $upperlimit ]] && [[ $nodeblock -ge $lowerlimit ]]
										then
											echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${YELLOW}Different block count from explorer within variance${NC}"
										else
											echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock      ${RED}Different block count from explorer${NC}"
									fi
							fi
						else
							echo -e "${RED}Something is wrong with ${CYAN}$i${NC}"
					fi

			fi

			echo -e ""

		done

		if [[ $foundone == 0 ]]
			then
				echo -e "${CYAN}Found no $ticker nodes${NC}"
		fi

		exit
	;;

	14)	echo -e "Beginning Status Checks of Nodes"

		foundone=0
		updatechainfile="no"
		offlinerepairall="no"
		updateallnodes="no"
		blockcompare=0

		echo -e ""
		echo -e "${YELLOW}Checking for $ticker MN's${NC}"
		echo -e ""

		for i in $(ls /home/); do

#			echo -e ""

			if [[ $i == *scc* ]]
				then
					foundone=1
					processtestresult=""

					echo -e "found ${CYAN}$i${NC}..."

					updatechainfilelocal=""
					processtestresult=""
					mn_status=""

					if ! checkprocess $i
						then
							if [[ $updateallnodes == "no" ]]
								then
									echo -e ""
									echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$i${YELLOW} node not found, node doesn't appear to be started${NC}"

									checkifstart $i

									mn_status_exitcode=1
									mn_status_exitcode2=1
									processtestresult=1
							fi
						else
							mn_status=$($i masternode status)
							mn_status_exitcode=$?
							mn_status_exitcode2=0
							processtestresult=0
					fi

#					updatechainfilelocal=""
#					mn_status=""
#					mn_status=$($i masternode status)
#					mn_status_exitcode=$?
#					mn_status_exitcode2=0

#					echo -e "$mn_status"
#					echo -e ""
#					echo -e "${CYAN}$i${NC}"

					grep -e 'state' <<< $mn_status
					grep -e 'status' <<< $mn_status

					if grep -iq 'BANNED' <<< $mn_status
						then 
							mn_status_exitcode2=1
							echo -e "Got here POSE_BANNED"
					fi

					if grep -iq 'ERROR' <<< $mn_status
						then 
							mn_status_exitcode2=1
							echo -e "Got here ERROR"
					fi

#					if grep -q 'WAITING' <<< $mn_status
#						then 
#							mn_status_exitcode2=1
#							echo -e "Got here Waiting"
#					fi

#					grep -e 'ERROR' <<< $mn_status > /dev/null
#					mn_status_exitcode2=$?
					echo -e ""

					if [[ $mn_status_exitcode != 0 ]] || [[ $mn_status_exitcode2 != 0 ]] || [[ $processtestresult != 0 ]]
						then
							mn_status_exitcode=1
						else
							echo -e "${YELLOW}Appears to be in good shape${NC}"
							mn_status_exitcode=0
							mn_status_exitcode2=0
					fi

					if [[ $mn_status_exitcode != 0 ]]
						then
							echo -e "${RED}Something appears to be wrong with node ${CYAN}$i${NC}"
							echo -e ""

							if [[ $updateallnodes == "no" ]]
								then
									echo -e "${YELLOW}Do you wish to initiate repair of this node${NC}"
									echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
									read repairnode
									checkyesno $repairnode
								else
									repairnode="yes"
							fi

							if [[ $repairnode == yes ]]
								then
									if [[ $updatechainfile == 0 ]]
										then
											echo -e ""
											echo -e "${YELLOW}Do you wish to update the offline chain file first?"
											echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
											read updatechainfile
											checkyesno $updatechainfile

											if [[ $updatechainfile == "yes" ]]
												then
													echo -e ""
													echo -e "${YELLOW}Update from local node or from the web?${NC}"
													echo -e "${CYAN}Yes ${YELLOW}for local copy or ${CYAN}No ${YELLOW}for Web download${NC}"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read updatechainfilelocal
													checkyesno $updatechainfilelocal

													if [[ $updatechainfilelocal == "yes" ]]
														then
															offlinechainfilebuild
														else
															echo -e "${CYAN}Downloading updated bootstrap for offline install/repair${NC}"
															cd /root
															wget -nv --show-progress ${snapshot} -O ${coinname}.zip
															echo -e ""
													fi
											fi
									fi

									repairnode="yes"

								else
									echo -e ""
									echo -e "${RED}Not repairing node at this time${NC}"
									echo -e ""
									mn_status_exitcode=0
									mn_status=0
									mn_status_exitcode2=0
							fi 
					fi

					if [[ $mn_status_exitcode != 0 ]]  || [[ $mn_status_exitcode2 != 0 ]]
						then
											if [[ $offlinerepairall == "no" ]] || [[ $offlinerepairall == 0 ]]
												then
													if [[ $offlinerepairall != "no" ]]
														then
															echo -e ""
															echo -e "${YELLOW}Do you wish to use offline bootstrap for all repairs?"
															echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
															read offlinerepairall
															checkyesno $offlinerepairall
													fi
											fi

											if [[ $updateallnodes != "yes" ]]
												then
#													echo -e "${YELLOW}Do you wish to chain repair this node?${NC}"
#													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
#													read repairnode
#													checkyesno $repairnode
#													echo -e ""

													if [[ $repairnode == "yes" ]]
														then
															echo -e ""
															echo -e "${YELLOW}Do you wish to repair all nodes automatically?${NC}"
															echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
															read updateallnodes
															checkyesno $updateallnodes
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

						else
							if [[ $mn_status_exitcode != 0 ]]  || [[ $mn_status_exitcode2 != 0 ]]
								then
								echo -e ""
								echo -e "${RED}Something is wrong with ${CYAN}$i${NC}"
								echo -e ""

								if [[ $updatechainfile == 0 ]] && [[ $mn_status != 0 ]]
									then
										echo -e "${YELLOW}Do you wish to update the offline chain file first?"
										echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
										read updatechainfile
										checkyesno $updatechainfile

										if [[ $updatechainfile == "yes" ]]
											then
												echo -e ""
												echo -e "${YELLOW}Update from local node or from the web?${NC}"
												echo -e "${CYAN}Yes ${YELLOW}for local copy or ${CYAN}No ${YELLOW}for Web download${NC}"
												echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
												read updatechainfilelocal
												checkyesno $updatechainfilelocal

												if [[ $updatechainfilelocal == "yes" ]]
													then
														offlinechainfilebuild
													else
														echo -e "${CYAN}Downloading updated bootstrap for offline install/repair${NC}"
														cd /root
														wget -nv --show-progress ${snapshot} -O ${coinname}.zip
														echo -e ""
												fi
										fi

										if [[ $offlinerepairall == 0 ]]
											then
												echo -e ""
												echo -e "${YELLOW}Do you wish to use offline bootstrap for all repairs?"
												echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
												read offlinerepairall
												checkyesno $offlinerepairall
												echo -e ""
										fi

										if [[ $updateallnodes == "yes" ]]
											then
												repairmode="yes"
											else
												if [[ $repairnode == "yes" ]]
													then
														echo -e "${YELLOW}Do you wish to repair all nodes automatically?${NC}"
														echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
														read updateallnodes
														checkyesno $updateallnodes
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
					fi
			fi

			echo -e ""

		done

		if [[ $foundone == 0 ]]
			then
				echo -e "${CYAN}Found no $ticker nodes${NC}"
		fi

		exit

	;;


	15)	echo -e "Beginning Explorer comparison tool with optional repair"

		foundone=0
		updatechainfile=0
		updatechainfilelocal=0
		offlinerepairall=0
		updateallnodes=0
		blockcompare=0

		if [[ $blockcompare == 0 ]]
			then
				echo -e ""
				echo -e "${YELLOW}Compare how many block difference count, enter a number${NC}"
				read blockcompare
				echo -e ""
		fi

		for i in $(ls /home/); do

			if [[ $i == *scc* ]]
				then
					echo -e "${YELLOW}Checking for $ticker MN's${NC}"
					echo -e "found ${CYAN}$i${NC}..."
#					echo -e ""

					foundone=1
					currentblock=$(curl -s https://www.coinexplorer.net/api/v1/SCC/getblockcount)
					currentblockstatus=$?

					if [[ $currentblockstatus == 1 ]]
						then
							echo -e "${YELLOW}Explorer not responding${NC}"
							exit
					fi

					nodeblock=0
					nodeblock=$($i getblockcount)
					nodestatus=$?
					blockcount=($currentblock - $nodeblock)

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
													echo -e ""
													echo -e "${YELLOW}Do you wish to update the offline chain file first?"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read updatechainfile
													checkyesno $updatechainfile

													if [[ $updatechainfile == "yes" ]]
														then
															echo -e ""
															echo -e "${YELLOW}Update from local node or from the web?${NC}"
															echo -e "${CYAN}Yes ${YELLOW}for local copy or ${CYAN}No ${YELLOW}for Web download${NC}"
															echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
															read updatechainfilelocal
															checkyesno $updatechainfilelocal

															if [[ $updatechainfilelocal == "yes" ]]
																then
																	offlinechainfilebuild
																else
																	echo -e "${CYAN}Downloading updated bootstrap for offline install/repair${NC}"
																	cd /root
																	wget -nv --show-progress ${snapshot} -O ${coinname}.zip
																	echo -e ""
															fi
													fi
											fi

											if [[ $offlinerepairall == "no" ]] || [[ $offlinerepairall == 0 ]]
												then
													echo -e ""
													echo -e "${YELLOW}Do you wish to use offline bootstrap for all repairs?"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read offlinerepairall
													checkyesno $offlinerepairall
											fi

											if [[ $updateallnodes != "yes" ]]
												then
													echo -e "${YELLOW}Do you wish to chain repair this node?${NC}"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read repairnode
													checkyesno $repairnode
													echo -e ""

													if [[ $repairnode == "yes" ]]
														then
															echo -e "${YELLOW}Do you wish to repair all nodes?${NC}"
															echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
															read updateallnodes
															checkyesno $updateallnodes
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
									checkyesno $updatechainfile

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
											checkyesno $offlinerepairall
									fi

									if [[ $updateallnodes != "yes" ]]
										then
											echo -e "${YELLOW}Do you wish to chain repair this node?${NC}"
											echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
											read repairnode
											checkyesno $repairnode
											echo -e ""

											if [[ $repairnode == "yes" ]]
												then
													echo -e "${YELLOW}Do you wish to repair all nodes?${NC}"
													echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
													read updateallnodes
													checkyesno $updateallnodes
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

			echo -e ""

		done

		if [[ $foundone == 0 ]]
			then
				echo -e "${CYAN}Found no $ticker nodes${NC}"
		fi

		exit

	;;

	16) echo -e "${YELLOW}Available disk space is${CYAN}"

		df / -h

		echo -e "${NC}"

		echo -e "${YELLOW}Available memory (ram and swap) is${CYAN}"

		free -m -h

		echo -e "${NC}"

		echo -e "${YELLOW}Operating system version${CYAN}"

		cat /etc/os-release

		echo -e "${NC}"

		exit

	;;

	97) echo -e ""
		echo -e "${RED}Are you sure you wish to enter the pre-release menu?${NC}"
		echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
		read prereleaseyesno
		checkyesno $prereleaseyesno

		if [[ $prereleaseyesno == "yes" ]]
			then
				prereleasemenu
			else
				echo -e "${CYAN}Aborting${NC}"
				echo -e ""
		fi

		exit

	;;

	98)	maintmenu

		exit

	;;

	99)	echo -e "${MAGENTA}Beginning Update Checker Tool${NC}"

		echo -e ""

		sccmultitool_update=$(curl https://raw.githubusercontent.com/stakecube/SCC-Multitool/master/sccmultitool.sh)

		echo -e ""

		if [[ -f ~/sccmultitool.sh ]]
			then
				if [[ $(cmp <(echo "$sccmultitool_update") ~/sccmultitool.sh) ]] && [[ $(diff <(echo "$sccmultitool_update") ~/sccmultitool.sh) ]]
					then
						update=$([[ -f ~/sccmultitool.sh ]] && echo "1" || echo "0")
						echo "$sccmultitool_update" > ~/sccmultitool.sh
						chmod +x ~/sccmultitool.sh

						if [[ $update == "1" ]]
							then
								echo -e "${GREEN}SCCMultitool${NC} updated to the lastest version"
								echo -e ""
						fi

						echo -e ""
					else
						echo -e "${GREEN}SCCMultitool${NC} is already updated to the lastest version"
						echo -e ""
						exit
				fi
			else
				echo "$sccmultitool_update" > ~/sccmultitool.sh
				chmod +x ~/sccmultitool.sh
				echo -e "${GREEN}SCCmultitool${NC} installed"
				echo -e ""
		fi

		exit

	;;

esac
