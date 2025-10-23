#!/bin/sh
# ==============================================
# CyberNova Wipe Engine (POSIX-Compliant)
# ==============================================
# Modes:
#   1. autonuke     -> Automatically wipe ALL detected disks.
#   2. interactive  -> User selects disk + method.
#
# Safe, modular, and lightweight for live ISO use.
# ==============================================

set -eu

# --------- CONFIG ---------
LANG_DIR="/usr/local/share/wiper/lang"
LOG_FILE="/var/log/wiper.log"
WIPE_METHOD="shred"  # default method

# --------- FUNCTIONS ---------
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

banner() {
    printf "\033[1;31m"
    echo "========================================="
    echo " ⚠️  CYBERNOVA DISK WIPER  ⚠️"
    echo "========================================="
    printf "\033[0m\n"
}

detect_disks() {
    # Detect all block devices except loopback, CD-ROMs, etc.
    lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}'
}

wipe_disk() {
    disk="$1"
    method="$2"
    log "Wiping $disk using $method"
    echo "Wiping $disk..."
    case "$method" in
        dd)
            dd if=/dev/zero of="$disk" bs=1M status=progress || true
            ;;
        shred)
            shred -v -n 3 "$disk" || true
            ;;
        blkdiscard)
            blkdiscard "$disk" || true
            ;;
        *)
            echo "Unknown method: $method" >&2
            ;;
    esac
    sync
    log "Completed wiping $disk"
}

autonuke_mode() {
    banner
    echo "🚨 AUTO-NUKE MODE ACTIVATED 🚨"
    echo "This will destroy ALL DATA on all detected drives!"
    echo "Press Ctrl+C to cancel within 10 seconds..."
    sleep 10
    for d in $(detect_disks); do
        wipe_disk "$d" "$WIPE_METHOD"
    done
    echo "✅ All disks wiped successfully."
}

interactive_mode() {
    banner
    echo "INTERACTIVE MODE"
    echo ""
    echo "Detected disks:"
    echo ""
    detect_disks
    echo ""
    printf "Enter disk to wipe (e.g. /dev/sda): "
    read -r target
    printf "Select method (dd/shred/blkdiscard): "
    read -r method
    wipe_disk "$target" "$method"
    echo "✅ Done."
}

usage() {
    echo "Usage: $0 [autonuke|interactive]"
}

# --------- ENTRY POINT ---------
case "${1:-}" in
    autonuke)
        autonuke_mode
        ;;
    interactive)
        interactive_mode
        ;;
    *)
        usage
        ;;
esac

