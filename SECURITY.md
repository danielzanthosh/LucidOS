# LucidOS Security Model

This document describes the security architecture of LucidOS, with particular focus on the Lucid Agent agentic assistant layer.

---

## Core Security Principles

LucidOS is designed around these foundational security principles:

1. **Least privilege** â€” Every component runs with the minimum permissions it needs
2. **Explicit consent** â€” Users must confirm potentially dangerous actions
3. **Transparency** â€” All agent actions are logged and auditable
4. **Defense in depth** â€” Multiple layers of protection, not one magic solution
5. **Safe defaults** â€” The system is secure out of the box without user configuration

---

## Lucid Agent Security Model

### 1. No Unrestricted Root Access

The Lucid Agent **never runs as root** and **never has unrestricted sudo access**.

- The agent runs as the logged-in user (e.g., `lucid`)
- If an action requires elevated privileges, the user must authenticate via `sudo` interactively
- The agent cannot silently escalate privileges
- No `NOPASSWD` sudo rules are granted to the agent

### 2. Command Classification

Every command the agent might execute is classified into one of three categories:

#### âœ… Allowed Without Confirmation (Safe reads)
Commands that only read system state and cannot cause harm:
- `pwd`, `whoami`, `uname -a`
- `df -h`, `free -h`, `uptime`
- `ls`, `cat` (for non-sensitive paths)
- `echo`, `date`, `hostname`
- `ps aux` (process list)

#### âš ï¸ Requires Confirmation (Potentially impactful)
Commands that change system state or install software:
- `apt install`, `apt remove`, `apt upgrade`
- `systemctl start/stop/restart`
- `git clone`, `npm install`, `pip install`, `cargo build`
- `chmod`, `chown`
- Editing files outside the user's home directory
- `curl` or `wget` (network downloads)

#### ðŸš« Blocked (Destructive or dangerous)
Commands that are categorically blocked regardless of context:

```
rm -rf /
rm -rf /*
mkfs.*
dd if=
shred
userdel
passwd root
> /dev/sda (or similar disk devices)
chmod 777 /
chmod -R 777 /
```

Exfiltration-related blocks:
```
Commands accessing ~/.ssh/ without explicit approval
Commands accessing browser password stores
Commands that pipe output to external servers silently
Commands that read /etc/shadow or /etc/passwd for export
```

### 3. Action Logging

All commands processed by the agent are logged to:
```
/opt/lucidos-agent/logs/actions.log
```

Each log entry includes:
- Timestamp
- Command attempted
- Classification (allowed/confirmed/blocked)
- Whether user confirmed (for `requires_confirmation` commands)

The log file is owned by the user and readable only by that user.

```
# Log format example:
[2025-01-15 14:23:01] ALLOWED    | ls /home/lucid
[2025-01-15 14:23:15] CONFIRMED  | apt install htop    (user: yes)
[2025-01-15 14:23:45] BLOCKED    | rm -rf /tmp/../
[2025-01-15 14:24:01] CONFIRMED  | systemctl restart sshd  (user: no - cancelled)
```

### 4. No Remote Code Execution

The Lucid Agent must **never** allow remote prompts to directly execute shell commands:

- AI model outputs must be displayed to the user before execution
- The user must explicitly approve any command suggested by an AI model
- "Auto-execute" mode must be explicitly enabled by the user (disabled by default)
- Remote code injection via crafted prompts must be prevented

### 5. API Key Protection

When AI provider integration is added (Alpha 0.3+):

- API keys are stored in `~/.config/lucidos-agent/credentials` (chmod 600)
- API keys are **never** stored in:
  - `/opt/lucidos-agent/` (world-readable directory)
  - Environment variables in shell profiles
  - Plain text config files in `/etc/`
- API keys are loaded at runtime, not hardcoded
- The agent should support system keyring integration (e.g., KDE Wallet, GNOME Keyring)

---

## Future Sandboxing Plan (Alpha 0.3+)

