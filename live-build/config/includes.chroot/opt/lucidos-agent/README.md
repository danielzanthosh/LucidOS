# Lucid Agent â€” /opt/lucidos-agent/

This is the Lucid Agent, LucidOS's future-ready agentic AI assistant.

## Current Status: Alpha 0.1 â€” Skeleton / Placeholder

In Alpha 0.1, the Lucid Agent is a **safe terminal placeholder**. It does not yet have a real AI backend, but the architecture, permissions, and safety systems are in place and ready for future integration.

## What the Lucid Agent Will Do (Future Versions)

- **Alpha 0.3**: Terminal-based assistant with command explanation, local workflows
- **Alpha 0.4**: Integration with AI providers (local LLM or cloud API)
- **Beta**: Full GUI, sandboxed execution, plugin system

## Directory Structure

```
/opt/lucidos-agent/
â”œâ”€â”€ README.md           â† You are here
â”œâ”€â”€ policy/
â”‚   â””â”€â”€ default-policy.json   â† Command permission rules
â”œâ”€â”€ logs/
â”‚   â””â”€â”€ actions.log     â† Log of all agent actions (created at runtime)
â””â”€â”€ scripts/
    â”œâ”€â”€ safe-runner.sh  â† Safe command execution with classification
    â””â”€â”€ explain-command.sh â† Command explanation helper
```

## Security Architecture

The Lucid Agent is designed with safety as the top priority:

### 1. No root access
The agent runs as the logged-in user. It never gets automatic root.

### 2. Command classification
Every command is classified as:
- **Allowed** â€” safe read-only commands (ls, pwd, df, etc.)
- **Requires confirmation** â€” state-changing commands (apt, systemctl, git clone, etc.)
- **Blocked** â€” destructive commands (rm -rf /, mkfs, dd, etc.)

### 3. Logging
All commands (allowed, confirmed, blocked) are logged to:
```
/opt/lucidos-agent/logs/actions.log
```

### 4. User confirmation
Before running any risky command, the agent displays the full command
and asks the user to type 'yes' to confirm. It never auto-executes risky commands.

## How to Use (Alpha 0.1)

```bash
# Launch the agent from the terminal
lucidos-agent

# Or from the desktop launcher:
# Click "Lucid Agent" on the desktop or in the application menu
```

## How to Use safe-runner.sh Directly

```bash
# Run a command through the safe runner
/opt/lucidos-agent/scripts/safe-runner.sh "ls -la /home"

# The runner will:
# 1. Classify the command (allowed/confirm/blocked)
# 2. Ask for confirmation if needed
# 3. Execute the command (or block it)
# 4. Log the result
```

## Policy Files

The command permission policy is defined in two places:

1. **System policy**: `/etc/lucidos/agent-policy.json` (read-only, set by admin)
2. **Agent policy**: `/opt/lucidos-agent/policy/default-policy.json` (more detailed)

Both files define the same three categories: `allowed_without_confirmation`,
`requires_confirmation`, and `blocked`.

## Future Development (TODO)

- [ ] Alpha 0.3: Real interactive assistant with command explanations
- [ ] Alpha 0.3: Task automation (e.g., "set up a Python project")
- [ ] Alpha 0.4: Local LLM integration (Ollama, llama.cpp)
- [ ] Alpha 0.4: Cloud AI provider integration (optional, user-configured)
- [ ] Alpha 0.4: Plugin system with permission scopes
- [ ] Beta: Full GUI application with chat interface
- [ ] Beta: Sandboxed execution using bubblewrap or Flatpak
- [ ] Beta: Agent memory and session persistence

## Contributing

If you want to improve the Lucid Agent, see the main project README and ROADMAP.

**Security note for contributors:** Never remove the confirmation step for 
`requires_confirmation` commands. Never add commands to `allowed_without_confirmation`
that can write to the filesystem or make network requests.
