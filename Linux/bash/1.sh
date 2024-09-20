#!/bin/bash

# Function to change passwords to a strong one
change_passwords() {
  local strong_password="StrongP@ssw0rd123!" # Replace with your desired strong password
  for user in $(awk -F: '{ if ($3 >= 1000 && $3 != 65534) print $1 }' /etc/passwd); do
    echo "$user:$strong_password" | chpasswd
    echo "Password changed for user: $user"
  done
}

# Function to set password policies
set_password_policies() {
  echo "Setting password policies..."
  sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
  sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   10/' /etc/login.defs
  sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs
  echo "Password policies set."
}

# Function to enable firewall
enable_firewall() {
  echo "Enabling firewall..."
  ufw default deny incoming
  ufw default allow outgoing
  ufw enable
  echo "Firewall enabled."
}

# Function to configure internet settings (assuming using Firefox)
configure_internet_settings() {
  echo "Configuring internet settings..."
  
  # Set Security Level: High
  echo "user_pref(\"security.mixed_content.block_active_content\", true);" >> /etc/firefox/syspref.js
  echo "user_pref(\"security.mixed_content.block_display_content\", true);" >> /etc/firefox/syspref.js

  # Block all cookies
  echo "user_pref(\"network.cookie.cookieBehavior\", 2);" >> /etc/firefox/syspref.js

  # Never allow websites to request your information
  echo "user_pref(\"network.http.sendRefererHeader\", 0);" >> /etc/firefox/syspref.js

  # Turn on pop-up blocker
  echo "user_pref(\"dom.disable_open_during_load\", true);" >> /etc/firefox/syspref.js

  # Disable toolbars and extensions when in private browsing
  echo "user_pref(\"extensions.privatebrowsing.notification\", false);" >> /etc/firefox/syspref.js
  
  echo "Internet settings configured."
}

# Execute functions
change_passwords
set_password_policies
enable_firewall
configure_internet_settings

echo "All tasks completed."
