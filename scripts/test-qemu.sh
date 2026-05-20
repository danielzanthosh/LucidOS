#!/usr/bin/env bash
# =============================================================================
# LucidOS QEMU Test Script
# =============================================================================
# Tests the built LucidOS ISO in a QEMU virtual machine.
#
# Usage:
#   bash scripts/test-qemu.sh                    # Auto-find ISO in dist/
#   bash scripts/test-qemu.sh path/to/file.iso   # Use specific ISO
#
# Requirements:
#   qemu-system-x86_64 must be installed:
#     sudo apt install qemu-system-x86       (Debian/Ubuntu)
#     sudo dnf install qemu-system-x86       (Fedora)
#     brew install qemu                      (macOS - for testing only)
#
# Default settings:
#   RAM: 2048 MB (2 GB) — increase if KDE feels slow
#   CPU: 2 cores
#   Display: SDL (windowed)
#   Boot: CD-ROM (ISO)
#
# UEFI mode (optional):
#   To test UEFI boot, uncomment the OVMF lines below.
#   Install OVMF: sudo apt install ovmf
# =============================================================================

set -euo pipefail

# --------------------------------------------------------------------------
# Color helpers
# --------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# --------------------------------------------------------------------------
# Configuration — adjust these if needed
# --------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIST_DIR="${PROJECT_ROOT}/dist"

# QEMU settings
QEMU_RAM="2048"     # MB — KDE Plasma needs at least 1024, 2048 is comfortable
QEMU_CPUS="2"       # Number of virtual CPU cores
QEMU_VGA="virtio"   # virtio is fast; use "std" for compatibility

# Display backend selection:
# 'sdl'  — requires libsdl2 (apt install libsdl2-2.0-0); fails if not installed
# 'gtk'  — requires GTK3 QEMU build (default in Debian's qemu-system-x86 pkg)
# 'none' — headless; combine with -vnc :0 or -serial stdio
# Auto-detect: prefer gtk (more reliable in Debian VMs), fall back to sdl
# QEMU_DISPLAY is detected after QEMU_BIN is resolved below.

