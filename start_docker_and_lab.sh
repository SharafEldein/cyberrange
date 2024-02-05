#!/bin/bash

# Check if an argument is passed
if [ $# -eq 0 ]; then
    echo "Usage: $0 <SSH_USER>"
    exit 1
fi

# Source the shared configuration script to ensure all variables are correctly initialized
source /home/sharaf/CyberRange_v2/config.sh "$1"

# Create the Docker network with the generated subnet, if it doesn't already exist
echo "Generating isolated environment for Student: $(echo $SSH_USER | cut -d '_' -f 1)..."
docker network ls | grep -w "$NETWORK_NAME" &> /dev/null || \
docker network create --subnet="$SUBNET" "$NETWORK_NAME" > /dev/null

# Check if the DinD container for the user exists and is running
DIND_RUNNING=$(docker ps -q -f name="$SSH_USER" -f status=running)
if [ -z "$DIND_RUNNING" ]; then
    docker run -d --privileged \
        --name "$SSH_USER" \
        --network "$NETWORK_NAME" \
        -v "$VOLUME_DIR":"$VOLUME_DEST" dind-custom:latest > /dev/null

    echo "Waiting..."
    until docker exec "$SSH_USER" docker info &> /dev/null; do
        echo -n "."
        sleep 1
    done

    # Load the Docker image
    docker exec "$SSH_USER" docker load -i /seed-ubuntu-large.tar > /dev/null && \
    docker exec "$SSH_USER" rm /seed-ubuntu-large.tar
else
    echo "Environment for ${SSH_USER} is already running."
fi


# List and select the lab to run
bash /home/sharaf/CyberRange_v2/list_and_select_lab.sh "$SSH_USER"