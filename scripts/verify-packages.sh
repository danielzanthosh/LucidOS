#!/usr/bin/env bash
# =============================================================================
# LucidOS Package Verification Script
# =============================================================================
# Validates that every package referenced by live-build package lists exists in
# the configured Debian package sources before the ISO build starts.
#
# Usage:
#   bash scripts/verify-packages.sh
#
# The script is designed to run after `apt-get update` inside the Debian
# Bookworm CI container or on a Debian/Ubuntu build host with apt metadata
# already refreshed.
# =============================================================================

set -euo pipefail

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGE_LIST_DIR="${PROJECT_ROOT}/live-build/config/package-lists"

if ! command -v apt-cache &>/dev/null; then
    error "apt-cache is not available."
    error "Install the apt package or run this inside Debian/Ubuntu."
    exit 1
fi

if [[ ! -d "${PACKAGE_LIST_DIR}" ]]; then
    error "Package list directory not found: ${PACKAGE_LIST_DIR}"
    exit 1
fi

tmp_packages="$(mktemp)"
tmp_missing="$(mktemp)"
trap 'rm -f "${tmp_packages}" "${tmp_missing}"' EXIT

find "${PACKAGE_LIST_DIR}" -type f -name '*.list.chroot' -print0 \
    | sort -z \
    | while IFS= read -r -d '' file; do
        awk '
            {
                sub(/[[:space:]]+#.*/, "", $0)
            }
            /^[[:space:]]*$/ { next }
            /^[[:space:]]*#/ { next }
            {
                print $1
            }
        ' "${file}"
    done \
    | sort -u > "${tmp_packages}"

TOTAL_PACKAGES="$(wc -l < "${tmp_packages}" | tr -d '[:space:]')"
info "Checking ${TOTAL_PACKAGES} package names from ${PACKAGE_LIST_DIR}"

while IFS= read -r pkg; do
    [[ -z "${pkg}" ]] && continue

    candidate="$(apt-cache policy "${pkg}" 2>/dev/null | awk -F': ' '/^  Candidate:/ {print $2; exit}')"
    if [[ -z "${candidate}" || "${candidate}" == "(none)" ]]; then
        echo "${pkg}" >> "${tmp_missing}"
    fi
done < "${tmp_packages}"

if [[ -s "${tmp_missing}" ]]; then
    error "One or more package list entries are unavailable in the current apt sources:"
    sort -u "${tmp_missing}" | sed 's/^/  - /'
    echo ""
    echo "Review the matching lines in live-build/config/package-lists/*.list.chroot"
    echo "and replace them with Debian Bookworm package names."
    exit 1
fi

success "All package-list entries resolved successfully"
