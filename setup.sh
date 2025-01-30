#!/bin/bash

# Function to check if the script is run as root
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Please run this script as root."
        exit 1
    fi
}

# Function to create a user if they don't exist
create_user_if_not_exists() {
    local username=$1

    if id "$username" &>/dev/null; then
        echo "User '$username' already exists."
    else
        echo "Creating user '$username'..."
        adduser --disabled-password --gecos "" "$username"
        echo "User '$username' created successfully."
    fi
}

# Function to prompt for a password and set it for the user
set_user_password() {
    local username=$1

    echo "Enter password for new user '$username':"
    read -s password1
    echo "Confirm password:"
    read -s password2

    if [[ "$password1" != "$password2" ]]; then
        echo "Error: Passwords do not match."
        exit 1
    fi

    echo "$username:$password1" | chpasswd
    echo "Password set successfully for user '$username'."
}

# Function to add a user to a group
add_user_to_group() {
    local username=$1
    local group=$2

    echo "Adding user '$username' to the '$group' group..."
    groupadd -f "$group"
    usermod -aG "$group" "$username"
    echo "User '$username' added to the '$group' group successfully."
}

# Function to add an SSH key from a GitHub user
add_ssh_key_from_github() {
    local username=$1
    local github_username=$2
    local ssh_dir="/home/$username/.ssh"
    local authorized_keys="$ssh_dir/authorized_keys"

    echo "Adding SSH key from GitHub user '$github_username'..."

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    chown "$username:$username" "$ssh_dir"

    curl -s "https://github.com/$github_username.keys" >> "$authorized_keys"
    chmod 600 "$authorized_keys"
    chown "$username:$username" "$authorized_keys"

    echo "SSH key added successfully."
}

# Function to configure SSH security
configure_ssh_security() {
    echo "Configuring SSH security..."

    sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
    sed -i '/^#PasswordAuthentication/s/^#//' /etc/ssh/sshd_config
    sed -i '/^PasswordAuthentication/s/yes/no/' /etc/ssh/sshd_config

    systemctl restart ssh.service
    echo "SSH security configured: root login and password authentication disabled."
}

# Function to prompt for importing an SSH key
import_ssh_key_prompt() {
    read -p "Do you want to import an SSH key from GitHub? (yes/no): " import_key_choice

    if [[ "$import_key_choice" == "yes" || "$import_key_choice" == "y" ]]; then
        read -p "Enter your GitHub username: " github_username
        add_ssh_key_from_github "$1" "$github_username"
    else
        echo "Skipping SSH key import."
    fi
}

# Function to update and install required packages
update_and_install_packages() {
    echo "Updating system and installing required packages..."

    # Update and install packages
    apt update && apt upgrade -y
    apt install -y build-essential btop

    echo "System updated and packages installed successfully."
}

# Main script execution
main() {
    check_root

    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <username>"
        exit 1
    fi

    local username="$1"

    create_user_if_not_exists "$username"
    set_user_password "$username"
    add_user_to_group "$username" "ssh"
    add_user_to_group "$username" "sudo"
    import_ssh_key_prompt "$username"
    configure_ssh_security
    update_and_install_packages
}

# Run the script
main "$@"