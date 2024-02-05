#!/bin/bash

SSH_USER="$1"

echo "Cleaning up..."
docker rm -f "$SSH_USER" > /dev/null 2>&1
docker network rm "$SSH_USER-net" > /dev/null 2>&1
