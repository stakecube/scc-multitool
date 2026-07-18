#!/bin/bash
#Coin info
version="3.5.1.0"
prereleaseavailable=0
coinname=stakecubecoin
coinnamed=sccd
coinnamecli=scc-cli
ticker=SCC
coindir=scc
sleeptimerinsec=120
sleeprandomtimer=65
binaries="https://github.com/stakecube/StakeCubeCoin/releases/download/v3.5.1.0/scc-v3.5.1.0-1542625b0-linux-nodes.zip"
prereleasebinaries="https://github.com/stakecube/StakeCubeCoin/releases/download/v3.4.7.1/scc-3.4.7.1-linux-nodes.zip"
snapshot='https://stakecubecoin.net/bootstrap.zip'
port=40000
rpcport=39999
discord='https://discord.gg/xxjZzJE'
netcfg="/etc/netplan/01-netcfg.yaml"

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

if [[ "$(uname -s)" != "Linux" ]]; then
    msgc "Not running on Linux..." "$RED"
    exit 1
fi

#############################

#pre-setup checks and dependencies installs
if pgrep -x apt >/dev/null ||
   pgrep -x apt-get >/dev/null ||
   pgrep -x dpkg >/dev/null; then
    echo -e "${RED}Error:${NC} apt or dpkg is already running; aborting"
    exit 1
fi


echo -e "Checking/installing/updating other script dependency's"
if ! apt -y -qq install \
    curl zip unzip nano ufw software-properties-common \
    pwgen p7zip-full p7zip-rar; then
    echo -e "${RED}Dependency installation failed${NC}"
    exit 1
fi

#setup variables for passwords
pass=`pwgen 14 1 b` || exit 1
rpcuser=`pwgen 14 1 b` || exit 1
rpcpass=`pwgen 36 1 b` || exit 1

clear

if sccmultitool_update=$(
    curl -fsS --connect-timeout 10 --max-time 60 \
        https://raw.githubusercontent.com/stakecube/SCC-Multitool/master/sccmultitool.sh
); then
    if [[ -n "$sccmultitool_update" ]]; then
        if [[ -f "$HOME/sccmultitool.sh" ]] &&
           ! cmp -s <(printf '%s\n' "$sccmultitool_update") \
                   "$HOME/sccmultitool.sh"; then
            updatesccmultitool=1
        else
            updatesccmultitool=0
        fi
    else
        updatesccmultitool=0
    fi
else
    updatesccmultitool=0
