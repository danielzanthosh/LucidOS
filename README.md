# LucidOS**A Debian-based live Linux distribution with a premium glass-inspired desktop and a future-ready agentic assistant layer.**LucidOS is an experimental custom Linux distribution built on **Debian 12 Bookworm**, designed to boot from a USB drive, install on real hardware, run inside virtual machines, and eventually provide safe AI-assisted control over the desktop.It is not a macOS clone. It is an original Linux desktop project with a clean, translucent visual identity called **Lucid Glass**.---## OverviewLucidOS combines:- **Debian 12 Bookworm** as the stable base- **KDE Plasma 5** as the desktop environment- **Calamares** as the graphical installer- **Debian live-build** for ISO generation- **Lucid Glass** as the visual identity- **Lucid Agent** as a future safe agentic assistant layerThe goal is to create a Linux desktop that feels modern, minimal, premium, and intelligent while still being safe, understandable, and based on proven open-source foundations.---## Project StatusLucidOS is currently in early alpha.| Version | Status | Focus ||---|---|---|| Alpha 0.1 | In progress | Bootable Debian ISO, KDE desktop, installer, agent skeleton || Alpha 0.2 | Planned | Lucid Glass KDE theme, improved wallpaper, welcome experience || Alpha 0.3 | Planned | Lucid Agent GUI and command explanation || Alpha 0.4 | Planned | Codex/OpenClaw-style provider integration || Beta | Future | Polished desktop, update flow, hardware testing |Alpha builds are experimental and should be tested in a VM before using on real hardware.---## What LucidOS IsLucidOS is designed to be:- **Bootable** from a USB pendrive as a live operating system- **Installable** on real hardware using Calamares- **Testable** in QEMU, VirtualBox, or VMware- **Customizable** through Debian live-build- **Modern-looking** with a glass-inspired KDE desktop- **Agent-ready** with a safe command permission model---## What LucidOS Is NotLucidOS is not:- A macOS clone- An Apple-themed Linux distribution- A custom Linux kernel project- A new package manager- A replacement for Debian- A finished production operating systemLucidOS does **not** use Apple logos, Apple icons, Apple wallpapers, macOS branding, or copyrighted design assets.---## Core Features### Alpha 0.1- Debian 12 Bookworm base- KDE Plasma desktop- SDDM display manager- Calamares graphical installer- Live USB boot support- VM installation support- Original LucidOS wallpaper placeholder- Lucid Agent terminal placeholder- Safe command runner concept- Security policy foundation- GitHub Actions build workflow support- Beginner-friendly build scripts---## System Architecture```txtLucidOS├── Debian 12 Bookworm base├── KDE Plasma 5 desktop├── SDDM login manager├── Calamares installer├── live-build ISO pipeline├── Lucid Glass visual identity└── Lucid Agent safety layer
```


The operating system is generated using Debian live-build. Most custom files are placed inside `live-build/config/includes.chroot/`, which are copied into the final live system during ISO creation.


---


## Repository Structure



```
lucidos/├── README.md├── BUILDING.md├── SECURITY.md├── ROADMAP.md├── docs/├── scripts/│   ├── build.sh│   ├── clean.sh│   ├── test-qemu.sh│   └── verify-host.sh├── live-build/│   ├── auto/│   └── config/│       ├── package-lists/│       ├── hooks/│       └── includes.chroot/├── assets/└── .github/    └── workflows/
```


---


## Requirements



### Recommended Build Environment



Use a Debian 12 Bookworm VM or physical Debian 12 system.


Recommended specs:


| Resource | Minimum | Recommended |
| --- | --- | --- |
| CPU | 2 cores | 4 cores |
| RAM | 4 GB | 8 GB |
| Disk space | 25 GB | 50+ GB |
| OS | Debian/Ubuntu | Debian 12 Bookworm |


Windows users should build inside a Debian VM or use GitHub Actions. Building directly on Windows is not supported.


---


## Install Build Dependencies



On Debian/Ubuntu:


```
sudo apt updatesudo apt install -y \  live-build \  debootstrap \  squashfs-tools \  xorriso \  isolinux \  syslinux-common \  qemu-system-x86 \  ovmf \  git
```


---


## Build the ISO Locally



From the project root:


```
bash scripts/verify-host.shbash scripts/build.sh
```


After a successful build, the ISO should appear at:


```
dist/lucidos-alpha-0.1-amd64.iso
```


For detailed build notes, see:


```
BUILDING.md
```


---


## Test the ISO in QEMU



```
bash scripts/test-qemu.sh
```


To test a specific ISO:


```
bash scripts/test-qemu.sh dist/lucidos-alpha-0.1-amd64.iso
```


Manual UEFI test:


```
qemu-system-x86_64 \  -m 2048 \  -smp 2 \  -cdrom dist/lucidos-alpha-0.1-amd64.iso \  -boot d \  -vga virtio \  -net nic \  -net user \  -bios /usr/share/OVMF/OVMF_CODE.fd \  -display gtk
```


---


## Build with GitHub Actions



LucidOS can be built in GitHub Actions without needing a local Linux build machine.


To build in CI:


1. Push the project to GitHub.
2. Open the repository on GitHub.
3. Go to **Actions**.
4. Select **Build LucidOS ISO**.
5. Click **Run workflow**.
6. Wait for the workflow to finish.
7. Download the `lucidos-alpha-iso` artifact.


The artifact contains the generated ISO and is usually retained for 7 days.


GitHub Actions is useful for checking whether the ISO builds, but GUI boot testing should still be done locally in QEMU, VirtualBox, or VMware.


---


## Flash to USB



### On Linux



Check your USB device name first:


```
lsblk
```


Then flash the ISO:


```
sudo dd if=dist/lucidos-alpha-0.1-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```


Replace `/dev/sdX` with the correct USB device.


Be careful. Choosing the wrong drive can erase data.


### On Windows



Recommended tools:


- Rufus
- Balena Etcher
- Ventoy


If asked, choose **DD mode** for best compatibility.


---


## Install in a Virtual Machine



### VirtualBox



1. Create a new VM.
2. Choose Linux → Debian 64-bit.
3. Assign at least 2 GB RAM.
4. Create a 20 GB or larger virtual disk.
5. Attach the LucidOS ISO.
6. Boot the VM.
7. Click **Install LucidOS**.
8. Follow the Calamares installer.


### VMware



1. Create a new Linux VM.
2. Select Debian 64-bit.
3. Attach the LucidOS ISO.
4. Boot and run the installer.


### QEMU



```
bash scripts/test-qemu.sh
```


---


## Default Live User



| Setting | Value |
| --- | --- |
| Username | `lucid` |
| Password | `lucid` |
| Hostname | `lucidos` |
| Desktop | KDE Plasma |
| Shell | Bash |


---


## Lucid Glass Design Direction



Lucid Glass is the visual identity of LucidOS.


Design goals:


- Clean translucent surfaces
- Soft blue and cyan tones
- Minimal gradients
- Glass-like depth
- Smooth shadows
- Calm desktop background
- Readable contrast
- No copied proprietary assets


The style should feel premium and modern without imitating any existing operating system too directly.


---


## Lucid Agent



Lucid Agent is the planned assistant layer for LucidOS.


The current version is only a safe terminal-based skeleton. Future versions may support:


- Explaining terminal errors
- Suggesting commands
- Creating projects
- Opening apps
- Editing files with permission
- Installing packages with confirmation
- Helping with coding workflows
- Integrating Codex/OpenClaw-style automation


Lucid Agent is designed around safety first.


---


## Agent Safety Model



Lucid Agent must never receive unrestricted root control.


The intended safety flow is:


```
User request→ Agent proposes action→ User reviews command→ User confirms→ Command runs→ Action is logged
```


Command categories:


| Category | Behavior |
| --- | --- |
| Safe commands | May run with little friction |
| Risky commands | Require confirmation |
| Admin commands | Require sudo/password |
| Destructive commands | Blocked |
| Private data access | Requires explicit permission |


For more details, see:


```
SECURITY.md
```


---


## Current Known Risks



LucidOS is early alpha, so some parts may need manual testing:


- Calamares installer flow needs VM validation
- KDE Plasma may override some default theme settings
- SDDM LucidOS theme is installed but not enabled by default
- GitHub Actions builds may fail if runner disk space changes
- Bookworm is currently pinned; Trixie/Plasma 6 migration requires a separate audit


---


## Roadmap



### Alpha 0.1



- Bootable Debian ISO
- KDE Plasma desktop
- Calamares installer
- Lucid Agent skeleton
- GitHub Actions ISO build


### Alpha 0.2



- Lucid Glass KDE look-and-feel package
- Improved wallpaper
- Better theme defaults
- Welcome app improvements
- Optional SDDM theme testing


### Alpha 0.3



- Lucid Agent GUI
- Command explanation
- Permission prompt UI
- Local project automation


### Alpha 0.4



- Codex/OpenClaw-style provider integration
- Sandboxed command runner
- Safer app/file automation


### Beta



- Polished desktop experience
- Update system
- Hardware compatibility testing
- Better documentation
- Install testing on real machines


---


## Development Principles



LucidOS follows these rules:


- Stability before visuals
- Safety before automation
- Original design before imitation
- Simple scripts before clever hacks
- Clear docs before mystery magic
- VM testing before real hardware installs


Basically: make it boot, make it safe, then make it beautiful.


---


## Contributing



Contributions are welcome while the project is in early development.


Good contributions include:


- Build fixes
- Debian package compatibility fixes
- KDE theme improvements
- Documentation improvements
- Safe agent permission improvements
- VM testing reports


Please do not contribute:


- Apple-branded assets
- macOS screenshots
- Copied wallpapers
- Trademarked logos
- Unlicensed icon packs
- Unsafe automation scripts


---


## License



LucidOS build scripts and custom configuration are released under the **MIT License**, unless stated otherwise.


Packages included in the ISO retain their original licenses from Debian or their upstream projects.


---


## Disclaimer



LucidOS is experimental software.


Do not install alpha builds on your main computer unless you understand the risks. Test in a virtual machine first.


```
This README feels way more “real GitHub project” and less “school project that accidentally became a distro” 💀🔥
```

