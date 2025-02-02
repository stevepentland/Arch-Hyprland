#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Global Functions for Scripts #

set -e

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
RESET="$(tput sgr0)"

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Function that would show a progress bar to the user on one line
show_progress() {
    local pid=$1
    local package_name=$2
    local dots=""
    
    # Print initial message only once
    echo -n "${NOTE} Installing ${YELLOW}$package_name${RESET} ..."
    
    # Loop until the process is running
    while ps -p $pid &> /dev/null; do
        dots+="."
        echo -ne "\r${NOTE} Installing ${YELLOW}$package_name${RESET} ...$dots"  # Update the same line with dots
        sleep 1
    done
    
    # After the process finishes, show "Done!" on the same line
    echo -ne "\r${NOTE} Installing ${YELLOW}$package_name${RESET} ...$dots Done!"  # Replace dots with Done!
}


# Function to install packages with pacman
install_package_pacman() {
  # Check if package is already installed
  if pacman -Q "$1" &>/dev/null ; then
    echo -e "${OK} ${MAGENTA}$1${RESET} is already installed. Skipping..."
  else
    # Run pacman and redirect all output to a log file
    (
      stdbuf -oL sudo pacman -S --noconfirm --needed "$1" 2>&1
    ) >> "$LOG" 2>&1 &
    PID=$!
    show_progress $PID "$1"  # Show progress bar while the process runs

    # Double check if package is installed
    if pacman -Q "$1" &>/dev/null ; then
      echo -e "\n${OK} Package ${YELLOW}$1${RESET} has been successfully installed!"
    else
      echo -e "\n${ERROR} ${YELLOW}$1${RESET} failed to install. Please check the $LOG. You may need to install manually."
      exit 1
    fi
  fi
}

ISAUR=$(command -v yay || command -v paru)

# Function to install packages with either yay or paru
install_package() {
  # Checking if package is already installed
  if $ISAUR -Q "$1" &>> /dev/null ; then
    echo -e "${OK} ${MAGENTA}$1${RESET} is already installed. Skipping..."
  else
    # Run yay/paru and redirect all output to a log file
    (
      stdbuf -oL $ISAUR -S --noconfirm --needed "$1" 2>&1
    ) >> "$LOG" 2>&1 &
    PID=$!
    show_progress $PID "$1"  # Show progress bar while the process runs
    
    # Double check if package is installed
    if $ISAUR -Q "$1" &>> /dev/null ; then
      echo -e "\n${OK} Package ${YELLOW}$1${RESET} has been successfully installed!"
    else
      # Something is missing, exiting to review log
      echo -e "\n${ERROR} ${YELLOW}$1${RESET} failed to install :( , please check the install.log. You may need to install manually! Sorry I have tried :("
      exit 1
    fi
  fi
}
