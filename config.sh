#!/bin/bash

# User-specific variables
SSH_USER="$1" # Pass this as an argument to the scripts that source this config
CHOSEN_LAB="$2" # Pass this as an argument to the scripts that source this config

# Network and volume configuration
NETWORK_NAME="${SSH_USER}-net"
SUBNET=$(echo "9.$((RANDOM % 5)).$((RANDOM % 256)).0/24") # Random subnet generation
VOLUME_DIR="/home/sharaf/CyberRange_v2/Students/${SSH_USER}/chosen_lab_volume"
VOLUME_DEST="/lab_volume"
STUDENT_LABS_DIR="/home/sharaf/CyberRange_v2/Students/${SSH_USER}/Labs"

VOLUME_DIR="/home/sharaf/CyberRange_v2/Students/${SSH_USER}/chosen_lab_volume"
STUDENT_LABS_DIR="/home/sharaf/CyberRange_v2/Students/${SSH_USER}/Labs"

DOCKER_COMPOSE_FILE="${STUDENT_LABS_DIR}/lab_${CHOSEN_LAB}/${SSH_USER}_compose.yaml"