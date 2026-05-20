#!/usr/bin/env bash
# =============================================================================
# LucidOS Build Script
# =============================================================================
# This script builds the LucidOS live ISO using live-build.
#
# Usage:
#   bash scripts/build.sh
#
# Requirements:
#   - Must be run on Linux (Debian/Ubuntu strongly recommended)
#   - live-build must be installed: sudo apt install live-build
#   - Run from the project root directory
#
# Output:
#   - ISO file in dist/ directory
# =============================================================================

set -euo pipefail

# --------------------------------------------------------------------------
# Color output helpers
# --------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

# --------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIVE_BUILD_DIR="${PROJECT_ROOT}/live-build"
DIST_DIR="${PROJECT_ROOT}/dist"
ISO_NAME="lucidos-alpha-0.1-amd64.iso"

if [[ "${EUID}" -eq 0 ]]; then
    RUN_LB_BUILD=(lb build)
else
    RUN_LB_BUILD=(sudo lb build)
fi

# --------------------------------------------------------------------------
# Banner
# --------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${CYAN}"
echo "  ██╗     ██╗   ██╗ ██████╗██╗██████╗  ██████╗ ███████╗"
echo "  ██║     ██║   ██║██╔════╝██║██╔══██╗██╔═══██╗██╔════╝"
echo "  ██║     ██║   ██║██║     ██║██║  ██║██║   ██║███████╗"
echo "  ██║     ██║   ██║██║     ██║██║  ██║██║   ██║╚════██║"
echo "  ███████╗╚██████╔╝╚██████╗██║██████╔╝╚██████╔╝███████║"
echo "  ╚══════╝ ╚═════╝  ╚═════╝╚═╝╚═════╝  ╚═════╝ ╚══════╝"
echo ""
echo -e "  LucidOS Build System — Alpha 0.1${RESET}"
echo ""

# --------------------------------------------------------------------------
# Check 1: Must be running on Linux
# --------------------------------------------------------------------------
header "Checking build environment"

if [[ "$(uname -s)" != "Linux" ]]; then
    error "This script must be run on Linux."
    error "You appear to be running: $(uname -s)"
    echo ""
    echo "  Options:"
    echo "  1. Use a Debian VM (recommended)"
    echo "  2. Use WSL2 on Windows (not recommended, may fail)"
    echo "  See BUILDING.md for setup instructions."
    exit 1
fi
success "Running on Linux: $(uname -r)"

# --------------------------------------------------------------------------
# Check 2: Not running as root directly (live-build needs sudo for lb build)
# --------------------------------------------------------------------------
if [[ "${EUID}" -eq 0 ]]; then
    warn "Running as root. This is allowed but not recommended."
    warn "Prefer running as a regular user with sudo access."
fi

# --------------------------------------------------------------------------
# Check 3: live-build is installed
# --------------------------------------------------------------------------
if ! command -v lb &>/dev/null; then
    error "live-build is not installed."
    echo ""
    echo "  Install it with:"
    echo "    sudo apt install live-build"
    echo ""
    echo "  You may also need:"
    echo "    sudo apt install debootstrap squashfs-tools xorriso"
    exit 1
fi
success "live-build found: $(lb --version 2>/dev/null | head -1)"

# --------------------------------------------------------------------------
# Check 4: Required tools
# --------------------------------------------------------------------------
MISSING_TOOLS=()
for tool in debootstrap xorriso; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
    warn "Some recommended tools are missing: ${MISSING_TOOLS[*]}"
    warn "live-build may install them automatically, but if the build fails:"
    echo "  sudo apt install ${MISSING_TOOLS[*]}"
else
    success "Required build tools found"
fi

# --------------------------------------------------------------------------
# Check 5: Disk space (warn if less than 15 GB free)
# --------------------------------------------------------------------------
AVAILABLE_KB=$(df -k "${PROJECT_ROOT}" | awk 'NR==2 {print $4}')
AVAILABLE_GB=$(( AVAILABLE_KB / 1024 / 1024 ))
if [[ "$AVAILABLE_GB" -lt 15 ]]; then
    warn "Low disk space: ${AVAILABLE_GB} GB available (recommended: 20+ GB)"
    warn "Build may fail if space runs out"
else
    success "Disk space: ${AVAILABLE_GB} GB available"
fi

# --------------------------------------------------------------------------
# Check 6: live-build directory exists
# --------------------------------------------------------------------------
if [[ ! -d "${LIVE_BUILD_DIR}" ]]; then
    error "live-build directory not found: ${LIVE_BUILD_DIR}"
    error "Run this script from the project root directory"
    exit 1
fi
success "live-build directory found"

# --------------------------------------------------------------------------
# Pre-build: Create dist directory
# --------------------------------------------------------------------------
header "Preparing output directory"
mkdir -p "${DIST_DIR}"
success "Output directory ready: ${DIST_DIR}"

header "Clearing stale live-build outputs"
rm -rf "${LIVE_BUILD_DIR}/chroot" \
       "${LIVE_BUILD_DIR}/binary" \
       "${LIVE_BUILD_DIR}/build" \
       "${LIVE_BUILD_DIR}/cache"
