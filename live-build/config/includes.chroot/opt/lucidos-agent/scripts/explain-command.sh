#!/usr/bin/env bash
# =============================================================================
# LucidOS Command Explainer
# =============================================================================
# File: /opt/lucidos-agent/scripts/explain-command.sh
#
# PURPOSE:
#   Provides a human-readable explanation of what a shell command does.
#   Called by the Lucid Agent before showing commands to the user.
#
# USAGE:
#   /opt/lucidos-agent/scripts/explain-command.sh "apt install htop"
#   /opt/lucidos-agent/scripts/explain-command.sh "rm -rf /tmp/test"
#   /opt/lucidos-agent/scripts/explain-command.sh "systemctl restart sshd"
#
# HOW IT WORKS:
#   - Alpha 0.1: Pattern-based explanations from a built-in knowledge base
#   - Alpha 0.3 (TODO): Look up man page summaries dynamically
#   - Alpha 0.4 (TODO): Use an AI model to explain arbitrary commands
#
# OUTPUT:
#   Prints a human-friendly explanation to stdout.
#   Returns 0 on success, 1 if no explanation is available.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Color codes
# ---------------------------------------------------------------------------
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Main explanation function
# ---------------------------------------------------------------------------
explain_command() {
    local cmd="$1"
    local found=false

    # -----------------------------------------------------------------------
    # Built-in knowledge base
    # Pattern matching from most specific to most general
    # -----------------------------------------------------------------------

    # apt install
    if [[ "$cmd" =~ ^apt\ install\ (.+)$ ]] || [[ "$cmd" =~ ^apt-get\ install\ (.+)$ ]]; then
        local pkg="${BASH_REMATCH[1]}"
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  This command installs the package '${pkg}' from the Debian repository."
        echo ""
        echo "  What will happen:"
        echo "  1. apt will calculate which other packages are needed (dependencies)"
        echo "  2. All needed packages will be downloaded from the internet"
        echo "  3. The packages will be installed to your system"
        echo "  4. The package will be available for you to use"
        echo ""
        echo -e "  ${YELLOW}Requires internet connection and disk space.${RESET}"
        found=true
    fi

    # apt remove
    if [[ "$cmd" =~ ^apt\ (remove|purge)\ (.+)$ ]]; then
        local action="${BASH_REMATCH[1]}"
        local pkg="${BASH_REMATCH[2]}"
        echo -e "${CYAN}Explanation:${RESET}"
        if [[ "$action" == "purge" ]]; then
            echo "  This command removes the package '${pkg}' AND its configuration files."
        else
            echo "  This command removes the package '${pkg}' from your system."
        fi
        echo ""
        echo "  What will happen:"
        echo "  1. The package's files will be removed from your system"
        echo "  2. If '${action}' is used, configuration files are also removed"
        echo "  3. Dependent packages may also be removed if no longer needed"
        found=true
    fi

    # apt upgrade
    if [[ "$cmd" =~ ^apt\ upgrade ]] || [[ "$cmd" =~ ^apt-get\ upgrade ]]; then
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  This command upgrades all installed packages to their latest versions."
        echo ""
        echo "  What will happen:"
        echo "  1. apt will check the Debian repositories for newer package versions"
        echo "  2. All packages with available updates will be downloaded"
        echo "  3. The updated packages will be installed"
        echo ""
        echo -e "  ${YELLOW}This is a major operation — back up important data first.${RESET}"
        found=true
    fi

    # systemctl start/stop/restart/enable/disable
    if [[ "$cmd" =~ ^(sudo\ )?systemctl\ (start|stop|restart|enable|disable|status)\ (.+)$ ]]; then
        local action="${BASH_REMATCH[2]}"
        local service="${BASH_REMATCH[3]}"
        echo -e "${CYAN}Explanation:${RESET}"
        case "$action" in
            start)   echo "  This command STARTS the service '${service}'." ;;
            stop)    echo "  This command STOPS the service '${service}'." ;;
            restart) echo "  This command RESTARTS the service '${service}' (stops then starts it)." ;;
            enable)  echo "  This command enables '${service}' to START AUTOMATICALLY at boot." ;;
            disable) echo "  This command prevents '${service}' from starting automatically at boot." ;;
            status)  echo "  This command shows the current STATUS of the service '${service}'." ;;
        esac
        echo ""
        echo "  Systemd services are background processes that run on your system."
        echo "  Common services: sshd (remote login), networking, display manager."
        found=true
    fi

    # git clone
    if [[ "$cmd" =~ ^git\ clone\ (.+)$ ]]; then
        local url="${BASH_REMATCH[1]}"
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  This command downloads a git repository from the internet."
        echo "  Repository URL: ${url}"
        echo ""
        echo "  What will happen:"
        echo "  1. A connection will be made to the repository host"
        echo "  2. All code files and history will be downloaded"
        echo "  3. A new folder will be created in the current directory"
        echo ""
        echo -e "  ${YELLOW}Only clone repositories you trust.${RESET}"
        found=true
    fi

    # npm install
    if [[ "$cmd" =~ ^npm\ install ]]; then
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  This command installs Node.js packages using npm."
        echo ""
        echo "  What will happen:"
        echo "  1. npm reads the project's package.json file"
        echo "  2. All required packages are downloaded from npmjs.com"
        echo "  3. Packages are installed in the node_modules/ directory"
        echo ""
        echo -e "  ${YELLOW}npm packages are third-party code — verify the project before installing.${RESET}"
        found=true
    fi

    # pip install
    if [[ "$cmd" =~ ^pip(3)?\ install\ (.+)$ ]]; then
        local pkg="${BASH_REMATCH[2]}"
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  This command installs the Python package '${pkg}' using pip."
        echo ""
        echo "  What will happen:"
        echo "  1. pip downloads '${pkg}' from PyPI (Python Package Index)"
        echo "  2. The package is installed for your Python environment"
        echo "  3. You can import and use it in your Python scripts"
        echo ""
        echo -e "  ${YELLOW}Consider using a virtual environment (python3 -m venv) to keep packages isolated.${RESET}"
        found=true
    fi

    # chmod
    if [[ "$cmd" =~ ^chmod\ (.+)\ (.+)$ ]]; then
        local mode="${BASH_REMATCH[1]}"
        local target="${BASH_REMATCH[2]}"
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  This command changes the access permissions of '${target}'."
        echo "  New permissions: ${mode}"
        echo ""
        echo "  Permission basics:"
        echo "  - r (4) = read permission"
        echo "  - w (2) = write permission"
        echo "  - x (1) = execute permission"
        echo "  - Permissions apply to: owner, group, others"
        echo ""
        case "$mode" in
            755) echo "  chmod 755 = owner can read/write/execute; others can read/execute" ;;
            644) echo "  chmod 644 = owner can read/write; others can only read" ;;
            600) echo "  chmod 600 = only the owner can read/write; no access for others" ;;
            777) echo -e "  ${YELLOW}chmod 777 = EVERYONE can read/write/execute — generally unsafe!${RESET}" ;;
        esac
        found=true
    fi

    # rm
    if [[ "$cmd" =~ ^rm\ ]]; then
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  This command PERMANENTLY DELETES files or directories."
        echo ""
        echo -e "  ${YELLOW}⚠ WARNING: Deleted files cannot be easily recovered!${RESET}"
        echo "  There is no trash/recycle bin for rm."
        echo ""
        if [[ "$cmd" =~ -r ]]; then
            echo "  -r flag: deletes directories and their contents recursively"
        fi
        if [[ "$cmd" =~ -f ]]; then
            echo "  -f flag: forces deletion without prompting"
        fi
        found=true
    fi

    # ls
    if [[ "$cmd" =~ ^ls ]]; then
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  Lists files and directories. This is safe (read-only)."
        echo "  Common flags: -l (details), -a (show hidden), -h (human sizes)"
        found=true
    fi

    # df
    if [[ "$cmd" =~ ^df ]]; then
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  Shows disk space usage for filesystems. This is safe (read-only)."
        echo "  -h flag: shows sizes in human-readable format (KB, MB, GB)"
        found=true
    fi

    # curl / wget
    if [[ "$cmd" =~ ^(curl|wget)\ ]]; then
        local tool="${BASH_REMATCH[1]}"
        echo -e "${CYAN}Explanation:${RESET}"
        echo "  This command downloads content from the internet using ${tool}."
        echo ""
        echo -e "  ${YELLOW}Network requests send data to and receive data from external servers.${RESET}"
        echo "  Verify the URL before proceeding."
        found=true
    fi

    # Generic fallback: try to get the man page summary
    if [[ "$found" == false ]]; then
        local base_cmd
        base_cmd=$(echo "$cmd" | awk '{print $1}')  # Get the first word (the command name)

        echo -e "${CYAN}Explanation:${RESET}"
        echo "  No built-in explanation available for '${base_cmd}'."
        echo ""

        # Try to get the first line of the man page
        if man -f "$base_cmd" &>/dev/null 2>&1; then
            echo "  From the manual:"
            man -f "$base_cmd" 2>/dev/null | head -3 | sed 's/^/  /'
        fi

        echo ""
        echo -e "  ${YELLOW}For more information, run: man ${base_cmd}${RESET}"
        echo ""
        echo "  TODO (Alpha 0.3): This will use an AI model for better explanations."
        return 1
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
if [[ $# -eq 0 ]]; then
    echo "Usage: explain-command.sh \"command to explain\""
    exit 1
fi

CMD="$*"
echo ""
echo -e "${BOLD}Command analysis:${RESET} ${CMD}"
echo ""
explain_command "$CMD"
echo ""
