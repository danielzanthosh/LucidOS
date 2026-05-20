#!/usr/bin/env bash
# =============================================================================
# LucidOS Host Verification Script
# =============================================================================
# Checks whether the current system is ready to build the LucidOS ISO.
#
# Usage:
#   bash scripts/verify-host.sh
#
# Checks performed:
#   1. Operating system (must be Linux)
#   2. WSL detection (warn if WSL, may have issues)
#   3. Required build tools
#   4. Available disk space
#   5. Available RAM
#   6. Debian/Ubuntu detection
#   7. User not root
#   8. Internet connectivity (basic check)
# =============================================================================

set -euo pipefail

# --------------------------------------------------------------------------
# Color helpers
# --------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

pass()  { echo -e "  ${GREEN}✓${RESET} $*"; }
fail()  { echo -e "  ${RED}✗${RESET} $*"; FAILURES=$(( FAILURES + 1 )); }
warn()  { echo -e "  ${YELLOW}⚠${RESET} $*"; WARNINGS=$(( WARNINGS + 1 )); }
info()  { echo -e "  ${BLUE}→${RESET} $*"; }
section() { echo -e "\n${BOLD}${CYAN}[ $* ]${RESET}"; }

FAILURES=0
WARNINGS=0

# --------------------------------------------------------------------------
# Header
# --------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${CYAN}LucidOS Host Verification${RESET}"
echo -e "${CYAN}Checking whether this system can build the LucidOS ISO...${RESET}"

# --------------------------------------------------------------------------
# Section 1: Operating System
# --------------------------------------------------------------------------
section "Operating System"

OS_NAME="$(uname -s)"
if [[ "$OS_NAME" != "Linux" ]]; then
    fail "Not running on Linux (detected: ${OS_NAME})"
    echo ""
    echo -e "  ${RED}LucidOS must be built on Linux.${RESET}"
    echo "  Recommended: Debian 12 (Bookworm) VM"
    echo "  See BUILDING.md for VM setup instructions."
    echo ""
    # If on macOS or Windows, exit now — nothing else will work
    exit 1
else
    KERNEL="$(uname -r)"
    pass "Linux detected (kernel: ${KERNEL})"
fi

# --------------------------------------------------------------------------
# Section 2: WSL Detection
# --------------------------------------------------------------------------
section "WSL Detection"

IS_WSL=false
if grep -qi 'microsoft\|wsl' /proc/version 2>/dev/null; then
    IS_WSL=true
fi
if [[ -e /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
    IS_WSL=true
fi

if [[ "$IS_WSL" == true ]]; then
    warn "Running inside Windows Subsystem for Linux (WSL)"
    warn "live-build may fail in WSL due to:"
    warn "  - Loop device restrictions"
    warn "  - debootstrap limitations"
    warn "  - squashfs issues"
    info "Recommended: Use a Debian VM in VirtualBox or VMware instead"
    info "See BUILDING.md for VM setup guide"
else
    pass "Not running in WSL (good)"
fi

# --------------------------------------------------------------------------
# Section 3: Distribution Check
# --------------------------------------------------------------------------
section "Linux Distribution"

if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_NAME="${PRETTY_NAME:-unknown}"
    DISTRO_VERSION="${VERSION_CODENAME:-unknown}"
    
    case "$DISTRO_ID" in
        debian)
            if [[ "$DISTRO_VERSION" == "bookworm" ]] || [[ "$VERSION_ID" == "12" ]]; then
                pass "Debian 12 (Bookworm) — ideal build host"
            else
                warn "Debian detected but not Bookworm: ${DISTRO_NAME}"
                warn "Bookworm (Debian 12) is recommended for building LucidOS"
            fi
            ;;
        ubuntu)
            if [[ "$VERSION_ID" == "22.04" ]] || [[ "$VERSION_ID" == "24.04" ]]; then
                pass "Ubuntu ${VERSION_ID} — supported build host"
            else
                warn "Ubuntu detected but version may be untested: ${DISTRO_NAME}"
            fi
            ;;
        *)
            warn "Non-Debian/Ubuntu distro: ${DISTRO_NAME}"
            warn "live-build is designed for Debian systems. Your mileage may vary."
            ;;
    esac
    info "Detected: ${DISTRO_NAME}"
else
    warn "Cannot detect Linux distribution (/etc/os-release not found)"
fi

# --------------------------------------------------------------------------
# Section 4: Required Tools
# --------------------------------------------------------------------------
section "Required Build Tools"

# Tools required for building
declare -A TOOLS
TOOLS=(
    ["lb"]="live-build"
    ["debootstrap"]="debootstrap"
    ["xorriso"]="xorriso"
    ["mksquashfs"]="squashfs-tools"
    ["git"]="git"
    ["curl"]="curl"
)

ALL_TOOLS_OK=true
for tool in "${!TOOLS[@]}"; do
    pkg="${TOOLS[$tool]}"
    if command -v "$tool" &>/dev/null; then
        VERSION=$(${tool} --version 2>/dev/null | head -1 || echo "installed")
        pass "${tool} — ${VERSION}"
    else
        fail "${tool} not found (install: sudo apt install ${pkg})"
        ALL_TOOLS_OK=false
    fi
done

if [[ "$ALL_TOOLS_OK" == false ]]; then
    echo ""
    info "Install all missing tools with:"
    info "  sudo apt install live-build debootstrap squashfs-tools xorriso git curl"
