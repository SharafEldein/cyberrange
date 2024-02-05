#!/bin/bash

# Check if an argument is passed
if [ $# -eq 0 ]; then
    echo "Usage: $0 <SSH_USER>"
    exit 1
fi

# Source the shared configuration script
source /home/sharaf/CyberRange_v2/config.sh "$1"

# Generate labs
python3 /home/sharaf/CyberRange_v2/labs_repo/labs_generator.py "${SSH_USER}"

mkdir -p "$VOLUME_DIR"

bash /home/sharaf/CyberRange_v2/start_docker_and_lab.sh "$SSH_USER"
