#!/usr/bin/env bash
# =============================================================================
# LucidOS Clean Script
# =============================================================================
# Safely cleans live-build artifacts without deleting unrelated project files.
#
# Usage:
#   bash scripts/clean.sh            # Clean build artifacts only
#   bash scripts/clean.sh --all      # Clean everything including cache
#   bash scripts/clean.sh --dist     # Also remove built ISOs from dist/
#
# What gets cleaned:
#   - live-build chroot, binary, and build directories (safe to delete)
#   - Optionally: package cache (forces re-download on next build)
#   - Optionally: dist/ directory (removes finished ISOs)
#
# What is NEVER deleted:
#   - Source files (scripts/, live-build/auto/, live-build/config/)
#   - Documentation (README.md, BUILDING.md, etc.)
#   - Assets (assets/)
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
# Configuration
# --------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIVE_BUILD_DIR="${PROJECT_ROOT}/live-build"
DIST_DIR="${PROJECT_ROOT}/dist"

if [[ "${EUID}" -eq 0 ]]; then
    RUN_LB_CLEAN=(lb clean)
    RUN_LB_CLEAN_ALL=(lb clean --all)
else
    RUN_LB_CLEAN=(sudo lb clean)
    RUN_LB_CLEAN_ALL=(sudo lb clean --all)
fi

# Parse arguments
CLEAN_CACHE=false
CLEAN_DIST=false

for arg in "$@"; do
    case "$arg" in
        --all)   CLEAN_CACHE=true ;;
        --dist)  CLEAN_DIST=true ;;
        --help)
            echo "Usage: bash scripts/clean.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  (none)    Clean build artifacts only (chroot, binary)"
            echo "  --all     Also clean package cache (forces re-download)"
            echo "  --dist    Also remove built ISOs from dist/"
            echo "  --help    Show this message"
            exit 0
            ;;
        *)
            warn "Unknown argument: $arg (ignored)"
            ;;
    esac
done

# --------------------------------------------------------------------------
# Header
# --------------------------------------------------------------------------
echo ""
echo -e "${BOLD}LucidOS Clean Script${RESET}"
echo ""

# --------------------------------------------------------------------------
# Check: live-build directory exists
# --------------------------------------------------------------------------
if [[ ! -d "${LIVE_BUILD_DIR}" ]]; then
    error "live-build directory not found: ${LIVE_BUILD_DIR}"
    error "Run this script from the project root"
    exit 1
fi

# --------------------------------------------------------------------------
# Check: live-build is available
# --------------------------------------------------------------------------
if ! command -v lb &>/dev/null; then
    warn "live-build (lb) not found. Will try to clean manually."
    MANUAL_CLEAN=true
else
    MANUAL_CLEAN=false
fi

# --------------------------------------------------------------------------
# Show what will be cleaned
# --------------------------------------------------------------------------
echo "Will clean:"
echo "  ✓ live-build build artifacts (chroot, binary, build directories)"
if [[ "$CLEAN_CACHE" == true ]]; then
    echo "  ✓ live-build package cache (cache/)"
    warn "Package cache will be deleted. Next build will re-download all packages."
fi
if [[ "$CLEAN_DIST" == true ]]; then
    echo "  ✓ dist/ directory (built ISOs)"
    warn "This will delete your built ISO files!"
fi
echo ""

# --------------------------------------------------------------------------
# Confirmation for destructive operations
# --------------------------------------------------------------------------
if [[ "$CLEAN_CACHE" == true ]] || [[ "$CLEAN_DIST" == true ]]; then
    echo -n "Are you sure you want to proceed? [y/N] "
    read -r CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        info "Cancelled."
        exit 0
    fi
fi

# --------------------------------------------------------------------------
# Clean: live-build artifacts
# --------------------------------------------------------------------------
info "Cleaning live-build artifacts..."
cd "${LIVE_BUILD_DIR}"

if [[ "$MANUAL_CLEAN" == false ]]; then
    # Use lb clean for proper cleanup
    if [[ "$CLEAN_CACHE" == true ]]; then
        "${RUN_LB_CLEAN_ALL[@]}"
    else
        "${RUN_LB_CLEAN[@]}"
    fi
    success "lb clean completed"
else
    # Manual cleanup if lb is not available
    warn "Using manual cleanup (lb not found)"
    for dir in chroot binary build; do
        if [[ -d "${LIVE_BUILD_DIR}/${dir}" ]]; then
            info "Removing: ${dir}/"
            sudo rm -rf "${LIVE_BUILD_DIR:?}/${dir}"
        fi
    done
    for f in "${LIVE_BUILD_DIR}"/*.iso "${LIVE_BUILD_DIR}"/*.log; do
        if [[ -f "$f" ]]; then
            info "Removing: $(basename "$f")"
            rm -f "$f"
        fi
    done
    success "Manual cleanup completed"
fi

# --------------------------------------------------------------------------
# Clean: Cache (optional, requires --all)
# --------------------------------------------------------------------------
if [[ "$CLEAN_CACHE" == true ]] && [[ -d "${LIVE_BUILD_DIR}/cache" ]]; then
    info "Removing package cache..."
    sudo rm -rf "${LIVE_BUILD_DIR:?}/cache"
    success "Cache removed"
fi

# --------------------------------------------------------------------------
# Clean: dist/ (optional, requires --dist)
# --------------------------------------------------------------------------
if [[ "$CLEAN_DIST" == true ]]; then
    if [[ -d "${DIST_DIR}" ]]; then
        info "Removing dist/ directory..."
        rm -rf "${DIST_DIR:?}"
        success "dist/ removed"
    else
        info "dist/ does not exist, nothing to remove"
    fi
fi

# --------------------------------------------------------------------------
# Done
# --------------------------------------------------------------------------
echo ""
success "Clean complete. Safe to build again with: bash scripts/build.sh"
echo ""
