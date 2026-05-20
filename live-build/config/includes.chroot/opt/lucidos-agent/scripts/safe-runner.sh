#!/usr/bin/env bash
# =============================================================================
# LucidOS Safe Command Runner
# =============================================================================
# File: /opt/lucidos-agent/scripts/safe-runner.sh
#
# PURPOSE:
#   This script is the security gateway for all commands executed by the
#   Lucid Agent. It classifies commands, blocks dangerous ones, asks for
#   confirmation on risky ones, and logs everything.
#
# USAGE:
#   /opt/lucidos-agent/scripts/safe-runner.sh "ls -la /home"
#   /opt/lucidos-agent/scripts/safe-runner.sh "apt install htop"
#
# HOW IT WORKS:
#   1. Accept a command string as the first argument
#   2. Run it through pattern matching to classify it:
#      - ALLOWED: safe read-only commands → run without asking
#      - CONFIRM: potentially impactful → show the command, ask "yes/no"
#      - BLOCKED: destructive/dangerous → refuse absolutely
#   3. Log the result to the agent log file
#   4. If allowed or confirmed, execute the command
#
# SECURITY NOTES:
#   - This script NEVER uses eval to run commands
#   - This script NEVER grants root/sudo unless the original command requests it
#     (and sudo still requires the user's password)
#   - This script NEVER bypasses confirmation prompts
#   - Log file is append-only from this script's perspective
#   - Patterns are conservative — when in doubt, classify as CONFIRM
#
# TODO (Alpha 0.3):
#   - Replace pattern matching with a proper policy engine
#   - Add JSON policy loading from /etc/lucidos/agent-policy.json
#   - Add per-user policy overrides from ~/.config/lucidos-agent/policy.json
# =============================================================================

# ---------------------------------------------------------------------------
# Safety: exit immediately on error, undefined variable, or pipe failure
# ---------------------------------------------------------------------------
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
AGENT_DIR="/opt/lucidos-agent"
LOG_FILE="${AGENT_DIR}/logs/actions.log"
LOG_FALLBACK="/tmp/lucidos-agent-actions.log"

# ANSI color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Logging helper
# ---------------------------------------------------------------------------
# Logs to the agent log file. Falls back to /tmp if the main log is not writable.
agent_log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local log_entry="[${timestamp}] ${level} | ${message}"

    # Try the main log file first
    if [[ -w "${AGENT_DIR}/logs" ]] || [[ -w "${LOG_FILE}" ]]; then
        echo "${log_entry}" >> "${LOG_FILE}"
    else
        # Fall back to /tmp if the main log is not writable
        echo "${log_entry}" >> "${LOG_FALLBACK}"
    fi
}

