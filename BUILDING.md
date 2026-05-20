# Building LucidOS

This guide explains how to build the LucidOS ISO from source using `live-build` on a Debian-based host.

---

## âš ï¸ Important: Build Host Requirements

LucidOS **must** be built on a Debian or Ubuntu Linux system. The recommended setup is:

| Requirement | Recommended | Minimum |
|-------------|-------------|---------|
| OS | Debian 12 (Bookworm) | Debian 11 or Ubuntu 22.04 |
| Architecture | amd64 | amd64 |
| RAM | 8 GB | 4 GB |
| Free disk | 30 GB | 20 GB |
| CPU cores | 4+ | 2 |
| Internet | Required | Required |

---

## âš ï¸ WSL Warning

**Windows Subsystem for Linux (WSL1 and WSL2) is not recommended for building live-build ISOs.**

Reasons:
- `live-build` uses `debootstrap`, which requires certain kernel features
- `squashfs-tools` may behave unexpectedly in WSL
- Loop device mounting (used for ISO creation) is restricted or unavailable in WSL
- WSL2 supports some of these but behavior varies by Windows build and WSL version

**Recommended alternative:** Use a Debian 12 VM in VirtualBox, VMware, or QEMU on your Windows machine.

If you must use WSL2:
```bash
# Check if loop devices exist
ls /dev/loop*

# If they don't exist, live-build will likely fail
# Consider using a full Debian VM instead
```

---

## Setting Up a Debian VM (Recommended)

### Using VirtualBox on Windows:

