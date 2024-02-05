#!/bin/bash

STUDENT_ID="$1"
PUBLIC_KEY="$2"
USERNAME="$3"
EMAIL="$4"

# Set database credentials as environment variables
DB_USER="cyberrange_sharaf"
DB_PASS="P@\$\$@2166db"
DB_NAME="cyberrange_db"

# Validate email-id pair in the database
validate_email_id_pair() {
    local email="$1"
    local id="$2"
    local query="SELECT EXISTS(SELECT 1 FROM email_id_pairs WHERE email='$EMAIL' AND student_id=$STUDENT_ID)"

    local result=$(echo $query | mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N )
    # local result = $(echo $query | mysql)
    if [ "$result" != 1 ]; then
        echo "Invalid email-ID pair."
        exit 1
    fi
}

# Check and validate email-id pair
validate_email_id_pair "$EMAIL" "$STUDENT_ID"

# Update the authorized_keys file
AUTHORIZED_KEYS="/home/sharaf/.ssh/authorized_keys"

# Prepare the public key entry
KEY_ENTRY="command=\"/home/sharaf/CyberRange_v2/setup_environment.sh ${USERNAME}_${STUDENT_ID}\" $PUBLIC_KEY"

# Append the new public key to the authorized_keys file if not already present
if ! grep -Fxq "$KEY_ENTRY" "$AUTHORIZED_KEYS"; then
    echo "$KEY_ENTRY" >> "$AUTHORIZED_KEYS"
else
    echo "Public key already exists for ${USERNAME}_${STUDENT_ID}."
fi

# Check if user directory exists
USER_DIR="/home/sharaf/CyberRange_v2/Students/${USERNAME}_${STUDENT_ID}/Labs"
if [ ! -d "$USER_DIR" ]; then
    # Create user directory
    mkdir -p "$USER_DIR" || { echo "Failed to create user directory for ${USERNAME}_${STUDENT_ID}."; exit 1; }
fi

echo "User ($USERNAME) registration/update completed."

# Insert user info into students_data table
query="INSERT INTO students_data (student_id, username, email, public_key, comments) VALUES ($STUDENT_ID, '$USERNAME', '$EMAIL', '$PUBLIC_KEY', 'nothing') ON DUPLICATE KEY UPDATE username='$USERNAME', email='$EMAIL'"
echo $query | mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N 