# --------------------------------------------------------------------------
# Find the ISO to test
# --------------------------------------------------------------------------
if [[ $# -ge 1 ]]; then
    # Use the ISO path provided as argument
    ISO_PATH="$1"
else
    # Auto-discover: look in dist/ first, then live-build/
    ISO_PATH=""
    for search_dir in "${DIST_DIR}" "${PROJECT_ROOT}/live-build"; do
        for f in "${search_dir}"/*.iso "${search_dir}"/*.hybrid.iso; do
            if [[ -f "$f" ]]; then
                ISO_PATH="$f"
                break 2
            fi
        done
    done
fi

# --------------------------------------------------------------------------
# Validate ISO path
# --------------------------------------------------------------------------
if [[ -z "${ISO_PATH:-}" ]]; then
    error "No ISO found. Build the ISO first:"
    echo "  bash scripts/build.sh"
    echo ""
    echo "Or specify an ISO path:"
    echo "  bash scripts/test-qemu.sh /path/to/lucidos.iso"
    exit 1
fi

if [[ ! -f "${ISO_PATH}" ]]; then
    error "ISO not found: ${ISO_PATH}"
    exit 1
fi

ISO_SIZE=$(du -sh "${ISO_PATH}" | cut -f1)
success "Found ISO: ${ISO_PATH} (${ISO_SIZE})"

# --------------------------------------------------------------------------
# Check for QEMU
# --------------------------------------------------------------------------
QEMU_BIN=""
for qemu_candidate in qemu-system-x86_64 qemu-kvm; do
    if command -v "$qemu_candidate" &>/dev/null; then
        QEMU_BIN="$qemu_candidate"
        break
    fi
done

if [[ -z "${QEMU_BIN}" ]]; then
    error "QEMU not found. Install it with:"
    echo ""
    echo "  Debian/Ubuntu:  sudo apt install qemu-system-x86"
    echo "  Fedora:         sudo dnf install qemu-system-x86"
    echo "  Arch Linux:     sudo pacman -S qemu"
    echo ""
    echo "  Also useful: sudo apt install qemu-utils"
    exit 1
fi
success "QEMU found: $(command -v "${QEMU_BIN}")"

# Auto-detect display backend after selecting the available QEMU binary.
# Override with: QEMU_DISPLAY=gtk|sdl|vnc=:0 bash scripts/test-qemu.sh
if [[ -z "${QEMU_DISPLAY:-}" ]]; then
    if "${QEMU_BIN}" -display help 2>&1 | grep -q "^gtk"; then
        QEMU_DISPLAY="gtk"
    else
        QEMU_DISPLAY="sdl"
    fi
fi

# --------------------------------------------------------------------------
# KVM acceleration check
# --------------------------------------------------------------------------
KVM_FLAGS=""
if [[ -e /dev/kvm ]]; then
    if [[ -r /dev/kvm && -w /dev/kvm ]]; then
        KVM_FLAGS="-enable-kvm"
        success "KVM acceleration available (fast!)"
    else
        warn "KVM device found but not accessible. Running without acceleration."
        warn "To enable: sudo usermod -aG kvm \$USER (then log out and in)"
    fi
else
    warn "KVM not available. Running in software emulation (slower)."
    warn "To check KVM support: kvm-ok"
fi

# --------------------------------------------------------------------------
# UEFI mode (optional — uncomment to enable)
# --------------------------------------------------------------------------
# To test UEFI boot:
# 1. Install OVMF:  sudo apt install ovmf
# 2. Uncomment these two lines:
# OVMF_BIOS="/usr/share/OVMF/OVMF_CODE.fd"
# UEFI_FLAGS="-bios ${OVMF_BIOS}"
# And add ${UEFI_FLAGS} to the QEMU command below.
UEFI_FLAGS=""  # Empty = use legacy BIOS (simpler for testing)

# --------------------------------------------------------------------------
# Launch QEMU
# --------------------------------------------------------------------------
echo ""
echo -e "${BOLD}Starting LucidOS in QEMU...${RESET}"
echo ""
echo "  ISO:      ${ISO_PATH}"
echo "  RAM:      ${QEMU_RAM} MB"
echo "  CPUs:     ${QEMU_CPUS}"
echo "  KVM:      ${KVM_FLAGS:-disabled}"
echo "  Display:  ${QEMU_DISPLAY}"
echo ""
echo "  Tip: To quit QEMU, close the window or press Ctrl+Alt+G then Alt+F4"
echo ""

# Launch QEMU with the ISO
# -m       : Amount of RAM
# -smp     : Number of virtual CPUs
# -cdrom   : The ISO to boot
# -boot d  : Boot from CD-ROM
# -vga     : Graphics adapter (virtio is fastest, std is most compatible)
# -net nic : Basic network interface
# -net user: NAT network (easy, no setup needed)
# -enable-kvm : Hardware acceleration (only if available)
# -display : 'gtk' (recommended for Debian VMs) or 'sdl' (needs libsdl2)
#            If this fails: try "-display sdl" or "-display vnc=:0"
"${QEMU_BIN}" \
    ${KVM_FLAGS} \
    ${UEFI_FLAGS} \
    -m "${QEMU_RAM}" \
    -smp "${QEMU_CPUS}" \
    -cdrom "${ISO_PATH}" \
    -boot d \
    -vga "${QEMU_VGA}" \
    -net nic \
    -net user \
    -name "LucidOS Alpha 0.1" \
    -display "${QEMU_DISPLAY}"

# --------------------------------------------------------------------------
# Post-run
# --------------------------------------------------------------------------
echo ""
success "QEMU session ended."
echo ""
echo "  Next steps:"
echo "  - If it booted successfully, try 'Install LucidOS' from the desktop"
echo "  - If it didn't boot, check: bash scripts/verify-host.sh"
echo "  - See BUILDING.md for troubleshooting"