fi

# Optional tools
echo ""
info "Optional tools:"
for tool in qemu-system-x86_64 kvm-ok isolinux syslinux; do
    if command -v "$tool" &>/dev/null; then
        pass "${tool} (available)"
    else
        warn "${tool} not found (optional, needed for testing)"
    fi
done

# --------------------------------------------------------------------------
# Section 5: Disk Space
# --------------------------------------------------------------------------
section "Disk Space"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

AVAILABLE_KB=$(df -k "${PROJECT_ROOT}" | awk 'NR==2 {print $4}')
AVAILABLE_GB=$(( AVAILABLE_KB / 1024 / 1024 ))
TOTAL_KB=$(df -k "${PROJECT_ROOT}" | awk 'NR==2 {print $2}')
TOTAL_GB=$(( TOTAL_KB / 1024 / 1024 ))

info "Partition containing project: $(df -h "${PROJECT_ROOT}" | awk 'NR==2 {print $1}')"
info "Total size: ${TOTAL_GB} GB"
info "Available:  ${AVAILABLE_GB} GB"

if [[ "$AVAILABLE_GB" -ge 25 ]]; then
    pass "Disk space: ${AVAILABLE_GB} GB available (excellent)"
elif [[ "$AVAILABLE_GB" -ge 15 ]]; then
    pass "Disk space: ${AVAILABLE_GB} GB available (sufficient)"
elif [[ "$AVAILABLE_GB" -ge 10 ]]; then
    warn "Disk space: ${AVAILABLE_GB} GB available (tight, may work)"
    warn "Build requires ~15-20 GB. Consider freeing up space."
else
    fail "Disk space: ${AVAILABLE_GB} GB available (insufficient)"
    fail "Need at least 15 GB free. Free up space and try again."
fi

# --------------------------------------------------------------------------
# Section 6: RAM
# --------------------------------------------------------------------------
section "System RAM"

if [[ -f /proc/meminfo ]]; then
    TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    AVAIL_RAM_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    TOTAL_RAM_GB=$(( TOTAL_RAM_KB / 1024 / 1024 ))
    AVAIL_RAM_GB=$(( AVAIL_RAM_KB / 1024 / 1024 ))
    
    info "Total RAM:     ${TOTAL_RAM_GB} GB"
    info "Available RAM: ${AVAIL_RAM_GB} GB"
    
    if [[ "$TOTAL_RAM_GB" -ge 8 ]]; then
        pass "RAM: ${TOTAL_RAM_GB} GB total (excellent)"
    elif [[ "$TOTAL_RAM_GB" -ge 4 ]]; then
        pass "RAM: ${TOTAL_RAM_GB} GB total (sufficient)"
    elif [[ "$TOTAL_RAM_GB" -ge 2 ]]; then
        warn "RAM: ${TOTAL_RAM_GB} GB total (minimum, build may be slow)"
    else
        fail "RAM: ${TOTAL_RAM_GB} GB total (too low, build will likely fail)"
    fi
else
    warn "Cannot read /proc/meminfo to check RAM"
fi

# --------------------------------------------------------------------------
# Section 7: Internet connectivity
# --------------------------------------------------------------------------
section "Internet Connectivity"

DEBIAN_MIRROR="deb.debian.org"
if ping -c 1 -W 3 "${DEBIAN_MIRROR}" &>/dev/null 2>&1; then
    pass "Can reach ${DEBIAN_MIRROR} (Debian package mirror)"
elif curl -s --connect-timeout 5 "http://${DEBIAN_MIRROR}" &>/dev/null; then
    pass "HTTP access to ${DEBIAN_MIRROR} works"
else
    fail "Cannot reach ${DEBIAN_MIRROR}"
    fail "Internet access is required to download Debian packages"
    info "Check your network connection and DNS settings"
fi

# --------------------------------------------------------------------------
# Section 8: User privileges
# --------------------------------------------------------------------------
section "User Privileges"

if [[ "$EUID" -eq 0 ]]; then
    warn "Running as root. This is allowed but not recommended."
    warn "Prefer running as a regular user with sudo access."
else
    pass "Running as regular user: $(whoami)"
    
    # Check sudo access
    if sudo -n true 2>/dev/null; then
        pass "sudo access available (passwordless)"
    elif sudo -v 2>/dev/null; then
        pass "sudo access available"
    else
        fail "sudo not available or password required"
        info "live-build requires sudo. Configure sudo access for your user."
        info "  sudo usermod -aG sudo $(whoami)"
    fi
fi

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
echo ""
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo -e "${BOLD}Verification Summary${RESET}"
echo ""

if [[ $FAILURES -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}✓ All checks passed! Ready to build.${RESET}"
    echo ""
    echo "  Run: bash scripts/build.sh"
elif [[ $FAILURES -eq 0 ]]; then
    echo -e "  ${YELLOW}${BOLD}⚠ ${WARNINGS} warning(s). Build may work but review warnings above.${RESET}"
    echo ""
    echo "  Run: bash scripts/build.sh"
    echo "  (Proceed with caution)"
else
    echo -e "  ${RED}${BOLD}✗ ${FAILURES} failure(s) and ${WARNINGS} warning(s). Fix issues before building.${RESET}"
    echo ""
    echo "  See BUILDING.md for setup instructions."
fi

echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo ""

# Exit with error code if there were failures
[[ $FAILURES -eq 0 ]]
