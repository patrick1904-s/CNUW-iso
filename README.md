# ✅ Universal Disk Wiper – Development Checklist

A modular, ISO-based, multilingual, open-source **disk wiping tool** that complies with **NIST SP 800-88**.  
Bootable via USB/CD-ROM, supports **HDD, SSD, NVMe**, and securely handles **HPA/DCO removal**.  

---
##  1. Environment Setup
- [X] Install build tools: `live-build`, `debootstrap`, `xorriso`, `squashfs-tools`, `syslinux`, `isolinux`.
- [X] Set up project directory structure:

----

file struture

config/
├── includes.binary/
├── includes.chroot/usr/local/bin/
├── includes.chroot/usr/local/share/wiper/lang/
└── package-lists/
tests/
docs/
build.sh

- [X] Initialize git repo with `.gitignore` and `README.md`.
- [X] Create test lab with **QEMU/KVM** + virtual disks (HDD/SSD/NVMe simulation).

---

## 📌 2. Base ISO (Debian Live)
- [X] Configure `live-build` for **CLI-only Debian Live (bookworm)**.
- [ ] Add dependencies via `config/package-lists/wiper.list.chroot`:

---
tools

dialog
whiptail
nvme-cli
hdparm
util-linux
coreutils
secure-delete

---
- [ ] Ensure ISO is **hybrid** (bootable from USB & CD-ROM).

---

## 📌 3. Bootloader (ISOLINUX/SYSLINUX)
- [ ] Create `config/includes.binary/isolinux.cfg` with:
- Clear warning ⚠️ about **PERMANENT DATA DESTRUCTION**.
- Default entry → autostart `wiper.sh`.
- Menu option to select language (`--lang=`).
- [ ] Add custom boot splash (optional but user-friendly).

---

## 📌 4. Wipe Engine (`wiper.sh`)
- [ ] POSIX-compliant Bash script with two modes:
- `autonuke` → wipe all detected disks.
- `interactive` → user selects disk + method.
- [ ] Supported wipe methods:
- [ ] **Zero-fill** (`dd if=/dev/zero`).
- [ ] **Shred** (3-pass + final zero pass).
- [ ] **NVMe secure erase** (`nvme-cli`).
- [ ] **ATA secure erase** (`hdparm --security-erase`).
- [ ] Handle **HPA/DCO removal** (`hdparm --yes-i-know-what-i-am-doing --dco-restore`).
- [ ] Safety confirmations:
- User must type full device name (`/dev/sda`).
- Show warning before destruction.
- [ ] Logging:
- Store detailed logs in `/var/log/wiper.log`.
- Include start/end time, method, device, status.
- [ ] Compliance:
- Implement wiping patterns consistent with **NIST SP 800-88 Rev. 1**.

---

## 📌 5. Multilingual TUI
- [ ] Use `dialog` for friendly, menu-driven UI.
- [ ] Language files:
config/includes.chroot/usr/local/share/wiper/lang/en.lang
config/includes.chroot/usr/local/share/wiper/lang/es.lang
- [ ] Load strings dynamically (English default).
- [ ] Boot option `--lang=xx` or menu selection.
- [ ] Confirmations, warnings, and progress messages translated.

---

## 📌 6. Safety & Testing
- [ ] Implement **dry-run mode** (`--dry-run`) for testing without wiping.
- [ ] Write test script: `tests/dry-run-loopback.sh` (simulates loop devices).
- [ ] QEMU testing:
- Attach virtual HDD + SSD + NVMe.
- Validate each wipe method.
- Verify log outputs.
- [ ] Confirm wipes via:
- `hexdump` / `strings` on wiped devices.
- Recovery tools (should fail).

---

## 📌 7. Documentation
- [ ] `README.md` with:
- Safety warning ⚠️
- Build instructions (`./build.sh`)
- Usage instructions (autonuke/interactive).
- Screenshot of TUI.
- [ ] Add `docs/planV0.txt` (design notes).
- [ ] Add contribution guidelines + license (GPLv3 or similar).

---

## 📌 8. Build Automation
- [ ] Create `build.sh` wrapper:
```bash
#!/bin/bash
sudo lb clean
sudo lb build
mv live-image-amd64.hybrid.iso universal-disk-wiper.iso

📌 9. Release
