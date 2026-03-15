#!/bin/bash


send_via_scp() {
    local MY_HOST=$(hostname)
    local MY_DATE=$(date +%Y-%m-%d_%H-%M)

    local R_DIR="/home/${R_USER}/backups/${MY_HOST}"
    local FILE_NAME="${MY_HOST}_${MY_DATE}.txt"
    local TMP_FILE="/tmp/${FILE_NAME}"

    echo -e "${YELLOW}[*] Preparing Secure Copy (SCP)...${NC}"

    # temprary file
    {
        echo "##########################################################"
        echo "          FULL SYSTEM REPORT: ${MY_HOST}"
        echo "          GENERATED ON: $(date)"
        echo "##########################################################"
        echo ""
        echo "[SECTION 1: HARDWARE DETAILS]"
        get_hw_info
        echo ""
        echo "[SECTION 2: SOFTWARE & SECURITY DETAILS]"
        get_detailed_sw_info
        echo ""
        echo "##########################################################"
        echo "                END OF INTEGRATED REPORT"
        echo "##########################################################"
    } > "$TMP_FILE"

    # Creating the DIR in server using ssh
    ssh "${R_USER}@${R_IP}" "mkdir -p ${R_DIR}"

    # send with SCP
    scp "$TMP_FILE" "${R_USER}@${R_IP}:${R_DIR}/${FILE_NAME}"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✔] File transferred successfully to: ${R_DIR}/${FILE_NAME}${NC}"
    else
        echo -e "${RED}[!] Transfer failed. Check SSH connection.${NC}"
    fi

    # Deleting the temprary file
    rm -f "$TMP_FILE"
    }



send_integrated_report() {
    
   
    local MY_HOST=$(hostname)
    local MY_DATE=$(date +%Y-%m-%d_%H-%M)
    
    local R_DIR="/home/${R_USER}/backups/${MY_HOST}"
    local FILE_NAME="${MY_HOST}_${MY_DATE}.txt"

    echo -e "${YELLOW}[*] Connecting to Server to prepare directory...${NC}"
    
    
    ssh "${R_USER}@${R_IP}" "mkdir -p ${R_DIR}" #Creat the Dir if..

    
    # <<EOF: 
    local report=$(cat <<EOF
##########################################################
          FULL SYSTEM REPORT: ${MY_HOST}
          GENERATED ON: $(date)
##########################################################

[SECTION 1: HARDWARE DETAILS]
$(get_hw_info)

[SECTION 2: SOFTWARE & SECURITY DETAILS]
$(get_detailed_sw_info)

##########################################################
                END OF INTEGRATED REPORT
##########################################################
EOF
)

    #  cat will creat the file and fill it with the content of report
    echo "$report" | ssh "${R_USER}@${R_IP}" "cat > ${R_DIR}/${FILE_NAME}"

    # 
   local LOG_FILE="$HOME/reports/cron.log"
mkdir -p "$HOME/reports"

if [ $? -eq 0 ]; then  #A log file to the Cron..
    echo -e "${GREEN}[✔] Report sent successfully${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M')] SUCCESS - Report sent to ${R_IP}" >> "$LOG_FILE"
else
    echo -e "${RED}[!] Failed to send.${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M')] FAILED  - Could not connect to ${R_IP}" >> "$LOG_FILE"
fi
}






remote_report_menu() {
    clear

    # Get the absolute path of the current script
    local SCRIPT_PATH=$(readlink -f "$0")
    
    while(true) 
    do
    echo "=========================================="
    echo "        REPORT MANAGEMENT        "
    echo "=========================================="
    echo "1) Send Report via SSH"
    echo "2) Send Report via SCP"
    echo "3) Schedule Hourly Delivery (Auto)"
    echo "4) Schedule Daily Delivery (Auto - 00:00)"
    echo "5) STOP All Automated Deliveries"
    echo "6) Back to Main Menu"
    echo "------------------------------------------"
    local R_choice
    read -p "Choose an option [1-6]: " R_choice

    case $R_choice in
        1)
            echo "[*] Sending integrated report now..."
            send_integrated_report
            ;;
        2) 
            echo "[*] Sending integrated report now..."
            send_via_scp
            ;;

        3)
            # Remove existing entries for this script and add a new hourly one
            (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH"; echo "* * * * * $SCRIPT_PATH --auto") | crontab -
            echo -e "${GREEN}[✔] Success: Hourly delivery scheduled.${NC}"
            # crontab -l: give me the list
            # grep: get anything exept the script old cront
            # echo: add the new Cron
            # crontab -:  this is teh nex list.
            ;;
        4)
            #  daily (at midnight)
            (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH"; echo "0 0 * * * $SCRIPT_PATH --auto") | crontab -
            echo -e "${GREEN} Success: Daily delivery scheduled. ${NC}"
            ;;
        5)
            # Clean the crontab from any lines containing this script's path
            crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" | crontab -
            echo -e "${GREEN}[!] Automated delivery disabled.${NC}"
            ;;
        6)
            return
            ;;
        *)
            echo "Invalid option."
            sleep 1
            ;;
    esac
    done
}

