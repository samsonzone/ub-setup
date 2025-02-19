# Linux User Setup and SSH Hardening Script

Automates the process of creating a new user, configuring SSH security, and installing essential system packages on a Debian-based Linux system. 

## Features

- **User Management**
  - Creates a new user if it does not already exist
  - Sets a password for the new user
  - Adds the user to the `ssh` and `sudo` groups

- **SSH Configuration**
  - Optionally imports SSH keys from a specified GitHub user
  - Disables root login over SSH
  - Disables password authentication for SSH, enforcing key-based authentication

- **System Updates & Package Installation**
  - Updates the system
  - Installs essential packages like `build-essential` and `btop`

## Usage

Run the script as root:

```bash
sudo ./script.sh <username>
```

Replace `<username>` with the desired new user.

## Requirements

- Debian-based Linux distribution (Ubuntu, Debian, etc.)
- Root privileges

## Notes

- The script prompts for a password and SSH key import from GitHub.
- Modifies `/etc/ssh/sshd_config` to enforce security best practices.
- Restarts the SSH service to apply changes.

## Disclaimer

Use at your own risk. Ensure you have alternative SSH access before disabling password authentication.
