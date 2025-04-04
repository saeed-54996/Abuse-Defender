#!/bin/bash

# Colors for terminal output
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m" # No Color

IP_LIST_URL="https://raw.githubusercontent.com/saeed-54996/Abuse-Defender/main/blocked_ips.txt"
LOCAL_IP_LIST="/etc/abuse_defender/blocked_ips.txt"

# Ports to block
BLOCKED_PORTS=(16658 5564)

check_firewall_tools() {
    echo -e "${BLUE}[*] Checking firewall tools...${NC}"
    
    if ! command -v ufw &> /dev/null; then
        echo -e "${YELLOW}[*] Installing UFW...${NC}"
        sudo apt update && sudo apt install -y ufw
    fi

    if ! command -v iptables &> /dev/null; then
        echo -e "${YELLOW}[*] Installing iptables...${NC}"
        sudo apt update && sudo apt install -y iptables
    fi

    echo -e "${GREEN}[✔] Firewall tools are installed.${NC}"
}

install_firewall_rules() {
    check_firewall_tools

    echo -e "${BLUE}[*] Installing firewall rules...${NC}"
    mkdir -p /etc/abuse_defender
    curl -s "$IP_LIST_URL" -o "$LOCAL_IP_LIST"
    
    if [[ ! -s $LOCAL_IP_LIST ]]; then
        echo -e "${RED}[!] Failed to fetch the IP list or list is empty!${NC}"
        exit 1
    fi

    echo -e "${YELLOW}[*] Applying UFW rules...${NC}"
    while IFS= read -r ip; do
        ufw deny out from any to "$ip"
    done < "$LOCAL_IP_LIST"
    
    for port in "${BLOCKED_PORTS[@]}"; do
        ufw deny out "$port"/tcp
        ufw deny out "$port"/udp
    done

    echo -e "${YELLOW}[*] Applying iptables rules...${NC}"
    while IFS= read -r ip; do
        iptables -A OUTPUT -d "$ip" -j DROP
    done < "$LOCAL_IP_LIST"
    
    for port in "${BLOCKED_PORTS[@]}"; do
        iptables -A OUTPUT -p tcp --dport "$port" -j DROP
        iptables -A OUTPUT -p udp --dport "$port" -j DROP
    done
    
    echo -e "${YELLOW}[*] Reloading firewall rules...${NC}"
    ufw reload
    iptables-save > /etc/iptables/rules.v4

    echo -e "${GREEN}[✔] Firewall rules installed successfully!${NC}"
}

remove_firewall_rules() {
    check_firewall_tools

    echo -e "${BLUE}[*] Removing firewall rules...${NC}"
    
    if [[ ! -f $LOCAL_IP_LIST ]]; then
        echo -e "${RED}[!] No existing IP list found.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}[*] Removing UFW rules...${NC}"
    while IFS= read -r ip; do
        ufw delete deny out from any to "$ip" 2>/dev/null
    done < "$LOCAL_IP_LIST"
    
    for port in "${BLOCKED_PORTS[@]}"; do
        ufw delete deny out "$port"/tcp 2>/dev/null
        ufw delete deny out "$port"/udp 2>/dev/null
    done

    echo -e "${YELLOW}[*] Removing iptables rules...${NC}"
    while IFS= read -r ip; do
        iptables -D OUTPUT -d "$ip" -j DROP 2>/dev/null
    done < "$LOCAL_IP_LIST"
    
    for port in "${BLOCKED_PORTS[@]}"; do
        iptables -D OUTPUT -p tcp --dport "$port" -j DROP 2>/dev/null
        iptables -D OUTPUT -p udp --dport "$port" -j DROP 2>/dev/null
    done

    echo -e "${YELLOW}[*] Reloading firewall rules...${NC}"
    ufw reload
    iptables-save > /etc/iptables/rules.v4
    
    echo -e "${GREEN}[✔] Firewall rules removed successfully!${NC}"
}

show_menu() {
    echo -e "${BLUE}Abuse Defender Firewall Setup${NC}"
    echo -e "1) Install Firewall Rules"
    echo -e "2) Remove Firewall Rules"
    echo -e "3) Exit"
    echo -n "Select an option: "
    read -r option
    case $option in
        1) install_firewall_rules ;;
        2) remove_firewall_rules ;;
        3) exit 0 ;;
        *) echo -e "${RED}[!] Invalid option!${NC}" ; show_menu ;;
    esac
}

show_menu
