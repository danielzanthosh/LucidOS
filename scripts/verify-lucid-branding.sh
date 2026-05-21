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

require_executable() {
  [[ -f "$1" ]] || fail "Missing required executable file: $1"
  [[ -x "$1" ]] || fail "Required file is not executable: $1"
}

require_line() {
  local line="$1"
  local file="$2"
  grep -Fxq "$line" "$file" || fail "Expected exact line '$line' in $file"
}

forbidden_visible=(
  "Install Debian"
  "LucidOS Alpha 0.1"
  "LucidOS Build System"
  "Name=Install LucidOS"
  "Comment=Install LucidOS"
  "Comment=Safe local agentic assistant shell for LucidOS"
  "Exec=konsole -e lucidos-agent"
  "ID=lucidos"
  "DISTRIB_ID=LucidOS"
)

scan_paths=(README.md ROADMAP.md SECURITY.md scripts live-build assets .github)
existing_scan_paths=()

for path in "${scan_paths[@]}"; do
  if [[ -e "$path" ]]; then
    existing_scan_paths+=("$path")
  fi
done

for text in "${forbidden_visible[@]}"; do
  if ((${#existing_scan_paths[@]})); then
    matches="$(mktemp)"
    trap 'rm -f "$matches"' EXIT
    status=0
    grep -RFIn --exclude='verify-lucid-branding.sh' "$text" "${existing_scan_paths[@]}" >"$matches" || status=$?

    if [[ $status -eq 0 ]]; then
      cat "$matches"
      rm -f "$matches"
      fail "Found old visible branding: $text"
    elif [[ $status -gt 1 ]]; then
      cat "$matches" >&2
      rm -f "$matches"
      fail "grep failed while scanning for old visible branding: $text"
    fi

    rm -f "$matches"
  fi
done

require_file "live-build/config/includes.chroot/usr/share/backgrounds/lucid-wallpaper.svg"
require_file "live-build/config/includes.chroot/usr/share/icons/hicolor/scalable/apps/lucid-logo.svg"
require_executable "live-build/config/includes.chroot/usr/local/bin/lucid-agent"
require_executable "live-build/config/includes.chroot/usr/local/bin/lucid-agent-onboarding"
require_file "live-build/config/includes.chroot/etc/xdg/autostart/lucid-agent-onboarding.desktop"

require_line 'PRETTY_NAME="Lucid Linux Alpha 0.2"' "live-build/config/hooks/normal/0100-lucidos-defaults.hook.chroot"
require_line 'ID=lucid' "live-build/config/hooks/normal/0100-lucidos-defaults.hook.chroot"
require_line 'ID_LIKE=debian' "live-build/config/hooks/normal/0100-lucidos-defaults.hook.chroot"
require_line 'Name=Install Lucid Linux' "live-build/config/includes.chroot/usr/share/applications/install-lucidos.desktop"
require_line 'Name=Lucid Agent' "live-build/config/includes.chroot/usr/share/applications/lucidos-agent.desktop"
require_line 'Name=Install Lucid Linux' "live-build/config/hooks/live/0100-lucidos-live-user.hook.chroot"
require_line 'Comment=Install Lucid Linux to your hard drive using the Calamares installer' "live-build/config/hooks/live/0100-lucidos-live-user.hook.chroot"
require_line 'Name=Lucid Agent' "live-build/config/hooks/live/0100-lucidos-live-user.hook.chroot"
require_line 'Comment=Lucid Agent powered by Hermes' "live-build/config/hooks/live/0100-lucidos-live-user.hook.chroot"
require_line 'Exec=konsole --hide-menubar -e lucid-agent-onboarding' "live-build/config/hooks/live/0100-lucidos-live-user.hook.chroot"

echo "[OK] Lucid Linux branding verification passed"
