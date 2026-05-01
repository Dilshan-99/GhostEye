#!/bin/bash

#-------colors for Professional UI--------
# --- Colors ---
RED='\033[1;31m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear
echo -e "${CYAN}"
echo "            ____  "
echo "         .-'    \`-.  "
echo "       .'  ______  \`.  "
echo -e "      /   /_${RED}oooooo${CYAN}_\   \ "
echo -e "     |    ${RED}o${WHITE}  (  )${RED}  o${CYAN}    | "
echo -e "      \   \_${RED}oooooo${CYAN}_/   / "
echo "       \`.          .'  "
echo "         \`-.____.-'  "
echo -e "${RED}"
echo "  _____ _               _   ______             "
echo " / ____| |             | | |  ____|            "
echo "| |  __| |__   ___  ___| |_| |__  _   _  ___   "
echo "| | |_ | '_ \ / _ \/ __| __|  __|| | | |/ _ \  "
echo "| |__| | | | | (_) \__ \ |_| |___| |_| |  __/  "
echo " \_____|_| |_|\___/|___/\__|______\__, |\___|  "
echo "                                  __/ |       "
echo "      [ Stealth OS Auditor ]     |___/        "
echo -e "${NC}"
echo -e "${WHITE} >> Started: $(date +'%H:%M:%S') | Target: $(hostname)${NC}"
echo -e "${RED}======================================================${NC}"

# --- Module 1: System Reconnaissance ---
echo -e "\n${CYAN}[!] INITIALIZING SYSTEM RECONNAISSANCE...${NC}"

#Basic System Information
echo -e "\n${WHITE}--- Basic Information ---${NC}"
printf "${CYAN}%-20s${NC} : %s\n" "Hostname" "$(hostname)"
printf "${CYAN}%-20s${NC} : %s\n" "Kernel Version" "$(uname -r)"
printf "${CYAN}%-20s${NC} : %s\n" "Architecture" "$(uname -m)"
printf "${CYAN}%-20s${NC} : %s\n" "Operating System" "$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d '"' -f 2)"

# User Information
echo -e "\n${WHITE}--- User Information ---${NC}"
printf "${CYAN}%-20s${NC} : %s\n" "Current User" "$(whoami)"
printf "${CYAN}%-20s${NC} : %s\n" "User ID (UID)" "$(id -u)"
printf "${CYAN}%-20s${NC} : %s\n" "Groups" "$(groups)"

# Check if we have sudo privileges (without password prompt)
echo -ne "${CYAN}%-20s${NC} : " "Sudo Privileges"
if sudo -n true 2>/dev/null; then
    echo -e "${RED}YES (Passwordless Sudo!)${NC}"
else
    echo -e "No Passwordless Sudo"
fi

echo -e "\n${RED}======================================================${NC}"


# --- Module 2: SUID Hunter ---
echo -e "\n${YELLOW}[!] SCANNING FOR SUID BINARIES...${NC}"
echo -e "${WHITE}Checking for files with SUID bit set (Potential PrivEsc routes)${NC}\n"

# find SUID
suid_files=$(find /usr/bin /bin -perm -4000 -type f 2>/dev/null)

if [ -z "$suid_files" ]; then
    echo -e "${BLUE}[-] No SUID binaries found in standard paths.${NC}"
else
    echo -e "${RED}Found SUID Binaries:${NC}"
    echo "$suid_files" | while read -r file; do
        basename=$(basename "$file")
        # GTFOBins catagrize binaries based on their potential for privilege escalation. Highlighting high priority ones.
        if echo "cp,find,vim,nano,bash,sh,python,perl,ruby,lua,nmap,sed,awk" | grep -qw "$basename"; then
            echo -e "  ${RED}[!] $file  <-- HIGH PRIORITY (Check GTFOBins)${NC}"
        else
            echo -e "  ${CYAN}[+] $file${NC}"
        fi
    done
fi

echo -e "\n${RED}======================================================${NC}"

# --- Module 3: Writable Directory Hunter ---
echo -e "\n${YELLOW}[!] SCANNING FOR WRITABLE DIRECTORIES...${NC}"
echo -e "${WHITE}Looking for locations where files can be written (Useful for exploits)${NC}\n"

# Search for writable directories globally, excluding standard system paths to reduce noise
writable_dirs=$(find / -writable -type d 2>/dev/null | grep -E -v "^/proc|^/sys|^/dev")

if [ -z "$writable_dirs" ]; then
    echo -e "${BLUE}[-] No writable directories found.${NC}"
else
    echo -e "${RED}Writable Directories Detected:${NC}"
    
    # Display only the first 10 results to keep the output clean and organized
    echo "$writable_dirs" | head -n 10
    echo -e "\n${CYAN}[+] Only showing first 10 results for clarity.${NC}"
fi

echo -e "\n${RED}======================================================${NC}"

# --- Module 4: Network Information Hunter ---
echo -e "\n${YELLOW}[!] COLLECTING NETWORK INFORMATION...${NC}"
echo -e "${WHITE}Scanning for active network interfaces and listening ports${NC}\n"

# Get Local IP Addresses (Excluding loopback)
echo -e "${CYAN}Network Interfaces & IPs:${NC}"
ip addr | grep -w "inet" | grep -v "127.0.0.1" | awk '{print "  [+] " $NF " : " $2}' | cut -d '/' -f 1

# Check for Listening Ports (Internal & External)
echo -e "\n${CYAN}Active Listening Ports:${NC}"
if command -v netstat >/dev/null 2>&1; then
    netstat -tuln | grep "LISTEN" | awk '{print "  [+] Port: " $4}' | sed 's/.*://' | sort -u
elif command -v ss >/dev/null 2>&1; then
    ss -tuln | grep "LISTEN" | awk '{print "  [+] Port: " $4}' | sed 's/.*://' | sort -u
else
    echo -e "${RED}  [-] netstat or ss command not found. Skipping port scan.${NC}"
fi

echo -e "\n${RED}======================================================${NC}"

# --- Module 5: Security Protection Hunter ---
echo -e "\n${YELLOW}[!] CHECKING SYSTEM PROTECTIONS...${NC}"
echo -e "${WHITE}Scanning for Firewalls and Security configurations${NC}\n"

# Check for IPTables (Firewall) rules
echo -ne "${CYAN}%-20s${NC} : " "IPTables Rules"
if [ -x "$(command -v iptables)" ]; then
    rules=$(sudo -n iptables -L 2>/dev/null | grep -c "Chain")
    if [ "$rules" -gt 0 ]; then echo -e "${RED}ACTIVE (Rules found)${NC}"; else echo -e "${GREEN}No Rules Set${NC}"; fi
else
    echo -e "Not Installed"
fi

# Check for SELinux or AppArmor
echo -ne "${CYAN}%-20s${NC} : " "SELinux"
if [ -x "$(command -v getenforce)" ]; then getenforce; else echo -e "Not Active"; fi

echo -ne "${CYAN}%-20s${NC} : " "AppArmor"
if [ -x "$(command -v aa-status)" ]; then echo -e "${RED}Active${NC}"; else echo -e "Not Active"; fi

echo -e "\n${RED}======================================================${NC}"
echo -e "${GREEN}>> [ SCAN COMPLETED SUCCESSFULLY ] <<${NC}"