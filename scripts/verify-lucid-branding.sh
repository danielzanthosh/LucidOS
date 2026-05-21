#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "Missing required file: $1"
}

require_text() {
  local pattern="$1"
  local file="$2"
  grep -Fq "$pattern" "$file" || fail "Expected '$pattern' in $file"
}

forbidden_visible=(
  "Install Debian"
  "LucidOS Alpha 0.1"
  "LucidOS Build System"
)

scan_paths=(README.md BUILDING.md ROADMAP.md SECURITY.md scripts live-build assets .github)
existing_scan_paths=()

for path in "${scan_paths[@]}"; do
  if [[ -e "$path" ]]; then
    existing_scan_paths+=("$path")
  fi
done

for text in "${forbidden_visible[@]}"; do
  if ((${#existing_scan_paths[@]})) && grep -RFIn --exclude='verify-lucid-branding.sh' "$text" "${existing_scan_paths[@]}"; then
    fail "Found old visible branding: $text"
  fi
done

require_file "live-build/config/includes.chroot/usr/share/backgrounds/lucid-wallpaper.svg"
require_file "live-build/config/includes.chroot/usr/share/icons/hicolor/scalable/apps/lucid-logo.svg"
require_file "live-build/config/includes.chroot/usr/local/bin/lucid-agent"
require_file "live-build/config/includes.chroot/usr/local/bin/lucid-agent-onboarding"
require_file "live-build/config/includes.chroot/etc/xdg/autostart/lucid-agent-onboarding.desktop"

require_text 'PRETTY_NAME="Lucid Linux Alpha 0.2"' "live-build/config/hooks/normal/0100-lucidos-defaults.hook.chroot"
require_text 'ID=lucid' "live-build/config/hooks/normal/0100-lucidos-defaults.hook.chroot"
require_text 'ID_LIKE=debian' "live-build/config/hooks/normal/0100-lucidos-defaults.hook.chroot"
require_text 'Name=Install Lucid Linux' "live-build/config/includes.chroot/usr/share/applications/install-lucidos.desktop"
require_text 'Name=Lucid Agent' "live-build/config/includes.chroot/usr/share/applications/lucidos-agent.desktop"

echo "[OK] Lucid Linux branding verification passed"