1. Download [VirtualBox](https://www.virtualbox.org/)
2. Download [Debian 12 netinstall ISO](https://www.debian.org/CD/netinst/)
3. Create a VM:
   - Type: Linux, Debian (64-bit)
   - RAM: 4â€“8 GB
   - Disk: 40 GB (dynamically allocated)
4. Install Debian with default settings
5. After install, set up a shared folder to access your LucidOS project

### Shared folder setup in VirtualBox:
```bash
# In the Debian VM, mount the shared folder
sudo mkdir -p /mnt/lucidos-project
sudo mount -t vboxsf LucidOS /mnt/lucidos-project

# Or add to /etc/fstab for auto-mount:
# LucidOS  /mnt/lucidos-project  vboxsf  defaults,uid=1000,gid=1000  0  0
```

---

## Installing Required Build Tools

On your Debian build host:

```bash
# Update package list
sudo apt update

# Install live-build and dependencies
sudo apt install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-common \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools

# Optional but useful
sudo apt install -y git curl wget
```

### Verify installation:
```bash
lb --version
debootstrap --version
```

---

## Build Commands

### Quick build (recommended first time):
```bash
# From the project root
bash scripts/verify-host.sh   # Check host readiness
bash scripts/build.sh          # Build the ISO
```

### Manual build (for debugging):
```bash
cd live-build

# Step 1: Configure
sudo lb config

# Step 2: Build (this will take 15â€“60 minutes depending on network/speed)
sudo lb build

# Step 3: Find your ISO
ls -lh *.iso
```

### Cleaning up:
```bash
bash scripts/clean.sh
# or manually:
cd live-build && sudo lb clean
```

---

## Building with GitHub Actions

The repository includes a `Build LucidOS ISO` GitHub Actions workflow for CI
builds of Alpha 0.1.

To run it manually:

1. Open the repository on GitHub.
2. Go to **Actions**.
3. Select **Build LucidOS ISO**.
4. Click **Run workflow** and run it from `main`.

The workflow also runs on pushes to `main` when files under `live-build/`,
`scripts/`, or `.github/workflows/` change.

When the run completes, open the run summary and download the
`lucidos-alpha-iso` artifact. It contains the ISO from `dist/*.iso` and is kept
for 7 days.

GitHub Actions does not replace local GUI testing. After downloading the ISO,
boot it locally with QEMU, VirtualBox, or VMware to verify KDE, SDDM, Calamares,
and live-session behavior. Runner disk space can vary; if CI fails from low
space, tune the cleanup step in `.github/workflows/build-iso.yml`.

---

## Build Process Overview

The `lb build` command performs these steps:

1. **bootstrap** â€” Downloads and installs a minimal Debian system using `debootstrap`
2. **chroot** â€” Installs additional packages inside the chroot environment
3. **binary** â€” Creates the final bootable image

This process typically takes **20â€“60 minutes** on first run, depending on:
- Your internet speed (packages are downloaded fresh)
- Your CPU and disk speed
- How many packages are included

Subsequent builds are faster because cached packages are reused.

---

## Troubleshooting

### Error: `lb: command not found`
```bash
sudo apt install live-build
```

### Error: `debootstrap: command not found`
```bash
sudo apt install debootstrap
```

### Error: Permission denied during build
Always run `lb build` with `sudo`:
```bash
sudo lb build
```

### Error: Not enough disk space
The build directory will use 5â€“15 GB during build. Ensure you have 20+ GB free.
```bash
df -h  # Check available space
```

### Error: Network timeouts during debootstrap
Try changing the Debian mirror in `live-build/auto/config`:
```bash
# Change --mirror-bootstrap to a mirror near you
# e.g., http://ftp.us.debian.org/debian/ for US
#        http://ftp.de.debian.org/debian/ for Germany
```

A list of mirrors: https://www.debian.org/mirror/list

### Error: squashfs or loop device errors in WSL
You need a real Linux environment. See the WSL warning above.

### Error: Calamares not found or not working
If `calamares-settings-debian` is not in Debian stable repos, you may need to:
```bash
# Option 1: Use calamares from backports
echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt update
sudo apt install -t bookworm-backports calamares

# Option 2: Configure calamares manually
# See /etc/calamares/ for configuration files
```

### ISO doesn't boot in VirtualBox
- Ensure you selected "Legacy" or "EFI" boot correctly
- The LucidOS ISO is a hybrid ISO (supports both BIOS and UEFI)
- In VirtualBox, try toggling "Enable EFI (special OSes only)"

### KDE Plasma doesn't start
Check for display manager issues:
```bash
# In a live session, check SDDM logs
journalctl -u sddm

# Try starting plasma manually
startplasma-x11
```

---

## Disk Space Notes

| Stage | Space Used |
|-------|-----------|
| Source code (this repo) | ~5 MB |
| Downloaded packages cache | 3â€“8 GB |
| Build chroot | 4â€“8 GB |
| Final ISO | 1.5â€“3 GB |
| **Total needed** | **~20 GB** |

The build cache (packages) is kept in `live-build/cache/` and reused on subsequent builds. Delete it with `lb clean --cache` to force a fresh download.

---

## Advanced: Custom Package Mirror

To use a local or faster mirror, edit `live-build/auto/config`:

```bash
# Add mirror options to lb config:
--mirror-bootstrap "http://your-mirror.example.com/debian/"
--mirror-chroot "http://your-mirror.example.com/debian/"
--mirror-binary "http://your-mirror.example.com/debian/"
```

---

## Advanced: Building for Different Architectures

Currently LucidOS targets `amd64` only. To build for `arm64` (experimental):

```bash
# Would require:
# 1. Changing --architectures in auto/config
# 2. Cross-compilation tools
# 3. Different kernel package

# This is not supported in Alpha 0.1
```

---

## After Building

Once the ISO is built:

1. **Test in QEMU:**
   ```bash
   bash scripts/test-qemu.sh
   ```

2. **Flash to USB:**
   ```bash
   # See scripts/flash-usb-notes.md
   ```

3. **Install in a VM:** See README.md

---

## Getting Help

- Check the [live-build documentation](https://live-team.pages.debian.net/live-manual/)
- Review logs in `live-build/build/` after a failed build
- Open an issue in the project repository
