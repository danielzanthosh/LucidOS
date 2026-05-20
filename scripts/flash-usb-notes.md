# Flashing LucidOS to a USB Drive

This document explains how to write the LucidOS ISO to a USB drive to create a bootable live USB.

---

## ⚠️ Warning

**Flashing to the wrong device will destroy all data on it.**

Always double-check the device path before running `dd` or any flashing tool.

---

## Finding Your USB Drive

### On Linux:
```bash
# List all block devices (before and after inserting USB)
lsblk

# Or with more detail:
sudo fdisk -l

# Look for your USB drive — it will usually be /dev/sdb or /dev/sdc
# Do NOT use /dev/sda (that's usually your main hard drive)
```

Example output:
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 500.1G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
└─sda2   8:2    0 499.6G  0 part /
sdb      8:16   1  14.4G  0 disk       <--- This is your 14 GB USB drive
└─sdb1   8:17   1  14.4G  0 part
```

---

## Method 1: dd (Linux — Recommended)

```bash
# STEP 1: Identify your USB drive (e.g., /dev/sdb)
lsblk

# STEP 2: Unmount if mounted
sudo umount /dev/sdX*

# STEP 3: Flash the ISO
# Replace /dev/sdX with your actual USB device (e.g., /dev/sdb)
# Replace the path to the ISO with your actual ISO path
sudo dd if=dist/lucidos-alpha-0.1-amd64.iso \
        of=/dev/sdX \
        bs=4M \
        status=progress \
        oflag=sync

# STEP 4: Wait for completion (may take 5–15 minutes)
# STEP 5: Eject the USB
sudo eject /dev/sdX
```

**Do not remove the USB until the command completes and the prompt returns.**

---

## Method 2: cp (Linux — Alternative)

On modern Linux, `cp` can work similarly to `dd` for ISO images:

```bash
sudo cp dist/lucidos-alpha-0.1-amd64.iso /dev/sdX
sync
sudo eject /dev/sdX
```

---

## Method 3: Rufus (Windows — Recommended for Windows users)

1. Download [Rufus](https://rufus.ie) (free, open source)
2. Insert your USB drive
3. Open Rufus
4. Under "Device", select your USB drive
5. Under "Boot selection", click "SELECT" and choose the LucidOS ISO
6. **Important**: When asked about write mode, select **DD Image** (not ISO mode)
7. Click START
8. Wait for completion

---

## Method 4: Balena Etcher (Windows/macOS/Linux)

1. Download [Balena Etcher](https://www.balena.io/etcher/)
2. Click "Flash from file" and select the ISO
3. Click "Select target" and choose your USB drive
4. Click "Flash!"

Etcher is simpler than Rufus but uses DD mode by default, which is correct for hybrid ISOs.

---

## Method 5: GNOME Disks (Linux GUI)

1. Open GNOME Disks
2. Select your USB drive from the left panel
3. Click the menu (⋮) → "Restore Disk Image..."
4. Select the LucidOS ISO
5. Click "Start Restoring..."

---

## Verifying the Flash

After flashing, you can verify the write was successful:

```bash
# Check that the ISO is readable from the USB
sudo dd if=/dev/sdX bs=4M count=1 status=none | head -c 8 | xxd
# Should show: 45 46 49 20 50 41 52 54 (EFI PART) or similar boot magic bytes
```

---

## Booting from USB

1. Insert the USB into the target computer
2. Restart the computer
3. Press the boot menu key during startup:
   - **Dell**: F12
   - **HP**: F9 or Esc
   - **Lenovo**: F12 or F1
   - **ASUS**: F8 or Esc
   - **Acer**: F12
   - **Apple Mac**: Hold Option/Alt
4. Select your USB drive from the boot menu
5. LucidOS should start booting

### If the USB doesn't appear in the boot menu:
- Check if Secure Boot is enabled (disable it in BIOS/UEFI for Live USB)
- Try both UEFI and Legacy/BIOS boot modes
- Try a different USB port (preferably USB 2.0 if USB 3.0 has issues)
- Re-flash the USB (the write may have failed)

---

## USB Drive Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Capacity | 4 GB | 8 GB+ |
| Speed | USB 2.0 | USB 3.0+ |
| Format | Will be overwritten | Any |

Fast USB drives (USB 3.0/3.1) will boot significantly faster than slow USB 2.0 drives.

---

## Persistence (Optional — Not in Alpha 0.1)

Alpha 0.1 does not support persistent storage. Changes made in the live session are lost on reboot.

Persistent USB support is planned for a future release. For now:
- Use the "Install LucidOS" option to install to a hard drive/SSD
- Or keep your work in a separate partition on the USB drive

---

*LucidOS is a hybrid ISO — it supports both BIOS and UEFI boot.*
