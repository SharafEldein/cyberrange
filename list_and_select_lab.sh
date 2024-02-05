#!/bin/bash

# Check if an argument is passed
if [ $# -eq 0 ]; then
    echo "Usage: $0 <SSH_USER>"
    exit 1
fi

source /home/sharaf/CyberRange_v2/config.sh "$1"

echo "Available labs for $(echo $SSH_USER|cut -d "_" -f 1):"
labs=($(ls "${STUDENT_LABS_DIR}" | grep "^lab_" | sed 's/^lab_//'))
for i in "${!labs[@]}"; do
    echo "$((i+1)). Lab ${labs[i]}"
done

# Input sanitization: Ensure the user input is a valid positive integer
read -p "Enter the lab number you want to run: " lab_index
if ! [[ "$lab_index" =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid input. Please enter a valid positive integer."
    exit 1
fi

CHOSEN_LAB=${labs[$((lab_index-1))]}

if [[ -z "$CHOSEN_LAB" ]]; then
    echo "Invalid lab selection."
    exit 1
else
    echo "You have selected Lab ${CHOSEN_LAB}."
    /bin/bash /home/sharaf/CyberRange_v2/start_selected_lab.sh "$SSH_USER" "$CHOSEN_LAB"
fi
