#!/bin/bash

echo "Installing ShellEye dependencies..."
sudo apt update
sudo apt install bash msmtp msmtp-mta openssh-client curl -y
echo "Done! All dependencies installed."
echo "Now run: bash main.sh"