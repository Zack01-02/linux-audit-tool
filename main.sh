#!/bin/bash

# Load all modules
source ./config.sh
source ./hardware.sh
source ./software.sh
source ./network.sh
source ./reports.sh
source ./remote.sh
source ./email.sh

show_logo() {
    clear
    
    echo -e "${BLUE}"
    echo "  ██████  ██   ██ ███████ ██      ██      ███████ ██    ██ ███████ "
    echo " ██       ██   ██ ██      ██      ██      ██       ██  ██  ██      "
    echo "  █████   ███████ █████   ██      ██      █████     ████   █████   "
    echo "      ██  ██   ██ ██      ██      ██      ██         ██    ██      "
    echo "  ██████  ██   ██ ███████ ███████ ███████ ███████    ██    ███████ "
    echo -e "${NC}"
    echo -e "${YELLOW}       >>--- Linux Audit & Monitoring Tool v1.0 ---<<${NC}"
    echo ""
}


Case1(){

 while(true)
  do
  echo -e "${YELLOW}===== Software Information =====${NC}"
  echo -e "1) Basic Information"
  echo -e "2) Detailed Information"
  echo -e "3) Generate Report"
  echo -e "${RED}4) Exit${NC}"
  echo -e "${YELLOW}=====================${NC}"

  local choice2
  read -p "Choose an option [1-4]: " choice2

  case $choice2 in
   1) get_sw_info
      read -p "Press Enter to continue..."
     ;;
   2) get_detailed_sw_info
    read -p "Press Enter to continue..."
     ;;
   3) generate_report_menu_s
    read -p "Press Enter to continue..."
    ;;
   4)

     break
    ;;
    *)
     echo -e "${RED}Invalid option! Try again.${NC}"
     sleep 1
    ;;
    esac
done          
}



Case2(){

 while(true)

  do
  echo -e "${YELLOW}===== Hardware Information =====${NC}"
  echo -e "1) Basic Information"
  echo -e "2) Detailed Information"
  echo -e "3) Generate Report"
  echo -e "${RED}4) Exit${NC}"
  echo -e "${YELLOW}=====================${NC}"

  local choice2
  read -p "Choose an option [1-4]: " choice2

  case $choice2 in
   1) get_hw_info
      read -p "Press Enter to continue..."
     ;;
   2) get_detailed_hw_info
    read -p "Press Enter to continue..."
     ;;
   3) generate_report_menu_h
    read -p "Press Enter to continue..."
    ;;
   4)

     break
    ;;
    *)
     echo -e "${RED}Invalid option! Try again.${NC}"
     sleep 1
    ;;
    esac
done
         
}





if [[ "$1" == "--auto" ]] 
then
send_integrated_report
exit 0
fi



while true 
do

show_logo
    echo -e "${YELLOW}===== MAIN MENU =====${NC}"
    echo -e "1) Software Information"
    echo -e "2) Hardware Information"
    echo -e "3) Network Status"
    echo -e "4) Send Status Email"
    echo -e "${RED}5) Exit${NC}"
    echo -e "${YELLOW}=====================${NC}"
    

    read -p "Choose an option [1-5]: " choice

    case $choice in
        1)
            clear
            Case1 
            ;;
        2)
            clear
            Case2
            ;;
        3)
             echo "Working on Network Info..."
             get_netw_info
             read -p "Press Enter to continue..."
             ;;
        4)
           
          remote_report_menu
          ;;

        5)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option! Try again.${NC}"
            sleep 1
            ;;
    esac
done
