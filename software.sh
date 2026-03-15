#!/bin/bash


basicSoftinfo() {
    local os_name=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    local kernel=$(uname -r)  # In bash every Var is Global!
    local up_time=$(uptime -p)
    local current_user=$(whoami)

    echo -e "${BLUE}======= BASIC SOFTWARE INFO =======${NC}"
    printf "%-15s : ${GREEN}%s${NC}\n" "OS" "$os_name"
    printf "%-15s : %s\n" "Kernel" "$kernel"
    printf "%-15s : %s\n" "Uptime" "$up_time"
    printf "%-15s : %s\n" "Current User" "$current_user"
    echo -e "${BLUE}====================================${NC}"
}


get_sw_info(){
    clear
    echo -e "${BLUE}--- SOFTWARE INFORMATION  ---${NC}"


    local os_name=$(cat /etc/os-release | grep ^PRETTY | sed 's/PRETTY_NAME="//g' | sed 's/"//g' )
    local kernel=$(hostnamectl | grep Kernel)
    local up_time=$(uptime -p)
    local top_5=$(ps aux --sort=%cpu | head -n 5)
    local current_user=$(whoami)
    local last_5=$(last -n 5)
    local Arch=$(hostnamectl | grep Archi)
    local failed_count=$(systemctl list-units --state==failed --no-legend | wc -l)
    local logged_users=$(who | wc -l)
    local pkg_count=$(dpkg -l 2> /dev/null | wc -l)

      #systemctl: all services
      #list-units: show me the list of evrithing
      #state==failed: for feltering the failed ones
      #no-legend: only the result, it's mean with out any explain or other written

    
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}       SOFTWARE & SYSTEM REPORT           ${NC}"
    echo -e "${BLUE}==========================================${NC}"



     
      echo -e "${YELLOW}[CORE IDENTITY]${NC}"
    printf "%-15s : %s\n" "OS" "$os_name"
    printf "%-15s : %s\n" "Architecture" "$(echo $Arch | cut -d: -f2)"
    printf "%-15s : %s\n" "Kernel" "$(echo $kernel | cut -d: -f2)"
    echo "" # new line

     # %-15: Rserve 15 space to the text, if it less put spaces in, So all colum willbe equal;;
     #printf do not make \n automaticly



     echo -e "${YELLOW}[SYSTEM STATUS]${NC}"
     echo -e "Uptime         : $up_time"
     echo -e "Current User   : ${GREEN}$current_user${NC}"



   if [ "$failed_count" -gt 0 ]; then
        echo -e "Failed Services: ${RED}$failed_count (Action Required!)${NC}"
    else
        echo -e "Failed Services: ${GREEN}0 (All Stable)${NC}"
    fi

     echo -e "Logged-in users: $logged_users"
     echo -e "installed pkg: $pkg_count"
    echo ""


    echo -e "${YELLOW}[TOP 5 CPU CONSUMERS]${NC}"
    echo -e "${BLUE}USER       PID %CPU %MEM COMMAND${NC}"
   # we want only the important information
   # username, prossesID, % of usage CPU, % of usage RAM
   #the name of the command or the progaram(COMMAND)
    echo "$top_5" | awk '{printf "%-10s %-5s %-4s %-4s %-10s\n", $1, $2, $3, $4, $11}' | tail -n +2
    echo ""


    
  echo -e "${YELLOW}[LAST 5 LOGINS]${NC}"
    echo "$last_5"
  echo -e "${YELLOW}[OPEN PORTS]${NC}"
    ss -tuln | awk 'NR>1{printf "%-6s %-25s\n",$1, $5}'
    echo ""
    
    echo -e "${BLUE}==========================================${NC}"
}



get_detailed_sw_info(){
    
    # -Basic-
    local os_name=$(cat /etc/os-release | grep ^PRETTY | sed 's/PRETTY_NAME="//g' | sed 's/"//g')
    local kernel=$(hostnamectl | grep Kernel | cut -d: -f2)
    local arch=$(hostnamectl | grep Archi | cut -d: -f2)
    local up_time=$(uptime -p)
    local current_user=$(whoami)
    
    # -Detaled-
    # 1. Packages
    local logged_users=$(who | wc -l)
    local pkg_count=$(dpkg -l 2> /dev/null | wc -l)
    local updates=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
    
    # Secvices: Active-Disactive
    local active_srv=$(systemctl list-units --type=service --state=running --no-legend | wc -l)
    local total_srv=$(systemctl list-units --type=service --all --no-legend | wc -l)
    local failed_count=$(systemctl list-units --state=failed --no-legend | wc -l)


[ -t 1 ] && clear #is the output to the ter (stdoutput(1))

    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}      DETAILED SOFTWARE & SECURITY REPORT   ${NC}"
    echo -e "${BLUE}==========================================${NC}"

    # Identity
    echo -e "${YELLOW}[CORE IDENTITY]${NC}"
    printf "%-18s : %s\n" "OS" "$os_name"
    printf "%-18s : %s\n" "Architecture" "$arch"
    printf "%-18s : %s\n" "Kernel" "$kernel"
    echo ""

    #  Security(Packeges)
    echo -e "${YELLOW}[MANAGEMENT & UPDATES]${NC}"
    printf "%-18s : %s\n" "Total Packages" "$pkg_count"
    if [ "$updates" -gt 0 ]; then
        printf "%-18s : ${RED}%s Updates Available${NC}\n" "Security Updates" "$updates"
    else
        printf "%-18s : ${GREEN}All Up-to-date${NC}\n" "Security Updates"
    fi
    echo ""

    # Sevices and System
    echo -e "${YELLOW}[SYSTEM SERVICES]${NC}"
    echo -e "Uptime             : $up_time"
    echo -e "Current User       : ${GREEN}$current_user${NC}"
    printf "%-18s : %s Running / %s Total\n" "Services Status" "$active_srv" "$total_srv"
    
    if [ "$failed_count" -gt 0 ]; then
        echo -e "Failed Services    : ${RED}$failed_count (Action Required!)${NC}"
    else
        echo -e "Failed Services    : ${GREEN}0 (Stable)${NC}"
    fi
    echo ""

    # Top 10 Proc
    echo -e "${YELLOW}[TOP 10 CPU CONSUMERS]${NC}"
    printf "${BLUE}%-10s %-7s %-5s %-5s %-15s${NC}" "USER" "PID" "%CPU" "%MEM" "COMMAND"
    echo ""
    ps aux --sort=-%cpu | head -n 11 | tail -n 10 | awk '{printf "%-10s %-7s %-5s %-5s %-15s\n", $1, $2, $3, $4, $11}'
    echo ""

    # Log security
    echo -e "${YELLOW}[SECURITY: RECENT LOGINS]${NC}"
    last -n 5

     echo -e "${YELLOW}[OPEN PORTS]${NC}"
    ss -tuln | awk 'NR>1{printf "%-6s %-25s\n",$1, $5}'
    echo ""
    
    echo -e "${BLUE}==========================================${NC}"
}