fi

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
  \___ \| __/ _` | |/ / _ \ |   | | | |  _ \ / _ \
  ____) | || (_| |   <  __/ |___| |_| | |_) |  __/
 |_____/ \__\__,_|_|\_\___|\_____\__,_|_.__/ \___|
EOF

}

displayname

#Tool menu
echo
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
echo
if [[ $prereleaseavailable == 1 ]]; then echo -e "${CYAN}97 - Pre-Release Menu${NC}"; fi
echo -e "${YELLOW}98 - Maintenance Sub-Menu - extra functions"
echo -e "${YELLOW}99 - Check for updated script from GitHub${NC}"
echo
echo -e "${YELLOW}0  - Exit"
echo
echo -e "${MAGENTA}This script can now use an optional sleep delay of up to 5 minutes per node on startup${NC}"
echo -e "${MAGENTA}This helps to prevent the VPS from being overloaded upon reboot when there are many nodes installed${NC}"
echo -e "${MAGENTA}This can make the install/start/restart/repair node(s) look like it has stopped working${NC}"
echo -e "${MAGENTA}This is just a side effect of the delay only(if it occurs)${NC}"
echo
echo -e "${YELLOW}This is an ${RED}OPTIONAL${YELLOW} feature that you can use by selecting appropriate options${NC}"
echo -e "${YELLOW}Please run the check install/update service files before installing nodes${NC}"
echo -e "${RED}only IF${YELLOW} you want to use the sleep delay functionality, it only needs to be ran once${NC}"
echo -e "${NC}"

if [[ $updatesccmultitool == "1" ]]
	then
		echo -e "${CYAN}New version of ${GREEN}SCCMultitool${NC}${CYAN} available${NC}"
		echo -e ""
fi

read -rp "> " start
echo

function displaypause() {

    local delaycount=$1

    echo -e "${YELLOW}Press any key to abort countdown and continue${NC}"

		while [ $delaycount -ge 0 ]
        do
          echo -en "${GREEN}Countdown ${NC}$delaycount"
          sleep 1
          echo -en "${ERASEBACK}${NC}${BEGINLINE}${NC}"

          if read -r -n 1 -t 0.05 anykey; then
             echo -en "${ERASEBACK}${NC}${BEGINLINE}${NC}"
             return 0 
          fi

       delaycount=$(($delaycount - 1))
    done

    echo

    return

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

function checkprocess() {
    local processname="$1"

    # Retrieve process info for the user
    local processidentoutput
    processidentoutput=$(ps -U "$processname" -jh)

    # Count how many matches for process name
    local processident
    processident=$(echo "$processidentoutput" | grep -c "$processname")
    local processidentstatus=$?

    # Check if process is in sleep mode
    local checkprocessname
    checkprocessname=$(echo "$processidentoutput" | grep -c sleep)
    local checkprocessstatus=$?

    if [[ "$checkprocessstatus" -eq 0 ]]; then
        echo -e ""
        echo -e "${YELLOW}Process is in sleep mode waiting to start still${NC}"

        # Extract sleep counter
        local sleepcounter
        sleepcounter=$(echo "$processidentoutput" | grep 'sleep[ 0-9]' | awk '{print $NF}')
        echo -e "${YELLOW}$sleepcounter"

        # Add 15 seconds and pause
        sleepcounter=$(( sleepcounter + 15 ))
        echo -e "$sleepcounter"
        displaypause "$sleepcounter"
    fi

    # Return 1 if process exists, 0 if not
    if [[ "$processident" -gt 0 ]]; then
        return 0  # process found
    else
        return 1  # process not found
    fi
}

is_variable_name() {
    [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

prompt_yes_no() {
    if [[ $# -lt 2 ]] || ! is_variable_name "$1"; then
        echo "prompt_yes_no: invalid destination variable" >&2
        return 2
    fi

    local -n result_var="$1"
    local prompt="$2"
    local response

    echo >&2
    echo -e "${YELLOW}${prompt}${NC}" >&2
    echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}" >&2

    if ! read -r response; then
        echo >&2
        echo -e "${RED}Input closed; aborting operation${NC}" >&2
        return 1
    fi

    case "${response,,}" in
        yes|no)
            result_var="${response,,}"
            return 0
            ;;
        *)
            echo >&2
            echo -e "${YELLOW}Please enter only${MAGENTA} yes${YELLOW} or${MAGENTA} no${NC}" >&2
            echo >&2
            echo -e "${RED}Aborting operation${NC}" >&2
            echo >&2
            return 1
            ;;
    esac
}

checkaliasvalidity() {
    if [[ $# -lt 1 ]]; then
        echo "checkaliasvalidity: alias argument missing" >&2
        return 2
    fi

    local aliasname="$1"
    local mode="${2:-require_existing}"
    local conf_file="/home/$aliasname/.${coindir}/${coinname}.conf"

    if [[ ! "$aliasname" =~ ^[A-Za-z0-9_-]+$ ]]; then
        echo -e "${RED}Invalid alias '${aliasname}' — aborting${NC}" >&2
        return 1
    fi

    case "$mode" in
        allow_new)
            return 0
            ;;
        require_existing)
            if [[ ! -f "$conf_file" ]]; then
                echo -e "${RED}Node not found at $conf_file${NC}" >&2
                return 1
            fi
            ;;
        *)
            echo "checkaliasvalidity: invalid mode '$mode'" >&2
            return 2
            ;;
    esac

    return 0
}

prompt_for_alias() {
    if [[ $# -lt 1 ]] || ! is_variable_name "$1"; then
	      echo "prompt_for_alias: invalid destination variable" >&2
        return 2
    fi

    local -n result_var="$1"
    local supplied_alias="${2:-}"
    local alias_input

    if [[ -n "$supplied_alias" ]]; then
        checkaliasvalidity "$supplied_alias" require_existing || return 1
        result_var="$supplied_alias"
        return 0
    fi

    echo >&2
    echo -e "${YELLOW}Checking home directory for masternode aliases${NC}" >&2
    echo >&2

    find /home \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf '%f\n' |
        sort |
        column

    echo >&2
    echo -e "${YELLOW}Above are the installed account names${NC}" >&2
    echo -e "${CYAN}Enter the masternode alias${NC}" >&2
    echo >&2

    if ! read -r alias_input; then
        echo -e "${RED}Input closed; aborting operation${NC}" >&2
        return 1
    fi

    # Remove leading and trailing whitespace without xargs.
    alias_input="${alias_input#"${alias_input%%[![:space:]]*}"}"
    alias_input="${alias_input%"${alias_input##*[![:space:]]}"}"

    checkaliasvalidity "$alias_input" require_existing || return 1

    result_var="$alias_input"
    return 0
}

checkblskey() {
    local -n result_var="$1"
    local key="${2,,}"

    if [[ ! "$key" =~ ^[0-9a-f]{64}$ ]]; then
        echo -e "${RED}Invalid BLS private key.${NC}" >&2
        echo -e "${YELLOW}It must be exactly 64 hexadecimal characters (0-9, a-f).${NC}" >&2
        return 1
    fi

    result_var="$key"
    return 0
}

function debugmodeonoffsub() {
    local alias=$1
    local onoff=$2
    local debugcmd=$3
    local debugcount=$4
    local grepcheckstatus=$5

    # Uncomment for debugging
    # echo -e ""
    # echo -e "debugcount=$debugcount"
    # echo -e "debugcmd=$debugcmd"
    # echo -e "grepcheckstatus=$grepcheckstatus"

    if [[ "$grepcheckstatus" -eq 1 && "$debugcount" -eq 0 && "$onoff" -eq 1 ]]; then
        echo -e ""
        echo -e "${YELLOW}Debug line not found, inserting turned on${NC}"
        echo 'debug=1' >> "/home/$alias/.scc/stakecubecoin.conf"
        echo -e ""
        echo -e "${YELLOW}Restarting node and pausing ${sleeptimerinsec} seconds${NC}"
        systemctl restart "$alias" --no-block
        displaypause "$sleeptimerinsec"
        return
    elif [[ "$grepcheckstatus" -eq 1 && "$debugcount" -eq 0 && "$onoff" -eq 0 ]]; then
        echo -e ""
        echo -e "${YELLOW}Debug line not found, inserting turned off${NC}"
        echo 'debug=0' >> "/home/$alias/.scc/stakecubecoin.conf"
        echo -e ""
        echo -e "${YELLOW}Restarting node and pausing ${sleeptimerinsec} seconds${NC}"
        systemctl restart "$alias" --no-block
        displaypause "$sleeptimerinsec"
        return
    fi

    local debugcmd_lower="${debugcmd,,}"

    case "$debugcmd_lower" in
        "debug=0")
            if [[ "$onoff" -eq 0 ]]; then
                echo -e "${YELLOW}Debugging already disabled on node ${CYAN}$alias${NC}"
                return
            elif [[ "$onoff" -eq 1 ]]; then
                echo -e "${YELLOW}Enabling debugging on node ${CYAN}$alias${NC}"
                sed -i 's/debug=0/debug=1/gi' "/home/$alias/.scc/stakecubecoin.conf"
                echo -e "${YELLOW}Restarting node and pausing ${sleeptimerinsec} seconds${NC}"
                systemctl restart "$alias" --no-block
                displaypause "$sleeptimerinsec"
                return
            fi
            ;;
        "debug=1")
            if [[ "$onoff" -eq 1 ]]; then
                echo -e "${YELLOW}Debugging already enabled on node ${CYAN}$alias${NC}"
                return
            elif [[ "$onoff" -eq 0 ]]; then
                echo -e "${YELLOW}Disabling debugging on node ${CYAN}$alias${NC}"
                sed -i 's/debug=1/debug=0/gi' "/home/$alias/.scc/stakecubecoin.conf"
                echo -e "${YELLOW}Restarting node and pausing ${sleeptimerinsec} seconds${NC}"
                systemctl restart "$alias" --no-block
                displaypause "$sleeptimerinsec"
                return
            fi
            ;;
        *)
            # fallback or do nothing
            ;;
    esac

    return
}

function checkifstart() {
    local alias="$1"
    local yesnostart

    prompt_yes_no yesnostart "${YELLOW}Do you wish to try and start ${CYAN}$alias${YELLOW}?${NC}" || return 1
    
    if [[ "$yesnostart" == "yes" ]]; then
        echo
        echo -e "${YELLOW}This will only attempt a start and will not verify it started${NC}"
        systemctl start "$alias" --no-block
        echo -e "${CYAN}Sent start command${NC}"
    else
        echo
        echo -e "${YELLOW}Not starting${NC}"
    fi

    return
}

function debugmodeonoff() {
    local alias="$1"
    local onoff="$2"
    local errorpid=0
    local foundone=0
    local debugcmd="empty"
    local debugcount
    local grepcheckstatus

    echo -e ""
    echo -e "${YELLOW}Checking for ${ticker} MN's${NC}"
    echo -e ""

    # Check specific alias
    if [[ "$alias" != "0" ]]; then
        if ! checkprocess "$alias"; then
            errorpid=1
            echo -e ""
            echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$alias${YELLOW} not found${NC}"
            return
        fi

        debugcmd=$(grep -ix 'debug=[0-1]' "/home/$alias/.scc/stakecubecoin.conf")
        grepcheckstatus=$?

        # Determine if debug is not set
        if [[ -z "$debugcmd" && $grepcheckstatus -eq 1 ]]; then
            debugcmd="empty"
        fi

        debugcount=$(grep -cFi 'debug' "/home/$alias/.scc/stakecubecoin.conf")
        debugcountstatus=$?

        # Debugging output (keep as per your instructions)
        # echo -e "debugcmd=$debugcmd"
        # echo -e "debugcount=$debugcount"
        # echo -e "debugcountstatus=$debugcountstatus"

        if [[ "$debugcount" -eq 1 && $debugcountstatus -eq 1 ]]; then
            debugcount=0
        fi

        echo -e "found ${CYAN}$alias${NC}..."

        debugmodeonoffsub "$alias" "$onoff" "$debugcmd" "$debugcount" "$grepcheckstatus"
        return
    fi

    # Loop through /home/ to find relevant nodes
    for i in /home/*; do
        basename_i=$(basename "$i")
        echo -e ""

        if [[ "$basename_i" == *scc* ]]; then
            foundone=1
            errorpid=0
            grepcheckstatus=""
            debugcmd=""

            echo -e "found ${CYAN}$basename_i${NC}..."

            debugcount=$(grep -cFi 'debug' "$i/.scc/stakecubecoin.conf")
            debugcmd=$(grep -ix 'debug=[0-1]' "$i/.scc/stakecubecoin.conf")
            grepcheckstatus=$?

            # Debugging output (keep as per your instructions)
            # echo -e "debugcmd=$debugcmd"
            # echo -e "debugcount=$debugcount"
            # echo -e "debugcountstatus=$debugcountstatus"

            # Check if process exists
            if ! checkprocess "$basename_i"; then
                errorpid=1
                echo -e ""
                echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$basename_i${YELLOW} not found${NC}"
            fi

            if [[ $errorpid -eq 0 ]]; then
                if [[ -z "$debugcmd" ]]; then
                    debugcmd=1
                    debugcount=0
                fi

                debugmodeonoffsub "$basename_i" "$onoff" "$debugcmd" "$debugcount" "$grepcheckstatus"
            fi
        fi
    done

    if [[ "$foundone" -eq 0 ]]; then
        echo -e ""
        echo -e "${CYAN}No ${ticker} nodes found${NC}"
    fi
}

checknetcfgfile() {
    local candidate

    for candidate in \
        /etc/netplan/01-netcfg.yaml \
        /etc/netplan/00-installer-config.yaml \
        /etc/netplan/50-cloud-init.yaml
    do
        if [[ -f "$candidate" ]]; then
            netcfg="$candidate"
            return 0
        fi
    done

    echo
    echo -e "${RED}Error: network configuration file not found${NC}"
    echo -e "${YELLOW}Checked:${NC}"
    echo "  /etc/netplan/01-netcfg.yaml"
    echo "  /etc/netplan/00-installer-config.yaml"
    echo "  /etc/netplan/50-cloud-init.yaml"
    echo
    return 1
}


sleeprandomfilecheck() {
    local maxwait="$1"
    local sleepnumberfile="/usr/local/bin/sleeprandom"

    if [[ ! "$maxwait" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid maximum sleep value: $maxwait${NC}"
        return 1
    fi

    (( maxwait > 5 )) || maxwait=6

    cat > "$sleepnumberfile" <<EOF
#!/bin/bash
MINWAIT=5
MAXWAIT=$maxwait
sleep \$((MINWAIT + RANDOM % (MAXWAIT - MINWAIT + 1)))
EOF

    chmod 0755 "$sleepnumberfile" || return 1
    echo -e "${CYAN}Sleep delay configured with MAXWAIT=$maxwait${NC}"
}

erase_chain_data() {
    local alias="$1"
    local node_home="/home/$alias"
    local data_dir="$node_home/.${coindir}"

    checkaliasvalidity "$alias" require_existing || return 1

    if [[ -z "$alias" ||
          "$node_home" != "/home/$alias" ||
          "$data_dir" != "/home/$alias/.${coindir}" ||
          ! -d "$data_dir" ]]; then
        echo -e "${RED}Unsafe or missing data directory: $data_dir${NC}"
        return 1
    fi

    if ! find "$data_dir" -type f \
        \( -name '.lock' -o -name '.walletlock' \) \
        -delete; then
        echo -e "${RED}Failed removing lock files from $data_dir${NC}"
        return 1
    fi

    if ! find "$data_dir" \
        -mindepth 1 \
        -maxdepth 1 \
        ! -name 'wallet.dat' \
        ! -name '*.conf' \
        -delete; then
        echo -e "${RED}Failed cleaning chain directory $data_dir${NC}"
        return 1
    fi

    return 0
}

function chain_repair() {

	local alias="$1"
	local bootstrapchoice="$2"
	local updateallnodes="${3:-no}"
	local chaindownload=0
	local nodesblock=0
  local currentblock
  local upperlimit lowerlimit
  local forcechainrepair
  local checkchainrepair2

  # ------------------------------------------------------------------
  # 1. Resolve alias
  # ------------------------------------------------------------------
  prompt_for_alias alias "$alias" || return 1
  if [[ -z "$alias" ]]; then
      echo -e "${RED}No alias provided — aborting${NC}"
      return 1
  fi

  local node_home="/home/$alias"

	echo
	echo -e "${YELLOW}Checking ${CYAN}$alias${YELLOW} block count against explorer${NC}"
	echo

  # -----------------------------------------------------------------
  # Get the current block height from the explorer API.
  # -----------------------------------------------------------------
  if ! currentblock=$(
      curl -fsS --connect-timeout 10 --max-time 30 \
          https://www.coinexplorer.net/api/v1/SCC/getblockcount
  ); then
      echo -e "${RED}Failed to contact explorer API${NC}"
      return 1
  fi

  currentblock="${currentblock//$'\r'/}"
  currentblock="${currentblock//$'\n'/}"

  if [[ ! "$currentblock" =~ ^[0-9]+$ ]]; then
      echo -e "${RED}Explorer returned an invalid block height: $currentblock${NC}"
      return 1
  fi

  upperlimit=$((currentblock + 5))
  lowerlimit=$((currentblock - 5))

  echo
  echo -e "${YELLOW}Explorer Block Height: ${CYAN}$currentblock${NC}"
  echo -e "${YELLOW}Lower Block Height:  ${CYAN}$lowerlimit${NC}"
  echo -e "${YELLOW}Upper Block Height:  ${CYAN}$upperlimit${NC}"
  echo

  local alias_command="/usr/local/bin/$alias"

  if [[ ! -x "$alias_command" ]]; then
      echo -e "${RED}Alias command not found: $alias_command${NC}"
      return 1
  fi

  if ! nodesblock=$("$alias_command" getblockcount); then
      echo -e "${RED}Unable to obtain block count from $alias${NC}"
      return 1
  fi

  nodesblock="${nodesblock//$'\r'/}"
  nodesblock="${nodesblock//$'\n'/}"

  if [[ ! "$nodesblock" =~ ^[0-9]+$ ]]; then
      echo -e "${RED}Invalid block count returned by $alias: $nodesblock${NC}"
      return 1
  fi

  if [[ "$currentblock" -eq "$nodesblock" ]]; then
    echo -e "${CYAN}${alias}${NC} sccnode: $nodesblock explorer: $currentblock ${CYAN}Same as explorer${NC}"
    echo
    echo -e "${MAGENTA}Chain repair is not needed for this node${NC}"
    echo

    if [[ "$updateallnodes" == "yes" ]]; then
        return 0
    fi

    prompt_yes_no forcechainrepair \
        "Do you wish to force the chain repair anyway?" || return 1

    [[ "$forcechainrepair" == "yes" ]] || return 0

  elif (( nodesblock <= upperlimit && nodesblock >= lowerlimit )); then
    echo -e "${CYAN}${alias}${NC} sccnode: $nodesblock explorer: $currentblock ${YELLOW}Within allowed variance${NC}"
    echo
    echo -e "${YELLOW}Chain repair is normally not required${NC}"
    echo

    if [[ "$updateallnodes" == "no" ]]; then
        prompt_yes_no checkchainrepair2 \
            "Do you wish to repair this node anyway?" || return 1

        [[ "$checkchainrepair2" == "yes" ]] || return 0
    fi

  else
    echo -e "${CYAN}${alias}${NC} sccnode: $nodesblock explorer: $currentblock ${RED}Outside allowed variance${NC}"
    echo
    echo -e "${RED}The node appears to require a chain repair${NC}"
    echo

    if [[ "$updateallnodes" == "no" ]]; then
        prompt_yes_no checkchainrepair2 \
            "Continue with the chain repair?" || return 1

        [[ "$checkchainrepair2" == "yes" ]] || return 0
    fi
  fi

  echo -e "${YELLOW}Downloading and/or Unzipping and replacing chain files for ${MAGENTA}$alias${NC}"

  local bootstrap_file="$HOME/${coinname}.zip"

  case "$bootstrapchoice" in
      yes|no)
          ;;
      "")
          prompt_yes_no bootstrapchoice "Use offline bootstrap?" || return 1
          ;;
      *)
          echo -e "${RED}Invalid bootstrap choice: $bootstrapchoice${NC}"
          return 2
          ;;
  esac

  if [[ "$bootstrapchoice" == "no" ]]; then
      prompt_yes_no chaindownload \
          "${YELLOW}Download a bootstrap from the web? Select ${CYAN}no${YELLOW} for full chain synchronization.${NC}" ||
          return 1

      if [[ "$chaindownload" == "yes" ]]; then
          if ! wget -nv --show-progress \
              "$snapshot" -O "${bootstrap_file}.part"; then
              rm -f -- "${bootstrap_file}.part"
              echo -e "${RED}Bootstrap download failed; existing chain remains untouched${NC}"
              return 1
          fi

          mv -- "${bootstrap_file}.part" "$bootstrap_file" || return 1
          bootstrapchoice="yes"
      fi
  fi

  if [[ "$bootstrapchoice" == "yes" ]]; then
      if [[ ! -f "$bootstrap_file" ]]; then
          echo -e "${RED}Bootstrap file not found: $bootstrap_file${NC}"
          return 1
      fi

      if ! 7za t "$bootstrap_file" >/dev/null; then
          echo -e "${RED}Bootstrap archive failed verification${NC}"
          return 1
      fi
  fi

  echo
  echo -e "Stopping ${MAGENTA}$alias${NC}"

  systemctl stop -- "$alias" || return 1
  displaypause 10

  erase_chain_data "$alias" || return 1

  if [[ "$bootstrapchoice" == "yes" ]]; then
      if ! 7za x "$bootstrap_file" -o"$node_home"; then
          echo -e "${RED}Bootstrap extraction failed${NC}"
          echo -e "${MAGENTA}${alias} remains stopped${NC}"
          return 1
      fi

      echo -e "${YELLOW}${coinname} chain directory updated${NC}"
  else
      echo -e "${CYAN}${alias}${YELLOW} will perform a full chain synchronization${NC}"
  fi

  chown -R -- "$alias:$alias" "$node_home" || return 1
  systemctl start --no-block "${alias}.service" || return 1

	displaypause 10

	echo
	echo -e "${YELLOW}Please wait for a moment.. and use ${CYAN}$alias masternode status${YELLOW} to check if $alias is ready for POSE unban or still showing READY${NC}"
	echo -e "${YELLOW}If $alias showing POSE banned you will need to run the protx update command to unban${NC}"
	echo -e "${YELLOW}Below is an example of the protx update command to use in your main wallets debug console${NC}"
	echo -e "${YELLOW}protx update_service proTxHash ipAndPort operatorKey (operatorPayoutAddress feeSourceAddress)${NC}"
	echo
	echo -e "${YELLOW}Example: protx update_service proTxHash (127.0.0.1:40000 or [2001:2000:2000:2000:0000:0000:0000:0052]:40000) (blsprivatekey) '""' (feeSourceAddress)${NC}"
	echo -e "${CYAN}Chain repair tool finished${NC}"

}

function install_mn() {

	local bypassipv6setup=$1
	local bypassipv6addr=$2
	local sleepdelay=$3

  if [[ "$bypassipv6setup" == "yes" ]]; then
      ipadd="${bypassipv6addr#[}"
      ipadd="${ipadd%]}"

      if [[ "$ipadd" == *:* ]]; then
          ipchoice="yes"
          echo -e "${MAGENTA}Setting config for IPv6 address $ipadd${NC}"
      elif [[ "$ipadd" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
          ipchoice="no"
          echo -e "${MAGENTA}Setting config for IPv4 address $ipadd${NC}"
      else
          echo -e "${RED}Invalid manual IP address: $bypassipv6addr${NC}"
          return 1
      fi
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

  if ! read -r alias; then
      echo -e "${RED}Input closed; aborting installation${NC}" >&2
      return 1
  fi

  checkaliasvalidity "$alias" allow_new || return 1

  local node_conf="/home/$alias/.${coindir}/${coinname}.conf"

  if [[ -f "$node_conf" ]]; then
      echo
      echo -e "${RED}Error: duplicate node name${NC}"
      echo
      return 1
  fi


	echo -e ""
	echo -e "${YELLOW}${UNDERLINE}Enter the BLS secret key${NC}"

  if ! read -r blskey; then
      echo -e "${RED}Input closed; aborting installation${NC}" >&2
      return 1
  fi

  checkblskey blskey "$blskey" || return 1


	echo -e ""
	echo -e "${YELLOW}${UNDERLINE}Please enter a unique RPC port number. Default is ${CYAN}$rpcport${NC}"
	echo -e "${YELLOW}Examples: for ${CYAN}sccmn001 ${YELLOW}use ${CYAN}40010 ${YELLOW}and so on${NC}"
	echo -e "${YELLOW}So it's 4(node number)0 (40010 for sccmn001)${NC}"
	read -r rpcport

	if [[ $bypassipv6setup == no ]]
		then

			#IPv4/v6 choice and setup
			echo -e ""

      prompt_yes_no ipchoice "${YELLOW}Would you like to setup with an IPv6 address?${NC}" || return 1

			#script network config dependency
			echo -e ""
			echo -e "Checking/installing dependency for auto IP setup"

			if [[ $ipchoice == yes ]]
				then
					#set default IPv6

  				checknetcfgfile || return 1

          sed -i '1{/^$/d}' "$netcfg" || return 1
          netconfcount=$(grep -cF '/64' "$netcfg")

					linenumber1=$(grep -nF '/64' "$netcfg" | cut -d: -f1 | head -n 1)
					linenumber2=$((linenumber1 + netconfcount))
#					echo -e "$linenumber1"
#					echo -e "$linenumber2"
          dipv6=$(sed -n "${linenumber1}p" "$netcfg")

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
	fi


	echo -e ""
#	echo -e "${YELLOW}Use offline bootstrap?${NC}"
#	echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
#	read bootstrapchoice

#	checkyesno $bootstrapchoice

  prompt_yes_no bootstrapchoice "${YELLOW}Use offline bootstrap?${NC}" || return 1

	if [[ $bootstrapchoice == no ]]
		then
			echo -e ""
#			echo -e "${YELLOW}Do you wish to download from the web (${CYAN}yes${YELLOW}) or full chain downlaod (${CYAN}no${YELLOW})${NC}"
#			echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
#			read chaindownload

#			checkyesno $chaindownload

      prompt_yes_no chaindownload "${YELLOW}Do you wish to download from the web (${CYAN}yes${YELLOW}) or full chain downlaod (${CYAN}no${YELLOW})${NC}" || return 1
		else
			chaindownload=0
	fi

  if [[ "$bypassipv6setup" == "no" && "$ipchoice" == "yes" ]]; then
      echo
      echo -e "${CYAN}Applying IP configuration${NC}"

      sed -i "${linenumber2}i\\${finalconfigipv6}" "$netcfg" || return 1
      netplan apply || return 1
  fi

	echo -e ""
	ufw allow ssh

	echo -e "${CYAN}Making sure your VPS is up to date before continuing install${NC}"
	apt update -y

	#setup user
	echo -e ""
	echo -e "${YELLOW}Setting up user ${CYAN}$alias${NC}"

  if ! adduser \
      --disabled-password \
      --gecos "" \
      "$alias"; then
      echo -e "${RED}Failed to create user $alias${NC}"
      return 1
  fi

  printf '%s:%s\n' "$alias" "$pass" | chpasswd || return 1
	echo -e ""
	echo -e "${CYAN}User ${CYAN}$alias${CYAN} setup${NC}"
	echo -e ""

	#Sleep/Delay check and install

	if [[ $sleepdelay == yes ]]
		then
			sleeprandomfilecheck $sleeprandomtimer
	fi

  local wrapper_file="/usr/local/bin/$alias"
  local service_file="/etc/systemd/system/${alias}.service"

	#Node binaries check and install if needed
	cd /usr/local/bin
	binfile=/usr/local/bin/${coinnamecli}
	if test -e "$binfile"
		then
			echo -e "${CYAN}Node binaries already downloaded and setup${NC}"
			echo -e ""

    else
      echo -e "${YELLOW}Installing node binaries for ${MAGENTA}$alias${NC}"

      local binary_archive="/usr/local/bin/${coinname}.zip"
      local binary_part="${binary_archive}.part"

      if ! wget -nv --show-progress "$binaries" -O "$binary_part"; then
          rm -f -- "$binary_part"
          echo -e "${RED}Binary download failed${NC}"
          return 1
      fi

      if ! mv -- "$binary_part" "$binary_archive"; then
          echo -e "${RED}Unable to finalize binary download${NC}"
          return 1
      fi
    
      if ! 7za t "$binary_archive" >/dev/null; then
          echo -e "${RED}Binary archive verification failed${NC}"
          return 1
      fi

      if ! 7za x "$binary_archive" -o/usr/local/bin; then
          echo -e "${RED}Binary extraction failed${NC}"
          return 1
      fi

      chmod +x "/usr/local/bin/$coinnamecli" "/usr/local/bin/$coinnamed" || return 1

      rm -f -- "$binary_archive"


			echo -e "${CYAN}$alias node binaries downloaded and installed${NC}"
			echo -e ""
	fi

	#Node intergration - creation of alias in /usr/local/bin for executing commands to users daemon
	echo -e "${YELLOW}Node Intergration${NC}"
  cat > "$wrapper_file" <<EOF
#!/bin/bash
exec /usr/local/bin/$coinnamecli \
    -conf=/home/$alias/.${coindir}/${coinname}.conf \
    -datadir=/home/$alias/.${coindir} \
    "\$@"
EOF
  chmod +x "/usr/local/bin/$alias" || return 1
	cd /etc/systemd/system
	echo -e "${CYAN}Node Intergration done${NC}"
	echo -e ""

	#Setup system service
	echo -e "${YELLOW}Setting up system service${NC}"
	echo -e "[Unit]" > $service_file
	echo -e "Description=$ticker service" >> $service_file
	echo -e "After=network.target" >> $service_file
	echo -e "" >> $service_file
	echo -e "[Service]" >> $service_file
	echo -e "User=$alias" >> $service_file
	echo -e "Group=root" >> $service_file
	echo -e "" >> $service_file
	echo -e "Type=forking" >> $service_file

	if [[ $sleepdelay == yes ]]
		then
			echo -e "ExecStartPre=/usr/local/bin/sleeprandom" >> $service_file
	fi

	echo -e "ExecStart=/usr/local/bin/$coinnamed -daemon -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir">> $service_file
	echo -e "ExecStop=-/usr/local/bin/$coinnamecli -conf=/home/$alias/.$coindir/$coinname.conf -datadir=/home/$alias/.$coindir stop" >> $service_file
	echo -e "" >> $service_file
	echo -e "Restart=always" >> $service_file
	echo -e "PrivateTmp=true" >> $service_file
	echo -e "TimeoutStopSec=6000s" >> $service_file
	echo -e "TimeoutStartSec=3000s" >> $service_file
	echo -e "StartLimitInterval=120s" >> $service_file
	echo -e "StartLimitBurst=5" >> $service_file
	echo -e "" >> $service_file
	echo -e "[Install]" >> $service_file
	echo -e "WantedBy=multi-user.target" >> $service_file
  systemctl daemon-reload || return 1
  systemctl enable "${alias}.service" || return 1
  echo -e "${CYAN}System service setup and enabled${NC}"


	#update/copy chain files or get snapshot# from web or fresh complete chain download
	echo

	mkdir -p "/home/$alias/.${coindir}" || return 1

  echo
 	echo -e "${YELLOW}Downloading and/or Unzipping chain files for ${MAGENTA}$alias${NC}"
	echo

	mkdir -p "/home/$alias/.${coindir}"
	chown "$alias:$alias" "/home/$alias/.${coindir}"

  local bootstrap_file="$HOME/${coinname}.zip"
  local bootstrap_part="${bootstrap_file}.part"

	if [[ "$bootstrapchoice" == yes ]] && [[ "$chaindownload" == 0 ]]
    then
			sccfile="$HOME/${coinname}.zip"
			if [[ -f "$sccfile" ]]; then
          if ! 7za x "$sccfile" -o"/home/$alias"; then
              echo -e "${RED}Bootstrap extraction failed${NC}"
              return 1
          fi

          echo -e "${YELLOW}${coinname} local chain directory updated${NC}"
    
          echo -e "${YELLOW}$coinname local bootstrap directory updated${NC}"
      else
					echo -e "${RED}File doesn't exist${NC}, ${YELLOW}downloading chain${NC}"

          if ! wget -nv --show-progress "$snapshot" -O "$bootstrap_part"; then
              rm -f -- "$bootstrap_part"
              echo -e "${RED}Bootstrap download failed${NC}"
              return 1
          fi

          mv -- "$bootstrap_part" "$bootstrap_file" || return 1

          if ! 7za t "$HOME/${coinname}.zip" >/dev/null; then
              echo -e "${RED}Bootstrap archive failed verification${NC}"
              return 1
          fi

          if ! 7za x "$HOME/${coinname}.zip" -o"/home/$alias"; then
              echo -e "${RED}Bootstrap extraction failed${NC}"
              return 1
          fi

					echo -e "${YELLOW}$coinname chain directory updated${NC}"
			fi
		else
			if [[ $chaindownload == yes ]]
				then

          if ! wget -nv --show-progress "$snapshot" -O "$bootstrap_part"; then
              rm -f -- "$bootstrap_part"
              echo -e "${RED}Bootstrap download failed${NC}"
              return 1
          fi

          if ! mv -- "$bootstrap_part" "$bootstrap_file"; then
              echo -e "${RED}Unable to finalize bootstrap download${NC}"
              return 1
          fi

          if ! 7za t "$bootstrap_file" >/dev/null; then
              echo -e "${RED}Bootstrap archive failed verification${NC}"
              return 1
          fi

          if ! 7za x "$HOME/${coinname}.zip" -o"/home/$alias"; then
              echo -e "${RED}Bootstrap extraction failed${NC}"
              return 1
          fi

					echo -e "${YELLOW}$coinname chain directory setup${NC}"
			fi
	fi

	echo -e ""

	#make conf file
	echo -e ""
	echo -e "${YELLOW}Creating $coinname conf file${NC}"

  local conf_file="/home/$alias/.${coindir}/${coinname}.conf"

  cat > "$conf_file" <<EOF
rpcuser=$rpcuser
rpcpassword=$rpcpass
rpcport=$rpcport
rpcallowip=127.0.0.1
port=$port
listen=1
server=1
daemon=0
txindex=1
maxconnections=125
EOF

	#IPv6 check and edit
  if [[ "$ipchoice" == "yes" ]]; then
      if [[ "$bypassipv6setup" != "yes" ]]; then
          ipadd="$ipv6conf"
      fi

      {
          echo "bind=[$ipadd]"
          echo "externalip=[$ipadd]:$port"
      } >> "$conf_file"
  else
      {
          echo "bind=$ipadd"
          echo "externalip=$ipadd:$port"
      } >> "$conf_file"
  fi

  {
      echo "masternodeblsprivkey=$blskey"
      echo "addnode=173.249.9.78"
      echo "addnode=173.249.9.77"
  } >> "$conf_file"

	echo -e "${CYAN}$coinname conf file created${NC}"
	echo

	#Set permisions and firewall rules
	echo -e "${YELLOW}Setting permissions and firewall rules${NC}"
	cd "/home/$alias"
	chown -R -- "$alias:$alias" "/home/$alias" || return 1
  ufw allow "$port/tcp" comment "$alias port"
  ufw allow from 127.0.0.1 to any port "$rpcport" proto tcp \
      comment "$alias RPC port"
  echo -e "${YELLOW}Permissions and firewall rules set${NC}"
	echo
	echo -e "${YELLOW}Starting Node${NC}"

	systemctl start --no-block "$alias"

	echo
	echo -e "${YELLOW}Please wait a moment and then read the following information${NC}"
	displaypause 15
	echo
	echo -e "${CYAN}$ticker${YELLOW} MN setup completed${NC}"
	echo

	#Closeing/finish text
	echo -e "${UNDERLINE}Masternode setup complete for ${CYAN}$alias${NC}"
	echo
	echo -e "Alias name = $alias"
	echo -e "IP/Bind = $ipadd"
	echo -e "Port = $port"
	echo -e "rpcport = $rpcport"
	echo -e "BLS secret key = $blskey"
	echo -e "alias password = $pass"
	echo
	echo -e "${YELLOW}Please note that if you are installing multiple MNs you will need to setup swap space${NC}"
	echo -e "${YELLOW}Please wait for sync and then use ${CYAN}$alias -getinfo${NC} or ${CYAN}$alias masternode status ${YELLOW}to check on the node${NC}"
	echo
	echo
	echo -e "For more information or support please visit the ${CYAN}$ticker${NC} Discord server"
	echo -e "Support is provided via email: ${MAGENTA}${UNDERLINE}support@stakecube.zohodesk.com${NC}"
	echo
	echo -e "${CYAN}$discord${NC}"
	echo

}

function ipv6_setup() {

    # Enable IPv6
    displaypause 2
    sed -i "/net.ipv6.conf.all.disable_ipv6.*/d" /etc/sysctl.conf
    sysctl -q -p

    local netcfg="/etc/netplan/50-cloud-init.yaml"
    local netcfg2="/etc/netplan/01-netcfg.yaml"
    local cloudinit="/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
    local filefixed=0

    # Check if the primary netplan config exists
    if [[ -f "$netcfg" ]]; then
        echo -e "${CYAN}Determined Auto Configuration in place.${NC}"
        prompt_yes_no autoconfigchoice "${CYAN}Do you wish to disable auto and setup static network configuration?${NC}" || return 1

        if [[ "$autoconfigchoice" == "yes" ]]; then
            if ! mv -- "$netcfg" "$netcfg2"; then
                echo -e "${RED}Failed to move netplan configuration${NC}"
                return 1
            fi

            netcfg="$netcfg2"
            filefixed=1

            if [[ -f "$cloudinit" ]]; then
                netdone=0
            else
                echo "network: {config: disabled}" > "$cloudinit"
            fi
        else
            echo -e "${RED}Aborting due to configuration error.${NC}"
            return 1
        fi
    fi

    checknetcfgfile || return 1

    # Enable IPv6
    echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6

    # If config wasn't fixed, clean up the netplan file
    if [[ "$filefixed" -eq 0 ]]; then
        sed -i 's/^#//' "$netcfg"
        sed -i '/^$/d' "$netcfg"
    fi

    # Regenerate and apply netplan configuration
    netplan generate
    netplan apply
    displaypause 5
}

# --------------------------------------------------------------
# 3)  Wallet update tool for ALL ${ticker} nodes
# --------------------------------------------------------------
function wallet_update_all() {
    echo -e "${YELLOW}Starting Wallet update tool for ${CYAN}All ${ticker}${YELLOW} nodes${NC}"
    echo

    local binary_archive="/usr/local/bin/${coinname}.zip"
    local binary_part="${binary_archive}.part"

    pushd /usr/local/bin >/dev/null || return 1

    if ! wget -nv --show-progress "$binaries" -O "$binary_part"; then
        rm -f -- "$binary_part"
        echo -e "${RED}Binary download failed; existing binaries were not changed${NC}"
        popd >/dev/null
        return 1
    fi

    if ! mv -- "$binary_part" "$binary_archive"; then
        echo -e "${RED}Unable to finalize binary download${NC}"
        popd >/dev/null
        return 1
    fi

    if ! 7za t "$binary_archive" >/dev/null; then
        echo -e "${RED}Binary archive verification failed; existing binaries were not changed${NC}"
        popd >/dev/null
        return 1
    fi

    local temp_dir

    if ! temp_dir=$(mktemp -d); then
        popd >/dev/null
        return 1
    fi

    if ! 7za x -y "$binary_archive" -o"$temp_dir"; then
        rm -rf -- "$temp_dir"
        popd >/dev/null
        return 1
    fi

    if [[ ! -f "$temp_dir/$coinnamecli" ||
          ! -f "$temp_dir/$coinnamed" ]]; then
        echo -e "${RED}Expected binaries are missing from the archive${NC}"
        rm -rf -- "$temp_dir"
        popd >/dev/null
        return 1
    fi

    if ! install -m 0755 \
        "$temp_dir/$coinnamecli" \
        "/usr/local/bin/$coinnamecli"; then
        rm -rf -- "$temp_dir"
        popd >/dev/null
        return 1
    fi

    if ! install -m 0755 \
        "$temp_dir/$coinnamed" \
        "/usr/local/bin/$coinnamed"; then
        rm -rf -- "$temp_dir"
        popd >/dev/null
        return 1
    fi

    rm -rf -- "$temp_dir"
    rm -f -- "$binary_archive"
    popd >/dev/null

    # optional pause so the user can see the result of the extraction
    displaypause 15

    # ----- Ask for the restart delay ------------------------------------------------
    echo -e "How long between node (re)starts in seconds?"
    echo -e "Blank/Empty equals 120 seconds"
    read -r secondsdelay

    # If the user entered a non‑empty value, honour it – otherwise keep the default 120
    if [[ -n "$secondsdelay" ]]; then
        sleeptimerinsec=$secondsdelay
    else
        sleeptimerinsec=120
    fi

    # ----- Walk through every home directory ----------------------------------------
    echo
    echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN's${NC}"

    local foundone=0

    for dir in /home/*; do
        local i
        i=$(basename "$dir")

        [[ "$i" == *scc* ]] || continue

        foundone=1

        echo -e "${YELLOW}found ${CYAN}$i${NC}..."
        echo

        echo
        echo -e "${YELLOW}Restarting ${CYAN}$i${YELLOW}...${NC}"

        systemctl stop "$i" || {
            echo -e "${RED}Failed to stop $i${NC}"
            continue
        }

        displaypause 3

        systemctl start --no-block "$i" || {
            echo -e "${RED}Failed to start $i${NC}"
            continue
        }

        displaypause "$sleeptimerinsec"
    done

    if [[ "$foundone" -eq 0 ]]; then
        echo -e "${CYAN}No ${ticker} nodes found to update${NC}"
    fi

    echo -e "${CYAN}Wallet update tool finished${NC}"
    return 0
}

# --------------------------------------------------------------
#  setup_swap – create, resize or delete the system swapfile
# --------------------------------------------------------------
#  $1  = desired size in megabytes (0 → delete the swapfile)
# --------------------------------------------------------------
function setup_swap() {
    # -----------------------------------------------------------------
    # Validate that the caller supplied a numeric argument
    # -----------------------------------------------------------------
    echo
    if [[ -z "$1" || ! $(is_number "$1") ]]; then
        echo -e "${YELLOW}<size_in_mbytes>${NC} must be a number"
        return 1
    fi

    local requested_mb=$1
    local avail_mb total_mb swapfile="/var/swapfile"
    local fstab_line="/var/swapfile none swap 0 0"

    # -----------------------------------------------------------------
    # How much free space do we have on the root filesystem?
    # -----------------------------------------------------------------
    avail_mb=$(df / --output=avail -m | tail -n1 | tr -d ' ')
    total_mb=$(df / --output=size -m | tail -n1 | tr -d ' ')

    if (( requested_mb >= avail_mb )); then
        echo -e "There's only $avail_mb MB available on the disk"
        return 1
    fi

    # -----------------------------------------------------------------
    # If a swapfile already exists, turn it off first (quietly)
    # -----------------------------------------------------------------
    if [[ -f "$swapfile" ]]; then
        swapoff "$swapfile" &>/dev/null
    fi

    # -----------------------------------------------------------------
    # Delete the swapfile (size = 0)
    # -----------------------------------------------------------------
    if (( requested_mb == 0 )); then
        rm -f "$swapfile"
        # Remove any stray entry from /etc/fstab
        sed -i "\|${swapfile}|d" /etc/fstab
        echo -e "Swapfile deleted"
        return 0
    fi

    # -----------------------------------------------------------------
    # Create / resize the swapfile
    # -----------------------------------------------------------------
    echo -e "Generating swapfile, this may take some time depending on the size..."
    echo -e "$((requested_mb * 1024 * 1024)) bytes swapfile"

    # Remove any old file that might be left over
    rm -f "$swapfile"

    # Prefer fallocate (fast) – fall back to dd if it fails
    if ! fallocate -l "${requested_mb}M" "$swapfile" 2>/dev/null; then
        echo -e "${YELLOW}fallocate failed, falling back to dd (slower)…${NC}"
        dd if=/dev/zero of="$swapfile" bs=1M count="$requested_mb" status=progress
    fi

    chmod 600 "$swapfile"
    mkswap "$swapfile" &>/dev/null
    swapon "$swapfile" &>/dev/null

    # -----------------------------------------------------------------
    # Ensure the swapfile is listed in /etc/fstab
    # -----------------------------------------------------------------
    if ! grep -qF "$swapfile" /etc/fstab; then
        echo "$fstab_line" >> /etc/fstab
    fi

    echo
    echo -e "${YELLOW}Swapfile new size = ${GREEN}${requested_mb} MB${NC}"
    echo
    echo -e "Use ${YELLOW}swapon -s${NC} to see the changes of your swapfile and ${YELLOW}free -m${NC} to see the total available memory"
}

# --------------------------------------------------------------
#  offlinechainfilebuild – create a zip‑based “offline bootstrap”
# --------------------------------------------------------------
function offlinechainfilebuild() {
    local alias

    echo -e "${YELLOW}Beginning creation of offline bootstrap file${NC}"
    echo

    # -----------------------------------------------------------------
    #  Show the list of possible masternode accounts (debug output)
    # -----------------------------------------------------------------
    prompt_for_alias alias || return 1

    echo
    echo -e "${YELLOW}Stopping node ${CYAN}$alias${NC}"
    echo

    # Stop the systemd service (quote to protect special characters)
    if ! systemctl stop "${alias}.service"; then
        echo -e "${RED}Failed to stop ${CYAN}$alias${NC}"
        return 1
    fi
    displaypause 5

    echo -e "${YELLOW}Starting the zip process${NC}"

    # -----------------------------------------------------------------
    #  Define where the zip will live (in the invoking user’s home)
    # -----------------------------------------------------------------
    local zipdir="/home/$alias"
    local zipfile="${HOME}/stakecubecoin.zip"
    local ziptemp="${zipfile}.part"

    # Remove any old zip that might exist – silent if it does not
    rm -f -- "$ziptemp"

    # -----------------------------------------------------------------
    #  Build the archive
    # -----------------------------------------------------------------
    #   -tzip       → zip archive
    #   -r         → recurse into sub‑directories
    #   -xr!PAT    → exclude pattern (wallet.dat, *.conf, debug.log)
    #   .scc/*     → include everything under the .scc directory
    #   The leading “--” tells 7za that everything that follows is a file name,
    #   not another option (helps when the path starts with a “‑”).
    # -----------------------------------------------------------------
    local archive_status=0

    if ! pushd "$zipdir" >/dev/null; then
        echo -e "${RED}Failed to cd to $zipdir${NC}"
        systemctl start --no-block "${alias}.service"
        return 1
    fi

    if command -v 7za >/dev/null 2>&1; then
        7za a -tzip -r \
            '-xr!wallet.dat' \
            '-xr!*.conf' \
            '-xr!debug.log' \
            -- "$ziptemp" .scc/* ||
            archive_status=$?
    else
        zip -r "$ziptemp" .scc/* \
            -x '*.conf' \
            -x 'debug.log' \
            -x 'wallet.dat' ||
            archive_status=$?
    fi

    popd >/dev/null

    if (( archive_status == 0 )); then
        if ! 7za t "$ziptemp" >/dev/null; then
            echo -e "${RED}New bootstrap archive failed verification${NC}"
            archive_status=1
        elif ! mv -- "$ziptemp" "$zipfile"; then
            echo -e "${RED}Failed to install new bootstrap archive${NC}"
            archive_status=1
        fi
    fi

    echo
    echo -e "${YELLOW}Starting ${CYAN}$alias${NC}"

    # Restart the node (no‑block so the script continues immediately)
    if ! systemctl start --no-block "${alias}.service"; then
        echo -e "${RED}Failed to restart ${CYAN}$alias${NC}"
        return 1
    fi

    if (( archive_status != 0 )); then
        rm -f -- "$ziptemp"
        echo
        echo -e "${RED}Offline bootstrap creation failed${NC}"
        return "$archive_status"
    fi

    echo
    echo -e "${YELLOW}Done creating offline bootstrap file${NC}"

    # The function ends here – callers can check `$?` if they need a status
    return 0
}

# --------------------------------------------------------------
#  mn_uninstall – Interactive removal of a single masternode
# --------------------------------------------------------------
function mn_uninstall() {
    echo
    echo -e "${YELLOW}Checking home directory for MN alias's${NC}"
    # Show the list of accounts – useful for the operator to pick the right one
    ls /home
    echo
    echo -e "${YELLOW}Above are the alias names for installed MN's${NC}"
    echo -e "${CYAN}Please enter MN alias name${NC}"
    echo
    read -r alias

    # ---------------------------------------------------------
    # Verify the alias points to a valid node configuration
    # ---------------------------------------------------------
    checkaliasvalidity "$alias" require_existing || return 1

    # ---------------------------------------------------------
    # Stop, disable and delete the system‑d service
    # ---------------------------------------------------------
    echo
    echo -e "${YELLOW}Stopping ${MAGENTA}$alias${NC}"
    systemctl stop "$alias"

    echo
    echo -e "${YELLOW}Pausing script to ensure ${MAGENTA}$alias${YELLOW} has stopped${NC}"
    displaypause 20

    echo -e "${YELLOW}Disabling $alias service${NC}"
    systemctl disable "$alias"

    # ---------------------------------------------------------
    # Clean up binaries, service file, user, and home dir
    # ---------------------------------------------------------
    echo -e "${YELLOW}Removing binary, service file, user and home directory${NC}"
    rm -f "/usr/local/bin/$alias"
    rm -f "/etc/systemd/system/${alias}.service"

    systemctl daemon-reload || {
        echo -e "${RED}Warning: systemd daemon reload failed${NC}"
    }

    # `deluser` may not exist on every distro; fall back to `userdel` if needed.
    if command -v deluser >/dev/null 2>&1; then
        deluser "$alias"
    else
        userdel -r "$alias" 2>/dev/null || true
    fi

    # Remove the home directory (in case `deluser` didn’t wipe it)
    rm -rf "/home/$alias"

    echo
    echo -e "${CYAN}$alias removed${NC}"
}

# --------------------------------------------------------------
#  Multiple‑node uninstall tool
# --------------------------------------------------------------
function uninstall_multiple_nodes() {
    echo -e "${YELLOW}Beginning Multiple Nodes Uninstall Tool${NC}"
    echo
    echo -e "${YELLOW}Press ${CYAN}Control‑C${YELLOW} to abort at alias selection to quit${NC}"
    echo

    local found_any=0

    # Walk through every home directory – avoid the "ls | $(…)" anti‑pattern
    for dir in /home/*; do
        local i=$(basename "$dir")

        # Only act on accounts that contain “scc” (your masternode accounts)
        if [[ $i == *scc* ]]; then
            found_any=1
            # The original script just called mn_uninstall; keep that behavior.
            # If mn_uninstall expects the alias as an argument, pass it here:
            #   mn_uninstall "$i"
            mn_uninstall
        fi
    done

    # If no matching accounts were found, let the user know.
    if [[ $found_any -eq 0 ]]; then
        echo -e "${CYAN}Found no SCC node nodes${NC}"
        echo
    fi

    return 0
}

# --------------------------------------------------------------
# 4)  Stop/Start/Restart tool for ALL ${ticker} nodes
# --------------------------------------------------------------
function node_control_tool() {
    echo -e "Starting stop/start tool..."
    echo -e "Please enter ${CYAN}stop${NC} to stop all ${ticker} nodes"
    echo -e "Please enter ${CYAN}start${NC} to start all ${ticker} nodes"
    echo -e "Please enter ${CYAN}restart${NC} to restart all ${ticker} nodes"
    read -r stopstart
    echo

    # Validate the command
    case "$stopstart" in
        stop|start|restart) ;;
        *) echo -e "${RED}Invalid entry${NC}"; return 1 ;;
    esac

    # If we are going to start or restart, ask for the inter‑restart delay
    if [[ $stopstart == restart || $stopstart == start ]]; then
        echo -e "How long between node (re)starts in seconds?"
        echo -e "Blank/Empty equals 120 seconds"
        read -r secondsdelay
        if [[ -n "$secondsdelay" ]]; then
            sleeptimerinsec=$secondsdelay
        else
            sleeptimerinsec=120
        fi
    fi

    echo -e "Starting ${CYAN}$stopstart${NC} tool"

    # -----------------------------------------------------------------
    # Walk through each home directory and act on SCC nodes
    # -----------------------------------------------------------------
    for dir in /home/*; do
        local i=$(basename "$dir")
        echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN's"
        echo -e "${YELLOW}found ${CYAN}$i${YELLOW}...${NC}"

        if [[ $i != *scc* ]]; then
            echo -e "${CYAN}${ticker}${NC} node not found"
            continue
        fi

        echo -e "${MAGENTA}${stopstart}ing ${CYAN}$i${MAGENTA}..${NC}"

        if [[ $stopstart == restart ]]; then
            systemctl stop "$i"
            displaypause 5
            systemctl start --no-block "$i"
        else
            # For both "stop" and "start" we can use the same command pattern
            systemctl "$stopstart" --no-block "$i"
        fi

        # Pause logic – a longer pause after a **stop** (to let the daemon shut down)
        if [[ $stopstart == stop ]]; then
            echo -e "${YELLOW}Pausing for 10 seconds${NC}"
            displaypause 10
            echo
        else
            echo -e "Pausing for $sleeptimerinsec seconds to let ${CYAN}$i${NC} settle"
            displaypause "$sleeptimerinsec"
            echo
        fi
    done

    echo -e "Wallet tool finished"
    return 0
}

# --------------------------------------------------------------
#  check_status_nodes – runs the “masternode status” checks
# --------------------------------------------------------------
function check_status_nodes() {
    echo -e "Beginning Status Checks of Nodes"

    # -----------------------------------------------------------------
    # Local state variables (kept as booleans/flags)
    # -----------------------------------------------------------------
    local foundone=0
    local updatechainfile=false     # ask once if we should update the chain file
    local offlinerepairall=false    # ask once if we want offline‑bootstrap for all repairs
    local updateallnodes=false      # ask once if we want to auto‑repair every node
    local bootstrap_file="$HOME/${coinname}.zip"
    local bootstrap_part="${bootstrap_file}.part"

    echo -e ""
    echo -e "${YELLOW}Checking for $ticker MN's${NC}"
    echo -e ""

    # -----------------------------------------------------------------
    # Iterate over every home directory that looks like an SCC node
    # -----------------------------------------------------------------
    for homedir in /home/*; do
        local i=$(basename "$homedir")          # strip the path, keep only the user name
        [[ $i != *scc* ]] && continue           # skip non‑SCC directories

        foundone=1
        echo -e "found ${CYAN}$i${NC}..."

        # -------------------------------------------------------------
        # Verify the daemon process is running; try to start it if not
        # -------------------------------------------------------------
        local mn_status mn_status_exitcode
        if ! checkprocess "$i"; then
            echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$i${YELLOW} node not found${NC}"

            checkifstart "$i" || return 1

            echo -e "${YELLOW}Skipping health check until the node finishes starting${NC}"
            echo
            continue
        fi

        mn_status=$("$i" masternode status)   # $i must be the CLI binary name
        mn_status_exitcode=$?

        # -------------------------------------------------------------
        # Show the relevant bits of the status output (debug)
        # -------------------------------------------------------------
        # echo -e "Full status dump:"   # <‑‑ uncomment for full dump
        # echo "$mn_status"
        grep -E '(state|status)' <<< "$mn_status"
        echo -e ""

        # -------------------------------------------------------------
        # Look for obvious error strings
        # -------------------------------------------------------------
        if grep -iq 'BANNED\|ERROR' <<< "$mn_status"; then
            mn_status_exitcode=1
        fi

        # -------------------------------------------------------------
        # Healthy node → skip the rest of the loop
        # -------------------------------------------------------------
        if [[ $mn_status_exitcode -eq 0 ]]; then
            echo -e "${YELLOW}Appears to be in good shape${NC}"
            echo -e ""
            continue
        fi

        # -------------------------------------------------------------
        # Node appears broken – ask the user if they want a repair
        # -------------------------------------------------------------
        echo -e "${RED}Something appears to be wrong with node ${CYAN}$i${NC}"
        echo -e ""
        local repairnode
        prompt_yes_no repairnode "${YELLOW}Do you wish to initiate repair of this node${NC}" || return 1
        if [[ $repairnode != "yes" ]]; then
            echo -e "${YELLOW}Skipping repair${NC}"
            echo -e ""
            continue
        fi

        # -----------------------------------------------------------------
        # Chain‑file update (asked only once per run)
        # -----------------------------------------------------------------
        if [[ $updatechainfile == false ]]; then
            prompt_yes_no updatechainfile "${YELLOW}Do you wish to update the offline chain file first?${NC}" || return 1
            if [[ $updatechainfile == "yes" ]]; then
                local updatechainfilelocal
								echo -e "${YELLOW}Update from local node or from the web?${NC}"
                prompt_yes_no updatechainfilelocal "${CYAN}Yes ${YELLOW}for local copy or ${CYAN}No ${YELLOW}for Web download${NC}" || return 1
                if [[ $updatechainfilelocal == "yes" ]]; then
                    offlinechainfilebuild
                else
                    echo -e "${CYAN}Downloading updated bootstrap...${NC}"
                    cd $HOME

                    if ! wget -nv --show-progress "$snapshot" -O "$bootstrap_part"; then
                        rm -f -- "$bootstrap_part"
                        echo -e "${RED}Bootstrap download failed${NC}"
                        return 1
                    fi

                    mv -- "$bootstrap_part" "$bootstrap_file" || return 1

                    echo -e ""
                fi
            fi
        fi

        # -----------------------------------------------------------------
        # Decide once whether to use offline bootstrap for *all* repairs
        # -----------------------------------------------------------------
        if [[ $offlinerepairall == false ]]; then
            prompt_yes_no offlinerepairall "${YELLOW}Do you wish to use offline bootstrap for all repairs?${NC}" || return 1
        fi

        # -----------------------------------------------------------------
        # Decide once whether to auto‑repair *all* nodes
        # -----------------------------------------------------------------
        if [[ $updateallnodes == false ]]; then
            prompt_yes_no updateallnodes "${YELLOW}Do you wish to repair all nodes automatically?${NC}" || return 1
        fi

        # -----------------------------------------------------------------
        # Perform the actual repair
        # -----------------------------------------------------------------
        if [[ $offlinerepairall == "yes" ]]; then
            chain_repair "$i" "yes" "$updateallnodes" || return 1
        else
            chain_repair "$i" "no" "$updateallnodes" || return 1
        fi

        echo -e ""
    done

    # -----------------------------------------------------------------
    # No nodes found at all?
    # -----------------------------------------------------------------
    if [[ $foundone -eq 0 ]]; then
        echo -e "${CYAN}Found no $ticker nodes${NC}"
    fi
}


# Call the function (if this is your script's context)
# explorer_compare


# --------------------------------------------------------------
# 13) Explorer comparison tool
# --------------------------------------------------------------
function explorer_compare() {
    local foundone=0
    local currentblock
    local upperlimit lowerlimit
    local i

    # -----------------------------------------------------------------
    # Get the current block height from the explorer API.
    # -----------------------------------------------------------------
    if ! currentblock=$(
        curl -fsS --connect-timeout 10 --max-time 30 \
            https://www.coinexplorer.net/api/v1/SCC/getblockcount
    ); then
        echo -e "${RED}Failed to contact explorer API${NC}"
        return 1
    fi

    currentblock="${currentblock//$'\r'/}"
    currentblock="${currentblock//$'\n'/}"

    if [[ ! "$currentblock" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Explorer returned an invalid block height: $currentblock${NC}"
        return 1
    fi

    upperlimit=$((currentblock + 5))
    lowerlimit=$((currentblock - 5))

    echo -e ""
    echo -e "${YELLOW}Explorer Block Height: ${CYAN}$currentblock${NC}"
    echo -e "${YELLOW}Lower Block Height:  ${CYAN}$lowerlimit${NC}"
    echo -e "${YELLOW}Upper Block Height:  ${CYAN}$upperlimit${NC}"
    echo -e ""

    # -----------------------------------------------------------------
    # Loop over each home directory that looks like an SCC node.
    # -----------------------------------------------------------------
    for i in /home/*; do
        i=$(basename "$i")                 # strip the path, keep just the user name
        [[ $i != *scc* ]] && continue     # skip non‑SCC directories

        echo -e "${YELLOW}Checking for $ticker MN's${NC}"
        echo -e "found ${CYAN}$i${NC}..."
        # echo -e ""                     # <‑‑ uncomment for extra spacing if desired

        foundone=1
        local nodeblock=0

        # -----------------------------------------------------------------
        # Verify the daemon process is running; try to start it if not.
        # -----------------------------------------------------------------
        if ! checkprocess "$i"; then
            echo -e "${RED}Process for ${CYAN}$i${RED} not found${NC}"
            checkifstart "$i" || return 1
            echo -e "${YELLOW}Skipping block comparison until the node finishes starting${NC}"
            echo
            continue
        fi

        # -----------------------------------------------------------------
        # Compare node block height with explorer height.
        # -----------------------------------------------------------------
        local alias_command="/usr/local/bin/$i"

        if [[ ! -x "$alias_command" ]]; then
            echo -e "${RED}Alias command not found: $alias_command${NC}"
            continue
        fi

        if ! nodeblock=$("$alias_command" getblockcount); then
            echo -e "${RED}Unable to obtain block count from $i${NC}"
            continue
        fi

        nodeblock="${nodeblock//$'\r'/}"
        nodeblock="${nodeblock//$'\n'/}"

        if [[ ! "$nodeblock" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid block count returned by $i: $nodeblock${NC}"
            continue
        fi
        if [[ $currentblock -eq $nodeblock ]]; then
            echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock  ${CYAN}Same as explorer${NC}"
        elif (( nodeblock <= upperlimit && nodeblock >= lowerlimit )); then
            echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock  ${YELLOW}Different block count from explorer within variance${NC}"
        else
            echo -e "${CYAN}$i ${NC}sccnode: $nodeblock   explorer: $currentblock  ${RED}Different block count from explorer${NC}"
        fi

        echo -e ""
    done

    # -----------------------------------------------------------------
    # If we never found an SCC node, let the user know.
    # -----------------------------------------------------------------
    if [[ $foundone -eq 0 ]]; then
        echo -e "${CYAN}Found no $ticker nodes${NC}"
    fi
}

explorer_compare_and_repair() {

    # ------------------------------------------------------------------
    # State variables — all local to avoid polluting parent scope
    # ------------------------------------------------------------------
    local foundone=0
    local updatechainfile="no"
    local updatechainfilelocal="no"
    local offlinerepairall="unset"
    local updateallnodes="no"
    local blockcompare
    local currentblock
    local upperlimit lowerlimit
    local nodeblock blockdiff
    local repairnode

    echo -e "${CYAN}Beginning Explorer comparison tool with optional repair${NC}"
    echo

    # ------------------------------------------------------------------
    # 1. Fetch explorer block height
    # ------------------------------------------------------------------
    if ! currentblock=$(
        curl -fsS --connect-timeout 10 --max-time 30 \
            https://www.coinexplorer.net/api/v1/SCC/getblockcount
    ); then
        echo -e "${RED}Failed to contact explorer API${NC}"
        return 1
    fi

    currentblock="${currentblock//$'\r'/}"
    currentblock="${currentblock//$'\n'/}"

    if [[ ! "$currentblock" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Explorer returned an invalid block height: $currentblock${NC}"
        return 1
    fi

    upperlimit=$((currentblock + 5))
    lowerlimit=$((currentblock - 5))
 
    echo -e "${YELLOW}Explorer Block Height: ${CYAN}${currentblock}${NC}"
    echo -e "${YELLOW}Lower Block Height:    ${CYAN}${lowerlimit}${NC}"
    echo -e "${YELLOW}Upper Block Height:    ${CYAN}${upperlimit}${NC}"
    echo

    # ------------------------------------------------------------------
    # 2. Ask how many blocks difference triggers a repair
    # ------------------------------------------------------------------
    echo -e "${YELLOW}How many blocks difference should trigger a repair? (enter a number)${NC}"
    read -r blockcompare
    blockcompare=$(printf '%s' "$blockcompare" | xargs)

    if [[ ! "$blockcompare" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid number '${blockcompare}' — aborting${NC}"
        return 1
    fi
    echo

    # ------------------------------------------------------------------
    # 3. Walk home directories — avoid parsing ls
    # ------------------------------------------------------------------
    for homedir in /home/*/; do

        i=$(basename "$homedir")

        # Only process entries matching the coin ticker
        [[ "$i" != *scc* ]] && continue

        echo -e "${YELLOW}Checking ${CYAN}${i}${YELLOW} ...${NC}"
        foundone=1

        # --------------------------------------------------------------
        # 3a. Query node block height
        # --------------------------------------------------------------
        local alias_command="/usr/local/bin/$i"

        if [[ ! -x "$alias_command" ]]; then
            echo -e "${RED}Alias command not found: $alias_command${NC}"
            continue
        fi

        if ! nodeblock=$("$alias_command" getblockcount); then
            echo -e "${RED}Unable to obtain block count from $i${NC}"
            continue
        fi

        nodeblock="${nodeblock//$'\r'/}"
        nodeblock="${nodeblock//$'\n'/}"

        if [[ ! "$nodeblock" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid block count returned by $i: $nodeblock${NC}"
            continue
        fi

        blockdiff=$(( currentblock - nodeblock ))
        # Ensure positive difference for comparison
        (( blockdiff < 0 )) && blockdiff=$(( -blockdiff ))

        if [[ "$currentblock" -eq "$nodeblock" ]]; then
            echo -e "${CYAN}${i}${NC} node: ${nodeblock}   explorer: ${currentblock}   ${CYAN}In sync${NC}"
            echo
            continue    # nothing to do for this node
        fi

        if [[ "$blockdiff" -le "$blockcompare" ]]; then
            echo -e "${CYAN}${i}${NC} node: ${nodeblock}   explorer: ${currentblock}   ${YELLOW}Within ${blockcompare}-block tolerance — skipping${NC}"
            echo
            continue
        fi

        # Block diff exceeds tolerance — fall through to repair logic
        echo -e "${CYAN}${i}${NC} node: ${nodeblock}   explorer: ${currentblock}   ${RED}Out of sync by ${blockdiff} blocks${NC}"
        echo


        # --------------------------------------------------------------
        # 3b. One-time: offer to refresh the offline bootstrap file
        #     (only asked once across all nodes)
        # --------------------------------------------------------------
        if [[ "$updatechainfile" == "no" ]]; then
            prompt_yes_no updatechainfile "${YELLOW}Refresh the offline bootstrap file before repairing?${NC}" || return 1

            if [[ "$updatechainfile" == "yes" ]]; then
                prompt_yes_no updatechainfilelocal "${YELLOW}Build from local node (${CYAN}yes${YELLOW}) or download from web (${CYAN}no${YELLOW})?${NC}" || return 1

                if [[ "$updatechainfilelocal" == "yes" ]]; then
                    offlinechainfilebuild || return 1
                else
                    echo -e "${CYAN}Downloading bootstrap...${NC}"
                    wget --no-verbose --show-progress "${snapshot}" \
                         -O "/root/${coinname}.zip" \
                         || { echo -e "${RED}Download failed${NC}"; return 1; }
                fi
                echo
            fi
        fi

        # --------------------------------------------------------------
        # 3c. One-time: ask whether to use offline bootstrap for ALL repairs
        # --------------------------------------------------------------
        if [[ "$offlinerepairall" == "unset" ]]; then
            prompt_yes_no offlinerepairall "${YELLOW}Use offline bootstrap for all repairs?${NC}" || return 1
            echo
        fi

        # --------------------------------------------------------------
        # 3d. Per-node: ask whether to repair this node
        #     (skipped if user already said repair all)
        # --------------------------------------------------------------
        if [[ "$updateallnodes" != "yes" ]]; then
            prompt_yes_no repairnode "${YELLOW}Chain repair ${CYAN}${i}${YELLOW}?${NC}" || return 1
    	      echo

            if [[ "$repairnode" == "yes" ]]; then
                prompt_yes_no updateallnodes "${YELLOW}Repair ALL out-of-sync nodes without asking again?${NC}" || return 1
                echo
            fi
        else
            repairnode="yes"
        fi

        # --------------------------------------------------------------
        # 3e. Execute repair (or skip)
        # --------------------------------------------------------------
        if [[ "$repairnode" == "yes" ]]; then
            if [[ "$offlinerepairall" == "yes" ]]; then
                chain_repair "$i" "yes" "$updateallnodes" || return 1
            else
                chain_repair "$i" "no" "$updateallnodes" || return 1
            fi
        else
            echo -e "${YELLOW}Skipping repair for ${CYAN}${i}${NC}"
        fi

        echo

    done   # end of home directory loop

    # ------------------------------------------------------------------
    # 4. Summary
    # ------------------------------------------------------------------
    if [[ $foundone -eq 0 ]]; then
        echo -e "${CYAN}No ${ticker} nodes found in /home${NC}"
    fi
}

update_sleep_delay_services() {
    local foundone=0
    local updated=0
    local servicefile

    echo -e "${YELLOW}Beginning Optional Sleep delay install/update tool${NC}"

    sleeprandomfilecheck "$sleeprandomtimer"

    echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN service files${NC}"
    echo

    shopt -s nullglob
    for servicefile in /etc/systemd/system/*scc*.service; do
        foundone=1

        echo -e "${YELLOW}Found ${CYAN}$(basename "$servicefile")${YELLOW}...${NC}"
        echo
        echo -e "${CYAN}Checking file ${MAGENTA}$(basename "$servicefile")${NC}"

        if grep -Fxq 'ExecStartPre=/usr/local/bin/sleeprandom' "$servicefile"; then
            echo -e "${CYAN}Already updated${NC}"
        else
            sed -i \
                -e '/^ExecStart=.*/i ExecStartPre=/usr/local/bin/sleeprandom' \
                -e 's/^TimeoutStartSec=.*/TimeoutStartSec=3000s/' \
                "$servicefile"

            echo -e "${CYAN}Updated ${MAGENTA}$(basename "$servicefile")${NC}"
            echo
            updated=1
        fi

        echo
    done
    shopt -u nullglob

    if [[ $foundone -eq 0 ]]; then
        echo -e "${CYAN}Found no SCC nodes${NC}"
        return 0
    fi

    if [[ $updated -eq 1 ]]; then
        echo -e "${YELLOW}Reloading systemd daemon files${NC}"
        echo
        systemctl daemon-reload
    fi

    return 0
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

      local binary_archive="/usr/local/bin/${coinname}.zip"
      local binary_part="${binary_archive}.part"
      local temp_dir

      if ! wget -nv --show-progress "$prereleasebinaries" -O "$binary_part"; then
          rm -f -- "$binary_part"
          echo -e "${RED}Prerelease download failed; existing binaries were not changed${NC}"
          return 1
      fi

      mv -- "$binary_part" "$binary_archive" || return 1

      if ! 7za t "$binary_archive" >/dev/null; then
          echo -e "${RED}Prerelease archive failed verification${NC}"
          return 1
      fi

      if ! temp_dir=$(mktemp -d); then
          return 1
      fi

      if ! 7za x -y "$binary_archive" -o"$temp_dir"; then
          rm -rf -- "$temp_dir"
          return 1
      fi

      if [[ ! -f "$temp_dir/$coinnamecli" ||
            ! -f "$temp_dir/$coinnamed" ]]; then
          echo -e "${RED}Expected binaries are missing from the archive${NC}"
          rm -rf -- "$temp_dir"
          return 1
      fi

      if ! install -m 0755 \
          "$temp_dir/$coinnamecli" \
          "/usr/local/bin/$coinnamecli"; then
          rm -rf -- "$temp_dir"
          return 1
      fi

      if ! install -m 0755 \
          "$temp_dir/$coinnamed" \
          "/usr/local/bin/$coinnamed"; then
          rm -rf -- "$temp_dir"
          return 1
      fi

      rm -rf -- "$temp_dir"
      rm -f -- "$binary_archive"

			cd $HOME
			displaypause 15

			echo -e "How long between node (re)starts in seconds?"
			echo -e "Blank/Empty equals 120 seconds"
			read -r secondsdelay

			if [[ $secondsdelay != "" ]]
				then
					sleeptimerinsec=$secondsdelay
			fi

			for dir in /home/*; do
        [[ -d "$dir" ]] || continue
        i=$(basename "$dir")
        [[ "$i" == *scc* ]] || continue

				echo -e ""
				echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} MN's${NC}"
				echo -e "${YELLOW}found ${CYAN}$i${NC}..."
				echo -e ""

				if [[ $i == *scc* ]]
					then
						echo -e "${YELLOW}Restarting ${CYAN}$i${YELLOW}..${NC}"
						systemctl stop "$i"
						displaypause 3
						systemctl start --no-block "$i"
						echo -e "${CYAN}$i${YELLOW} updated and restarted${NC}"
						echo -e ""
						echo -e "${YELLOW}Pausing for $sleeptimerinsec seconds to let ${CYAN}$i${YELLOW} settle${NC}"
						displaypause $sleeptimerinsec
					else
						echo -e "${YELLOW}No ${CYAN}$ticker${YELLOW} MN's found to update${NC}"
				fi

			done

			echo -e "${CYAN}Wallet update tool finished${NC}"
		  return 0

	;;

esac

}


function maintmenu() {


clear

displayname

#Tool maintenance menu
echo
echo -e "${UNDERLINE}${CYAN}Welcome to the StakeCube Multitools ${version}${NC}"
echo
echo -e "${YELLOW}Maintenance menu${NC}"
echo
echo -e "${YELLOW}Please enter a number from the list and press [ENTER] to start maintenance tool"
echo
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
echo
echo -e "${YELLOW}0  - Exit"
echo
echo -e "${MAGENTA}This script can now use an optional sleep delay of up to 5 minutes per node on startup${NC}"
echo -e "${MAGENTA}This helps to prevent the VPS from being overloaded upon reboot when there are many nodes installed${NC}"
echo -e "${MAGENTA}This can make the install/start/restart/repair node(s) look like it has stopped working${NC}"
echo -e "${MAGENTA}This is just a side effect of the delay only(if it occurs)${NC}"
echo
echo -e "${YELLOW}This is an ${RED}OPTIONAL${YELLOW} feature that you can use by selecting appropriate options${NC}"
echo -e "${YELLOW}Please run the check install/update service files before installing nodes${NC}"
echo -e "${RED}only IF${YELLOW} you want to use the sleep delay functionality, it only needs to be ran once${NC}"
echo -e "${NC}"

read -rp "> " maintstart
echo


case $maintstart in

	91)	update_sleep_delay_services

	  exit

	;;

	92)	echo -e "${YELLOW}Beginning Private Keys and IP for all nodes${NC}"

    echo -e "${YELLOW}Checking for ${CYAN}$ticker${YELLOW} IP/MN private keys${NC}"

    foundone=0

    shopt -s nullglob
    for nodedirs in /home/*scc*; do
        foundone=1

        conf="$nodedirs/.scc/stakecubecoin.conf"

        if [[ ! -f "$conf" ]]; then
            echo -e "${RED}Error reading conf file for $nodedirs${NC}"
            continue
        fi

        privkey=$(grep -m1 '^masternodeblsprivkey=' "$conf" | cut -d= -f2)
        ip=$(grep -m1 '^bind=' "$conf" | cut -d= -f2)

        echo -e "${YELLOW}found ${CYAN}$(basename "$nodedirs")${YELLOW}...${NC}"
        echo -e "${CYAN}IP: ${GREEN}$ip${NC}"
        echo -e "${CYAN}Private Key: ${MAGENTA}$privkey${NC}"
        echo
    done
    shopt -u nullglob

    if [[ $foundone -eq 0 ]]; then
        echo -e "${CYAN}Found no SCC nodes${NC}"
    fi

		exit

	;;

	93)	echo -e "${YELLOW}Beginning debug node tool - single node${NC}"

    prompt_for_alias alias || exit 1

		echo

    prompt_yes_no onoff "${YELLOW}Enable Debug Mode on Node?${NC}" || exit 1

		echo -e ""

		if [[ $onoff == "yes" ]]
			then
				onoff=1
			else
				onoff=0
		fi

		debugmodeonoff "$alias" "$onoff"

		exit

	;;

	94)	echo -e "${YELLOW}Beginning debug node tool - all nodes${NC}"

		echo

    prompt_yes_no onoff "${YELLOW}Enable Debug Mode on Nodes?${NC}\n${MAGENTA}no${YELLOW} will turn them off if on" || exit 1

		echo

		if [[ $onoff == "yes" ]];  then
				onoff=1
			else
				onoff=0
		fi

		alias=0
		debugmodeonoff "$alias" "$onoff"

		exit

	;;

	95)	echo -e "${YELLOW}Beginning check debug status tool on all ${ticker} nodes${NC}"
      echo

    foundone=0

    shopt -s nullglob
    for i in /home/*scc*; do
        foundone=1
        errorpid=0
        debugcount=0
        debugcmd=""

        nodename=$(basename "$i")
        conf="$i/.scc/stakecubecoin.conf"

        echo -e "found ${CYAN}$nodename${NC}..."

        if [[ ! -f "$conf" ]]; then
            echo -e "${RED}ERROR ${YELLOW}config file not found for ${CYAN}$nodename${NC}"
            echo
            continue
        fi

        debugcount=$(grep -ci '^debug' "$conf")
        debugcmd=$(grep -i '^debug=[01]$' "$conf")

        if ! checkprocess "$nodename"; then
            errorpid=1
            echo
            echo -e "${RED}ERROR ${YELLOW}process for ${CYAN}$nodename${YELLOW} not found${NC}"
        fi

        if [[ $errorpid -eq 0 ]]; then
            if [[ -z "$debugcmd" ]]; then
                echo
                echo -e "${YELLOW}Debugging command not found in config file on node ${CYAN}$nodename${NC}"
            elif [[ ${debugcmd,,} == "debug=0" ]]; then
                echo
                echo -e "${YELLOW}Debugging is disabled on node ${CYAN}$nodename${NC}"
            elif [[ ${debugcmd,,} == "debug=1" ]]; then
                echo
                echo -e "${YELLOW}Debugging is enabled on node ${CYAN}$nodename${NC}"
            fi
        fi

        echo
    done
    shopt -u nullglob

    if [[ $foundone -eq 0 ]]; then
        echo
        echo -e "${CYAN}No $ticker nodes found${NC}"
    fi

		exit

	;;

	96)	echo -e "${YELLOW}Beginning collect single node debug log tool${NC}"

		prompt_for_alias alias || exit 1
		
		echo
		echo -e "${YELLOW}Collecting log for ${CYAN}$alias${NC}"
		echo

		debugzipfilename="${alias}_debug.7z"

		rm ~/${debugzipfilename}
		7za a -t7z -spf -mx=5 -md=64m -mmt=on -- ~/${debugzipfilename} /home/$alias/.scc/debug.log 

		echo
		echo -e "${YELLOW}Completed file name is ${CYAN}${debugzipfilename}${YELLOW} in user roots folder${NC}"
		echo
		echo -e "${YELLOW}Tool Completed${NC}"

		exit

	;;

	97)	echo -e "${YELLOW}Beginning collection of debug logs on all ${ticker} nodes${NC}"

    echo

    debugzipfilename="SCC_nodes_debug_logs.7z"
    debugfilelist=""
    foundone=0

    shopt -s nullglob
    for i in /home/*scc*; do
        foundone=1
        nodename=$(basename "$i")
        debuglog="$i/.scc/debug.log"

        echo -e "found ${CYAN}$nodename${NC}..."

        if [[ -f "$debuglog" ]]; then
            debugfilelist+=" $debuglog"
        else
            echo -e "${YELLOW}Debug log not found for ${CYAN}$nodename${NC}"
        fi
    done
    shopt -u nullglob

    if [[ $foundone -eq 1 && -n "$debugfilelist" ]]; then
        echo
        echo -e "${CYAN}Zipping all debug logs${NC}"

        rm -f ~/"$debugzipfilename"
        7za a -t7z -spf -mx=5 -md=64m -mmt=on -- ~/"$debugzipfilename" $debugfilelist

    elif [[ $foundone -eq 0 ]]; then
        echo
        echo -e "${CYAN}No $ticker nodes found${NC}"
    else
        echo
        echo -e "${YELLOW}No debug logs found to archive${NC}"
    fi

		exit

	;;

	98)	echo -e "${YELLOW}Beginning deletion of debug log(s) for ${ticker} node(s)${NC}"

    echo

    prompt_yes_no eraseallnodes "${YELLOW}Do you wish to erase all nodes debug logs?${NC}" || exit 1

    singlealias=""

    if [[ $eraseallnodes == "no" ]]; then
        prompt_for_alias singlealias || exit 1
    fi

    if [[ $eraseallnodes == "yes" ]]; then

        echo -e "How long between node (re)starts in seconds?"
        echo -e "Blank/Empty equals 120 seconds"
        read -r secondsdelay

        if [[ -n "$secondsdelay" ]]; then
            sleeptimerinsec="$secondsdelay"
        fi

        shopt -s nullglob
        for i in /home/*scc*; do
            nodename=$(basename "$i")
            debuglog="$i/.scc/debug.log"

            echo -e "found ${CYAN}$nodename${NC}..."
            echo
            echo -e "${YELLOW}Erasing debug log file and restarting ${CYAN}$nodename${NC}"

            rm -f "$debuglog"
            systemctl stop "$nodename"
            systemctl restart "$nodename" --no-block

            echo
            echo -e "${YELLOW}Restarted node and pausing $sleeptimerinsec seconds${NC}"
            displaypause "$sleeptimerinsec"
            echo
        done
        shopt -u nullglob

    else
        debuglog="/home/$singlealias/.scc/debug.log"

        echo
        echo -e "${YELLOW}Erasing debug log file and restarting ${CYAN}$singlealias${NC}"

        rm -f "$debuglog"
        systemctl stop "$singlealias"
        systemctl restart "$singlealias" --no-block

        echo
        echo -e "${YELLOW}Restarted node and pausing $sleeptimerinsec seconds${NC}"
        displaypause "$sleeptimerinsec"
    fi

	  exit

  ;;

	99) echo -e "${YELLOW}Starting full sync chain download repair tool${NC}"

	  prompt_for_alias alias || exit 1

		echo

		echo -e "${YELLOW}Stopping node ${CYAN}$alias${NC}"

		systemctl stop "$alias.service"

		echo
		echo -e "${YELLOW}Pausing for 30 seconds${NC}"

		displaypause 30

    erase_chain_data "$alias" || exit 1

    echo -e "${RED}Chain files are deleted, restarting node ${CYAN}$alias${NC}"

		systemctl start --no-block "$alias.service"

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

  3)  wallet_update_all

    exit

  ;;

	4)  node_control_tool

	  exit

	;;

	5)	echo -e "${YELLOW}Starting Removal tool${NC}"

		mn_uninstall

		exit

	;;

  6)  uninstall_multiple_nodes

    exit

  ;;

	7)	echo -e "${YELLOW}Starting $ticker MasterNode install${NC}"

  	install_mn "no" "" "no" || exit 1

		exit

	;;

	8)	echo -e "${YELLOW}Starting $ticker MasterNode install with Sleep Delay functionality${NC}"

  	install_mn "no" "" "yes" || exit 1

		exit

	;;

	9) echo -e "${YELLOW}Beginning manual ip node install${NC}"
		echo
		echo -e "${YELLOW}Please specify a valid IPv4 or IPv6 address only${NC}"
		echo -e "${YELLOW}In x.x.x.x or [x:x:x:x:x:x:x:x] format${NC}"
		manualiptest="${manualipv6addr#[}"
		manualiptest="${manualiptest%]}"

		echo
		echo -e "${MAGENTA}Testing IP address${NC}"
		echo -e "${MAGENTA}Pinging Google${NC}"

		if ping google.com -c 5 -W 2 -I "$manualiptest"; then
    		echo -e "${CYAN}Passed${NC}"
    		echo

    		prompt_yes_no sleepquestion \
        		"${YELLOW}Do you wish to enable sleep delay?${NC}" || exit 1

		    if [[ "$sleepquestion" == "no" ]]; then
    		    install_mn "yes" "$manualiptest" "no" || exit 1
		    else
    		    install_mn "yes" "$manualiptest" "yes" || exit 1
    		fi
		else
    		echo -e "${RED}Error: ${CYAN}IP is invalid or unavailable${NC}"
		fi

		exit

	;;

	10)	echo -e "${CYAN}Downloading updated bootstrap for offline install/repair from StakeCube${NC}"

		wget -nv --show-progress ${snapshot} -O /root/${coinname}.zip

		exit

	;;

	11)	offlinechainfilebuild

		exit

	;;

	12)	echo -e "${YELLOW}Starting chain repair/PoSe maintenance tool${NC}"

  	chain_repair "" "" "no"|| exit 1

		exit

	;;

	13)	explorer_compare

    exit

  ;;

	14)	check_status_nodes

	  exit

	;;

	15)	explorer_compare_and_repair

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
#S		echo -e "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}"
  	prompt_yes_no prereleaseyesno "${CYAN}Please enter ${MAGENTA}yes${NC} ${CYAN}or${NC} ${MAGENTA}no${CYAN} only${NC}" || exit 1

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

		update_temp=$(mktemp) || exit 1

		if ! curl -fsS --connect-timeout 10 --max-time 60 \
    		https://raw.githubusercontent.com/stakecube/SCC-Multitool/master/sccmultitool.sh \
    		-o "$update_temp"; then
    		rm -f -- "$update_temp"
    		echo -e "${RED}Unable to download SCCMultitool update${NC}"
    		exit 1
		fi

		if [[ ! -s "$update_temp" ]]; then
    		rm -f -- "$update_temp"
    		echo -e "${RED}Downloaded update is empty; existing script was not changed${NC}"
    		exit 1
		fi

		if ! bash -n "$update_temp"; then
    		rm -f -- "$update_temp"
    		echo -e "${RED}Downloaded update failed the Bash syntax check${NC}"
    		exit 1
		fi

		if [[ -f "$HOME/sccmultitool.sh" ]] &&
   		cmp -s "$update_temp" "$HOME/sccmultitool.sh"; then
    		rm -f -- "$update_temp"
    		echo -e "${GREEN}SCCMultitool${NC} is already updated to the latest version"
    		exit
		fi

		install -m 0755 "$update_temp" "$HOME/sccmultitool.sh" || {
    		rm -f -- "$update_temp"
    		echo -e "${RED}Failed to install SCCMultitool update${NC}"
    		exit 1
		}

		rm -f -- "$update_temp"
		echo -e "${GREEN}SCCMultitool${NC} updated to the latest version"

		exit

	;;

esac
