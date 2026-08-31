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

# --------------------------------------------------------------
# Devnet variables - Batch11A named devnet
# --------------------------------------------------------------
# Keep devnet binaries separate from production binaries. Set the archive URL
# before using the installer, or preinstall sccd and scc-cli in this directory.
devnet_name="batch11a"
devnet_binaries=""
devnet_binaries_sha256=""
devnet_binary_dir="/usr/local/bin/scc-devnet"
devnet_daemon="$coinnamed"
devnet_cli="$coinnamecli"
# Legacy/old-binary nodes used to test the protocol 70224 -> 70240 boundary.
# These binaries are the normal production-style binaries in /usr/local/bin.
devnet_legacy_binary_dir="/usr/local/bin"
devnet_legacy_daemon="$coinnamed"
devnet_legacy_cli="$coinnamecli"
devnet_legacy_peer_alias="sccdevold001"
devnet_legacy_mn_alias="sccdevoldmn001"
devnet_legacy_rpcport=19850
devnet_legacy_daemonize=1
devnet_legacy_service_type="forking"

# Shared named-devnet consensus/runtime values.
devnet_port=20000
devnet_controller_rpcport=19798
devnet_mn_rpcport=19799
devnet_rpcport_step=1
devnet_controller_alias="sccdevcontroller"
devnet_mn_alias="sccdevmn001"
devnet_controller_address=""
devnet_sporkaddr="yhWRxKRmJBwmFVzXTwBDVmUXiy8tnz6aXr"
# Intentionally blank. Never commit a spork private WIF to this public script.
devnet_sporkkey=""

devnet_server=1
devnet_listen=1
# Role-specific daemon and systemd behavior. The controller stays in the
# foreground so systemd supervises it directly; masternodes fork normally.
devnet_controller_daemonize=1
devnet_mn_daemonize=1
devnet_controller_service_type="forking"
devnet_mn_service_type="forking"
devnet_timeout_start_sec="3000s"
devnet_timeout_stop_sec="6000s"
devnet_allowprivatenet=1
devnet_minimumdifficultyblocks=10000
devnet_highsubsidyblocks=300
devnet_highsubsidyfactor=1000
devnet_powtargetspacing=30

# These values document the compiled activation boundary used by Batch11A.
# They are comments in generated configuration files, not daemon arguments.
devnet_basic_bls_activation_height=480
devnet_legacy_protocol=70224
devnet_basic_protocol=70240

devnet_minsporkkeys=1
devnet_fallbackfee="0.001"
devnet_rpcbind="127.0.0.1"
devnet_rpcallowip="127.0.0.1"
devnet_deprecatedrpc="legacy_mn"
devnet_txindex=1
devnet_maxconnections=125
devnet_debug=1

# When enabled, a missing IPv6 bind address is added to $netcfg.
# IPv4 addresses must already be assigned to the host.
devnet_manage_netplan=1
devnet_minimum_install_gib=5

# Full devnet node snapshots. Archives contain wallets, private keys, the full
# block/index state, and every other file under the selected node's .scc tree.
devnet_snapshot_dir="/root/scc-devnet-snapshots"
devnet_snapshot_stop_wait_sec=180
devnet_snapshot_rpc_wait_sec=300
devnet_snapshot_restart_delay_sec=2

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
    curl zip unzip nano ufw software-properties-common python3 \
    pwgen p7zip-full p7zip-rar; then
    echo -e "${RED}Dependency installation failed${NC}"
    exit 1
fi

# Password and RPC credentials are generated inside install_mn so that
# every single-node or batch installation receives unique credentials.

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
echo -e "${YELLOW}6  - Remove Masternodes - multiple"
echo -e "${YELLOW}7  - Masternode install - single"
echo -e "${YELLOW}8  - Masternode install - multiple"
echo -e "${YELLOW}9  - Masternode Install - singe with manually specified IPv4/IPv6 Address"
echo -e "${YELLOW}10 - Download/Update StakeCubeCoin local bootstrap file from stakecube"
echo -e "${YELLOW}11 - Make/Update your StakeCubeCoin local bootstrap file from an existing SCC node"
echo -e "${YELLOW}12 - Chain repair tool (single or all ${ticker} nodes)"
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
echo -e "${YELLOW}This is an