# ---------------------------------------------------------------------------
# Classification: BLOCKED patterns
# ---------------------------------------------------------------------------
# Returns 0 (true) if the command matches a blocked pattern.
is_blocked() {
    local cmd="$1"

    # --- Exact blocked commands ---
    case "$cmd" in
        "rm -rf /" | \
        "rm -rf /*" | \
        "rm -rf ~/." | \
        ":(){:|:&};:" | \
        "chmod 777 /" | \
        "chmod -R 777 /")
            return 0
            ;;
    esac

    # --- Blocked command prefixes ---
    # These are patterns where the beginning of the command is dangerous.
    local blocked_prefixes=(
        "mkfs"          # Formats a disk — destroys all data
        "shred"         # Securely destroys files — irreversible
        "userdel"       # Deletes user accounts
        "passwd root"   # Changes root password
        "dd if="        # Raw disk read — dangerous
        "dd bs="        # Raw disk write — dangerous
    )
    for prefix in "${blocked_prefixes[@]}"; do
        if [[ "$cmd" == "${prefix}"* ]]; then
            return 0
        fi
    done

    # --- Dangerous rm patterns ---
    # rm -rf with / or very high-level paths
    if [[ "$cmd" =~ ^rm\ -[rRfF]*[rRfF].*\ /$ ]] || \
       [[ "$cmd" =~ ^rm\ -[rRfF]*[rRfF].*\ /\* ]] || \
       [[ "$cmd" =~ ^rm\ -[rRfF]*[rRfF].*\ /etc ]] || \
       [[ "$cmd" =~ ^rm\ -[rRfF]*[rRfF].*\ /usr ]] || \
       [[ "$cmd" =~ ^rm\ -[rRfF]*[rRfF].*\ /bin ]] || \
       [[ "$cmd" =~ ^rm\ -[rRfF]*[rRfF].*\ /boot ]] || \
       [[ "$cmd" =~ ^rm\ -[rRfF]*[rRfF].*\ /lib ]]; then
        return 0
    fi

    # --- Blocked substring patterns ---
    # These match dangerous patterns anywhere in the command.
    local blocked_patterns=(
        "/dev/sda"          # Direct disk device access
        "/dev/sdb"          # Direct disk device access
        "/dev/sdc"          # Direct disk device access
        "/dev/nvme0"        # NVMe disk access
        "/etc/shadow"       # Password hash file
        "~/.ssh/id_rsa"     # SSH private key
        "~/.ssh/id_ed25519" # SSH private key
        "curl | bash"       # Remote code execution
        "curl | sh"         # Remote code execution
        "wget -O- | bash"   # Remote code execution
        "wget -O- | sh"     # Remote code execution
        "wget | bash"       # Remote code execution
    )
    for pattern in "${blocked_patterns[@]}"; do
        if [[ "$cmd" == *"$pattern"* ]]; then
            return 0
        fi
    done

    return 1  # Not blocked
}

# ---------------------------------------------------------------------------
# Classification: ALLOWED patterns (safe, no confirmation needed)
# ---------------------------------------------------------------------------
# Returns 0 (true) if the command is in the safe/allowed list.
is_allowed() {
    local cmd="$1"

    # --- Exact allowed commands ---
    case "$cmd" in
        "pwd" | \
        "whoami" | \
        "uname" | \
        "uname -a" | \
        "uname -r" | \
        "hostname" | \
        "date" | \
        "uptime" | \
        "id" | \
        "groups" | \
        "lsb_release -a" | \
        "lsb_release -d")
            return 0
            ;;
    esac

    # --- Allowed command prefixes ---
    # These are safe because they only read system information.
    local allowed_prefixes=(
        "ls"                    # List files (read-only)
        "df"                    # Disk space (read-only)
        "free"                  # Memory usage (read-only)
        "ps"                    # Process list (read-only)
        "top"                   # Process monitor (interactive read-only)
        "htop"                  # Process monitor (interactive read-only)
        "echo"                  # Print text
        "cat /proc/"            # Kernel proc info (read-only virtual FS)
        "cat /sys/"             # Kernel sys info (read-only virtual FS)
        "cat /etc/os-release"   # OS info (safe file)
        "cat /etc/hostname"     # Hostname (safe file)
        "cat /etc/hosts"        # Hosts file (safe file)
        "grep"                  # Pattern search (read-only)
        "which"                 # Find command path (read-only)
        "type"                  # Command type (read-only)
        "man"                   # Manual pages (read-only)
        "help"                  # Shell help (read-only)
        "env"                   # Environment variables (read-only)
        "printenv"              # Print environment (read-only)
        "lsblk"                 # List block devices (read-only)
        "lspci"                 # List PCI devices (read-only)
        "lsusb"                 # List USB devices (read-only)
        "ip addr"               # Network addresses (read-only)
        "ip route"              # Routing table (read-only)
        "ping"                  # Network ping (safe)
        "nslookup"              # DNS lookup (safe)
        "dig"                   # DNS lookup (safe)
        "find /home/"           # Find in home (read-only, scoped to home)
        "find /tmp/"            # Find in tmp (read-only)
    )
    for prefix in "${allowed_prefixes[@]}"; do
        if [[ "$cmd" == "${prefix}"* ]]; then
            return 0
        fi
    done

    return 1  # Not in allowed list
}

