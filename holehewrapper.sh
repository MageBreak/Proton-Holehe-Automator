#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./holehewrapper.sh target@email.com"
    exit 1
fi

TARGET=$1
mkdir -p ~/holehe_logs
LOGFILE=~/holehe_logs/scan_$(date +%Y%m%d_%H%M%S)_${TARGET}.txt

# --- VPN FUNCTIONS ---
start_vpn() {
    echo "[*] Shielding connection..."
    VPN_LOG=$(sudo dbus-run-session protonvpn connect 2>&1)
    if echo "$VPN_LOG" | grep -Ei "Connected|IP address" > /dev/null; then
        echo "[+] VPN Active: $(echo "$VPN_LOG" | grep "Connected" | head -n 1)"
        sleep 3
    else
        echo "[!] VPN Failed. Aborting."
        exit 1
    fi
}

rotate_vpn() {
    echo "[!] Rate limit detected. Rotating identity..."
    sudo dbus-run-session protonvpn disconnect > /dev/null 2>&1
    sleep 2
    start_vpn
}

stop_vpn() {
    echo "[*] Collapsing tunnel..."
    sudo dbus-run-session protonvpn disconnect > /dev/null 2>&1
}

# --- MAIN EXECUTION ---
start_vpn

echo "[+] Starting OSINT scan for $TARGET..."
# Use 'tee' to show results in CLI AND save to the log file
holehe "$TARGET" --only-used | tee "$LOGFILE"

# CHECK FOR RATE LIMITS [x]
if grep -q "\[x\]" "$LOGFILE"; then
    # Grab only actual site names, excluding the header 'Email'
    FAILED_SITES=$(grep "\[x\]" "$LOGFILE" | grep -v "Email" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
    
    if [ ! -z "$FAILED_SITES" ]; then
        rotate_vpn
        echo "[+] Retrying ONLY failed sites: $FAILED_SITES"
        holehe "$TARGET" --only-used --only-modules "$FAILED_SITES" | tee -a "$LOGFILE"
    fi
fi

echo -e "\n[✔] Report finalized at: $LOGFILE"
stop_vpn
