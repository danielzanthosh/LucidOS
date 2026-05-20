# ðŸŒŸ LucidOS

**A custom Debian-based Linux distribution with a premium Lucid Glass desktop identity and a future-ready agentic assistant layer.**

---

## What is LucidOS?

LucidOS is a custom Debian Stableâ€“based live distribution designed to be:

- **Bootable from USB** â€” Flash and run without installation
- **Installable on real hardware** â€” Via the Calamares graphical installer
- **Testable in virtual machines** â€” QEMU, VirtualBox, VMware
- **Beautiful** â€” KDE Plasma with a translucent "Lucid Glass" visual identity
- **Safe and intelligent** â€” Built with a future agentic assistant layer in mind

LucidOS is built on Debian Stable for maximum reliability and package availability. It uses KDE Plasma as the desktop environment for a polished, modern experience.

---

## What LucidOS is NOT

- âŒ Not a macOS clone â€” No Apple assets, names, icons, or branding
- âŒ Not built from a custom kernel â€” We reuse Debian's stable kernel
- âŒ Not a new package manager â€” We use `apt` and the Debian ecosystem
- âŒ Not a finished product â€” Alpha 0.1 is a working foundation

---

## Features (Alpha 0.1)

- âœ… Bootable live system (run without installing)
- âœ… KDE Plasma desktop
- âœ… Calamares graphical installer
- âœ… Lucid Glass wallpaper (original abstract gradient SVG)
- âœ… SDDM login screen with LucidOS theme placeholder
- âœ… Lucid Agent â€” safe agentic assistant skeleton (terminal-based)
- âœ… Secure permission architecture for future AI integration
- âœ… Clean, documented, and beginner-friendly project structure

---

## Requirements

### Host machine (for building):
- **Recommended:** Debian 12 (Bookworm) or Ubuntu 22.04+ VM or physical machine
- **RAM:** 4 GB minimum (8 GB recommended)
- **Disk:** 20 GB free minimum (30 GB recommended for build artifacts)
- **CPU:** Any x86_64 processor
- **WSL:** Supported but not recommended (see BUILDING.md)

### Build tools:
```bash
sudo apt install live-build debootstrap squashfs-tools xorriso
```

---

## How to Build

```bash
# 1. Clone or download the project
git clone https://github.com/your-org/lucidos.git
cd lucidos

# 2. Verify your build host is ready
bash scripts/verify-host.sh

# 3. Build the ISO
bash scripts/build.sh
```

The final ISO will appear in `lucidos/dist/lucidos-alpha-0.1-amd64.iso`.

See [BUILDING.md](BUILDING.md) for detailed instructions, troubleshooting, and VM setup.

---

## Building with GitHub Actions

LucidOS can also be built in CI using the `Build LucidOS ISO` workflow.

To trigger it manually, open the repository on GitHub, go to **Actions**,
select **Build LucidOS ISO**, choose **Run workflow**, and run it from `main`.

When the workflow finishes, open the completed run and download the
`lucidos-alpha-iso` artifact. The artifact contains `dist/*.iso` and is kept
for 7 days.

CI only proves that the ISO can be built. GUI boot and installer testing still
need to be done locally in QEMU, VirtualBox, or VMware. GitHub runner disk
space can also change over time; if the workflow runs out of space, the cleanup
step in `.github/workflows/build-iso.yml` may need tuning.

---

## How to Test in QEMU

```bash
# Quick test (requires qemu-system-x86)
bash scripts/test-qemu.sh

# Or manually:
qemu-system-x86_64 \
  -m 2048 \
  -cdrom dist/lucidos-alpha-0.1-amd64.iso \
  -boot d \
  -vga std
```

---

## How to Flash to USB

**On Linux:**
```bash
# CAUTION: Replace /dev/sdX with your actual USB device
# Check with: lsblk
sudo dd if=dist/lucidos-alpha-0.1-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

**On Windows:**
- Use [Rufus](https://rufus.ie) â€” recommended
- Use [Balena Etcher](https://www.balena.io/etcher/)
- Select DD mode (not ISO mode) if asked

See `scripts/flash-usb-notes.md` for more details.

---

## How to Install in a VM

### VirtualBox
1. Create a new VM (Linux, Debian 64-bit)
2. Assign 2+ GB RAM, 20+ GB disk
3. Attach the ISO as a CD/DVD drive
4. Boot the VM
5. Once booted, click "Install LucidOS" on the desktop
6. Follow the Calamares installer

### VMware
1. Create a new VM (Linux, Debian 11+)
2. Assign 2+ GB RAM, 20+ GB disk
3. Attach the ISO
4. Boot and follow the same steps as VirtualBox

### QEMU
```bash
bash scripts/test-qemu.sh
```

---

## Roadmap

| Phase | Focus |
|-------|-------|
| Alpha 0.1 | Bootable ISO, KDE, Calamares, Agent placeholder |
| Alpha 0.2 | Better KDE theme, custom SDDM, Welcome app |
| Alpha 0.3 | Real Lucid Agent GUI, command explanation |
| Alpha 0.4 | Codex/OpenClaw integration, sandboxed runner |
| Beta | Polished UI, update system, hardware testing |

See [ROADMAP.md](ROADMAP.md) for full details.

---

## Safety Notes

LucidOS includes a future-ready agentic assistant (Lucid Agent). This assistant is designed with safety as a core principle:

- The agent **never has unrestricted root access**
- All potentially dangerous commands require **explicit user confirmation**
- Destructive commands are **blocked outright**
- All agent actions are **logged**
- The agent runs with **user-level privileges** by default

See [SECURITY.md](SECURITY.md) for the full security model.

---

## Default Live User

| Setting | Value |
|---------|-------|
| Username | `lucid` |
| Password | `lucid` |
| Hostname | `lucidos` |
| Desktop | KDE Plasma |
| Shell | bash |

---

## License

LucidOS build scripts and configuration are released under the **MIT License**.
Individual packages included in the ISO retain their original licenses.

---

## Contributing

This is an early-stage project. Contributions are welcome! See BUILDING.md for development setup instructions.

> **Note:** Do not contribute Apple-branded assets, macOS screenshots, or any copyrighted design materials.