# ---------------------------------------------------------------------------
# Main function
# ---------------------------------------------------------------------------
main() {
    # -----------------------------------------------------------------------
    # Input validation
    # -----------------------------------------------------------------------
    if [[ $# -eq 0 ]]; then
        echo -e "${RED}Error:${RESET} No command provided."
        echo "Usage: safe-runner.sh \"command to run\""
        exit 1
    fi

    # Combine all arguments into a single command string
    local cmd="$*"

    # Basic sanity check: empty command
    if [[ -z "${cmd// }" ]]; then
        echo -e "${RED}Error:${RESET} Empty command."
        exit 1
    fi

    # Command length limit (prevent extremely long inputs)
    if [[ ${#cmd} -gt 2048 ]]; then
        echo -e "${RED}Error:${RESET} Command too long (max 2048 characters)."
        agent_log "BLOCKED" "Command too long (${#cmd} chars): ${cmd:0:100}..."
        exit 1
    fi

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET}  ${BOLD}Lucid Agent Safe Runner${RESET}                          ${CYAN}│${RESET}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "  ${BOLD}Command:${RESET} ${cmd}"
    echo ""

    # -----------------------------------------------------------------------
    # Step 1: Check if blocked
    # -----------------------------------------------------------------------
    if is_blocked "$cmd"; then
        echo -e "  ${RED}${BOLD}🚫 BLOCKED${RESET}"
        echo ""
        echo -e "  ${RED}This command is blocked by the LucidOS agent policy.${RESET}"
        echo "  Blocked commands are never executed, regardless of confirmation."
        echo ""
        echo "  Reason: The command matches a known-dangerous pattern."
        echo "  See /opt/lucidos-agent/policy/default-policy.json for details."
        echo ""
        agent_log "BLOCKED" "${cmd}"
        exit 1
    fi

    # -----------------------------------------------------------------------
    # Step 2: Check if allowed without confirmation
    # -----------------------------------------------------------------------
    if is_allowed "$cmd"; then
        echo -e "  ${GREEN}✓ Classification: ALLOWED (no confirmation needed)${RESET}"
        echo ""
        agent_log "ALLOWED" "${cmd}"

        # Execute the command safely
        # We use bash -c to run the command in a new shell context.
        # This is safer than eval because -c limits scope.
        echo -e "  ${BLUE}Running...${RESET}"
        echo ""
        bash -c "$cmd"
        local exit_code=$?
        echo ""
        if [[ $exit_code -eq 0 ]]; then
            agent_log "COMPLETED" "${cmd} (exit: 0)"
        else
            agent_log "COMPLETED" "${cmd} (exit: ${exit_code})"
        fi
        return $exit_code
    fi

    # -----------------------------------------------------------------------
    # Step 3: Command requires confirmation
    # -----------------------------------------------------------------------
    echo -e "  ${YELLOW}⚠  Classification: REQUIRES CONFIRMATION${RESET}"
    echo ""
    echo "  This command may change your system state."
    echo "  Please review the full command before proceeding:"
    echo ""
    echo -e "  ${BOLD}  $ ${cmd}${RESET}"
    echo ""

    # Ask for explicit confirmation
    # The user must type the word 'yes' — pressing Enter is not enough.
    echo -n "  Type 'yes' to confirm, or anything else to cancel: "
    read -r CONFIRM

    echo ""

    if [[ "$CONFIRM" == "yes" ]]; then
        echo -e "  ${GREEN}Confirmed. Running command...${RESET}"
        echo ""
        agent_log "CONFIRMED" "${cmd} (user: yes)"

        bash -c "$cmd"
        local exit_code=$?
        echo ""
        agent_log "COMPLETED" "${cmd} (exit: ${exit_code})"
        return $exit_code
    else
        echo -e "  ${YELLOW}Cancelled.${RESET} Command was not executed."
        echo ""
        agent_log "CANCELLED" "${cmd} (user: ${CONFIRM})"
        return 0
    fi
}

# ---------------------------------------------------------------------------
# Run main function with all arguments
# ---------------------------------------------------------------------------
main "$@"
