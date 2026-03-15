#!/bin/bash


send_email() {
    local recipient="$EMAIL_RECIPIENT"
    local subject="$EMAIL_SUBJECT"
    local report_file="$report_path"

    echo -e "${YELLOW}[*] Sending report via email...${NC}"

    # Checking
    if [ ! -f "$report_file" ]; then
        echo -e "${RED}[!] No report found. Generate a report first.${NC}"
        return
    fi

    # Email:
    {
        echo "To: $recipient"
        echo "Subject: $subject"
        echo ""
        cat "$report_file"
    } | msmtp "$recipient"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✔] Email sent to: $recipient${NC}"
    else
        echo -e "${RED}[!] Failed. Check ~/.msmtp.log${NC}"
    fi
}