rm -f "${LIVE_BUILD_DIR}"/*.iso "${LIVE_BUILD_DIR}/build.log" 2>/dev/null || true
success "Stale live-build outputs cleared"

# live-build auto scripts and hooks must be executable on Linux. If this tree
# was copied from Windows, the executable bits may be missing even though the
# shebangs are correct.
header "Normalizing live-build file permissions"
chmod 755 "${LIVE_BUILD_DIR}/auto/config" \
          "${LIVE_BUILD_DIR}/auto/build" \
          "${LIVE_BUILD_DIR}/auto/clean"
if [[ -d "${LIVE_BUILD_DIR}/config/hooks" ]]; then
    find "${LIVE_BUILD_DIR}/config/hooks" -type f -name "*.hook.*" -exec chmod 755 {} \;
fi
if [[ -d "${LIVE_BUILD_DIR}/config/includes.chroot/usr/local/bin" ]]; then
    find "${LIVE_BUILD_DIR}/config/includes.chroot/usr/local/bin" -type f -exec chmod 755 {} \;
fi
if [[ -d "${LIVE_BUILD_DIR}/config/includes.chroot/opt/lucidos-agent/scripts" ]]; then
    find "${LIVE_BUILD_DIR}/config/includes.chroot/opt/lucidos-agent/scripts" -type f -name "*.sh" -exec chmod 755 {} \;
fi
if [[ -f "${LIVE_BUILD_DIR}/config/includes.chroot/etc/sudoers.d/lucidos-live" ]]; then
    chmod 440 "${LIVE_BUILD_DIR}/config/includes.chroot/etc/sudoers.d/lucidos-live"
else
    warn "sudoers file not found; continuing without chmod"
fi
success "live-build scripts, hooks, launchers, and sudoers permissions normalized"

# --------------------------------------------------------------------------
# Build Step 1: Run lb config
# --------------------------------------------------------------------------
header "Configuring live-build"
cd "${LIVE_BUILD_DIR}"

info "Running: lb config"
info "(This reads auto/config and applies settings)"
echo ""

# lb config does NOT need sudo — it only writes config files.
# Only 'lb build' may require elevation (for chroot and mount operations).
# Running lb config with sudo can cause permission issues on config files.
if lb config; then
    success "live-build configured successfully"
else
    error "lb config failed. Check the output above for errors."
    exit 1
fi

# --------------------------------------------------------------------------
# Build Step 2: Run lb build
# --------------------------------------------------------------------------
header "Building LucidOS ISO"
info "This will take 20–60 minutes depending on network speed and hardware."
info "Packages are downloaded fresh on first build."
echo ""
warn "Do not interrupt the build. If it fails, run: bash scripts/clean.sh"
echo ""

START_TIME=$(date +%s)

if "${RUN_LB_BUILD[@]}" 2>&1 | tee "${LIVE_BUILD_DIR}/build.log"; then
    END_TIME=$(date +%s)
    ELAPSED=$(( END_TIME - START_TIME ))
    ELAPSED_MIN=$(( ELAPSED / 60 ))
    ELAPSED_SEC=$(( ELAPSED % 60 ))
    success "Build completed in ${ELAPSED_MIN}m ${ELAPSED_SEC}s"
else
    error "Build failed. Check the log: ${LIVE_BUILD_DIR}/build.log"
    echo ""
    echo "  Common fixes:"
    echo "  - Disk space: df -h"
    echo "  - Missing tools: sudo apt install debootstrap squashfs-tools xorriso"
    echo "  - Clean and retry: bash scripts/clean.sh && bash scripts/build.sh"
    exit 1
fi

# --------------------------------------------------------------------------
# Post-build: Find and move the ISO
# --------------------------------------------------------------------------
header "Locating built ISO"

# live-build produces the ISO in the live-build directory
ISO_FOUND=""
ISO_FOUND="$(find "${LIVE_BUILD_DIR}" -maxdepth 1 -type f \( -name "*.iso" -o -name "*.hybrid.iso" \) -printf '%T@ %p\n' | sort -nr | awk 'NR==1 { $1=""; sub(/^ /, ""); print }')"

if [[ -z "$ISO_FOUND" ]]; then
    error "No ISO file found in ${LIVE_BUILD_DIR}"
    error "The build may have failed silently. Check: ${LIVE_BUILD_DIR}/build.log"
    exit 1
fi

# Copy/move the ISO to dist/
DEST_ISO="${DIST_DIR}/${ISO_NAME}"
info "Copying ISO to: ${DEST_ISO}"
cp "${ISO_FOUND}" "${DEST_ISO}"

ISO_SIZE=$(du -sh "${DEST_ISO}" | cut -f1)
success "ISO ready: ${DEST_ISO} (${ISO_SIZE})"

# --------------------------------------------------------------------------
# Done
# --------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║          LucidOS ISO Build Complete!                 ║${RESET}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════╝${RESET}"
echo ""
echo "  ISO:  ${DEST_ISO}"
echo "  Size: ${ISO_SIZE}"
echo ""
echo "  Next steps:"
echo "  1. Test in QEMU:         bash scripts/test-qemu.sh"
echo "  2. Flash to USB:         see scripts/flash-usb-notes.md"
echo "  3. Install in a VM:      see README.md"
echo ""
