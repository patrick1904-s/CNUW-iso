#!/bin/sh
# ============================================================================
# Universal Disk Wiper — POSIX Compliant
# Modes:
#   - autonuke     → Wipe all detected disks automatically.
#   - interactive  → User selects disk + wipe method.
# ============================================================================

LOG_FILE="/var/log/wiper.log"
LANG="${1:-en}"

###############################################################################
# Utility Functions
###############################################################################
log() {
  echo "$(date '+%F %T') | $*" >>"$LOG_FILE"
}

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Error: This script must be run as root."
    exit 1
  fi
}

###############################################################################
# Zero-Fill Wipe Method
###############################################################################
wipe_zero_fill() {
  DISK="$1"
  echo "⚠️  Starting zero-fill wipe on $DISK ..."
  log "[INFO] Starting zero-fill on $DISK"

  if [ ! -b "$DISK" ]; then
    echo "❌ Error: $DISK is not a valid block device."
    log "[ERROR] Invalid device: $DISK"
    return 1
  fi

  dd if=/dev/zero of="$DISK" bs=1M status=progress conv=fsync
  if [ $? -eq 0 ]; then
    echo "✅ Zero-fill completed successfully on $DISK"
    log "[SUCCESS] Zero-fill completed on $DISK"
  else
    echo "❌ Zero-fill failed on $DISK"
    log "[FAILURE] Zero-fill failed on $DISK"
  fi
}

###############################################################################
# Autonuke Mode - Wipe All Disks
###############################################################################
autonuke() {
  echo "⚠️  AUTONUKE MODE ENABLED: All disks will be wiped!"
  log "[INFO] Autonuke mode started"

  for DISK in /dev/sd? /dev/nvme?n?; do
    if [ -b "$DISK" ]; then
      wipe_zero_fill "$DISK"
    fi
  done

  log "[INFO] Autonuke mode completed"
  echo "✅ All disks wiped (Zero-fill)."
}

###############################################################################
# Interactive Mode - User Chooses Disk + Method
###############################################################################
interactive() {
  echo "=== Interactive Disk Wiper ==="
  echo "Available Disks:"
  lsblk -d -o NAME,SIZE,MODEL

  echo
  echo "Enter disk name (e.g., sda or nvme0n1):"
  read -r DISK
  DISK="/dev/$DISK"

  echo
  echo "Select Wipe Method:"
  echo "1) Zero-fill (dd if=/dev/zero)"
  read -r METHOD

  case "$METHOD" in
  1)
    wipe_zero_fill "$DISK"
    ;;
  *)
    echo "❌ Invalid selection."
    ;;
  esac
}

###############################################################################
# Main Entry Point
###############################################################################
require_root

MODE="$1"
case "$MODE" in
autonuke)
  autonuke
  ;;
interactive)
  interactive
  ;;
*)
  echo "Usage: $0 [autonuke|interactive]"
  exit 1
  ;;
esac
