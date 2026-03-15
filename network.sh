#!/bin/bash


get_netw_info(){

  clear
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}        NETWORK CONNECTIVITY REPORT       ${NC}"
    echo -e "${BLUE}==========================================${NC}"

   #internel IP
    local local_ip
    local_ip=$(hostname -I | awk '{print $1}')

    
    echo -ne "${YELLOW}Checking External Connection...${NC}\r"
    local public_ip=$(curl -s --max-time 5 ifconfig.me)
         #ifconfig.me : a site respond with your IP
         # -s : silent(No Download --...)
         #--max-time 5: if it dosn't respond in 5 seconds GIVE-UP;;


    echo -e "${YELLOW}[IP ADDRESSES]${NC}"
    printf "%-15s : %s\n" "Internal IP" "$local_ip"
    
    if [ -z "$public_ip" ]
    then  # -z : is zero(is this variable embty??);;
        printf "%-15s : ${RED}Disconnected${NC}\n" "External IP"
    else
        printf "%-15s : ${GREEN}%s${NC}\n" "External IP" "$public_ip"
    fi
    echo ""
    
    
    #DNS, PING
    echo -e "${YELLOW}[CONNECTION TEST]${NC}"
    if ping -c 1 8.8.8.8 &> /dev/null  # -c 1 : send only one;;
    then # As we know []:is command So we can use 'ping' if it Done with success..;;

        printf "%-15s : ${GREEN}Online${NC}\n" "Internet"
    else
        printf "%-15s : ${RED}Offline${NC}\n" "Internet"
    fi

    echo -e "${BLUE}==========================================${NC}"
}