As the agent gains real AI capabilities, additional sandboxing will be added:

### Option A: Flatpak Sandboxing
```bash
# Agent runs in a Flatpak sandbox with restricted filesystem access
flatpak run --filesystem=home:ro org.lucidos.Agent
```

### Option B: bubblewrap (bwrap)
```bash
# Minimal sandbox using bubblewrap
bwrap --ro-bind /usr /usr \
      --ro-bind /lib /lib \
      --bind /home/lucid /home/lucid \
      --tmpfs /tmp \
      /usr/local/bin/lucidos-agent
```

### Option C: Restricted systemd service
```ini
# /etc/systemd/user/lucidos-agent.service
[Service]
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=read-only
NoNewPrivileges=yes
RestrictNamespaces=yes
```

### Option D: Container-based execution
```bash
# For commands that touch the filesystem, run in a container
podman run --rm \
           --network=none \
           -v /home/lucid:/workspace:rw \
           lucidos-sandbox-image \
           <command>
```

---

## Permission Scope Model (Future: Alpha 0.4+)

When plugins and extensions are added to the agent, they must declare their permission scopes:

### Filesystem Scope
```json
{
  "filesystem": {
    "read": ["~/Documents", "~/Downloads"],
    "write": ["~/LucidOS-projects"],
    "forbidden": ["/etc", "/boot", "/sys", "/proc", "~/.ssh"]
  }
}
```

### Network Scope
```json
{
  "network": {
    "allowed_domains": ["api.github.com", "pypi.org"],
    "blocked": ["*"],
    "localhost": true
  }
}
```

### Shell Scope
```json
{
  "shell": {
    "allowed_commands": ["ls", "cat", "grep", "find"],
    "requires_confirmation": ["apt", "systemctl"],
    "blocked": ["rm -rf", "mkfs", "dd"]
  }
}
```

### Package Manager Scope
```json
{
  "package_manager": {
    "can_install": false,
    "can_remove": false,
    "can_search": true,
    "requires_user_approval": true
  }
}
```

### Browser Automation Scope
```json
{
  "browser": {
    "can_read_history": false,
    "can_read_passwords": false,
    "can_open_urls": true,
    "can_fill_forms": false
  }
}
```

### System Settings Scope
```json
{
  "system_settings": {
    "can_change_display": false,
    "can_change_network": false,
    "can_install_updates": false,
    "can_read_system_info": true
  }
}
```

---

## Live System Security

### Default Live User
The live session uses:
- Username: `lucid`
- Password: `lucid`
- This is **intentional and expected** for a live system
- Users are warned to change credentials after installation

### sudoers Configuration
The live user has limited sudo access:
```
# /etc/sudoers.d/lucidos-live
# The live user can run specific commands without a password
# ONLY for commands needed to run the installer
lucid ALL=(ALL) NOPASSWD: /usr/bin/calamares
```

Everything else requires the `lucid` password.

### Post-Installation Security
After installing LucidOS to disk via Calamares:
- The live user account is removed
- A new user account is created with a user-chosen password
- Standard Debian sudoers rules apply
- The Lucid Agent runs with that user's privileges

---

## Reporting Security Issues

If you discover a security vulnerability in LucidOS:

1. **Do not** open a public GitHub issue
2. **Do** email the maintainer directly (address TBD for Alpha phase)
3. Include a description of the issue and steps to reproduce
4. Allow reasonable time for a fix before public disclosure

---

## Security Checklist for Contributors

Before submitting a PR that touches the agent or security model:

- [ ] Does this change give the agent new privileges? If so, is it justified?
- [ ] Are all new commands classified (allowed/confirm/blocked)?
- [ ] Are new actions logged?
- [ ] Are any API keys or secrets hardcoded? (They must not be)
- [ ] Does this allow remote code execution? (It must not)
- [ ] Has the change been tested with a non-root user?
- [ ] Are new file permissions appropriate (not 777)?

---

*Last updated: LucidOS Alpha 0.1*
