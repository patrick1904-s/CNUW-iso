#!/bin/bash
# ===============================
# 🧹 Wiper ISO Build Script
# ===============================

set -euo pipefail

# Optional: timestamped log
LOG_FILE="./build.log"
echo "Build started at $(date)" | tee "$LOG_FILE"

# Clean previous builds (optional, prevents conflicts)
echo "Cleaning previous build directories..." | tee -a "$LOG_FILE"
sudo rm -rf config/binary config/build config/cache

# Ensure config script is executable
chmod +x config/auto/config

# Run lb config
echo "Configuring live-build..." | tee -a "$LOG_FILE"
cd config/auto
sudo ./config | tee -a "$LOG_F
