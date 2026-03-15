#!/bin/bash


get_hw_info(){

 [ -t 1 ] && clear #is the output to the ter (stdoutput(1))

    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}       HARDWARE RESOURCES REPORT(basic)   ${NC}"
    echo -e "${BLUE}==========================================${NC}"


   local cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | sed 's/^[ /t]*//')
                                        # ^:start only from the begging(to save the spaces in the meddle)
                                        # [ /t] : serch fot space or tab; *:repeat(no matter its Num)
                                        # finaly remove them;
   local cpu_cores=$(lscpu | grep "^CPU(s)" | awk '{print $2}')
                # ^: search only for the one with CPU(s) in the begging;
   local load_average=$(uptime | awk -F'load average:' '{print $2}')

                #the varage is the last: 1min 5min 15min ( 1.00: All power(in it's limit) 2.00(there is prosses waiting) );;
                # -F: to choose the separator;
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100-$8}' | cut -d. -f1) # To get the value without floating




    echo -e "${YELLOW}[CPU INFORMATION]${NC}"
    printf "%-15s : %s\n" "Model" "$cpu_model"
    printf "%-15s : %s\n" "Cores" "$cpu_cores"
    printf "%-15s : %s\n" "Load Average" "$load_average"

  #Alert and Sending Email
    if [ "$cpu_usage" -gt 80 ]; then
    echo -e "${RED}[!] ALERT: CPU usage is ${cpu_usage}%${NC}"
    echo "ALERT: CPU usage reached ${cpu_usage}% on $(hostname) at $(date)" | msmtp "$EMAIL_RECIPIENT" 
    fi


    echo ""

    #RAM information;
    local ram_total 
    local ram_used 
    local ram_free
    read ram_total ram_used ram_free <<< $(free -m | awk 'NR==2{print $2, $3, $4}')
            # NR==2: Go to the second row, the first is just titles
            # <<< : Here string it takes what awk done and put, in the variables by order!!!
    local ram_usage_percent=$(( ram_used * 100 / ram_total ))
            #(()): let us to do calculation
            
    

      echo -e "${YELLOW}[MEMORY USAGE]${NC}"
    printf "%-15s : %s MB\n" "Total RAM" "$ram_total"
    printf "%-15s : %s MB (%s%%)\n" "Used RAM" "$ram_used" "$ram_usage_percent"

      # Warning if the percent of the usage >80;
    if [ $ram_usage_percent -gt 80 ]; then
        echo -e "${RED}[!] Warning: High RAM usage detected!${NC}"
    fi
    echo ""

     local disk_info=$(df -h / | awk 'NR==2 {print $2, $3, $5}') 
                # $2: Size ; $3: Avai ; $5: Used;;
     local d_total 
     local d_used 
     local d_perc
     read d_total d_used d_perc <<< $disk_info

       echo -e "${YELLOW}[DISK SPACE - Root /]${NC}"
    printf "%-15s : %s\n" "Total Size" "$d_total"
    printf "%-15s : %s (%s)\n" "Used Space" "$d_used" "$d_perc"
        #Used Space     : 11G (56%)

    local N=$(echo $d_perc | sed 's/%//')
     if [ $N -gt 80 ] 
     then
       printf "${RED} -Warning: Disk Full!!${NC}"
       fi

    
    # GPU
    echo -e "${YELLOW}[GPU]${NC}"
    local gpu=$(lspci 2>/dev/null | grep -i vga | cut -d: -f3)
    printf "%-15s : %s\n" "GPU" "${gpu:-N/A}"
    echo ""

    # Network Interfaces + MAC
    echo -e "${YELLOW}[NETWORK INTERFACES]${NC}"
    ip -o link show | awk '{printf "%-15s : %s\n", $2, $17}'
    echo ""


    echo -e "${BLUE}==========================================${NC}"

}



