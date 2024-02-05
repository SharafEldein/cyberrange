if [ $# -ne 2 ]; then
    echo "Usage: $0 <SSH_USER> <CHOSEN_LAB>"
    exit 1
fi

source /home/sharaf/CyberRange_v2/config.sh $1 $2

cp "$DOCKER_COMPOSE_FILE" "$VOLUME_DIR"

docker exec "$SSH_USER" docker-compose -f "/$VOLUME_DEST/${SSH_USER}_compose.yaml" up -d > /dev/null 2>&1


echo "Available containers for Lab ${CHOSEN_LAB}:"
containers=($(docker exec "$SSH_USER" docker ps --format "{{.Names}}" | grep "lab_${CHOSEN_LAB}"))
for i in "${!containers[@]}"; do
    echo "$((i+1)). ${containers[i]}"
done

# Input sanitization: Ensure the user input is a valid positive integer
read -p "Enter the number of the container you want to attach to: " container_number
if ! [[ "$container_number" =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid input. Please enter a valid positive integer."
    exit 1
fi

let container_index=container_number-1

CHOSEN_CONTAINER=${containers[$container_index]}

if [ ! -z "$CHOSEN_CONTAINER" ]; then
    echo "Attaching to container $CHOSEN_CONTAINER..."
    docker exec -it "$SSH_USER" docker exec -it "$CHOSEN_CONTAINER" /bin/bash
else
    echo "Container $CHOSEN_CONTAINER is not running."
fi

/bin/bash /home/sharaf/CyberRange_v2/cleanup_environment.sh "$SSH_USER"