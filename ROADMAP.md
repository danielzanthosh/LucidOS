# LucidOS Development Roadmap

This roadmap describes the planned development phases for LucidOS. Each phase builds on the previous one. Alpha phases are focused on foundation and correctness; Beta phases focus on polish and usability.

---

## Phase Overview

```
Alpha 0.1 â†’ Alpha 0.2 â†’ Alpha 0.3 â†’ Alpha 0.4 â†’ Beta â†’ 1.0
  (Now)      (Theme)    (Agent)    (AI Power)  (Polish) (Stable)
```

---

## ðŸ”· Alpha 0.1 â€” Working Foundation *(Current)*

**Goal:** A bootable, installable Debian live ISO with KDE Plasma and placeholder agent.

### Milestones:
- [x] Debian Stable live-build project structure
- [x] live-build auto/config (amd64, hybrid ISO, non-free firmware)
- [x] Package lists: core, desktop, installer, devtools
- [x] KDE Plasma desktop environment
- [x] SDDM display manager
- [x] Calamares graphical installer (or documented fallback)
- [x] Lucid Glass wallpaper (original abstract SVG)
- [x] SDDM theme placeholder (lucidos theme folder)
- [x] Lucid Agent skeleton (`/opt/lucidos-agent/`)
- [x] Agent security policy (`/etc/lucidos/agent-policy.json`)
- [x] Safe command runner (`safe-runner.sh`)
- [x] Desktop launchers (Lucid Agent, Install LucidOS)
- [x] Build scripts (`build.sh`, `clean.sh`, `test-qemu.sh`, `verify-host.sh`)
- [x] Documentation (`README.md`, `BUILDING.md`, `SECURITY.md`, `ROADMAP.md`)

### Known Alpha 0.1 Limitations:
- SDDM theme is a placeholder (uses default KDE look)
- Lucid Agent is terminal-only, no AI backend
- No custom application welcome screen
- KDE customization uses basic skel files (may need manual tuning)
- Calamares may need manual configuration depending on Debian repo availability

---

## ðŸ”· Alpha 0.2 â€” Visual Identity

**Goal:** Implement the Lucid Glass visual identity properly with custom KDE theme and polished SDDM.

### Planned Features:
- [ ] Real KDE Plasma theme: Lucid Glass (dark, translucent panels)
  - Custom color scheme
  - Blur effect on panels and application windows
  - Consistent icon theme (forked or original)
- [ ] Full SDDM theme implementation
  - Custom `Main.qml` with glass-like login card
  - Animated or gradient background
  - LucidOS logo (original SVG)
- [ ] Lucid Welcome application
  - First-run screen after login
  - Links to documentation, installer, agent
  - Quick setup options
- [ ] Custom KDE application launcher (panel widget)
- [ ] Improved KDE skel configuration
  - Panel layout with bottom dock-style panel
  - Desktop icons hidden by default (cleaner look)
  - Proper Breeze Dark as base theme
- [ ] Font improvements (system-wide Inter or Noto Sans)

### Technical Tasks:
- [ ] Create a Plasma Look and Feel package
- [ ] Package as a `.deb` or live-build include
- [ ] Test theme on different screen resolutions

---

## ðŸ”· Alpha 0.3 â€” Lucid Agent GUI

**Goal:** Transform the Lucid Agent from a terminal placeholder into a real interactive assistant.

### Planned Features:
- [ ] Lucid Agent GUI (Qt-based or web-based)
  - Chat interface
  - Command display with explanation
  - Permission request dialogs
  - Log viewer
- [ ] Command explanation engine
  - Before executing: "This command will install the `htop` package. Proceed?"
  - Use `man` page summaries or local knowledge base
  - Risk level display
- [ ] Local automation workflows
  - "Set up a Python project"
  - "Install development tools"
  - "Create a backup"
- [ ] Improved permission prompt UI
  - Native KDE dialog for confirmation
  - Clear explanation of what will happen
  - Option to see full command before approving
- [ ] Agent configuration panel in KDE System Settings

### Technical Tasks:
- [ ] Choose GUI toolkit (Qt6/QML or Electron or native KDE panel)
- [ ] Design agent plugin API
- [ ] Implement local knowledge base for command explanations
- [ ] Improve logging with structured output (JSON log format)

---

## ðŸ”· Alpha 0.4 â€” AI Provider Integration

**Goal:** Connect Lucid Agent to real AI backends (local and cloud).

### Planned Features:
- [ ] Codex / OpenAI API integration (optional, user-configured)
- [ ] Local LLM support via Ollama or llama.cpp
  - Run fully offline AI models
  - No data leaves the machine
- [ ] "OpenClaw"-style workflow engine
  - Decompose tasks into steps
  - Execute steps with confirmation
  - Rollback support for reversible steps
- [ ] Sandboxed command execution
  - bubblewrap or Flatpak sandbox
  - Network-isolated execution for untrusted commands
- [ ] Plugin system for agent capabilities
  - File management plugin
  - Development tools plugin
  - System administration plugin
- [ ] Agent memory (per-session and persistent)

### Technical Tasks:
- [ ] Implement API key management (KDE Wallet integration)
- [ ] Design prompt safety layer (prevent injection attacks)
- [ ] Implement sandboxing backend
- [ ] Design plugin permission schema

---

## ðŸ”· Beta â€” Polish and Stability

**Goal:** A feature-complete, well-tested release suitable for daily use.

### Planned Features:
- [ ] LucidOS Update Manager
  - GUI application for system updates
  - Notification of available updates
  - Safe update with rollback
- [ ] LucidOS Settings Hub
  - Unified settings for LucidOS-specific features
  - Theme switcher (Lucid Glass variants)
  - Agent configuration
  - Privacy settings
- [ ] Hardware compatibility testing
  - Test on common hardware configurations
  - Driver support documentation
  - Secure Boot compatibility (if feasible)
- [ ] Installation improvements
  - Improved Calamares branding
  - Better post-install setup
  - Hardware-specific configuration
- [ ] Performance optimization
  - Boot time reduction
  - Memory usage optimization
  - SSD/HDD tuning defaults
- [ ] Accessibility features
  - Screen reader support
  - High contrast mode
  - Large text option

### Testing:
- [ ] Automated ISO testing with testinfra or similar
- [ ] Hardware test lab (physical machines)
- [ ] Community beta testing program

---

## ðŸ”· 1.0 â€” Stable Release

**Goal:** Production-ready release with full documentation and support commitment.

### Requirements for 1.0:
- [ ] All Beta features complete and tested
- [ ] Security audit of Lucid Agent
- [ ] Full user documentation
- [ ] Verified hardware compatibility list
- [ ] Release signing (GPG-signed ISOs)
- [ ] Official website
- [ ] Community forum or issue tracker
- [ ] Long-term support plan

---

## Future Ideas (Post-1.0)

These are ideas for consideration after the 1.0 release:

- **LucidOS Server edition** â€” Headless server variant
- **LucidOS ARM edition** â€” Support for Raspberry Pi and ARM SBCs
- **LucidOS Education** â€” Pre-configured for students and developers
- **OEM installations** â€” Pre-installed on partner hardware
- **Mobile companion app** â€” Control/monitor from phone
- **Agent marketplace** â€” Community-contributed agent plugins

---

## How to Contribute to the Roadmap

Want to influence the roadmap? Open an issue or discussion in the project repository with:
- The feature you'd like to see
- Your use case / why it matters
- Your willingness to contribute code or testing

Items move up the roadmap based on community interest and maintainer capacity.

---

*Last updated: LucidOS Alpha 0.1*