get_detailed_hw_info(){


if [[ $EUID -ne 0 ]]
then
echo -e "${YELLOW}[!] Some details require root access. Please authenticate:${NC}"
sudo -v || { echo -e "${RE}Authentification failed! Returning...${NC}"; sleep 2; return; }
fi

clear

    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}    HARDWARE RESOURCES REPORT(Detailed)   ${NC}"
    echo -e "${BLUE}==========================================${NC}"


   local cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | sed 's/^[ /t]*//')
                                        # ^:start only from the begging(to save the spaces in the meddle)
                                        # [ /t] : serch fot space or tab; *:repeat(no matter its Num)
                                        # finaly remove them;
   local cpu_cores=$(lscpu | grep "^CPU(s)" | awk '{print $2}')
                # ^: search only for the one with CPU(s) in the begging;
   local load_average=$(uptime | awk -F'load average:' '{print $2}')

                #the varage is the last: 1min 5min 15min ( 1.00: All power(in it's limit) 2.00(there is prosses waiting) );;
                # -F: to choose the separator;
   local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100-$8}')


    echo -e "${YELLOW}[CPU INFORMATION]${NC}"
    printf "%-15s : %s\n" "Model" "$cpu_model"
    printf "%-15s : %s\n" "Cores" "$cpu_cores"
    printf "%-15s : %s\n" "Load Average" "$load_average"
    echo ""
    
     #Alert and Sending Email
    if [ "$cpu_usage" -gt 80 ]; then
    echo -e "${RED}[!] ALERT: CPU usage is ${cpu_usage}%${NC}"
    echo "ALERT: CPU usage reached ${cpu_usage}% on $(hostname) at $(date)" | msmtp "$EMAIL_RECIPIENT" 
    fi

    #RAM information;
    local ram_total 
    local ram_used 
    local ram_free
    read ram_total ram_used ram_free <<< $(free -m | awk 'NR==2{print $2, $3, $4}')
            # NR==2: Go to the second row, the first is just titles
            # <<< : Here string it takes what awk done and put, in the variables by order!!!
    local ram_usage_percent=$(( ram_used * 100 / ram_total ))
            #(()): let us to do calculation
    

      echo -e "${YELLOW}[MEMORY USAGE]${NC}"
    printf "%-15s : %s MB\n" "Total RAM" "$ram_total"
    printf "%-15s : %s MB (%s%%)\n" "Used RAM" "$ram_used" "$ram_usage_percent"

      # Warning if the percent of the usage >80;
    if [ $ram_usage_percent -gt 80 ]; then
        echo -e "${RED}[!] Warning: High RAM usage detected!${NC}"
    fi
    echo ""

     local disk_info=$(df -h / | awk 'NR==2 {print $2, $3, $5}') 
                # $2: Size ; $3: Avai ; $5: Used;;
     local d_total 
     local d_used 
     local d_perc
     read d_total d_used d_perc <<< $disk_info

       echo -e "${YELLOW}[DISK SPACE - Root /]${NC}"
    printf "%-15s : %s\n" "Total Size" "$d_total"
    printf "%-15s : %s (%s)\n" "Used Space" "$d_used" "$d_perc"
        #Used Space     : 11G (56%)

    local N=$(echo $d_perc | sed 's/%//')
     if [ $N -gt 80 ] 
     then
       printf "${RED} -Warning: Disk Full!!${NC}"
       fi


    local temp=$(sensors 2>/dev/null | grep "Package id 0" | awk '{print $4}')
    local freq=$(cat /proc/cpuinfo | grep MHz | awk '{print $4}' | head -n 1 | cut -d. -f1) # No floating

    local status
    if [ "$freq" -gt 2800 ]
    then
      status="${RED}High Performance${NC}"
    elif [ "$freq" -lt 1200 ] 
    then
      status="${BLUE}Power Saving${NC}"
    else
      status="${GREEN}Normal${NC}"
    fi

    local board_sn=$(sudo dmidecode -s baseboard-serial-number 2>/dev/null)
    local bios_ver=$(sudo dmidecode -s bios-version 2>/dev/null)




    echo -e "${YELLOW}[CPU & THERMAL]${NC}"
    printf "%-20s : %s\n" "Temperature" "${temp:-N/A}" 
    printf "%-20s : %s MHz\n" "Current Freq" "${freq:-N/A}" # if freq is empty(Default)
    printf "%-20s: %b\n" "Current Mode" "${status:-N/A}"

    echo -e "\n${YELLOW}[MOTHERBOARD & IDENTITY]${NC}"
    printf "%-20s : %s\n" "Serial Number" "${board_sn:-Permission Denied}"
    printf "%-20s : %s\n" "BIOS Version" "${bios_ver:-N/A}" 

    # GPU
    echo -e "${YELLOW}[GPU INFORMATION]${NC}"
    local gpu=$(lspci 2>/dev/null | grep -i vga | cut -d: -f3)
    printf "%-20s : %s\n" "GPU" "${gpu:-N/A}"
    echo ""

    # Network Interfaces + MAC
    echo -e "${YELLOW}[NETWORK INTERFACES & MAC]${NC}"
    ip -o link show | awk '{printf "%-15s MAC: %s\n", $2, $17}'
    echo ""

    # USB Devices
    echo -e "${YELLOW}[USB DEVICES]${NC}"
    lsusb 2>/dev/null | awk -F': ' '{print $2}' | while read line; do
        printf "  - %s\n" "$line"
    done
    echo ""

    echo ""
    echo ""

     local virt_type=$(systemd-detect-virt)
    
    if [ "$virt_type" != "none" ]; then
        echo -e "${YELLOW}[!] Virtual Environment Detected: ($virt_type)${NC}"
        echo -e "${BLUE}Note: Physical hardware sensors are hidden by the Hypervisor.${NC}"
    else
        echo -e "${GREEN}[+] Running on Physical Hardware.${NC}"
    fi
    
    echo -e "${BLUE}==============================${NC}"
}
