# LucidOS Icons

This directory contains custom icon assets for LucidOS.

## Current Status: Alpha 0.1 â€” Placeholder

In Alpha 0.1, LucidOS uses the **Papirus-Dark** icon theme (from Debian repos) as the default icon theme. No custom icons are included yet.

## Planned Custom Icons (Alpha 0.2+)

Future custom icons will be created for:
- LucidOS logo (SVG, multiple sizes)
- Lucid Agent application icon
- Lucid Welcome icon
- Custom application dock icons

## Icon Guidelines

All icons must:
- Be original artwork (no Apple, Windows, or other vendor icons)
- Follow the Freedesktop icon specification
- Be provided in SVG format (for resolution independence)
- Also be rendered to PNG at standard sizes: 16, 22, 24, 32, 48, 64, 96, 128, 256
- Use the Lucid Glass color palette

## Icon Naming Convention

Follow the Freedesktop icon naming specification:
- `lucidos-logo` â€” Main LucidOS logo
- `lucidos-agent` â€” Lucid Agent icon
- `lucidos-welcome` â€” Welcome screen icon

## Installing Custom Icons

To add a custom icon theme:
1. Create the icon theme directory:
   ```
   live-build/config/includes.chroot/usr/share/icons/lucid-glass/
   ```
2. Add an `index.theme` file
3. Add icons in the correct subdirectories by size

## Recommended Tools

- **Inkscape** (SVG editor)
- **GIMP** (bitmap editor)
- **icon-theme-spec** (freedesktop specification)
